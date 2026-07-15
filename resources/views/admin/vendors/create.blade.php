@extends('layouts.admin')

@section('title', 'Add Vendor')
@section('page_title', 'Register Vendor')

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card card-custom bg-white p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="m-0 fw-bold"><i class="bi bi-plus-circle text-success me-2"></i>Register New Vendor</h5>
                <a href="{{ route('admin.vendors.index') }}" class="btn btn-outline-secondary btn-sm">Back</a>
            </div>

            @if ($errors->any())
                <div class="alert alert-danger border-0 small">
                    <ul class="mb-0 ps-3">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form action="{{ route('admin.vendors.store') }}" method="POST" enctype="multipart/form-data">
                @csrf

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="shop_name" class="form-label fw-bold">Shop Name</label>
                        <input type="text" class="form-control" id="shop_name" name="shop_name" value="{{ old('shop_name') }}" placeholder="e.g. Sardar Vegetable Store" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="owner_name" class="form-label fw-bold">Owner Name</label>
                        <input type="text" class="form-control" id="owner_name" name="owner_name" value="{{ old('owner_name') }}" placeholder="e.g. Rameshbhai Patel" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="mobile_number" class="form-label fw-bold">Mobile Number</label>
                        <input type="text" class="form-control" id="mobile_number" name="mobile_number" value="{{ old('mobile_number') }}" placeholder="e.g. 9876543210" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="password" class="form-label fw-bold">Login Password</label>
                        <input type="password" class="form-control" id="password" name="password" placeholder="Set password for Vendor" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="category_id" class="form-label fw-bold">Shop Category (Sets Default Products)</label>
                        <select class="form-select" id="category_id" name="category_id" required>
                            <option value="">-- Select Category --</option>
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}" {{ old('category_id') == $category->id ? 'selected' : '' }}>
                                    {{ $category->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label fw-bold">Status</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="active" {{ old('status', 'active') == 'active' ? 'selected' : '' }}>Active</option>
                            <option value="inactive" {{ old('status') == 'inactive' ? 'selected' : '' }}>Inactive</option>
                        </select>
                    </div>
                </div>

                @php
                    $oldOpening = old('opening_time', '06:00 AM');
                    $openingParts = explode(' ', $oldOpening);
                    $openingTimeParts = explode(':', $openingParts[0] ?? '06:00');
                    $openingHr = $openingTimeParts[0] ?? '06';
                    $openingMin = $openingTimeParts[1] ?? '00';
                    $openingAmPm = $openingParts[1] ?? 'AM';

                    $oldClosing = old('closing_time', '08:00 PM');
                    $closingParts = explode(' ', $oldClosing);
                    $closingTimeParts = explode(':', $closingParts[0] ?? '08:00');
                    $closingHr = $closingTimeParts[0] ?? '08';
                    $closingMin = $closingTimeParts[1] ?? '00';
                    $closingAmPm = $closingParts[1] ?? 'PM';
                @endphp

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Opening Time</label>
                        <div class="d-flex gap-2">
                            <select id="opening_hour" class="form-select" style="width: auto;" onchange="updateOpeningTime()">
                                @for($i = 1; $i <= 12; $i++)
                                    @php $val = sprintf('%02d', $i); @endphp
                                    <option value="{{ $val }}" {{ $openingHr == $val ? 'selected' : '' }}>{{ $val }}</option>
                                @endfor
                            </select>
                            <span class="align-self-center fw-bold">:</span>
                            <select id="opening_minute" class="form-select" style="width: auto;" onchange="updateOpeningTime()">
                                @for($i = 0; $i < 60; $i += 5)
                                    @php $val = sprintf('%02d', $i); @endphp
                                    <option value="{{ $val }}" {{ $openingMin == $val ? 'selected' : '' }}>{{ $val }}</option>
                                @endfor
                            </select>
                            <select id="opening_ampm" class="form-select" style="width: auto;" onchange="updateOpeningTime()">
                                <option value="AM" {{ $openingAmPm == 'AM' ? 'selected' : '' }}>AM</option>
                                <option value="PM" {{ $openingAmPm == 'PM' ? 'selected' : '' }}>PM</option>
                            </select>
                        </div>
                        <input type="hidden" id="opening_time" name="opening_time" value="{{ $oldOpening }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Closing Time</label>
                        <div class="d-flex gap-2">
                            <select id="closing_hour" class="form-select" style="width: auto;" onchange="updateClosingTime()">
                                @for($i = 1; $i <= 12; $i++)
                                    @php $val = sprintf('%02d', $i); @endphp
                                    <option value="{{ $val }}" {{ $closingHr == $val ? 'selected' : '' }}>{{ $val }}</option>
                                @endfor
                            </select>
                            <span class="align-self-center fw-bold">:</span>
                            <select id="closing_minute" class="form-select" style="width: auto;" onchange="updateClosingTime()">
                                @for($i = 0; $i < 60; $i += 5)
                                    @php $val = sprintf('%02d', $i); @endphp
                                    <option value="{{ $val }}" {{ $closingMin == $val ? 'selected' : '' }}>{{ $val }}</option>
                                @endfor
                            </select>
                            <select id="closing_ampm" class="form-select" style="width: auto;" onchange="updateClosingTime()">
                                <option value="AM" {{ $closingAmPm == 'AM' ? 'selected' : '' }}>AM</option>
                                <option value="PM" {{ $closingAmPm == 'PM' ? 'selected' : '' }}>PM</option>
                            </select>
                        </div>
                        <input type="hidden" id="closing_time" name="closing_time" value="{{ $oldClosing }}">
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12 mb-3">
                        <div class="form-check form-switch card p-3 shadow-sm border-0 d-flex flex-row align-items-center gap-3">
                            <input class="form-check-input ms-0 mt-0" type="checkbox" id="is_closed" name="is_closed" value="1" {{ old('is_closed') ? 'checked' : '' }} style="width: 2.5em; height: 1.25em;">
                            <div>
                                <label class="form-check-label fw-bold" for="is_closed" style="cursor: pointer;">Today Shop Closed</label>
                                <div class="form-text text-muted small mt-0">If checked, this shop will be shown as closed immediately to customers, overriding default operating hours.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="shop_address" class="form-label fw-bold">Shop Address</label>
                    <textarea class="form-control" id="shop_address" name="shop_address" rows="3" placeholder="e.g. Gundawadi Main Road, Rajkot" required>{{ old('shop_address') }}</textarea>
                </div>

                <div class="mb-4">
                    <label for="shop_photo" class="form-label fw-bold">Shop Photo</label>
                    <input type="file" class="form-control" id="shop_photo" name="shop_photo" accept="image/*">
                    <small class="text-muted">Allowed types: jpeg, png, jpg, webp. Max size: 2MB.</small>
                </div>

                <button type="submit" class="btn btn-primary-custom w-100">Save Vendor</button>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function updateOpeningTime() {
    const hr = document.getElementById('opening_hour').value;
    const min = document.getElementById('opening_minute').value;
    const ampm = document.getElementById('opening_ampm').value;
    document.getElementById('opening_time').value = `${hr}:${min} ${ampm}`;
}
function updateClosingTime() {
    const hr = document.getElementById('closing_hour').value;
    const min = document.getElementById('closing_minute').value;
    const ampm = document.getElementById('closing_ampm').value;
    document.getElementById('closing_time').value = `${hr}:${min} ${ampm}`;
}
</script>
@endpush
