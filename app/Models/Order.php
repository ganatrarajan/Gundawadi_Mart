<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'master_order_id',
        'vendor_id',
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
        'customer_id' => 'integer',
        'master_order_id' => 'integer',
        'vendor_id' => 'integer',
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

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function address()
    {
        return $this->belongsTo(Address::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function masterOrder()
    {
        return $this->belongsTo(MasterOrder::class, 'master_order_id');
    }
}
