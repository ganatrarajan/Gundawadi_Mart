<?php

namespace App\Repositories\Contracts;

interface OrderRepositoryInterface
{
    public function create(array $data, array $items);
    public function findById($id);
    public function getCustomerOrders($customerId);
    public function getVendorOrders($vendorId);
    public function getAllOrders(array $filters = []);
    public function updateStatus($id, $status);
    public function updateDeliveryCharge($id, $charge);
}
