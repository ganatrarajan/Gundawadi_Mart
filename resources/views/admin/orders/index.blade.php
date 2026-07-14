@extends('layouts.admin')

@section('title', 'Manage Orders')
@section('page_title', 'Order Management')

@section('content')
<div class="card card-custom bg-white p-4">
    <!-- Filter Header -->
    <div class="row align-items-center mb-4 g-3">
        <div class="col-md-6">
            <h5 class="m-0 fw-bold"><i class="bi bi-cart3 text-success me-2"></i>Orders List</h5>
        </div>
        <div class="col-md-6 text-md-end">
            <form action="{{ route('admin.orders.index') }}" method="GET" class="d-inline-block">
                <div class="input-group input-group-sm">
                    <label class="input-group-text bg-light fw-bold small text-secondary">FILTER STATUS:</label>
                    <select name="status" class="form-select" onchange="this.form.submit()">
                        <option value="">-- All Statuses --</option>
                        <option value="pending" {{ $status == 'pending' ? 'selected' : '' }}>Pending</option>
                        <option value="accepted" {{ $status == 'accepted' ? 'selected' : '' }}>Accepted</option>
                        <option value="packing" {{ $status == 'packing' ? 'selected' : '' }}>Packing</option>
                        <option value="ready_for_pickup" {{ $status == 'ready_for_pickup' ? 'selected' : '' }}>Ready For Pickup</option>
                        <option value="out_for_delivery" {{ $status == 'out_for_delivery' ? 'selected' : '' }}>Out For Delivery</option>
                        <option value="delivered" {{ $status == 'delivered' ? 'selected' : '' }}>Delivered</option>
                        <option value="completed" {{ $status == 'completed' ? 'selected' : '' }}>Completed</option>
                        <option value="cancelled" {{ $status == 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                    </select>
                </div>
            </form>
        </div>
    </div>

    <!-- Orders Table -->
    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-light">
                <tr>
                    <th class="py-3">Order ID</th>
                    <th class="py-3">Date</th>
                    <th class="py-3">Customer</th>
                    <th class="py-3">Vendor Shop</th>
                    <th class="py-3">Delivery Slot</th>
                    <th class="py-3">Subtotal</th>
                    <th class="py-3">Delivery Charge</th>
                    <th class="py-3">Total</th>
                    <th class="py-3">Status</th>
                    <th class="py-3 text-center">Action</th>
                </tr>
            </thead>
            <tbody>
                @forelse($orders as $order)
                    <tr>
                        <td class="fw-bold">#{{ $order->id }}</td>
                        <td>{{ $order->created_at->format('Y-m-d H:i') }}</td>
                        <td>
                            <div>{{ $order->customer->name ?? 'New Customer' }}</div>
                            <small class="text-muted">{{ $order->customer->mobile }}</small>
                        </td>
                        <td>{{ $order->vendorOrders->map(fn($vo) => $vo->vendor->shop_name ?? '')->filter()->join(', ') }}</td>
                        <td>
                            @if($order->delivery_slot)
                                <span class="badge bg-info-subtle text-info border border-info px-2 py-1 fw-bold">
                                    <i class="bi bi-clock me-1"></i>{{ $order->delivery_slot }}
                                </span>
                            @else
                                <span class="text-muted italic small">Immediate / Standard</span>
                            @endif
                        </td>
                        <td>₹{{ number_format($order->subtotal, 2) }}</td>
                        <td class="{{ $order->delivery_charge == 0 ? 'text-danger fw-bold' : '' }}">
                            ₹{{ number_format($order->delivery_charge, 2) }}
                            @if($order->delivery_charge == 0 && $order->status != 'cancelled' && $order->status != 'delivered')
                                <small class="d-block text-danger small" style="font-size: 0.7rem;">Needs Charge</small>
                            @endif
                        </td>
                        <td class="fw-bold">₹{{ number_format($order->total, 2) }}</td>
                        <td>
                            <span class="badge badge-{{ $order->status }} text-uppercase px-2 py-1 small">
                                {{ str_replace('_', ' ', $order->status) }}
                            </span>
                        </td>
                        <td class="text-center text-nowrap">
                            <a href="{{ route('admin.orders.show', $order->id) }}" class="btn btn-sm btn-outline-primary-custom">
                                <i class="bi bi-eye"></i> Process
                            </a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="10" class="text-center py-4 text-muted">
                            No orders found.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
