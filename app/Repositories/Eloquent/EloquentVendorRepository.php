<?php

namespace App\Repositories\Eloquent;

use App\Models\Vendor;
use App\Repositories\Contracts\VendorRepositoryInterface;

class EloquentVendorRepository implements VendorRepositoryInterface
{
    public function allActive()
    {
        return Vendor::where('status', 'active')->get();
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
