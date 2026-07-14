<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $approvedAddress = $this->addresses()->where('status', 'approved')->first();
        $pendingAddress = $this->addresses()->where('status', 'pending')->first();

        return [
            'id' => $this->id,
            'name' => $this->name,
            'mobile' => $this->mobile,
            'status' => $this->status,
            'rejection_reason' => $this->rejection_reason,
            'delivery_km' => $this->delivery_km,
            'delivery_charge' => $this->delivery_charge,
            'handling_charge' => (double) \App\Models\Setting::getValue('handling_charge', 5.0),
            'platform_fee' => (double) \App\Models\Setting::getValue('platform_fee', 10.0),
            'show_handling_charge' => \App\Models\Setting::getValue('show_handling_charge', 'yes') === 'yes',
            'show_platform_fee' => \App\Models\Setting::getValue('show_platform_fee', 'yes') === 'yes',
            'allow_today_delivery' => \App\Models\Setting::getValue('allow_today_delivery', 'yes') === 'yes',
            'support_name' => \App\Models\Setting::getValue('support_name', 'Gundawadi Mart Support'),
            'support_mobile' => \App\Models\Setting::getValue('support_mobile', '9876543210'),
            'delivery_time_slots' => \App\Models\DeliverySlot::where('is_active', true)->get()->map(function($slot) {
                return $slot->start_time . ' - ' . $slot->end_time;
            })->toArray(),
            'profile_photo' => $this->profile_photo ? url('storage/' . $this->profile_photo) : null,
            'address' => $approvedAddress ? new AddressResource($approvedAddress) : null,
            'pending_address' => $pendingAddress ? new AddressResource($pendingAddress) : null,
        ];
    }
}
