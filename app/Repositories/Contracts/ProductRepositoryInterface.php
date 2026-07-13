<?php

namespace App\Repositories\Contracts;

interface ProductRepositoryInterface
{
    public function getVendorProducts($vendorId, array $filters = []);
    public function findById($id);
    public function create(array $data);
    public function update($id, array $data);
    public function updatePrice($id, $price);
}
