<?php

namespace App\Repositories\Contracts;

interface AddressRepositoryInterface
{
    public function getCustomerAddresses($customerId);
    public function create(array $data);
    public function findById($id);
}
