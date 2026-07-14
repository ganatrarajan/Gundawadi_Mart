<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $user = $request->user();
        $isVendor = false;
        if ($user && (get_class($user) === 'App\Models\Vendor' || $request->is('api/vendor/*'))) {
            $isVendor = true;
        }

        $deliveryAddress = $this->delivery_address;
        if ($isVendor) {
            $deliveryAddress = preg_replace('/,\s*Mobile:\s*[^\n]*/i', '', $deliveryAddress);
        }

        $status = strtolower($this->status);
        $milestones = [];
        
        // 1. Placed
        $milestones[] = [
            'status' => 'Order Placed',
            'time' => $this->created_at->format('d M Y, h:i A'),
            'is_completed' => true
        ];
        
        // 2. Accepted
        $isAccepted = in_array($status, ['accepted', 'packing', 'ready_for_pickup', 'ready for pickup', 'out_for_delivery', 'out for delivery', 'delivered', 'completed']);
        $milestones[] = [
            'status' => 'Accepted by Store',
            'time' => $isAccepted ? $this->updated_at->format('d M Y, h:i A') : '',
            'is_completed' => $isAccepted
        ];

        // 3. Packing
        $isPacking = in_array($status, ['packing', 'ready_for_pickup', 'ready for pickup', 'out_for_delivery', 'out for delivery', 'delivered', 'completed']);
        $milestones[] = [
            'status' => 'Packing Items',
            'time' => $isPacking ? $this->updated_at->format('d M Y, h:i A') : '',
            'is_completed' => $isPacking
        ];
        
        // 4. Ready For Pickup
        $isReady = in_array($status, ['ready_for_pickup', 'ready for pickup', 'out_for_delivery', 'out for delivery', 'delivered', 'completed']);
        $milestones[] = [
            'status' => 'Ready for Pickup',
            'time' => $isReady ? $this->updated_at->format('d M Y, h:i A') : '',
            'is_completed' => $isReady
        ];

        // 5. Out for Delivery
        $isOut = in_array($status, ['out_for_delivery', 'out for delivery', 'delivered', 'completed']);
        $milestones[] = [
            'status' => 'Out for Delivery',
            'time' => $isOut ? $this->updated_at->format('d M Y, h:i A') : '',
            'is_completed' => $isOut
        ];
        
        // 6. Delivered/Cancelled
        if ($status === 'cancelled' || $status === 'rejected') {
            $milestones[] = [
                'status' => 'Order Cancelled/Rejected',
                'time' => $this->updated_at->format('d M Y, h:i A'),
                'is_completed' => true
            ];
        } else {
            $isDelivered = ($status === 'delivered' || $status === 'completed');
            $milestones[] = [
                'status' => 'Delivered',
                'time' => $isDelivered ? $this->updated_at->format('d M Y, h:i A') : '',
                'is_completed' => $isDelivered
            ];
        }

        $isMaster = (get_class($this->resource) === 'App\Models\MasterOrder');

        if ($isMaster) {
            $firstVendorOrder = $this->vendorOrders->first();
            $vendorId = $firstVendorOrder ? $firstVendorOrder->vendor_id : 0;
            $vendorShopName = $this->vendorOrders->map(fn($vo) => $vo->vendor->shop_name ?? '')->filter()->join(', ');
            $vendorOwnerName = $this->vendorOrders->map(fn($vo) => $vo->vendor->owner_name ?? '')->filter()->join(', ');
            $vendorMobile = $this->vendorOrders->map(fn($vo) => $vo->vendor->mobile_number ?? '')->filter()->join(', ');
            $items = [];
            foreach ($this->vendorOrders as $vo) {
                foreach ($vo->items as $item) {
                    $items[] = new OrderItemResource($item);
                }
            }
        } else {
            $vendorId = $this->vendor_id;
            $vendorShopName = $this->vendor ? $this->vendor->shop_name : null;
            $vendorOwnerName = $this->vendor ? $this->vendor->owner_name : null;
            $vendorMobile = $this->vendor ? $this->vendor->mobile_number : null;
            $items = OrderItemResource::collection($this->whenLoaded('items'));
        }

        return [
            'id' => $this->id,
            'customer_id' => $this->customer_id,
            'customer_name' => $this->customer ? $this->customer->name : null,
            'customer_mobile' => ($isVendor || !$this->customer) ? null : $this->customer->mobile,
            'vendor_id' => $vendorId,
            'vendor_shop_name' => $vendorShopName,
            'vendor_owner_name' => $vendorOwnerName,
            'vendor_mobile' => $vendorMobile,
            'address_id' => $this->address_id,
            'delivery_address' => $deliveryAddress,
            'timeline' => $milestones,
            'subtotal' => $this->subtotal,
            'delivery_charge' => $this->delivery_charge,
            'handling_charge' => $this->handling_charge,
            'platform_fee' => $this->platform_fee,
            'total' => $this->total,
            'payment_method' => $this->payment_method,
            'status' => $this->status,
            'special_note' => $this->special_note,
            'delivery_slot' => $this->delivery_slot,
            'items' => $items,
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'is_master' => $isMaster,
        ];
    }
}
