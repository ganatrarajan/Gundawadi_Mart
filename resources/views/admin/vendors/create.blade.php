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

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="opening_time" class="form-label fw-bold">Opening Time</label>
                        <input type="text" class="form-control" id="opening_time" name="opening_time" value="{{ old('opening_time', '06:00 AM') }}" placeholder="e.g. 06:00 AM" required>
                        <div class="form-text text-muted small">Format: hh:mm AM/PM (e.g. 07:30 AM)</div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="closing_time" class="form-label fw-bold">Closing Time</label>
                        <input type="text" class="form-control" id="closing_time" name="closing_time" value="{{ old('closing_time', '08:00 PM') }}" placeholder="e.g. 08:00 PM" required>
                        <div class="form-text text-muted small">Format: hh:mm AM/PM (e.g. 09:00 PM)</div>
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
