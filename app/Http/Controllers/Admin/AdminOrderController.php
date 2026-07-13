<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\FcmService;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->input('status');
        
        $query = Order::with(['customer', 'vendor'])->orderBy('id', 'desc');
        
        if ($status) {
            $query->where('status', $status);
        }
        
        $orders = $query->get();
        return view('admin.orders.index', compact('orders', 'status'));
    }

    public function show($id)
    {
        $order = Order::with(['customer', 'vendor', 'items.product'])->findOrFail($id);
        
        $statuses = [
            'pending',
            'accepted',
            'packing',
            'ready_for_pickup',
            'out_for_delivery',
            'delivered',
            'cancelled'
        ];

        return view('admin.orders.show', compact('order', 'statuses'));
    }

    public function updateStatus(Request $request, $id)
    {
        $order = Order::findOrFail($id);

        $request->validate([
            'status' => 'required|in:pending,accepted,packing,ready_for_pickup,out_for_delivery,delivered,cancelled'
        ]);

        $status = $request->input('status');
        $order->status = $status;
        $order->save();

        // Notify Customer about status update
        $statusTexts = [
            'pending' => 'waiting for acceptance.',
            'accepted' => 'accepted.',
            'packing' => 'currently being packed.',
            'ready_for_pickup' => 'ready for delivery pickup.',
            'out_for_delivery' => 'out for delivery! Our agent is bringing it to your home.',
            'delivered' => 'successfully delivered! Thank you for buying from Gundawadi Mart.',
            'cancelled' => 'cancelled.'
        ];

        FcmService::send(
            'customer',
            $order->customer_id,
            $order->customer->device_token,
            "Order #{$order->id} Update",
            "Your order is " . ($statusTexts[$status] ?? $status)
        );

        // Notify Vendor if cancelled
        if ($status === 'cancelled') {
            FcmService::send(
                'vendor',
                $order->vendor_id,
                $order->vendor->device_token,
                "Order #{$order->id} Cancelled",
                "Order #{$order->id} has been cancelled."
            );
        }

        return redirect()->route('admin.orders.show', $id)->with('success', 'Order status updated successfully.');
    }

    public function updateDeliveryCharge(Request $request, $id)
    {
        $order = Order::findOrFail($id);

        $request->validate([
            'delivery_charge' => 'required|numeric|min:0'
        ]);

        $charge = (float) $request->input('delivery_charge');
        $order->delivery_charge = $charge;
        $order->total = $order->subtotal + $charge;
        $order->save();

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
