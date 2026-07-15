<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Vendor extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'shop_name',
        'owner_name',
        'mobile_number',
        'password',
        'shop_photo',
        'shop_address',
        'opening_time',
        'closing_time',
        'is_closed',
        'status',
        'otp',
        'otp_expires_at',
        'device_token',
        'category_id',
    ];

    protected $casts = [
        'otp_expires_at' => 'datetime',
        'password' => 'hashed',
        'is_closed' => 'boolean',
    ];

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
