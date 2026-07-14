<?php

namespace App\Repositories\Eloquent;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\MasterOrder;
use App\Models\Product;
use App\Services\FcmService;
use App\Repositories\Contracts\OrderRepositoryInterface;
use Illuminate\Support\Facades\DB;

class EloquentOrderRepository implements OrderRepositoryInterface
{
    public function create(array $data, array $items)
    {
        return DB::transaction(function () use ($data, $items) {
            // Group items by vendor_id by loading each product from DB
            $vendorItems = [];
            foreach ($items as $item) {
                $product = Product::find($item['product_id']);
                if ($product) {
                    $vendorId = $product->vendor_id;
                    $vendorItems[$vendorId][] = [
                        'item' => $item,
                        'product' => $product
                    ];
                }
            }

            if (empty($vendorItems)) {
                throw new \Exception("No valid products found for order.");
            }

            // Calculate subtotals
            $globalSubtotal = 0;
            $vendorSubtotals = [];
            foreach ($vendorItems as $vendorId => $vItems) {
                $vSubtotal = 0;
                foreach ($vItems as $vi) {
                    $price = isset($vi['item']['price']) ? (float) $vi['item']['price'] : (float) $vi['product']->today_price;
                    $qty = (int) $vi['item']['quantity'];
                    $vSubtotal += $price * $qty;
                }
                $vendorSubtotals[$vendorId] = $vSubtotal;
                $globalSubtotal += $vSubtotal;
            }

            // Create Master Order
            $masterOrder = MasterOrder::create([
                'customer_id' => $data['customer_id'],
                'address_id' => $data['address_id'],
                'delivery_address' => $data['delivery_address'],
                'subtotal' => $globalSubtotal,
                'delivery_charge' => $data['delivery_charge'] ?? 0.00,
                'handling_charge' => $data['handling_charge'] ?? 0.00,
                'platform_fee' => $data['platform_fee'] ?? 0.00,
                'total' => $globalSubtotal + ($data['delivery_charge'] ?? 0.00) + ($data['handling_charge'] ?? 0.00) + ($data['platform_fee'] ?? 0.00),
                'payment_method' => $data['payment_method'] ?? 'cash_on_delivery',
                'delivery_slot' => $data['delivery_slot'] ?? null,
                'status' => 'pending',
                'special_note' => $data['special_note'] ?? null,
            ]);

            // Create Sub-orders (Orders) for each vendor
            foreach ($vendorItems as $vendorId => $vItems) {
                $vSubtotal = $vendorSubtotals[$vendorId];
                
                $subOrder = Order::create([
                    'customer_id' => $data['customer_id'],
                    'master_order_id' => $masterOrder->id,
                    'vendor_id' => $vendorId,
                    'address_id' => $data['address_id'],
                    'delivery_address' => $data['delivery_address'],
                    'subtotal' => $vSubtotal,
                    'delivery_charge' => 0.00,
                    'handling_charge' => 0.00,
                    'platform_fee' => 0.00,
                    'total' => $vSubtotal,
                    'payment_method' => $data['payment_method'] ?? 'cash_on_delivery',
                    'status' => 'pending',
                    'special_note' => $data['special_note'] ?? null,
                    'delivery_slot' => $data['delivery_slot'] ?? null,
                ]);

                // Create Order Items for this sub-order
                foreach ($vItems as $vi) {
                    $item = $vi['item'];
                    $product = $vi['product'];
                    $price = isset($item['price']) ? (float) $item['price'] : (float) $product->today_price;
                    $unit = isset($item['unit']) ? $item['unit'] : $product->unit;
                    
                    OrderItem::create([
                        'order_id' => $subOrder->id,
                        'product_id' => $product->id,
                        'product_name' => $product->name,
                        'price' => $price,
                        'unit' => $unit,
                        'quantity' => (int) $item['quantity'],
                        'total_price' => $price * (int) $item['quantity'],
                    ]);
                }
            }

            return $masterOrder->load('vendorOrders.items');
        });
    }

    public function findById($id)
    {
        return Order::with(['customer', 'vendor', 'items.product', 'address'])->find($id);
    }

    public function findMasterById($id)
    {
        return MasterOrder::with(['customer', 'address', 'vendorOrders.vendor', 'vendorOrders.items.product'])->find($id);
    }

    public function getCustomerOrders($customerId)
    {
        return MasterOrder::where('customer_id', $customerId)
            ->with(['vendorOrders.vendor', 'vendorOrders.items'])
            ->orderBy('id', 'desc')
            ->get();
    }

    public function getVendorOrders($vendorId)
    {
        return Order::where('vendor_id', $vendorId)
            ->where('status', '!=', 'pending')
            ->with(['customer', 'items'])
            ->orderBy('id', 'desc')
            ->get();
    }

    public function getAllOrders(array $filters = [])
    {
        $query = Order::with(['customer', 'vendor']);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['vendor_id'])) {
            $query->where('vendor_id', $filters['vendor_id']);
        }

        if (isset($filters['customer_id'])) {
            $query->where('customer_id', $filters['customer_id']);
        }

        return $query->orderBy('id', 'desc')->get();
    }

    public function getAllMasterOrders(array $filters = [])
    {
        $query = MasterOrder::with(['customer', 'vendorOrders.vendor']);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['customer_id'])) {
            $query->where('customer_id', $filters['customer_id']);
        }

        return $query->orderBy('id', 'desc')->get();
    }

    public function updateStatus($id, $status)
    {
        $order = Order::findOrFail($id);
        $order->status = $status;
        $order->save();

        // If order belongs to a master order, check if we need to auto-update master order status
        if ($order->master_order_id) {
            $masterOrder = $order->masterOrder;
            if ($masterOrder) {
                $allSubOrders = $masterOrder->vendorOrders;
                
                // Check if all sub-orders are ready_for_pickup, delivered, completed or cancelled
                $allReady = true;
                foreach ($allSubOrders as $sub) {
                    $subStatus = strtolower($sub->status);
                    if (!in_array($subStatus, ['ready_for_pickup', 'ready for pickup', 'delivered', 'completed', 'cancelled'])) {
                        $allReady = false;
                        break;
                    }
                }

                if ($allReady) {
                    $masterOrder->status = 'ready_for_pickup';
                    $masterOrder->save();

                    // Notify Customer that overall order is ready for delivery
                    FcmService::send(
                       'customer',
                       $masterOrder->customer_id,
                       $masterOrder->customer->device_token,
                       "Order Ready for Delivery",
                       "All items in your order #{$masterOrder->id} are packed. Out for delivery soon!"
                    );
                }
            }
        }

        $order->load(['customer', 'items', 'vendor']);
        return $order;
    }

    public function updateMasterStatus($id, $status)
    {
        $masterOrder = MasterOrder::findOrFail($id);
        $masterOrder->status = $status;
        $masterOrder->save();

        // Propagate status change to all sub-orders
        $subOrderStatus = $status;
        if ($status === 'delivered') {
            $subOrderStatus = 'completed'; // sub orders are marked completed when delivered
        }

        foreach ($masterOrder->vendorOrders as $subOrder) {
            $subOrder->status = $subOrderStatus;
            $subOrder->save();

            // Notify each vendor when order is accepted or cancelled
            if ($status === 'accepted') {
                FcmService::send(
                    'vendor',
                    $subOrder->vendor_id,
                    $subOrder->vendor->device_token,
                    "New Order Assigned",
                    "Order #{$subOrder->id} has been accepted by Admin and is ready for packing."
                );
            } elseif ($status === 'cancelled') {
                FcmService::send(
                    'vendor',
                    $subOrder->vendor_id,
                    $subOrder->vendor->device_token,
                    "Order #{$subOrder->id} Cancelled",
                    "Order #{$subOrder->id} has been cancelled."
                );
            }
        }

        return $masterOrder;
    }

    public function updateDeliveryCharge($id, $charge)
    {
        // For Master Order charge updates
        $masterOrder = MasterOrder::findOrFail($id);
        $masterOrder->delivery_charge = $charge;
        $masterOrder->total = $masterOrder->subtotal + $charge + $masterOrder->handling_charge + $masterOrder->platform_fee;
        $masterOrder->save();
        return $masterOrder;
    }
}
