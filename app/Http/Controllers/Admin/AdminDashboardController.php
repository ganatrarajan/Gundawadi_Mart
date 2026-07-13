<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use App\Models\Customer;
use App\Models\Order;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $totalVendors = Vendor::count();
        $totalCustomers = Customer::count();
        $totalOrders = Order::count();
        $pendingOrders = Order::where('status', 'pending')->count();
        $completedOrders = Order::where('status', 'delivered')->count();
        $todayOrders = Order::whereDate('created_at', today())->count();

        $recentOrders = Order::with(['customer', 'vendor'])
            ->orderBy('id', 'desc')
            ->limit(5)
            ->get();

        return view('admin.dashboard', compact(
            'totalVendors',
            'totalCustomers',
            'totalOrders',
            'pendingOrders',
            'completedOrders',
            'todayOrders',
            'recentOrders'
        ));
    }
}
