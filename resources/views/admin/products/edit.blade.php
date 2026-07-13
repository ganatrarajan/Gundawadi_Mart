@extends('layouts.admin')

@section('title', 'Edit Product')
@section('page_title', 'Update Product')

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card card-custom bg-white p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="m-0 fw-bold"><i class="bi bi-pencil-square text-success me-2"></i>Edit Product #{{ $product->id }}</h5>
                <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary btn-sm">Back</a>
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

            <form action="{{ route('admin.products.update', $product->id) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="vendor_id" class="form-label fw-bold">Select Vendor</label>
                        <select class="form-select" id="vendor_id" name="vendor_id" required>
                            @foreach($vendors as $vendor)
                                <option value="{{ $vendor->id }}" {{ old('vendor_id', $product->vendor_id) == $vendor->id ? 'selected' : '' }}>
                                    {{ $vendor->shop_name }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="category_id" class="form-label fw-bold">Select Category</label>
                        <select class="form-select" id="category_id" name="category_id" required>
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}" {{ old('category_id', $product->category_id) == $category->id ? 'selected' : '' }}>
                                    {{ $category->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="name" class="form-label fw-bold">Product Name</label>
                        <input type="text" class="form-control" id="name" name="name" value="{{ old('name', $product->name) }}" required>
                    </div>

                    <div class="col-md-3 mb-3">
                        <label for="today_price" class="form-label fw-bold">Today's Price (₹)</label>
                        <input type="number" step="0.01" class="form-control" id="today_price" name="today_price" value="{{ old('today_price', $product->today_price) }}" required>
                    </div>

                    <div class="col-md-3 mb-3">
                        <label for="unit_select" class="form-label fw-bold">Unit</label>
                        <select class="form-select mb-2" id="unit_select">
                            <option value="1kg">1kg</option>
                            <option value="500g">500g</option>
                            <option value="250g">250g</option>
                            <option value="1 piece">1 piece</option>
                            <option value="1 bunch">1 bunch</option>
                            <option value="1 packet">1 packet</option>
                            <option value="custom">Custom...</option>
                        </select>
                        <input type="text" class="form-control" id="unit" name="unit" value="{{ old('unit', $product->unit) }}" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label fw-bold">Status</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="active" {{ old('status', $product->status) == 'active' ? 'selected' : '' }}>Active</option>
                            <option value="inactive" {{ old('status', $product->status) == 'inactive' ? 'selected' : '' }}>Inactive</option>
                        </select>
                    </div>

                    <div class="col-md-6 mb-4">
                        <label for="image" class="form-label fw-bold">Product Image</label>
                        @if($product->image)
                            <div class="mb-2">
                                <img src="{{ asset('storage/' . $product->image) }}" alt="{{ $product->name }}" style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px;">
                                <div class="text-muted small">Current Image</div>
                            </div>
                        @endif
                        <input type="file" class="form-control" id="image" name="image" accept="image/*">
                        <small class="text-muted">Upload a new image to replace the current one. Max size: 2MB.</small>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary-custom w-100">Update Product</button>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const unitSelect = document.getElementById('unit_select');
    const unitInput = document.getElementById('unit');

    function updateUnitFields() {
        const val = unitSelect.value;
        if (val === 'custom') {
            unitInput.style.display = 'block';
            unitInput.required = true;
            if (['1kg', '500g', '250g', '1 piece', '1 bunch', '1 packet'].includes(unitInput.value)) {
                unitInput.value = '';
            }
        } else {
            unitInput.style.display = 'none';
            unitInput.value = val;
            unitInput.required = false;
        }
    }

    const initialVal = unitInput.value;
    if (['1kg', '500g', '250g', '1 piece', '1 bunch', '1 packet'].includes(initialVal)) {
        unitSelect.value = initialVal;
    } else if (initialVal) {
        unitSelect.value = 'custom';
    } else {
        unitSelect.value = '1kg';
    }
    updateUnitFields();

    unitSelect.addEventListener('change', updateUnitFields);
});
</script>
@endsection
