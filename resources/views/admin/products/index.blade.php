@extends('layouts.admin')

@section('title', 'Manage Products')
@section('page_title', 'Product Management')

@section('content')
<div class="card card-custom bg-white p-4">
    <!-- Filter and Actions Header -->
    <div class="row align-items-center mb-4 g-3">
        <div class="col-md-4">
            <h5 class="m-0 fw-bold"><i class="bi bi-basket text-success me-2"></i>Products List</h5>
        </div>
        <div class="col-md-5">
            <form action="{{ route('admin.products.index') }}" method="GET" class="d-flex align-items-center">
                <label for="vendor_filter" class="me-2 fw-bold text-nowrap small text-secondary">FILTER BY VENDOR:</label>
                <select name="vendor_id" id="vendor_filter" class="form-select form-select-sm" onchange="this.form.submit()">
                    <option value="">-- All Vendors --</option>
                    @foreach($vendors as $vendor)
                        <option value="{{ $vendor->id }}" {{ $selectedVendorId == $vendor->id ? 'selected' : '' }}>
                            {{ $vendor->shop_name }} ({{ $vendor->owner_name }})
                        </option>
                    @endforeach
                </select>
            </form>
        </div>
        <div class="col-md-3 text-md-end">
            <a href="{{ route('admin.products.create') }}" class="btn btn-primary-custom btn-sm py-2">
                <i class="bi bi-plus-lg me-1"></i> Add Product
            </a>
        </div>
    </div>

    <!-- Products Table -->
    <div class="table-responsive">
        <table class="table table-hover align-middle" id="products-table">
            <thead class="table-light">
                <tr>
                    <th class="py-3">Image</th>
                    <th class="py-3">Name</th>
                    <th class="py-3">Vendor Shop</th>
                    <th class="py-3">Category</th>
                    <th class="py-3">Today's Price</th>
                    <th class="py-3">Unit</th>
                    <th class="py-3">Status</th>
                    <th class="py-3 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($products as $product)
                    <tr>
                        <td>
                            @if($product->image)
                                <img src="{{ asset('storage/' . $product->image) }}" alt="{{ $product->name }}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;">
                            @else
                                <div class="bg-light text-center text-muted" style="width: 50px; height: 50px; line-height: 50px; border-radius: 8px;">
                                    <i class="bi bi-image"></i>
                                </div>
                            @endif
                        </td>
                        <td class="fw-bold">{{ $product->name }}</td>
                        <td>{{ $product->vendor->shop_name }}</td>
                        <td>{{ $product->category->name }}</td>
                        <td class="text-success fw-bold">₹{{ number_format($product->today_price, 2) }}</td>
                        <td>{{ $product->unit }}</td>
                        <td>
                            <span class="badge badge-{{ $product->status }} text-uppercase">
                                {{ $product->status }}
                            </span>
                        </td>
                        <td class="text-center text-nowrap">
                            <a href="{{ route('admin.products.edit', $product->id) }}" class="btn btn-sm btn-outline-primary-custom me-2">
                                <i class="bi bi-pencil"></i> Edit
                            </a>
                            <form action="{{ route('admin.products.destroy', $product->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this product?');">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                    <i class="bi bi-trash"></i> Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8" class="text-center py-4 text-muted">
                            No products found. Select a vendor or click "Add Product" to add.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

@push('scripts')
<script>
    $(document).ready(function() {
        $('#products-table').DataTable({
            "order": [[ 1, "asc" ]], // Sort by name by default
            "pageLength": 10,
            "columnDefs": [
                { "orderable": false, "targets": [0, 7] } // Disable sorting on Image and Actions
            ]
        });
    });
</script>
@endpush
@endsection
