<?php

namespace App\Repositories\Contracts;

interface OrderRepositoryInterface
{
    public function create(array $data, array $items);
    public function findById($id);
    public function findMasterById($id);
    public function getCustomerOrders($customerId, array $filters = []);
    public function getVendorOrders($vendorId, array $filters = []);
    public function getAllOrders(array $filters = []);
    public function getAllMasterOrders(array $filters = []);
    public function updateStatus($id, $status);
    public function updateMasterStatus($id, $status);
    public function updateDeliveryCharge($id, $charge);
}
