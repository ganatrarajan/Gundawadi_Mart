<?php

namespace App\Repositories\Eloquent;

use App\Models\Customer;
use App\Repositories\Contracts\CustomerRepositoryInterface;

class EloquentCustomerRepository implements CustomerRepositoryInterface
{
    public function findOrCreateByMobile($mobile)
    {
        return Customer::firstOrCreate(
            ['mobile' => $mobile],
            ['status' => 'active']
        );
    }

    public function findById($id)
    {
        return Customer::find($id);
    }

    public function update($id, array $data)
    {
        $customer = Customer::findOrFail($id);
        $customer->update($data);
        return $customer;
    }
}
