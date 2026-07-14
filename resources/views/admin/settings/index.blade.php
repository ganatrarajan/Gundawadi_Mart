@extends('layouts.admin')

@section('title', 'System Settings')
@section('page_title', 'System Settings')

@section('content')
<div class="row justify-content-center">
    <div class="col-md-8">
        <div class="card card-custom bg-white p-4">
            <h5 class="fw-bold mb-4">
                <i class="bi bi-gear text-success me-2"></i>Edit Global Billing Settings
            </h5>
            
            <form action="{{ route('admin.settings.update') }}" method="POST">
                @csrf
                
                <!-- Platform Fee -->
                <div class="card p-3 mb-4 border border-light shadow-sm">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <label for="platform_fee" class="form-label fw-bold">Platform Fee (₹)</label>
                            <div class="form-text text-muted mb-2">Dynamic fee applied globally to all transactions.</div>
                        </div>
                        <div class="col-md-4">
                            <input type="number" step="0.01" min="0" class="form-control @error('platform_fee') is-invalid @enderror" id="platform_fee" name="platform_fee" value="{{ old('platform_fee', $platformFee) }}" required>
                            @error('platform_fee')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>
                    <hr class="my-3 text-muted">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <label for="show_platform_fee" class="form-label fw-bold">Enable Platform Fee billing line</label>
                            <div class="form-text text-muted mb-2">Turn off to completely hide Platform Fee from customers.</div>
                        </div>
                        <div class="col-md-4">
                            <select class="form-select" id="show_platform_fee" name="show_platform_fee" required>
                                <option value="yes" {{ old('show_platform_fee', $showPlatformFee) === 'yes' ? 'selected' : '' }}>Show (Yes)</option>
                                <option value="no" {{ old('show_platform_fee', $showPlatformFee) === 'no' ? 'selected' : '' }}>Hide (No)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Handling Charge -->
                <div class="card p-3 mb-4 border border-light shadow-sm">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <label for="handling_charge" class="form-label fw-bold">Handling Charge (₹)</label>
                            <div class="form-text text-muted mb-2">Packing and handling fee added to orders.</div>
                        </div>
                        <div class="col-md-4">
                            <input type="number" step="0.01" min="0" class="form-control @error('handling_charge') is-invalid @enderror" id="handling_charge" name="handling_charge" value="{{ old('handling_charge', $handlingCharge) }}" required>
                            @error('handling_charge')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>
                    <hr class="my-3 text-muted">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <label for="show_handling_charge" class="form-label fw-bold">Enable Handling Charge billing line</label>
                            <div class="form-text text-muted mb-2">Turn off to completely hide Handling Charges from customers.</div>
                        </div>
                        <div class="col-md-4">
                            <select class="form-select" id="show_handling_charge" name="show_handling_charge" required>
                                <option value="yes" {{ old('show_handling_charge', $showHandlingCharge) === 'yes' ? 'selected' : '' }}>Show (Yes)</option>
                                <option value="no" {{ old('show_handling_charge', $showHandlingCharge) === 'no' ? 'selected' : '' }}>Hide (No)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Accept Same-Day Orders -->
                <div class="card p-3 mb-4 border border-light shadow-sm">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <label for="allow_today_delivery" class="form-label fw-bold">Accept Same-Day (Today's) Orders</label>
                            <div class="form-text text-muted mb-2">Turn off to completely disable delivery options for "Today" (only "Tomorrow" delivery slots will be available).</div>
                        </div>
                        <div class="col-md-4">
                            <select class="form-select" id="allow_today_delivery" name="allow_today_delivery" required>
                                <option value="yes" {{ old('allow_today_delivery', $allowTodayDelivery) === 'yes' ? 'selected' : '' }}>Enabled (Yes)</option>
                                <option value="no" {{ old('allow_today_delivery', $allowTodayDelivery) === 'no' ? 'selected' : '' }}>Disabled (No)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Support Contact Details -->
                <div class="card p-3 mb-4 border border-light shadow-sm">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="support_name" class="form-label fw-bold">Support Contact Name</label>
                            <input type="text" class="form-control" id="support_name" name="support_name" value="{{ old('support_name', $supportName) }}" required>
                        </div>
                        <div class="col-md-6">
                            <label for="support_mobile" class="form-label fw-bold">Support Contact Mobile</label>
                            <input type="text" class="form-control" id="support_mobile" name="support_mobile" value="{{ old('support_mobile', $supportMobile) }}" required>
                        </div>
                    </div>
                </div>

                <!-- Actions -->
                <div class="text-end mt-4">
                    <button type="submit" class="btn btn-primary-custom px-4 py-2">
                        <i class="bi bi-save me-1"></i> Save Config Settings
                    </button>
                </div>
            </form>
        </div>

        <!-- Delivery Slots Manager Card -->
        <div class="card card-custom bg-white p-4 mt-4">
            <h5 class="fw-bold mb-4">
                <i class="bi bi-clock text-success me-2"></i>Delivery Time Slots Manager
            </h5>

            <div class="row g-4">
                <!-- Add New Slot Form -->
                <div class="col-md-5 border-end pe-4">
                    <h6 class="fw-bold mb-3 text-secondary small text-uppercase">Add Time Slot</h6>
                    <form action="{{ route('admin.settings.storeSlot') }}" method="POST">
                        @csrf
                        <div class="mb-3">
                            <label for="start_time" class="form-label fw-bold">Start Time</label>
                            <input type="text" class="form-control" id="start_time" name="start_time" placeholder="e.g. 09:00 AM" required>
                            <div class="form-text small text-muted" style="font-size: 0.75rem;">Format: hh:mm AM/PM (e.g. 09:00 AM)</div>
                        </div>
                        <div class="mb-3">
                            <label for="end_time" class="form-label fw-bold">End Time</label>
                            <input type="text" class="form-control" id="end_time" name="end_time" placeholder="e.g. 12:00 PM" required>
                            <div class="form-text small text-muted" style="font-size: 0.75rem;">Format: hh:mm AM/PM (e.g. 12:00 PM)</div>
                        </div>
                        <div class="mb-3 form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="is_active" name="is_active" value="1" checked>
                            <label class="form-check-label fw-bold text-secondary" for="is_active">Active (Show to customers)</label>
                        </div>
                        <button type="submit" class="btn btn-success btn-sm w-100 fw-bold py-2">
                            <i class="bi bi-plus-lg me-1"></i> Add Time Slot
                        </button>
                    </form>
                </div>

                <!-- Existing Slots List -->
                <div class="col-md-7 ps-4">
                    <h6 class="fw-bold mb-3 text-secondary small text-uppercase">Configured Slots</h6>
                    <div class="table-responsive">
                        <table class="table table-sm table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Slot Range</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($deliverySlots as $slot)
                                    <tr>
                                        <td class="fw-bold text-dark">
                                            <i class="bi bi-clock me-2 text-success"></i>{{ $slot->start_time }} - {{ $slot->end_time }}
                                        </td>
                                        <td class="text-center">
                                            <form action="{{ route('admin.settings.toggleSlot', $slot->id) }}" method="POST">
                                                @csrf
                                                <button type="submit" class="btn btn-sm btn-{{ $slot->is_active ? 'success' : 'secondary' }} rounded-pill px-3 py-0" style="font-size: 0.75rem;">
                                                    {{ $slot->is_active ? 'Active' : 'Inactive' }}
                                                </button>
                                            </form>
                                        </td>
                                        <td class="text-center">
                                            <form action="{{ route('admin.settings.deleteSlot', $slot->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this delivery slot?');">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-outline-danger border-0">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="3" class="text-center py-3 text-muted small">No delivery slots configured yet.</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
