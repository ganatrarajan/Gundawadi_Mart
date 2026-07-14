<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MasterOrder;
use App\Models\Order;
use App\Repositories\Contracts\OrderRepositoryInterface;
use App\Services\FcmService;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    protected $orderRepository;

    public function __construct(OrderRepositoryInterface $orderRepository)
    {
        $this->orderRepository = $orderRepository;
    }

    public function index(Request $request)
    {
        $status = $request->input('status');
        
        $masterQuery = MasterOrder::with(['customer', 'vendorOrders.vendor']);
        $legacyQuery = Order::whereNull('master_order_id')->with(['customer', 'vendor']);
        
        if ($status) {
            $masterQuery->where('status', $status);
            $legacyQuery->where('status', $status);
        }
        
        $masters = $masterQuery->get();
        $legacies = $legacyQuery->get();
        
        // Wrap legacy orders in mock MasterOrder instances for visual parity
        $mockedLegacies = $legacies->map(function ($subOrder) {
            $mockMaster = new MasterOrder();
            $mockMaster->id = $subOrder->id;
            $mockMaster->customer_id = $subOrder->customer_id;
            $mockMaster->address_id = $subOrder->address_id;
            $mockMaster->delivery_address = $subOrder->delivery_address;
            $mockMaster->subtotal = $subOrder->subtotal;
            $mockMaster->delivery_charge = $subOrder->delivery_charge;
            $mockMaster->handling_charge = $subOrder->handling_charge;
            $mockMaster->platform_fee = $subOrder->platform_fee;
            $mockMaster->total = $subOrder->total;
            $mockMaster->payment_method = $subOrder->payment_method;
            $mockMaster->status = $subOrder->status;
            $mockMaster->special_note = $subOrder->special_note;
            $mockMaster->delivery_slot = $subOrder->delivery_slot;
            $mockMaster->created_at = $subOrder->created_at;
            $mockMaster->updated_at = $subOrder->updated_at;
            
            $mockMaster->setRelation('customer', $subOrder->customer);
            $mockMaster->setRelation('address', $subOrder->address);
            $mockMaster->setRelation('vendorOrders', collect([$subOrder]));
            
            return $mockMaster;
        });
        
        $orders = $masters->concat($mockedLegacies)->sortByDesc('created_at');
        
        return view('admin.orders.index', compact('orders', 'status'));
    }

    public function show($id)
    {
        $order = MasterOrder::with([
            'customer', 
            'address', 
            'vendorOrders.vendor', 
            'vendorOrders.items.product'
        ])->find($id);
        
        if (!$order) {
            $subOrder = Order::with(['customer', 'vendor', 'items.product', 'address'])->find($id);
            if ($subOrder) {
                if ($subOrder->master_order_id) {
                    return redirect()->route('admin.orders.show', $subOrder->master_order_id);
                } else {
                    // Mock legacy single-vendor order as a MasterOrder structure
                    $mockMaster = new MasterOrder();
                    $mockMaster->id = $subOrder->id;
                    $mockMaster->customer_id = $subOrder->customer_id;
                    $mockMaster->address_id = $subOrder->address_id;
                    $mockMaster->delivery_address = $subOrder->delivery_address;
                    $mockMaster->subtotal = $subOrder->subtotal;
                    $mockMaster->delivery_charge = $subOrder->delivery_charge;
                    $mockMaster->handling_charge = $subOrder->handling_charge;
                    $mockMaster->platform_fee = $subOrder->platform_fee;
                    $mockMaster->total = $subOrder->total;
                    $mockMaster->payment_method = $subOrder->payment_method;
                    $mockMaster->status = $subOrder->status;
                    $mockMaster->special_note = $subOrder->special_note;
                    $mockMaster->delivery_slot = $subOrder->delivery_slot;
                    $mockMaster->created_at = $subOrder->created_at;
                    $mockMaster->updated_at = $subOrder->updated_at;
                    
                    $mockMaster->setRelation('customer', $subOrder->customer);
                    $mockMaster->setRelation('address', $subOrder->address);
                    $mockMaster->setRelation('vendorOrders', collect([$subOrder]));
                    
                    $order = $mockMaster;
                }
            } else {
                abort(404);
            }
        }
        
        $statuses = [
            'pending',
            'accepted',
            'packing',
            'ready_for_pickup',
            'out_for_delivery',
            'delivered',
            'completed',
            'cancelled'
        ];

        return view('admin.orders.show', compact('order', 'statuses'));
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,accepted,packing,ready_for_pickup,out_for_delivery,delivered,completed,cancelled'
        ]);

        $status = $request->input('status');
        
        $masterOrder = MasterOrder::find($id);
        if ($masterOrder) {
            $order = $this->orderRepository->updateMasterStatus($id, $status);
        } else {
            $subOrder = Order::find($id);
            if ($subOrder) {
                if ($subOrder->master_order_id) {
                    $this->orderRepository->updateMasterStatus($subOrder->master_order_id, $status);
                    return redirect()->route('admin.orders.show', $subOrder->master_order_id)->with('success', 'Order status updated successfully.');
                } else {
                    $subOrder->status = $status;
                    $subOrder->save();
                    $order = $subOrder;
                }
            } else {
                abort(404);
            }
        }

        // Notify Customer about status update
        $statusTexts = [
            'pending' => 'waiting for acceptance.',
            'accepted' => 'accepted.',
            'packing' => 'currently being packed.',
            'ready_for_pickup' => 'ready for delivery pickup.',
            'out_for_delivery' => 'out for delivery! Our agent is bringing it to your home.',
            'delivered' => 'successfully delivered! Thank you for buying from Gundawadi Mart.',
            'completed' => 'completed.',
            'cancelled' => 'cancelled.'
        ];

        FcmService::send(
            'customer',
            $order->customer_id,
            $order->customer->device_token,
            "Order #{$order->id} Update",
            "Your order is " . ($statusTexts[$status] ?? $status)
        );

        return redirect()->route('admin.orders.show', $id)->with('success', 'Order status updated successfully.');
    }

    public function updateDeliveryCharge(Request $request, $id)
    {
        $request->validate([
            'delivery_charge' => 'required|numeric|min:0'
        ]);

        $charge = (float) $request->input('delivery_charge');
        
        $masterOrder = MasterOrder::find($id);
        if ($masterOrder) {
            $order = $this->orderRepository->updateDeliveryCharge($id, $charge);
        } else {
            $subOrder = Order::find($id);
            if ($subOrder) {
                if ($subOrder->master_order_id) {
                    $this->orderRepository->updateDeliveryCharge($subOrder->master_order_id, $charge);
                    return redirect()->route('admin.orders.show', $subOrder->master_order_id)->with('success', 'Delivery charge updated successfully.');
                } else {
                    $subOrder->delivery_charge = $charge;
                    $subOrder->total = $subOrder->subtotal + $charge + $subOrder->handling_charge + $subOrder->platform_fee;
                    $subOrder->save();
                    $order = $subOrder;
                }
            } else {
                abort(404);
            }
        }

        // Notify Customer about delivery charge
        FcmService::send(
            'customer',
            $order->customer_id,
            $order->customer->device_token,
            "Delivery Charge Confirmed",
            "Delivery charge for order #{$order->id} has been updated to ₹{$charge}. New Total is ₹{$order->total}."
        );

        return redirect()->route('admin.orders.show', $id)->with('success', 'Delivery charge updated successfully.');
    }
}
