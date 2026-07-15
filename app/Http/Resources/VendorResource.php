<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VendorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $isOpen = true;
        if ($this->is_closed) {
            $isOpen = false;
        } elseif ($this->opening_time && $this->closing_time) {
            try {
                $now = now('Asia/Kolkata');
                $openTime = \Carbon\Carbon::createFromFormat('h:i A', $this->opening_time, 'Asia/Kolkata');
                $closeTime = \Carbon\Carbon::createFromFormat('h:i A', $this->closing_time, 'Asia/Kolkata');
                
                // If closing time is on the next day (e.g. 06:00 PM to 02:00 AM)
                if ($closeTime->lt($openTime)) {
                    $isOpen = $now->between($openTime, $now->copy()->endOfDay()) || $now->between($now->copy()->startOfDay(), $closeTime);
                } else {
                    $isOpen = $now->between($openTime, $closeTime);
                }
            } catch (\Exception $e) {
                $isOpen = true; // Fallback to open if time parsing fails
            }
        }

        return [
            'id' => $this->id,
            'shop_name' => $this->shop_name,
            'owner_name' => $this->owner_name,
            'mobile' => $this->mobile_number,
            'shop_photo' => $this->shop_photo ? (str_starts_with($this->shop_photo, 'http') ? $this->shop_photo : asset('storage/' . $this->shop_photo)) : null,
            'shop_address' => $this->shop_address,
            'opening_time' => $this->opening_time ?? '06:00 AM',
            'closing_time' => $this->closing_time ?? '08:00 PM',
            'is_closed' => (bool)$this->is_closed,
            'status' => $this->status,
            'is_open' => $isOpen,
            'support_name' => \App\Models\Setting::getValue('support_name', 'Gmart Partner Support'),
            'support_mobile' => \App\Models\Setting::getValue('support_mobile', '9876543210'),
        ];
    }
}
