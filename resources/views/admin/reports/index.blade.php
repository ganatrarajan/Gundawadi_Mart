@extends('layouts.admin')

@section('title', 'Sales Reports')
@section('page_title', 'Revenue & Sales Reports')

@section('content')
<!-- Date Filter Form -->
<div class="card card-custom bg-white p-4 mb-4">
    <form action="{{ route('admin.reports.index') }}" method="GET" class="row align-items-end g-3">
        <div class="col-md-4">
            <label for="start_date" class="form-label fw-bold small text-secondary">START DATE</label>
            <input type="date" class="form-control form-control-sm" id="start_date" name="start_date" value="{{ $startDate }}">
        </div>
        <div class="col-md-4">
            <label for="end_date" class="form-label fw-bold small text-secondary">END DATE</label>
            <input type="date" class="form-control form-control-sm" id="end_date" name="end_date" value="{{ $endDate }}">
        </div>
        <div class="col-md-4">
            <button type="submit" class="btn btn-primary-custom btn-sm w-100 py-2"><i class="bi bi-filter me-1"></i> Filter Reports</button>
        </div>
    </form>
</div>

<!-- Overall Summary (Delivered Orders Only) -->
<div class="row g-4 mb-5">
    <div class="col-md-4">
        <div class="card card-custom p-4 bg-success text-white">
            <h6 class="text-uppercase small mb-2 text-white-50">Total Revenue (Delivered)</h6>
            <h2 class="fw-bold m-0">₹{{ number_format($revenueStats->total_revenue ?? 0, 2) }}</h2>
            <small class="mt-2 d-block">Overall sales volume including delivery charges.</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card card-custom p-4 bg-primary text-white">
            <h6 class="text-uppercase small mb-2 text-white-50">Vendor Product Sales Share</h6>
            <h2 class="fw-bold m-0">₹{{ number_format($revenueStats->total_subtotal ?? 0, 2) }}</h2>
            <small class="mt-2 d-block">Subtotal disbursed to local vegetable vendors.</small>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card card-custom p-4 bg-warning text-dark">
            <h6 class="text-uppercase small mb-2 text-dark-50">Delivery Charges Collected</h6>
            <h2 class="fw-bold m-0">₹{{ number_format($revenueStats->total_delivery_charge ?? 0, 2) }}</h2>
            <small class="mt-2 d-block">Revenue from manually assigned delivery fees.</small>
        </div>
    </div>
</div>

<div class="row g-4">
    <!-- Daily Sales Table -->
    <div class="col-lg-7">
        <div class="card card-custom bg-white p-4">
            <h5 class="fw-bold mb-4 text-success"><i class="bi bi-calendar-check me-2"></i>Daily Order Statistics</h5>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Date</th>
                            <th>Orders</th>
                            <th>Subtotal</th>
                            <th>Delivery</th>
                            <th class="text-end">Total Revenue</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($dailyOrders as $day)
                            <tr>
                                <td class="fw-bold">{{ $day->date }}</td>
                                <td>{{ $day->order_count }} Orders</td>
                                <td>₹{{ number_format($day->subtotal_sum, 2) }}</td>
                                <td>₹{{ number_format($day->delivery_charge_sum, 2) }}</td>
                                <td class="text-end fw-bold text-success">₹{{ number_format($day->total_revenue, 2) }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center py-4 text-muted">
                                    No data in select range.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Vendor Sales Table -->
    <div class="col-lg-5">
        <div class="card card-custom bg-white p-4">
            <h5 class="fw-bold mb-4 text-success"><i class="bi bi-shop me-2"></i>Vendor Sales (Completed Only)</h5>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Shop Name</th>
                            <th>Orders</th>
                            <th class="text-end">Product Sales</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($vendorSales as $sales)
                            <tr>
                                <td class="fw-bold">{{ $sales->vendor->shop_name ?? 'N/A' }}</td>
                                <td>{{ $sales->order_count }} Orders</td>
                                <td class="text-end fw-bold text-success">₹{{ number_format($sales->total_sales, 2) }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="3" class="text-center py-4 text-muted">
                                    No completed vendor sales in this range.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
