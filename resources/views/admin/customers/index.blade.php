@extends('layouts.admin')

@section('title', 'Manage Customers')
@section('page_title', 'Customer Management')

@section('content')
@if(session('success'))
    <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>{{ session('success') }}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
@endif

<div class="card card-custom bg-white p-4">
    <!-- Filters Header -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
        <h5 class="m-0 fw-bold"><i class="bi bi-person-circle text-success me-2"></i>Customers List</h5>
        
        <!-- Status Filter Tabs -->
        <div class="btn-group" role="group">
            <a href="{{ route('admin.customers.index') }}" class="btn btn-outline-success btn-sm {{ !request('status') ? 'active' : '' }}">
                All
            </a>
            <a href="{{ route('admin.customers.index', ['status' => 'pending_approval']) }}" class="btn btn-outline-success btn-sm {{ request('status') === 'pending_approval' ? 'active' : '' }}">
                Pending Approval 
                @php $pendingCount = \App\Models\Customer::where('status', 'pending_approval')->count(); @endphp
                @if($pendingCount > 0)
                    <span class="badge bg-warning text-dark ms-1">{{ $pendingCount }}</span>
                @endif
            </a>
            <a href="{{ route('admin.customers.index', ['status' => 'approved']) }}" class="btn btn-outline-success btn-sm {{ request('status') === 'approved' ? 'active' : '' }}">
                Approved
            </a>
            <a href="{{ route('admin.customers.index', ['status' => 'rejected']) }}" class="btn btn-outline-success btn-sm {{ request('status') === 'rejected' ? 'active' : '' }}">
                Rejected
            </a>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-light">
                <tr>
                    <th class="py-3">Customer</th>
                    <th class="py-3">Mobile</th>
                    <th class="py-3">Address</th>
                    <th class="py-3">Delivery Configs</th>
                    <th class="py-3">Total Orders</th>
                    <th class="py-3">Registered On</th>
                    <th class="py-3">Status</th>
                    <th class="py-3 text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($customers as $customer)
                    @php
                        // Get the pending address first, if not found then the approved address
                        $address = $customer->addresses()->where('status', 'pending')->first() 
                                   ?? $customer->addresses()->where('status', 'approved')->first();
                    @endphp
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                @if($customer->profile_photo)
                                    <img src="{{ url('storage/' . $customer->profile_photo) }}" alt="Profile" class="rounded-circle me-2" style="width: 40px; height: 40px; object-fit: cover;">
                                @else
                                    <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-2 text-success" style="width: 40px; height: 40px;">
                                        <i class="bi bi-person-fill fs-5"></i>
                                    </div>
                                @endif
                                <div>
                                    <div class="fw-bold">{{ $customer->name ?? 'New Registration' }}</div>
                                    <small class="text-muted">ID: #{{ $customer->id }}</small>
                                </div>
                            </div>
                        </td>
                        <td>{{ $customer->mobile }}</td>
                        <td>
                            @if($address)
                                <div class="text-wrap" style="max-width: 250px;">
                                    <strong>{{ $address->full_name }}</strong><br>
                                    <small class="text-muted">
                                        {{ $address->house_number }}, {{ $address->street }}, {{ $address->area }}<br>
                                        {{ $address->landmark ? 'Near ' . $address->landmark . ', ' : '' }}{{ $address->city }} - {{ $address->pincode }}
                                    </small>
                                </div>
                            @else
                                <span class="text-muted small">No address submitted</span>
                            @endif
                        </td>
                        <td>
                            @if($customer->status === 'approved')
                                <div class="small">
                                    <strong>KM:</strong> {{ $customer->delivery_km }} km<br>
                                    <strong>Charge:</strong> ₹{{ number_format($customer->delivery_charge, 2) }}
                                </div>
                            @elseif($customer->status === 'pending_approval')
                                <span class="text-warning small fw-bold">Pending Review</span>
                            @else
                                <span class="text-muted small">N/A</span>
                            @endif
                        </td>
                        <td class="fw-bold text-success">{{ $customer->orders_count }} Orders</td>
                        <td>{{ $customer->created_at->format('Y-m-d H:i') }}</td>
                        <td>
                            @if($customer->status === 'approved')
                                <span class="badge bg-success">Approved</span>
                            @elseif($customer->status === 'pending_approval')
                                <span class="badge bg-warning text-dark">Pending Approval</span>
                            @elseif($customer->status === 'rejected')
                                <span class="badge bg-danger" data-bs-toggle="tooltip" title="Reason: {{ $customer->rejection_reason }}">Rejected</span>
                                <div class="small text-danger text-wrap mt-1" style="max-width: 150px; font-size: 11px;">
                                    <strong>Reason:</strong> {{ $customer->rejection_reason }}
                                </div>
                            @else
                                <span class="badge bg-secondary">{{ $customer->status }}</span>
                            @endif
                        </td>
                        <td class="text-end text-nowrap">
                            @if($customer->status === 'pending_approval')
                                <div class="btn-group me-2">
                                    <button type="button" class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#approveModal{{ $customer->id }}" title="Approve Customer">
                                        Approve
                                    </button>
                                    <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#rejectModal{{ $customer->id }}" title="Reject Customer">
                                        Reject
                                    </button>
                                </div>
                            @endif
                            <div class="btn-group">
                                <button type="button" class="btn btn-sm btn-outline-primary-custom" data-bs-toggle="modal" data-bs-target="#editConfigModal{{ $customer->id }}" title="Edit Config & Distance">
                                    <i class="bi bi-pencil"></i> Edit
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-warning text-dark" data-bs-toggle="modal" data-bs-target="#resetPasswordModal{{ $customer->id }}" title="Reset Password">
                                    <i class="bi bi-key"></i> Pass
                                </button>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8" class="text-center py-4 text-muted">
                            No customers found for this status.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Modals rendered outside of table rows to prevent trigger conflicts and DOM layout shifts -->
@foreach($customers as $customer)
    @if($customer->status === 'pending_approval')
        @php
            $address = $customer->addresses()->where('status', 'pending')->first() 
                       ?? $customer->addresses()->where('status', 'approved')->first();
        @endphp
        <!-- Approve Modal -->
        <div class="modal fade" id="approveModal{{ $customer->id }}" tabindex="-1" aria-labelledby="approveModalLabel{{ $customer->id }}" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <form action="{{ route('admin.customers.approve', $customer->id) }}" method="POST">
                        @csrf
                        <div class="modal-header bg-success text-white">
                            <h6 class="modal-title" id="approveModalLabel{{ $customer->id }}"><i class="bi bi-shield-check me-2"></i>Verify & Approve Customer Address</h6>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            @if($address)
                                <div class="mb-3 p-3 bg-light rounded">
                                    <h6 class="fw-bold text-success mb-2 d-block small">Submitted Address Detail:</h6>
                                    <p class="mb-1 small"><strong>Recipient:</strong> {{ $address->full_name }} ({{ $address->mobile }})</p>
                                    <p class="mb-0 small"><strong>Location:</strong> {{ $address->house_number }}, {{ $address->street }}, {{ $address->area }}, {{ $address->city }} - {{ $address->pincode }}</p>
                                </div>
                            @endif
                            <div class="mb-3">
                                <label class="form-label fw-bold">Delivery Distance (KM) *</label>
                                <input type="number" step="0.1" name="delivery_km" class="form-control" placeholder="e.g. 2.5" required min="0">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Delivery Charge (₹) *</label>
                                <input type="number" step="5" name="delivery_charge" class="form-control" placeholder="e.g. 30" required min="0">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-success btn-sm">Approve Customer</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Reject Modal -->
        <div class="modal fade" id="rejectModal{{ $customer->id }}" tabindex="-1" aria-labelledby="rejectModalLabel{{ $customer->id }}" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <form action="{{ route('admin.customers.reject', $customer->id) }}" method="POST">
                        @csrf
                        <div class="modal-header bg-danger text-white">
                            <h6 class="modal-title" id="rejectModalLabel{{ $customer->id }}"><i class="bi bi-shield-x me-2"></i>Reject Customer Registration</h6>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Rejection Reason *</label>
                                <textarea name="rejection_reason" class="form-control" rows="3" placeholder="Explain why the registration was rejected..." required></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-danger btn-sm">Reject Customer</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    @endif

    <!-- Edit Config Modal -->
    <div class="modal fade" id="editConfigModal{{ $customer->id }}" tabindex="-1" aria-labelledby="editConfigModalLabel{{ $customer->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="{{ route('admin.customers.update-config', $customer->id) }}" method="POST">
                    @csrf
                    <div class="modal-header bg-primary text-white">
                        <h6 class="modal-title" id="editConfigModalLabel{{ $customer->id }}"><i class="bi bi-pencil-square me-2"></i>Edit Customer Settings</h6>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-start">
                        <div class="mb-3">
                            <label for="status_{{ $customer->id }}" class="form-label fw-bold">Account Status</label>
                            <select class="form-select" id="status_{{ $customer->id }}" name="status" onchange="toggleStatusFields({{ $customer->id }}, this.value)" required>
                                <option value="pending_approval" {{ $customer->status === 'pending_approval' ? 'selected' : '' }}>PENDING APPROVAL</option>
                                <option value="approved" {{ $customer->status === 'approved' ? 'selected' : '' }}>APPROVED</option>
                                <option value="rejected" {{ $customer->status === 'rejected' ? 'selected' : '' }}>REJECTED</option>
                            </select>
                        </div>
                        
                        <!-- Fields for Approved status -->
                        <div id="approved_fields_{{ $customer->id }}" style="display: {{ $customer->status === 'approved' ? 'block' : 'none' }};">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Delivery Distance (KM)</label>
                                <input type="number" step="0.1" name="delivery_km" class="form-control" value="{{ $customer->delivery_km }}" placeholder="e.g. 2.5" min="0">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Delivery Charge (₹)</label>
                                <input type="number" step="5" name="delivery_charge" class="form-control" value="{{ $customer->delivery_charge }}" placeholder="e.g. 30" min="0">
                            </div>
                        </div>
                        
                        <!-- Fields for Rejected status -->
                        <div id="rejected_fields_{{ $customer->id }}" style="display: {{ $customer->status === 'rejected' ? 'block' : 'none' }};">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Rejection Reason</label>
                                <textarea name="rejection_reason" class="form-control" rows="3" placeholder="Explain why the registration was rejected...">{{ $customer->rejection_reason }}</textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Reset Password Modal -->
    <div class="modal fade" id="resetPasswordModal{{ $customer->id }}" tabindex="-1" aria-labelledby="resetPasswordModalLabel{{ $customer->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="{{ route('admin.customers.reset-password', $customer->id) }}" method="POST">
                    @csrf
                    <div class="modal-header bg-warning text-dark">
                        <h6 class="modal-title" id="resetPasswordModalLabel{{ $customer->id }}"><i class="bi bi-key me-2"></i>Reset Customer Password</h6>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-start">
                        <div class="mb-3">
                            <label class="form-label fw-bold">New Password</label>
                            <input type="password" name="password" class="form-control" placeholder="Enter new password (min 6 chars)" required minlength="6">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-warning btn-sm fw-bold">Reset Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endforeach

@push('scripts')
<script>
    function toggleStatusFields(customerId, status) {
        const approvedDiv = document.getElementById('approved_fields_' + customerId);
        const rejectedDiv = document.getElementById('rejected_fields_' + customerId);
        
        if (status === 'approved') {
            approvedDiv.style.display = 'block';
            rejectedDiv.style.display = 'none';
        } else if (status === 'rejected') {
            approvedDiv.style.display = 'none';
            rejectedDiv.style.display = 'block';
        } else {
            approvedDiv.style.display = 'none';
            approvedDiv.querySelector('input[name="delivery_km"]').value = '';
            approvedDiv.querySelector('input[name="delivery_charge"]').value = '';
            rejectedDiv.style.display = 'none';
            rejectedDiv.querySelector('textarea[name="rejection_reason"]').value = '';
        }
    }
</script>
@endpush

@endsection
