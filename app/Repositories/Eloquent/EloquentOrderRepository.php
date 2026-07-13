<?php

namespace App\Repositories\Eloquent;

use App\Models\Order;
use App\Models\OrderItem;
use App\Repositories\Contracts\OrderRepositoryInterface;
use Illuminate\Support\Facades\DB;

class EloquentOrderRepository implements OrderRepositoryInterface
{
    public function create(array $data, array $items)
    {
        return DB::transaction(function () use ($data, $items) {
            $order = Order::create($data);

            foreach ($items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item['product_id'],
                    'product_name' => $item['product_name'],
                    'price' => $item['price'],
                    'unit' => $item['unit'],
                    'quantity' => $item['quantity'],
                    'total_price' => $item['price'] * $item['quantity'],
                ]);
            }

            return $order->load('items');
        });
    }

    public function findById($id)
    {
        return Order::with(['customer', 'vendor', 'items.product', 'address'])->find($id);
    }

    public function getCustomerOrders($customerId)
    {
        return Order::where('customer_id', $customerId)
            ->with(['vendor', 'items'])
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

    public function updateStatus($id, $status)
    {
        $order = Order::findOrFail($id);
        $order->update(['status' => $status]);
        $order->load(['customer', 'items', 'vendor']);
        return $order;
    }

    public function updateDeliveryCharge($id, $charge)
    {
        $order = Order::findOrFail($id);
        $order->delivery_charge = $charge;
        $order->total = $order->subtotal + $charge + $order->handling_charge + $order->platform_fee;
        $order->save();
        return $order;
    }
}
