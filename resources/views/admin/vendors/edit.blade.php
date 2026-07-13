@extends('layouts.admin')

@section('title', 'Edit Vendor')
@section('page_title', 'Update Vendor')

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card card-custom bg-white p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="m-0 fw-bold"><i class="bi bi-pencil-square text-success me-2"></i>Edit Vendor #{{ $vendor->id }}</h5>
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

            <form action="{{ route('admin.vendors.update', $vendor->id) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="shop_name" class="form-label fw-bold">Shop Name</label>
                        <input type="text" class="form-control" id="shop_name" name="shop_name" value="{{ old('shop_name', $vendor->shop_name) }}" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="owner_name" class="form-label fw-bold">Owner Name</label>
                        <input type="text" class="form-control" id="owner_name" name="owner_name" value="{{ old('owner_name', $vendor->owner_name) }}" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="mobile_number" class="form-label fw-bold">Mobile Number</label>
                        <input type="text" class="form-control" id="mobile_number" name="mobile_number" value="{{ old('mobile_number', $vendor->mobile_number) }}" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="password" class="form-label fw-bold">Login Password (Leave blank to keep current)</label>
                        <input type="password" class="form-control" id="password" name="password" placeholder="New password">
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="category_id" class="form-label fw-bold">Shop Category</label>
                        <select class="form-select" id="category_id" name="category_id" required>
                            <option value="">-- Select Category --</option>
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}" {{ old('category_id', $vendor->category_id) == $category->id ? 'selected' : '' }}>
                                    {{ $category->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label fw-bold">Status</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="active" {{ old('status', $vendor->status) == 'active' ? 'selected' : '' }}>Active</option>
                            <option value="inactive" {{ old('status', $vendor->status) == 'inactive' ? 'selected' : '' }}>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="opening_time" class="form-label fw-bold">Opening Time</label>
                        <input type="text" class="form-control" id="opening_time" name="opening_time" value="{{ old('opening_time', $vendor->opening_time) }}" placeholder="e.g. 06:00 AM" required>
                        <div class="form-text text-muted small">Format: hh:mm AM/PM (e.g. 07:30 AM)</div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="closing_time" class="form-label fw-bold">Closing Time</label>
                        <input type="text" class="form-control" id="closing_time" name="closing_time" value="{{ old('closing_time', $vendor->closing_time) }}" placeholder="e.g. 08:00 PM" required>
                        <div class="form-text text-muted small">Format: hh:mm AM/PM (e.g. 09:00 PM)</div>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="shop_address" class="form-label fw-bold">Shop Address</label>
                    <textarea class="form-control" id="shop_address" name="shop_address" rows="3" required>{{ old('shop_address', $vendor->shop_address) }}</textarea>
                </div>

                <div class="mb-4">
                    <label for="shop_photo" class="form-label fw-bold">Shop Photo</label>
                    @if($vendor->shop_photo)
                        <div class="mb-2">
                            <img src="{{ asset('storage/' . $vendor->shop_photo) }}" alt="{{ $vendor->shop_name }}" style="width: 120px; height: 120px; object-fit: cover; border-radius: 8px;">
                            <div class="text-muted small">Current Photo</div>
                        </div>
                    @endif
                    <input type="file" class="form-control" id="shop_photo" name="shop_photo" accept="image/*">
                    <small class="text-muted">Upload a new photo to replace the current one. Max size: 2MB.</small>
                </div>

                <button type="submit" class="btn btn-primary-custom w-100">Update Vendor</button>
            </form>
        </div>
    </div>
</div>
@endsection
