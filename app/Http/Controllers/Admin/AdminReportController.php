<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Vendor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminReportController extends Controller
{
    public function index(Request $request)
    {
        // Default range: last 30 days
        $startDate = $request->input('start_date', now()->subDays(30)->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->format('Y-m-d'));

        // 1. Daily Orders Report
        $dailyOrders = Order::selectRaw('DATE(created_at) as date, COUNT(id) as order_count, SUM(subtotal) as subtotal_sum, SUM(delivery_charge) as delivery_charge_sum, SUM(total) as total_revenue')
            ->whereBetween(DB::raw('DATE(created_at)'), [$startDate, $endDate])
            ->groupByRaw('DATE(created_at)')
            ->orderBy('date', 'desc')
            ->get();

        // 2. Vendor Sales Report
        $vendorSales = Order::selectRaw('vendor_id, COUNT(id) as order_count, SUM(subtotal) as total_sales')
            ->whereBetween(DB::raw('DATE(created_at)'), [$startDate, $endDate])
            ->where('status', 'delivered')
            ->with('vendor')
            ->groupBy('vendor_id')
            ->get();

        // 3. Overall Revenue Statistics (Delivered only)
        $revenueStats = Order::selectRaw('COUNT(id) as order_count, SUM(subtotal) as total_subtotal, SUM(delivery_charge) as total_delivery_charge, SUM(total) as total_revenue')
            ->where('status', 'delivered')
            ->first();

        return view('admin.reports.index', compact('dailyOrders', 'vendorSales', 'revenueStats', 'startDate', 'endDate'));
    }
}
