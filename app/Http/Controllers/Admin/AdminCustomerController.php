<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Address;
use App\Services\FcmService;
use Illuminate\Http\Request;

class AdminCustomerController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->input('status');
        
        $query = Customer::withCount('orders')->with(['addresses' => function($q) {
            $q->whereIn('status', ['approved', 'pending']);
        }]);

        if ($status) {
            $query->where('status', $status);
        }

        $customers = $query->orderBy('created_at', 'desc')->get();
        return view('admin.customers.index', compact('customers'));
    }

    public function approveCustomer(Customer $customer, Request $request)
    {
        $request->validate([
            'delivery_km' => 'required|numeric|min:0',
            'delivery_charge' => 'required|numeric|min:0',
        ]);

        \DB::transaction(function () use ($customer, $request) {
            $customer->update([
                'status' => 'approved',
                'delivery_km' => $request->input('delivery_km'),
                'delivery_charge' => $request->input('delivery_charge'),
                'rejection_reason' => null,
            ]);

            $pendingAddress = $customer->addresses()->where('status', 'pending')->first();
            if ($pendingAddress) {
                $pendingAddress->update([
                    'status' => 'approved',
                    'delivery_km' => $request->input('delivery_km'),
                    'delivery_charge' => $request->input('delivery_charge'),
                ]);
            }
        });

        FcmService::send(
            'customer',
            $customer->id,
            $customer->device_token,
            'Registration Approved',
            'Your account has been approved. You can now login and place orders.'
        );

        return redirect()->back()->with('success', 'Customer approved successfully.');
    }

    public function rejectCustomer(Customer $customer, Request $request)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:1000',
        ]);

        \DB::transaction(function () use ($customer, $request) {
            $customer->update([
                'status' => 'rejected',
                'rejection_reason' => $request->input('rejection_reason'),
            ]);

            $pendingAddress = $customer->addresses()->where('status', 'pending')->first();
            if ($pendingAddress) {
                $pendingAddress->update([
                    'status' => 'rejected',
                ]);
            }
        });

        FcmService::send(
            'customer',
            $customer->id,
            $customer->device_token,
            'Registration Rejected',
            'Your registration was rejected. Reason: ' . $request->input('rejection_reason')
        );

        return redirect()->back()->with('success', 'Customer registration rejected.');
    }

    public function addressRequests()
    {
        $requests = Address::with('customer')
            ->where('status', 'pending')
            ->whereHas('customer', function($q) {
                $q->where('status', 'approved');
            })
            ->orderBy('created_at', 'desc')
            ->get();

        return view('admin.customers.address_requests', compact('requests'));
    }

    public function approveAddressChange(Address $address, Request $request)
    {
        $request->validate([
            'delivery_km' => 'required|numeric|min:0',
            'delivery_charge' => 'required|numeric|min:0',
        ]);

        $customer = $address->customer;

        \DB::transaction(function () use ($address, $customer, $request) {
            Address::where('customer_id', $customer->id)
                ->where('status', 'approved')
                ->update(['status' => 'replaced']);

            $address->update([
                'status' => 'approved',
                'delivery_km' => $request->input('delivery_km'),
                'delivery_charge' => $request->input('delivery_charge'),
            ]);

            $customer->update([
                'delivery_km' => $request->input('delivery_km'),
                'delivery_charge' => $request->input('delivery_charge'),
            ]);
        });

        FcmService::send(
            'customer',
            $customer->id,
            $customer->device_token,
            'Address Change Approved',
            'Your new delivery address has been verified and approved.'
        );

        return redirect()->back()->with('success', 'Address change request approved.');
    }

    public function rejectAddressChange(Address $address, Request $request)
    {
        $address->update(['status' => 'rejected']);

        $customer = $address->customer;

        FcmService::send(
            'customer',
            $customer->id,
            $customer->device_token,
            'Address Change Rejected',
            'Your address change request was rejected. Active address remains unchanged.'
        );

        return redirect()->back()->with('success', 'Address change request rejected.');
    }

    public function updateConfig(Customer $customer, Request $request)
    {
        $request->validate([
            'status' => 'required|in:pending_approval,approved,rejected',
            'delivery_km' => 'required_if:status,approved|nullable|numeric|min:0',
            'delivery_charge' => 'required_if:status,approved|nullable|numeric|min:0',
            'rejection_reason' => 'required_if:status,rejected|nullable|string|max:1000',
        ]);

        $status = $request->input('status');

        \DB::transaction(function () use ($customer, $status, $request) {
            $customer->update([
                'status' => $status,
                'delivery_km' => $status === 'approved' ? $request->input('delivery_km') : $customer->delivery_km,
                'delivery_charge' => $status === 'approved' ? $request->input('delivery_charge') : $customer->delivery_charge,
                'rejection_reason' => $status === 'rejected' ? $request->input('rejection_reason') : null,
            ]);

            if ($status === 'approved') {
                $address = $customer->addresses()->whereIn('status', ['pending', 'approved'])->first();
                if ($address) {
                    $address->update([
                        'status' => 'approved',
                        'delivery_km' => $request->input('delivery_km'),
                        'delivery_charge' => $request->input('delivery_charge'),
                    ]);
                }
            } elseif ($status === 'rejected') {
                $address = $customer->addresses()->where('status', 'pending')->first();
                if ($address) {
                    $address->update(['status' => 'rejected']);
                }
            }
        });

        // Send Notification based on status
        if ($status === 'approved') {
            FcmService::send(
                'customer',
                $customer->id,
                $customer->device_token,
                'Account Approved / Updated',
                'Your delivery distance has been configured/updated to ' . $request->input('delivery_km') . ' km.'
            );
        } elseif ($status === 'rejected') {
            FcmService::send(
                'customer',
                $customer->id,
                $customer->device_token,
                'Account Deactivated',
                'Your account registration status has been set to rejected. Reason: ' . $request->input('rejection_reason')
            );
        }

        return redirect()->back()->with('success', 'Customer configurations updated successfully.');
    }

    public function resetPassword(Customer $customer, Request $request)
    {
        $request->validate([
            'password' => 'required|string|min:6',
        ]);

        $customer->update([
            'password' => \Illuminate\Support\Facades\Hash::make($request->input('password')),
        ]);

        return redirect()->back()->with('success', 'Customer password reset successfully.');
    }
}
