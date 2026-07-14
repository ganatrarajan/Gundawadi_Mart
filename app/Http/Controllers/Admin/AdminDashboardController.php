<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use App\Models\Customer;
use App\Models\Order;
use App\Models\MasterOrder;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $totalVendors = Vendor::count();
        $totalCustomers = Customer::count();
        
        $masterCount = MasterOrder::count();
        $legacyCount = Order::whereNull('master_order_id')->count();
        $totalOrders = $masterCount + $legacyCount;
        
        $pendingOrders = MasterOrder::where('status', 'pending')->count() + Order::whereNull('master_order_id')->where('status', 'pending')->count();
        $completedOrders = MasterOrder::whereIn('status', ['delivered', 'completed'])->count() + Order::whereNull('master_order_id')->whereIn('status', ['delivered', 'completed'])->count();
        $todayOrders = MasterOrder::whereDate('created_at', today())->count() + Order::whereNull('master_order_id')->whereDate('created_at', today())->count();

        // Get recent master orders and legacy orders
        $masters = MasterOrder::with(['customer', 'vendorOrders.vendor'])
            ->orderBy('id', 'desc')
            ->limit(5)
            ->get();

        $legacies = Order::whereNull('master_order_id')
            ->with(['customer', 'vendor'])
            ->orderBy('id', 'desc')
            ->limit(5)
            ->get();

        // Wrap legacy orders in mock MasterOrder instances for visual parity
        $mockedLegacies = $legacies->map(function ($subOrder) {
            $mockMaster = new MasterOrder();
            $mockMaster->id = $subOrder->id;
            $mockMaster->customer_id = $subOrder->customer_id;
            $mockMaster->address_id = $subOrder->address_id;
            $mockMaster->delivery_address = $subOrder->delivery_address;
            $mockMaster->subtotal = $subOrder->subtotal;
            $mockMaster->delivery_charge = $subOrder->delivery_charge;
            $mockMaster->handling_charge = $subOrder->handling_charge;
            $mockMaster->platform_fee = $subOrder->platform_fee;
            $mockMaster->total = $subOrder->total;
            $mockMaster->payment_method = $subOrder->payment_method;
            $mockMaster->status = $subOrder->status;
            $mockMaster->special_note = $subOrder->special_note;
            $mockMaster->delivery_slot = $subOrder->delivery_slot;
            $mockMaster->created_at = $subOrder->created_at;
            $mockMaster->updated_at = $subOrder->updated_at;
            
            $mockMaster->setRelation('customer', $subOrder->customer);
            $mockMaster->setRelation('address', $subOrder->address);
            $mockMaster->setRelation('vendorOrders', collect([$subOrder]));
            
            return $mockMaster;
        });

        $recentOrders = $masters->concat($mockedLegacies)
            ->sortByDesc('created_at')
            ->take(5);

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
