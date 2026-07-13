@extends('layouts.admin')

@section('title', 'Admin Dashboard')
@section('page_title', 'Dashboard Overview')

@section('content')
<div class="row g-4">
    <!-- Stat 1: Total Vendors -->
    <div class="col-md-4 col-lg-2">
        <div class="card card-custom p-4 bg-white">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-muted text-uppercase small mb-2">Total Vendors</h6>
                    <h3 class="fw-bold m-0 text-dark">{{ $totalVendors }}</h3>
                </div>
                <div class="fs-2 text-success"><i class="bi bi-people-fill"></i></div>
            </div>
        </div>
    </div>

    <!-- Stat 2: Total Customers -->
    <div class="col-md-4 col-lg-2">
        <div class="card card-custom p-4 bg-white">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-muted text-uppercase small mb-2">Customers</h6>
                    <h3 class="fw-bold m-0 text-dark">{{ $totalCustomers }}</h3>
                </div>
                <div class="fs-2 text-info"><i class="bi bi-person-circle"></i></div>
            </div>
        </div>
    </div>

    <!-- Stat 3: Total Orders -->
    <div class="col-md-4 col-lg-2">
        <div class="card card-custom p-4 bg-white">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-muted text-uppercase small mb-2">Total Orders</h6>
                    <h3 class="fw-bold m-0 text-dark">{{ $totalOrders }}</h3>
                </div>
                <div class="fs-2 text-primary"><i class="bi bi-cart-fill"></i></div>
            </div>
        </div>
    </div>

    <!-- Stat 4: Pending Orders -->
    <div class="col-md-4 col-lg-2">
        <div class="card card-custom p-4 bg-white">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-muted text-uppercase small mb-2">Pending</h6>
                    <h3 class="fw-bold m-0 text-warning">{{ $pendingOrders }}</h3>
                </div>
                <div class="fs-2 text-warning"><i class="bi bi-hourglass-split"></i></div>
            </div>
        </div>
    </div>

    <!-- Stat 5: Completed Orders -->
    <div class="col-md-4 col-lg-2">
        <div class="card card-custom p-4 bg-white">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-muted text-uppercase small mb-2">Completed</h6>
                    <h3 class="fw-bold m-0 text-success">{{ $completedOrders }}</h3>
                </div>
                <div class="fs-2 text-success"><i class="bi bi-check-circle-fill"></i></div>
            </div>
        </div>
    </div>

    <!-- Stat 6: Today's Orders -->
    <div class="col-md-4 col-lg-2">
        <div class="card card-custom p-4 bg-white">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-muted text-uppercase small mb-2">Today's Orders</h6>
                    <h3 class="fw-bold m-0 text-danger">{{ $todayOrders }}</h3>
                </div>
                <div class="fs-2 text-danger"><i class="bi bi-calendar-event-fill"></i></div>
            </div>
        </div>
    </div>
</div>

<div class="row mt-5">
    <div class="col-12">
        <div class="card card-custom bg-white p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="m-0 fw-bold"><i class="bi bi-clock-history text-success me-2"></i>Recent Orders</h5>
                <a href="{{ route('admin.orders.index') }}" class="btn btn-outline-primary-custom btn-sm">View All Orders</a>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th class="py-3">Order ID</th>
                            <th class="py-3">Customer</th>
                            <th class="py-3">Vendor Shop</th>
                            <th class="py-3">Subtotal</th>
                            <th class="py-3">Delivery Charge</th>
                            <th class="py-3">Total</th>
                            <th class="py-3">Status</th>
                            <th class="py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($recentOrders as $order)
                            <tr>
                                <td class="fw-bold">#{{ $order->id }}</td>
                                <td>
                                    <div>{{ $order->customer->name ?? 'New Customer' }}</div>
                                    <small class="text-muted">{{ $order->customer->mobile }}</small>
                                </td>
                                <td>{{ $order->vendor->shop_name }}</td>
                                <td>₹{{ number_format($order->subtotal, 2) }}</td>
                                <td>₹{{ number_format($order->delivery_charge, 2) }}</td>
                                <td class="fw-bold">₹{{ number_format($order->total, 2) }}</td>
                                <td>
                                    <span class="badge badge-{{ $order->status }} text-uppercase px-2 py-1 small">
                                        {{ str_replace('_', ' ', $order->status) }}
                                    </span>
                                </td>
                                <td class="text-center">
                                    <a href="{{ route('admin.orders.show', $order->id) }}" class="btn btn-sm btn-primary-custom">
                                        <i class="bi bi-eye me-1"></i> View
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="8" class="text-center py-4 text-muted">
                                    No orders placed yet.
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
