@extends('layouts.admin')

@section('title', 'Manage Vendors')
@section('page_title', 'Vendor Management')

@section('content')
<div class="card card-custom bg-white p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="m-0 fw-bold"><i class="bi bi-people text-success me-2"></i>Vendors List</h5>
        <a href="{{ route('admin.vendors.create') }}" class="btn btn-primary-custom">
            <i class="bi bi-plus-lg me-1"></i> Add Vendor
        </a>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle" id="vendors-table">
            <thead class="table-light">
                <tr>
                    <th class="py-3">Photo</th>
                    <th class="py-3">Shop Name</th>
                    <th class="py-3">Owner</th>
                    <th class="py-3">Category</th>
                    <th class="py-3">Mobile Number</th>
                    <th class="py-3">Address</th>
                    <th class="py-3">Status</th>
                    <th class="py-3 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($vendors as $vendor)
                    <tr>
                        <td>
                            @if($vendor->shop_photo)
                                <img src="{{ asset('storage/' . $vendor->shop_photo) }}" alt="{{ $vendor->shop_name }}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;">
                            @else
                                <div class="bg-light text-center text-muted" style="width: 50px; height: 50px; line-height: 50px; border-radius: 8px;">
                                    <i class="bi bi-shop"></i>
                                </div>
                            @endif
                        </td>
                        <td class="fw-bold">{{ $vendor->shop_name }}</td>
                        <td>{{ $vendor->owner_name }}</td>
                        <td>
                            <span class="badge bg-success-subtle text-success fw-bold text-uppercase border border-success">
                                {{ $vendor->category->name ?? 'N/A' }}
                            </span>
                        </td>
                        <td>{{ $vendor->mobile_number }}</td>
                        <td style="max-width: 200px; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                            {{ $vendor->shop_address }}
                        </td>
                        <td>
                            <span class="badge badge-{{ $vendor->status }} text-uppercase">
                                {{ $vendor->status }}
                            </span>
                            @if($vendor->is_closed)
                                <div class="mt-1">
                                    <span class="badge bg-danger text-uppercase fw-bold" style="font-size: 0.75rem;">Closed Today</span>
                                </div>
                            @endif
                        </td>
                        <td class="text-center text-nowrap">
                            <a href="{{ route('admin.products.index', ['vendor_id' => $vendor->id]) }}" class="btn btn-sm btn-outline-info me-2" title="Manage Products">
                                <i class="bi bi-basket"></i> Products
                            </a>
                            <a href="{{ route('admin.vendors.edit', $vendor->id) }}" class="btn btn-sm btn-outline-primary-custom me-2">
                                <i class="bi bi-pencil"></i> Edit
                            </a>
                            <form action="{{ route('admin.vendors.destroy', $vendor->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this vendor? This will delete all products and orders related to this vendor!');">
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
                            No vendors registered yet.
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
        $('#vendors-table').DataTable({
            "order": [[ 1, "asc" ]], // Sort by Shop Name by default
            "pageLength": 10,
            "columnDefs": [
                { "orderable": false, "targets": [0, 7] } // Disable sorting on Photo and Actions
            ]
        });
    });
</script>
@endpush
@endsection
