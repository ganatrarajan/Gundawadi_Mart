<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard') - Gundawadi Mart Admin</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
    <!-- Custom CSS -->
    <style>
        body {
            font-family: 'Outfit', sans-serif;
            background-color: #f4f7f6;
            color: #333;
        }
        .sidebar {
            background-color: #1b5e20;
            color: white;
            min-height: 100vh;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
        }
        .sidebar .nav-link {
            color: rgba(255,255,255,0.8);
            border-radius: 8px;
            margin: 4px 12px;
            padding: 10px 15px;
            transition: all 0.2s ease;
        }
        .sidebar .nav-link:hover {
            color: white;
            background-color: rgba(255,255,255,0.1);
        }
        .sidebar .nav-link.active {
            color: white;
            background-color: #2e7d32;
            font-weight: 500;
        }
        .navbar-brand-custom {
            padding: 20px;
            text-align: center;
            font-size: 1.5rem;
            font-weight: 700;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            background-color: #123e16;
        }
        .main-navbar {
            background-color: white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            padding: 15px 30px;
        }
        .content-area {
            padding: 30px;
        }
        .card-custom {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
            transition: transform 0.2s ease;
        }
        .card-custom:hover {
            transform: translateY(-2px);
        }
        .btn-primary-custom {
            background-color: #2e7d32;
            border-color: #2e7d32;
            color: white;
            font-weight: 500;
            padding: 8px 20px;
            border-radius: 8px;
        }
        .btn-primary-custom:hover {
            background-color: #1b5e20;
            border-color: #1b5e20;
            color: white;
        }
        .btn-outline-primary-custom {
            color: #2e7d32;
            border-color: #2e7d32;
            font-weight: 500;
            padding: 8px 20px;
            border-radius: 8px;
        }
        .btn-outline-primary-custom:hover {
            background-color: #2e7d32;
            color: white;
        }
        .badge-pending { background-color: #ffc107; color: #000; }
        .badge-accepted { background-color: #0d6efd; color: white; }
        .badge-packing { background-color: #6f42c1; color: white; }
        .badge-ready_for_pickup { background-color: #fd7e14; color: white; }
        .badge-out_for_delivery { background-color: #17a2b8; color: white; }
        .badge-delivered { background-color: #198754; color: white; }
        .badge-cancelled { background-color: #dc3545; color: white; }
        .badge-active { background-color: #198754; color: white; }
        .badge-inactive { background-color: #6c757d; color: white; }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
            <div class="navbar-brand-custom">
                <i class="bi bi-shop text-warning me-2"></i>Gundawadi Mart
            </div>
            <ul class="nav flex-column mt-4">
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.dashboard') ? 'active' : '' }}" href="{{ route('admin.dashboard') }}">
                        <i class="bi bi-speedometer2 me-2"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.categories.*') ? 'active' : '' }}" href="{{ route('admin.categories.index') }}">
                        <i class="bi bi-grid me-2"></i> Categories
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.vendors.*') ? 'active' : '' }}" href="{{ route('admin.vendors.index') }}">
                        <i class="bi bi-people me-2"></i> Vendors
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.products.*') ? 'active' : '' }}" href="{{ route('admin.products.index') }}">
                        <i class="bi bi-basket me-2"></i> Products
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.customers.index') ? 'active' : '' }}" href="{{ route('admin.customers.index') }}">
                        <i class="bi bi-person-circle me-2"></i> Customers
                        @php
                            $pendingRegCount = \App\Models\Customer::where('status', 'pending_approval')->count();
                        @endphp
                        @if($pendingRegCount > 0)
                            <span class="badge bg-warning text-dark ms-2">{{ $pendingRegCount }}</span>
                        @endif
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.customers.address-requests') ? 'active' : '' }}" href="{{ route('admin.customers.address-requests') }}">
                        <i class="bi bi-geo-alt-fill me-2"></i> Address Requests
                        @php
                            $pendingAddrCount = \App\Models\Address::where('status', 'pending')->whereHas('customer', function($q) { $q->where('status', 'approved'); })->count();
                        @endphp
                        @if($pendingAddrCount > 0)
                            <span class="badge bg-danger ms-2">{{ $pendingAddrCount }}</span>
                        @endif
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.orders.*') ? 'active' : '' }}" href="{{ route('admin.orders.index') }}">
                        <i class="bi bi-cart3 me-2"></i> Orders
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.reports.*') ? 'active' : '' }}" href="{{ route('admin.reports.index') }}">
                        <i class="bi bi-bar-chart-line me-2"></i> Reports
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ Route::is('admin.settings.*') ? 'active' : '' }}" href="{{ route('admin.settings.index') }}">
                        <i class="bi bi-gear me-2"></i> System Settings
                    </a>
                </li>
            </ul>
            <div class="mt-auto mb-4 text-center w-100">
                <form action="{{ route('admin.logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="btn btn-link text-white-50 nav-link border-0 text-start w-75 mx-auto">
                        <i class="bi bi-box-arrow-right me-2"></i> Logout
                    </button>
                </form>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 px-0 ms-auto">
            <!-- Navbar -->
            <nav class="navbar main-navbar d-flex justify-content-between align-items-center">
                <h4 class="m-0 font-weight-bold text-success">@yield('page_title', 'Overview')</h4>
                <div class="d-flex align-items-center">
                    <div class="dropdown">
                        <a class="btn dropdown-toggle d-flex align-items-center text-decoration-none text-dark" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-badge-fill me-2 fs-5 text-success"></i>
                            <strong>{{ Auth::guard('admin')->user()->name }}</strong>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                            <li>
                                <form action="{{ route('admin.logout') }}" method="POST">
                                    @csrf
                                    <button type="submit" class="dropdown-item py-2">
                                        <i class="bi bi-box-arrow-right me-2 text-danger"></i> Logout
                                    </button>
                                </form>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>

            <!-- Content Area -->
            <div class="content-area">
                <!-- Alert Messages -->
                @if(session('success'))
                    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i>{{ session('success') }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                @endif
                @if(session('error'))
                    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>{{ session('error') }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                @endif

                @yield('content')
            </div>
        </div>
    </div>
</div>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<!-- Bootstrap 5 Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- DataTables JS -->
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>

@stack('scripts')
</body>
</html>
