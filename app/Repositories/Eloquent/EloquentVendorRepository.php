<?php

namespace App\Repositories\Eloquent;

use App\Models\Vendor;
use App\Repositories\Contracts\VendorRepositoryInterface;

class EloquentVendorRepository implements VendorRepositoryInterface
{
    public function allActive($search = null)
    {
        $query = Vendor::where('status', 'active');

        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('shop_name', 'like', "%{$search}%")
                  ->orWhere('owner_name', 'like', "%{$search}%");
            });
        }

        return $query->get();
    }

    public function findById($id)
    {
        return Vendor::find($id);
    }

    public function findByMobile($mobileNumber)
    {
        return Vendor::where('mobile_number', $mobileNumber)->first();
    }

    public function create(array $data)
    {
        return Vendor::create($data);
    }

    public function update($id, array $data)
    {
        $vendor = Vendor::findOrFail($id);
        $vendor->update($data);
        return $vendor;
    }

    public function delete($id)
    {
        $vendor = Vendor::findOrFail($id);
        return $vendor->delete();
    }
}
