<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AddressResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'full_name' => $this->full_name,
            'mobile' => $this->mobile,
            'house_number' => $this->house_number,
            'street' => $this->street,
            'area' => $this->area,
            'landmark' => $this->landmark,
            'city' => $this->city,
            'pincode' => $this->pincode,
            'delivery_km' => $this->delivery_km,
            'delivery_charge' => $this->delivery_charge,
            'status' => $this->status,
        ];
    }
}
