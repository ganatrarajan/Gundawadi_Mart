@extends('layouts.admin')

@section('title', 'Order Details #' . $order->id)
@section('page_title', 'Process Order #' . $order->id)

@section('content')
<div class="row mb-4">
    <div class="col-12">
        <a href="{{ route('admin.orders.index') }}" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left"></i> Back to Orders
        </a>
    </div>
</div>

<div class="row g-4">
    <!-- Left Column: Details -->
    <div class="col-lg-8">
        <!-- Order Items -->
        <div class="card card-custom bg-white p-4 mb-4">
            <h5 class="fw-bold mb-3 text-success"><i class="bi bi-bag-check me-2"></i>Ordered items</h5>
            
            @foreach($order->vendorOrders as $vendorOrder)
                <div class="mb-4 p-3 bg-light rounded border">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h6 class="fw-bold text-success m-0">
                            <i class="bi bi-shop me-1"></i>{{ $vendorOrder->vendor->shop_name }}
                        </h6>
                        <span class="badge bg-secondary text-uppercase">{{ str_replace('_', ' ', $vendorOrder->status) }}</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle table-sm m-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Item Name</th>
                                    <th>Unit</th>
                                    <th>Price</th>
                                    <th>Qty</th>
                                    <th class="text-end">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($vendorOrder->items as $item)
                                    <tr>
                                        <td class="fw-bold">{{ $item->product_name }}</td>
                                        <td>{{ $item->unit }}</td>
                                        <td>₹{{ number_format($item->price, 2) }}</td>
                                        <td>{{ $item->quantity }}</td>
                                        <td class="text-end fw-bold">₹{{ number_format($item->total_price, 2) }}</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            @endforeach

            <div class="table-responsive mt-3">
                <table class="table align-middle">
                    <tbody>
                        <tr>
                            <td colspan="4" class="text-end fw-bold py-3">Subtotal</td>
                            <td class="text-end fw-bold py-3">₹{{ number_format($order->subtotal, 2) }}</td>
                        </tr>
                        <tr>
                            <td colspan="4" class="text-end fw-bold text-success py-3">Delivery Charge</td>
                            <td class="text-end fw-bold text-success py-3">₹{{ number_format($order->delivery_charge, 2) }}</td>
                        </tr>
                        @if($order->handling_charge > 0)
                            <tr>
                                <td colspan="4" class="text-end fw-bold text-secondary py-2" style="font-size: 0.9rem;">Handling Charge</td>
                                <td class="text-end fw-bold text-secondary py-2" style="font-size: 0.9rem;">₹{{ number_format($order->handling_charge, 2) }}</td>
                            </tr>
                        @endif
                        @if($order->platform_fee > 0)
                            <tr>
                                <td colspan="4" class="text-end fw-bold text-secondary py-2" style="font-size: 0.9rem;">Platform Fee</td>
                                <td class="text-end fw-bold text-secondary py-2" style="font-size: 0.9rem;">₹{{ number_format($order->platform_fee, 2) }}</td>
                            </tr>
                        @endif
                        <tr class="table-light">
                            <td colspan="4" class="text-end fw-bold fs-5 py-3">Total Amount</td>
                            <td class="text-end fw-bold fs-5 text-success py-3">₹{{ number_format($order->total, 2) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Special Note and Delivery Address -->
        <div class="card card-custom bg-white p-4">
            <h5 class="fw-bold mb-3 text-success"><i class="bi bi-geo-alt me-2"></i>Delivery Details</h5>
            
            <div class="mb-4">
                <h6 class="fw-bold text-secondary small text-uppercase">Selected Delivery Slot</h6>
                <div class="p-3 bg-light rounded border mt-1 fw-bold text-info">
                    @if($order->delivery_slot)
                        <i class="bi bi-clock-history me-2"></i>{{ $order->delivery_slot }}
                    @else
                        <i class="bi bi-clock me-2"></i>Immediate / Standard Delivery
                    @endif
                </div>
            </div>

            <div class="mb-4">
                <h6 class="fw-bold text-secondary small text-uppercase">Delivery Address</h6>
                <div class="p-3 bg-light rounded border mt-1" style="white-space: pre-line;">
                    {{ $order->delivery_address }}
                </div>
            </div>

            <div>
                <h6 class="fw-bold text-secondary small text-uppercase">Special Note (Instructions)</h6>
                <div class="p-3 bg-light rounded border mt-1">
                    @if($order->special_note)
                        <span class="text-dark">"{{ $order->special_note }}"</span>
                    @else
                        <span class="text-muted italic">No instructions provided.</span>
                    @endif
                </div>
            </div>
        </div>
    </div>

    <!-- Right Column: Actions and Parties -->
    <div class="col-lg-4">
        <!-- Status & Charge Controls -->
        <div class="card card-custom bg-white p-4 mb-4">
            <h5 class="fw-bold mb-4 text-success"><i class="bi bi-sliders me-2"></i>Order Processing</h5>
            
            <!-- Delivery Charge Update -->
            <form action="{{ route('admin.orders.updateDeliveryCharge', $order->id) }}" method="POST" class="mb-4">
                @csrf
                <label for="delivery_charge" class="form-label fw-bold text-secondary small text-uppercase">Delivery Charge (₹)</label>
                <div class="input-group">
                    <span class="input-group-text">₹</span>
                    <input type="number" step="0.01" min="0" class="form-control" id="delivery_charge" name="delivery_charge" value="{{ $order->delivery_charge }}">
                    <button class="btn btn-primary-custom" type="submit">Update</button>
                </div>
                <small class="text-muted d-block mt-1">Review the customer address, set delivery charge, and save.</small>
            </form>

            <hr>

            <!-- Status Dropdown Update -->
            <form action="{{ route('admin.orders.updateStatus', $order->id) }}" method="POST">
                @csrf
                <label for="status" class="form-label fw-bold text-secondary small text-uppercase mt-2">Order Status</label>
                <div class="mb-3">
                    <select class="form-select" id="status" name="status">
                        @foreach($statuses as $statusOption)
                            <option value="{{ $statusOption }}" {{ $order->status == $statusOption ? 'selected' : '' }}>
                                {{ strtoupper(str_replace('_', ' ', $statusOption)) }}
                            </option>
                        @endforeach
                    </select>
                </div>
                <button type="submit" class="btn btn-success w-100 fw-bold">Update Order Status</button>
            </form>
        </div>

        <!-- Vendor & Customer Info -->
        <div class="card card-custom bg-white p-4">
            <h5 class="fw-bold mb-4 text-success"><i class="bi bi-person-lines-fill me-2"></i>Parties Involved</h5>
            
            <!-- Customer -->
            <div class="mb-4">
                <h6 class="fw-bold text-secondary small text-uppercase">Customer Information</h6>
                <div class="d-flex align-items-center mt-2">
                    <div class="fs-1 text-secondary me-3"><i class="bi bi-person-circle"></i></div>
                    <div>
                        <div class="fw-bold">{{ $order->customer->name ?? 'New Customer' }}</div>
                        <a href="tel:{{ $order->customer->mobile }}" class="text-decoration-none small"><i class="bi bi-telephone-fill me-1"></i>{{ $order->customer->mobile }}</a>
                    </div>
                </div>
            </div>

            <hr>

            <!-- Vendors -->
            <div>
                <h6 class="fw-bold text-secondary small text-uppercase mb-3">Vendors Information</h6>
                @foreach($order->vendorOrders as $vendorOrder)
                    <div class="d-flex align-items-start mt-2 mb-3">
                        <div class="fs-2 text-secondary me-3"><i class="bi bi-shop"></i></div>
                        <div>
                            <div class="fw-bold">{{ $vendorOrder->vendor->shop_name }}</div>
                            <div class="small text-muted">{{ $vendorOrder->vendor->owner_name }}</div>
                            <a href="tel:{{ $vendorOrder->vendor->mobile_number }}" class="text-decoration-none small">
                                <i class="bi bi-telephone-fill me-1"></i>{{ $vendorOrder->vendor->mobile_number }}
                            </a>
                            <div class="small text-muted mt-1" style="font-size: 0.8rem;">{{ $vendorOrder->vendor->shop_address }}</div>
                        </div>
                    </div>
                    @if(!$loop->last)
                        <hr class="my-2 border-dashed">
                    @endif
                @endforeach
            </div>
        </div>
    </div>
</div>
@endsection
