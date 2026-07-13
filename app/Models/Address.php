<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Address extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'full_name',
        'mobile',
        'house_number',
        'street',
        'area',
        'landmark',
        'city',
        'pincode',
        'delivery_km',
        'delivery_charge',
        'status',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
