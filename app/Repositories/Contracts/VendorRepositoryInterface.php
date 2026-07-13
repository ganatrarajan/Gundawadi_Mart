<?php

namespace App\Repositories\Contracts;

interface VendorRepositoryInterface
{
    public function allActive();
    public function findById($id);
    public function findByMobile($mobileNumber);
    public function create(array $data);
    public function update($id, array $data);
    public function delete($id);
}
