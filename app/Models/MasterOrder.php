<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MasterOrder extends Model
{
    use HasFactory;

    protected $table = 'master_orders';

    protected $fillable = [
        'customer_id',
        'address_id',
        'delivery_address',
        'subtotal',
        'delivery_charge',
        'handling_charge',
        'platform_fee',
        'total',
        'payment_method',
        'status',
        'special_note',
        'delivery_slot',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'delivery_charge' => 'decimal:2',
        'handling_charge' => 'decimal:2',
        'platform_fee' => 'decimal:2',
        'total' => 'decimal:2',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function address()
    {
        return $this->belongsTo(Address::class);
    }

    public function vendorOrders()
    {
        return $this->hasMany(Order::class, 'master_order_id');
    }

    public function getItemsAttribute()
    {
        return $this->vendorOrders->flatMap(function ($vo) {
            return $vo->items;
        });
    }
}
