@extends('layouts.admin')

@section('title', 'Edit Category')
@section('page_title', 'Update Category')

@section('content')
<div class="row">
    <div class="col-md-6">
        <div class="card card-custom bg-white p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="m-0 fw-bold"><i class="bi bi-pencil-square text-success me-2"></i>Edit Category #{{ $category->id }}</h5>
                <a href="{{ route('admin.categories.index') }}" class="btn btn-outline-secondary btn-sm">Back</a>
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

            <form action="{{ route('admin.categories.update', $category->id) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')

                <div class="mb-3">
                    <label for="name" class="form-label fw-bold">Category Name</label>
                    <input type="text" class="form-control" id="name" name="name" value="{{ old('name', $category->name) }}" required>
                </div>

                <div class="mb-3">
                    <label for="status" class="form-label fw-bold">Status</label>
                    <select class="form-select" id="status" name="status" required>
                        <option value="active" {{ old('status', $category->status) == 'active' ? 'selected' : '' }}>Active</option>
                        <option value="inactive" {{ old('status', $category->status) == 'inactive' ? 'selected' : '' }}>Inactive</option>
                    </select>
                </div>

                <div class="mb-4">
                    <label for="image" class="form-label fw-bold">Category Image</label>
                    @if($category->image)
                        <div class="mb-2">
                            <img src="{{ asset('storage/' . $category->image) }}" alt="{{ $category->name }}" style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px;">
                            <div class="text-muted small">Current Image</div>
                        </div>
                    @endif
                    <input type="file" class="form-control" id="image" name="image" accept="image/*">
                    <small class="text-muted">Upload a new image to replace the current one. Max size: 2MB.</small>
                </div>

                <button type="submit" class="btn btn-primary-custom w-100">Update Category</button>
            </form>
        </div>
    </div>
</div>
@endsection
