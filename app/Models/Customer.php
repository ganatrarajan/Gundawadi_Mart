<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Customer extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'name',
        'mobile',
        'password',
        'status',
        'rejection_reason',
        'delivery_km',
        'delivery_charge',
        'profile_photo',
        'otp',
        'otp_expires_at',
        'device_token',
    ];

    protected $casts = [
        'otp_expires_at' => 'datetime',
        'password' => 'hashed',
        'delivery_km' => 'float',
        'delivery_charge' => 'float',
    ];

    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
