<?php

namespace App\Repositories\Contracts;

interface CustomerRepositoryInterface
{
    public function findOrCreateByMobile($mobile);
    public function findById($id);
    public function update($id, array $data);
}
