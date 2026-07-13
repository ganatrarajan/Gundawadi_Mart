<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminCategoryController;
use App\Http\Controllers\Admin\AdminVendorController;
use App\Http\Controllers\Admin\AdminProductController;
use App\Http\Controllers\Admin\AdminCustomerController;
use App\Http\Controllers\Admin\AdminOrderController;
use App\Http\Controllers\Admin\AdminReportController;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

Route::prefix('admin')->name('admin.')->group(function () {
    
    // Guest Routes
    Route::middleware('guest:admin')->group(function () {
        Route::get('/login', [AdminAuthController::class, 'showLoginForm'])->name('login');
        Route::post('/login', [AdminAuthController::class, 'login']);
    });

    // Authenticated Admin Routes
    Route::middleware('auth:admin')->group(function () {
        Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
        
        Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');
        
        Route::resource('categories', AdminCategoryController::class);
        Route::resource('vendors', AdminVendorController::class);
        Route::resource('products', AdminProductController::class);
        
        Route::get('/customers', [AdminCustomerController::class, 'index'])->name('customers.index');
        Route::post('/customers/{customer}/approve', [AdminCustomerController::class, 'approveCustomer'])->name('customers.approve');
        Route::post('/customers/{customer}/reject', [AdminCustomerController::class, 'rejectCustomer'])->name('customers.reject');
        Route::post('/customers/{customer}/update-config', [AdminCustomerController::class, 'updateConfig'])->name('customers.update-config');
        Route::post('/customers/{customer}/reset-password', [AdminCustomerController::class, 'resetPassword'])->name('customers.reset-password');
        Route::get('/address-requests', [AdminCustomerController::class, 'addressRequests'])->name('customers.address-requests');
        Route::post('/address-requests/{address}/approve', [AdminCustomerController::class, 'approveAddressChange'])->name('customers.approve-address');
        Route::post('/address-requests/{address}/reject', [AdminCustomerController::class, 'rejectAddressChange'])->name('customers.reject-address');
        
        Route::get('/orders', [AdminOrderController::class, 'index'])->name('orders.index');
        Route::get('/orders/{id}', [AdminOrderController::class, 'show'])->name('orders.show');
        Route::post('/orders/{id}/status', [AdminOrderController::class, 'updateStatus'])->name('orders.updateStatus');
        Route::post('/orders/{id}/delivery-charge', [AdminOrderController::class, 'updateDeliveryCharge'])->name('orders.updateDeliveryCharge');
        
        Route::get('/reports', [AdminReportController::class, 'index'])->name('reports.index');

        Route::get('/settings', [\App\Http\Controllers\Admin\AdminSettingController::class, 'index'])->name('settings.index');
        Route::post('/settings', [\App\Http\Controllers\Admin\AdminSettingController::class, 'update'])->name('settings.update');
        Route::post('/settings/delivery-slots', [\App\Http\Controllers\Admin\AdminSettingController::class, 'storeSlot'])->name('settings.storeSlot');
        Route::post('/settings/delivery-slots/{id}/toggle', [\App\Http\Controllers\Admin\AdminSettingController::class, 'toggleSlot'])->name('settings.toggleSlot');
        Route::delete('/settings/delivery-slots/{id}', [\App\Http\Controllers\Admin\AdminSettingController::class, 'deleteSlot'])->name('settings.deleteSlot');
    });
});
