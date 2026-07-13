<?php

namespace App\Repositories\Eloquent;

use App\Models\Address;
use App\Repositories\Contracts\AddressRepositoryInterface;

class EloquentAddressRepository implements AddressRepositoryInterface
{
    public function getCustomerAddresses($customerId)
    {
        return Address::where('customer_id', $customerId)->get();
    }

    public function create(array $data)
    {
        return Address::create($data);
    }

    public function findById($id)
    {
        return Address::find($id);
    }
}
