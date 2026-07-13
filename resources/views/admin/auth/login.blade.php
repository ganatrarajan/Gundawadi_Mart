<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Gundawadi Mart</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #1b5e20 0%, #2e7d32 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            background-color: white;
            padding: 40px;
            width: 100%;
            max-width: 420px;
        }
        .login-title {
            font-weight: 700;
            color: #1b5e20;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-control-custom {
            border-radius: 8px;
            padding: 12px;
            border: 1px solid #ced4da;
        }
        .form-control-custom:focus {
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.25);
            border-color: #2e7d32;
        }
        .btn-login {
            background-color: #2e7d32;
            border: none;
            color: white;
            padding: 12px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: background-color 0.2s ease;
        }
        .btn-login:hover {
            background-color: #1b5e20;
        }
    </style>
</head>
<body>

<div class="login-card">
    <div class="text-center mb-4">
        <span class="fs-1 text-success"><i class="bi bi-shop"></i></span>
        <h2 class="login-title mt-2">Gundawadi Mart</h2>
        <p class="text-muted">Administrator Portal Login</p>
    </div>

    @if ($errors->any())
        <div class="alert alert-danger border-0 small shadow-sm">
            <ul class="mb-0 ps-3">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('admin.login') }}" method="POST">
        @csrf
        
        <div class="mb-3">
            <label for="email" class="form-label text-secondary small fw-bold">EMAIL ADDRESS</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0 text-success"><i class="bi bi-envelope"></i></span>
                <input type="email" class="form-control form-control-custom border-start-0" id="email" name="email" value="{{ old('email') }}" required autofocus placeholder="admin@gundawadimart.com">
            </div>
        </div>

        <div class="mb-4">
            <label for="password" class="form-label text-secondary small fw-bold">PASSWORD</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0 text-success"><i class="bi bi-lock"></i></span>
                <input type="password" class="form-control form-control-custom border-start-0" id="password" name="password" required placeholder="••••••••">
            </div>
        </div>

        <div class="form-check mb-4">
            <input type="checkbox" class="form-check-input" id="remember" name="remember">
            <label class="form-check-label text-muted small" for="remember">Remember me on this device</label>
        </div>

        <button type="submit" class="btn btn-login w-100 shadow-sm">Log In</button>
    </form>
</div>

</body>
</html>
