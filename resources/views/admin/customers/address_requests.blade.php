@extends('layouts.admin')

@section('title', 'Address Change Requests')
@section('page_title', 'Address Requests')

@section('content')
@if(session('success'))
    <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>{{ session('success') }}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
@endif

<div class="card card-custom bg-white p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="m-0 fw-bold"><i class="bi bi-geo-alt-fill text-success me-2"></i>Pending Address Change Requests</h5>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-light">
                <tr>
                    <th class="py-3">Customer</th>
                    <th class="py-3">Current Active Address</th>
                    <th class="py-3">New Requested Address</th>
                    <th class="py-3">Submitted On</th>
                    <th class="py-3 text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($requests as $req)
                    @php
                        // Get the currently active approved address
                        $oldAddress = $req->customer->addresses()->where('status', 'approved')->first();
                    @endphp
                    <tr>
                        <td>
                            <div class="fw-bold">{{ $req->customer->name }}</div>
                            <small class="text-muted">Mobile: {{ $req->customer->mobile }}</small><br>
                            <small class="text-muted">ID: #{{ $req->customer->id }}</small>
                        </td>
                        <td>
                            @if($oldAddress)
                                <div class="text-wrap small text-muted" style="max-width: 250px;">
                                    <strong>{{ $oldAddress->full_name }}</strong> ({{ $oldAddress->mobile }})<br>
                                    {{ $oldAddress->house_number }}, {{ $oldAddress->street }}, {{ $oldAddress->area }}, {{ $oldAddress->city }}<br>
                                    <strong>Current KM:</strong> {{ $req->customer->delivery_km }} km<br>
                                    <strong>Current Charge:</strong> ₹{{ number_format($req->customer->delivery_charge, 2) }}
                                </div>
                            @else
                                <span class="text-danger small fw-bold">No active approved address!</span>
                            @endif
                        </td>
                        <td>
                            <div class="text-wrap bg-light p-3 rounded small" style="max-width: 300px; border-left: 4px solid #198754;">
                                <strong>{{ $req->full_name }}</strong> ({{ $req->mobile }})<br>
                                {{ $req->house_number }}, {{ $req->street }}, {{ $req->area }}<br>
                                @if($req->landmark)<strong>Landmark:</strong> {{ $req->landmark }}<br>@endif
                                {{ $req->city }} - {{ $req->pincode }}
                            </div>
                        </td>
                        <td>{{ $req->created_at->format('Y-m-d H:i') }}</td>
                        <td class="text-end">
                            <div class="btn-group">
                                <button type="button" class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#approveModal{{ $req->id }}">
                                    Approve
                                </button>
                                <form action="{{ route('admin.customers.reject-address', $req->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to reject this address change?');" style="display:inline;">
                                    @csrf
                                    <button type="submit" class="btn btn-sm btn-danger">
                                        Reject
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="text-center py-5 text-muted">
                            <i class="bi bi-geo-alt fs-2 d-block mb-3 text-light"></i>
                            No pending address change requests.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Modals rendered outside of table rows to prevent trigger conflicts and DOM layout shifts -->
@foreach($requests as $req)
    <div class="modal fade" id="approveModal{{ $req->id }}" tabindex="-1" aria-labelledby="approveModalLabel{{ $req->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="{{ route('admin.customers.approve-address', $req->id) }}" method="POST">
                    @csrf
                    <div class="modal-header bg-success text-white">
                        <h6 class="modal-title" id="approveModalLabel{{ $req->id }}"><i class="bi bi-geo-alt me-2"></i>Verify New Address & Update Charges</h6>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-start">
                        <div class="mb-3 p-3 bg-light rounded">
                            <h6 class="fw-bold text-success mb-2 d-block small">Requested Address Detail:</h6>
                            <p class="mb-1 small"><strong>Recipient:</strong> {{ $req->full_name }} ({{ $req->mobile }})</p>
                            <p class="mb-0 small"><strong>Location:</strong> {{ $req->house_number }}, {{ $req->street }}, {{ $req->area }}, {{ $req->city }} - {{ $req->pincode }}</p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">New Delivery Distance (KM) *</label>
                            <input type="number" step="0.1" name="delivery_km" class="form-control" placeholder="e.g. 3.2" required min="0" value="{{ $req->customer->delivery_km }}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">New Delivery Charge (₹) *</label>
                            <input type="number" step="5" name="delivery_charge" class="form-control" placeholder="e.g. 35" required min="0" value="{{ $req->customer->delivery_charge }}">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success btn-sm">Approve Address Change</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endforeach

@endsection
