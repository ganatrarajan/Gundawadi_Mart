@extends('layouts.admin')

@section('title', 'Manage Categories')
@section('page_title', 'Category Management')

@section('content')
<div class="card card-custom bg-white p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="m-0 fw-bold"><i class="bi bi-grid text-success me-2"></i>Categories List</h5>
        <a href="{{ route('admin.categories.create') }}" class="btn btn-primary-custom">
            <i class="bi bi-plus-lg me-1"></i> Add Category
        </a>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-light">
                <tr>
                    <th class="py-3">ID</th>
                    <th class="py-3">Image</th>
                    <th class="py-3">Category Name</th>
                    <th class="py-3">Status</th>
                    <th class="py-3 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($categories as $category)
                    <tr>
                        <td>{{ $category->id }}</td>
                        <td>
                            @if($category->image)
                                <img src="{{ asset('storage/' . $category->image) }}" alt="{{ $category->name }}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;">
                            @else
                                <div class="bg-light text-center text-muted" style="width: 50px; height: 50px; line-height: 50px; border-radius: 8px;">
                                    <i class="bi bi-image"></i>
                                </div>
                            @endif
                        </td>
                        <td class="fw-bold">{{ $category->name }}</td>
                        <td>
                            <span class="badge badge-{{ $category->status }} text-uppercase">
                                {{ $category->status }}
                            </span>
                        </td>
                        <td class="text-center">
                            <a href="{{ route('admin.categories.edit', $category->id) }}" class="btn btn-sm btn-outline-primary-custom me-2">
                                <i class="bi bi-pencil"></i> Edit
                            </a>
                            <form action="{{ route('admin.categories.destroy', $category->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this category? All products in it will be deleted!');">
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
                        <td colspan="5" class="text-center py-4 text-muted">
                            No categories created yet. Initially you should create "Vegetables" and "Fruits".
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
