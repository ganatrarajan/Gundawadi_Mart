<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CustomerAuthController;
use App\Http\Controllers\Api\CustomerApiController;
use App\Http\Controllers\Api\VendorAuthController;
use App\Http\Controllers\Api\VendorApiController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ==========================================
// CUSTOMER AUTH & PUBLIC API
// ==========================================
Route::prefix('customer')->group(function () {
    Route::post('/register', [CustomerAuthController::class, 'register']);
    Route::post('/login', [CustomerAuthController::class, 'login']);

    // Protected Customer Routes
    Route::middleware(['auth:sanctum', 'customer'])->group(function () {
        Route::get('/vendors', [CustomerApiController::class, 'getVendors']);
        Route::get('/vendors/{vendorId}', [CustomerApiController::class, 'getVendorDetails']);
        
        Route::get('/addresses', [CustomerApiController::class, 'getAddresses']);
        Route::post('/addresses', [CustomerApiController::class, 'storeAddress']);
        
        Route::post('/orders', [CustomerApiController::class, 'storeOrder']);
        Route::get('/orders', [CustomerApiController::class, 'getOrders']);
        Route::get('/orders/{orderId}', [CustomerApiController::class, 'getOrderDetails']);
        Route::post('/orders/{orderId}/reorder', [CustomerApiController::class, 'reorder']);
        Route::post('/orders/{orderId}/cancel', [CustomerApiController::class, 'cancelOrder']);
        
        Route::post('/update-profile', [CustomerApiController::class, 'updateProfile']);
        Route::post('/profile', [CustomerApiController::class, 'updateProfile']);
        Route::get('/profile', [CustomerApiController::class, 'getProfile']);
        Route::post('/profile/upload-photo', [CustomerApiController::class, 'uploadProfilePhoto']);
        Route::post('/update-device-token', [CustomerApiController::class, 'updateDeviceToken']);
    });
});

// ==========================================
// VENDOR AUTH & API
// ==========================================
Route::prefix('vendor')->group(function () {
    Route::post('/login', [VendorAuthController::class, 'login']);

    // Protected Vendor Routes
    Route::middleware(['auth:sanctum', 'vendor'])->group(function () {
        Route::get('/dashboard', [VendorApiController::class, 'getDashboard']);
        
        Route::get('/products', [VendorApiController::class, 'getProducts']);
        Route::post('/products', [VendorApiController::class, 'storeProduct']);
        Route::put('/products', [VendorApiController::class, 'updateProductPut']);
        Route::post('/products/{productId}/update', [VendorApiController::class, 'updateProduct']);
        Route::patch('/products/{productId}/price', [VendorApiController::class, 'updatePrice']);
        Route::post('/products/{productId}/toggle', [VendorApiController::class, 'toggleStatus']);
        
        Route::get('/orders', [VendorApiController::class, 'getOrders']);
        Route::get('/orders/{orderId}', [VendorApiController::class, 'getOrderDetails']);
        Route::post('/orders/{orderId}/status', [VendorApiController::class, 'updateOrderStatus']);
        Route::post('/orders/items/update-price', [VendorApiController::class, 'updateOrderItemPrice']);
        
        Route::post('/update-device-token', [VendorApiController::class, 'updateDeviceToken']);

        // Vendor Profile Routes
        Route::get('/profile', [VendorApiController::class, 'getProfile']);
        Route::put('/profile', [VendorApiController::class, 'updateProfile']);
        Route::post('/profile/upload-photo', [VendorApiController::class, 'uploadShopPhoto']);

        // Flutter Client Compatibility Endpoints (POST requests with IDs in body)
        Route::post('/products/toggle', [VendorApiController::class, 'toggleStatusApi']);
        Route::post('/products/update-price', [VendorApiController::class, 'updatePriceApi']);
        Route::post('/orders/update-status', [VendorApiController::class, 'updateOrderStatusApi']);
        Route::post('/profile/update-fcm', [VendorApiController::class, 'updateDeviceToken']);
    });
});
