<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\VendorResource;
use App\Repositories\Contracts\VendorRepositoryInterface;
use App\Traits\ApiResponder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class VendorAuthController extends Controller
{
    use ApiResponder;

    protected $vendorRepository;

    public function __construct(VendorRepositoryInterface $vendorRepository)
    {
        $this->vendorRepository = $vendorRepository;
    }

    public function login(Request $request)
    {
        $request->validate([
            'mobile' => 'required|string',
            'password' => 'required|string',
        ]);

        $mobile = $request->input('mobile');
        $password = $request->input('password');
        
        // Find vendor
        $vendor = $this->vendorRepository->findByMobile($mobile);

        if (!$vendor) {
            return $this->errorResponse('Vendor account not found.', 404);
        }

        if ($vendor->status !== 'active') {
            return $this->errorResponse('Your vendor account is inactive. Please contact Admin.', 403);
        }

        // Verify password
        if (!Hash::check($password, $vendor->password)) {
            return $this->errorResponse('Invalid password credentials.', 422);
        }

        // Save device token for FCM if provided
        if ($request->has('device_token')) {
            $this->vendorRepository->update($vendor->id, [
                'device_token' => $request->input('device_token'),
            ]);
        }

        // Generate Token
        $token = $vendor->createToken('VendorToken')->plainTextToken;

        return $this->successResponse([
            'token' => $token,
            'vendor' => new VendorResource($vendor)
        ], 'Logged in successfully.');
    }
}
