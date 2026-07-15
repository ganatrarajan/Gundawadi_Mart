<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreProductRequest;
use App\Http\Requests\Api\UpdateProductPriceRequest;
use App\Http\Resources\OrderResource;
use App\Http\Resources\ProductResource;
use App\Models\Order;
use App\Models\Product;
use App\Repositories\Contracts\OrderRepositoryInterface;
use App\Repositories\Contracts\ProductRepositoryInterface;
use App\Repositories\Contracts\VendorRepositoryInterface;
use App\Services\FcmService;
use App\Traits\ApiResponder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class VendorApiController extends Controller
{
    use ApiResponder;

    protected $vendorRepository;
    protected $productRepository;
    protected $orderRepository;

    public function __construct(
        VendorRepositoryInterface $vendorRepository,
        ProductRepositoryInterface $productRepository,
        OrderRepositoryInterface $orderRepository
    ) {
        $this->vendorRepository = $vendorRepository;
        $this->productRepository = $productRepository;
        $this->orderRepository = $orderRepository;
    }

    public function getDashboard(Request $request)
    {
        $vendorId = $request->user()->id;

        $todayStart = now()->startOfDay();
        $todayEnd = now()->endOfDay();

        $todayOrders = Order::where('vendor_id', $vendorId)
            ->where('status', '!=', 'pending')
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->count();

        $pendingOrders = Order::where('vendor_id', $vendorId)
            ->whereIn('status', ['accepted', 'packing'])
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->count();

        $completedOrders = Order::where('vendor_id', $vendorId)
            ->whereIn('status', ['ready_for_pickup', 'delivered', 'completed'])
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->count();

        $todaySales = Order::where('vendor_id', $vendorId)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->whereIn('status', ['ready_for_pickup', 'delivered', 'completed'])
            ->sum('subtotal');

        return $this->successResponse([
            'today_orders' => $todayOrders,
            'pending_orders' => $pendingOrders,
            'completed_orders' => $completedOrders,
            'today_sales' => (double) $todaySales,
        ], 'Dashboard statistics fetched.');
    }

    public function getProducts(Request $request)
    {
        $vendorId = $request->user()->id;
        $products = $this->productRepository->getVendorProducts($vendorId);
        return $this->successResponse(ProductResource::collection($products), 'Products fetched.');
    }

    public function storeProduct(StoreProductRequest $request)
    {
        $vendorId = $request->user()->id;
        $data = $request->validated();
        $data['vendor_id'] = $vendorId;
        $data['status'] = 'active';

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('products', 'public');
        }

        $product = $this->productRepository->create($data);

        return $this->successResponse(new ProductResource($product), 'Product created successfully.', 201);
    }

    public function updateProduct(StoreProductRequest $request, $id)
    {
        $vendorId = (int) $request->user()->id;
        $product = $this->productRepository->findById($id);

        if (!$product || (int) $product->vendor_id !== $vendorId) {
            return $this->errorResponse('Product not found.', 404);
        }

        $data = $request->validated();

        if ($request->hasFile('image')) {
            // Delete old image if exists
            if ($product->image) {
                Storage::disk('public')->delete($product->image);
            }
            $data['image'] = $request->file('image')->store('products', 'public');
        }

        $updatedProduct = $this->productRepository->update($id, $data);

        return $this->successResponse(new ProductResource($updatedProduct), 'Product updated successfully.');
    }

    public function updatePrice(UpdateProductPriceRequest $request, $id)
    {
        $vendorId = (int) $request->user()->id;
        $product = $this->productRepository->findById($id);

        if (!$product || (int) $product->vendor_id !== $vendorId) {
            return $this->errorResponse('Product not found.', 404);
        }

        $price = $request->input('today_price');
        $updatedProduct = $this->productRepository->updatePrice($id, $price);

        return $this->successResponse(new ProductResource($updatedProduct), 'Product price updated successfully.');
    }

    public function toggleStatus(Request $request, $id)
    {
        $vendorId = $request->user()->id;
        $product = $this->productRepository->findById($id);

        if (!$product || $product->vendor_id !== $vendorId) {
            return $this->errorResponse('Product not found.', 404);
        }

        $newStatus = $product->status === 'active' ? 'inactive' : 'active';
        $updatedProduct = $this->productRepository->update($id, ['status' => $newStatus]);

        return $this->successResponse(new ProductResource($updatedProduct), "Product status updated to {$newStatus}.");
    }

    public function getOrders(Request $request)
    {
        $vendorId = $request->user()->id;
        $filters = $request->only(['date', 'month', 'year']);
        $orders = $this->orderRepository->getVendorOrders($vendorId, $filters);
        return $this->successResponse(OrderResource::collection($orders), 'Orders fetched.');
    }

    public function getOrderDetails($id, Request $request)
    {
        $vendorId = (int) $request->user()->id;
        $order = $this->orderRepository->findById($id);

        if (!$order || (int) $order->vendor_id !== $vendorId) {
            return $this->errorResponse('Order not found.', 404);
        }

        return $this->successResponse(new OrderResource($order), 'Order details fetched.');
    }

    public function updateOrderStatus(Request $request, $id)
    {
        $vendorId = (int) $request->user()->id;
        $order = $this->orderRepository->findById($id);

        if (!$order || (int) $order->vendor_id !== $vendorId) {
            return $this->errorResponse('Order not found.', 404);
        }

        $request->validate([
            'status' => 'required|in:accepted,rejected,packing,ready_for_pickup,cancelled'
        ]);

        $status = $request->input('status');
        $updatedOrder = $this->orderRepository->updateStatus($id, $status);

        // Notify Customer
        $statusTexts = [
            'accepted' => 'accepted and is being processed.',
            'rejected' => 'rejected by the vendor.',
            'cancelled' => 'cancelled.',
            'packing' => 'currently being packed.',
            'ready_for_pickup' => 'packed and is ready for pickup.',
        ];

        $orderIdText = $order->master_order_id ? "Market Order #{$order->master_order_id}" : "Order #{$order->id}";
        $msgText = $order->master_order_id 
            ? "Your items from \"{$order->vendor->shop_name}\" under order #{$order->master_order_id} are " . ($statusTexts[$status] ?? $status)
            : "Your order has been " . ($statusTexts[$status] ?? $status);

        FcmService::send(
            'customer',
            $order->customer_id,
            $order->customer->device_token,
            "{$orderIdText} Update",
            $msgText
        );

        // If ready for pickup, notify admin (log/db)
        if ($status === 'ready_for_pickup') {
            $adminMsg = $order->master_order_id
                ? "Items from {$order->vendor->shop_name} for order #{$order->master_order_id} are ready for pickup."
                : "Order #{$order->id} from {$order->vendor->shop_name} is ready for pickup. Please allocate delivery.";
            FcmService::send(
                'admin',
                1, // default admin id
                null,
                "Delivery Pickup Alert",
                $adminMsg
            );
        }

        return $this->successResponse(new OrderResource($updatedOrder), "Order status updated to {$status}.");
    }

    public function updateDeviceToken(Request $request)
    {
        $vendorId = $request->user()->id;
        $request->validate(['device_token' => 'required|string']);

        \Log::info("Vendor ID {$vendorId} attempting to update device token to: " . $request->input('device_token'));

        $this->vendorRepository->update($vendorId, [
            'device_token' => $request->input('device_token')
        ]);

        return $this->successResponse(null, 'Device token updated.');
    }

    // ==========================================
    // VENDOR PROFILE APIs
    // ==========================================
    public function getProfile(Request $request)
    {
        return $this->successResponse(new \App\Http\Resources\VendorResource($request->user()), 'Profile fetched.');
    }

    public function updateProfile(Request $request)
    {
        $vendorId = $request->user()->id;

        if ($request->has('address') && !$request->has('shop_address')) {
            $request->merge(['shop_address' => $request->input('address')]);
        }

        $request->validate([
            'shop_name' => 'required|string|max:255',
            'owner_name' => 'required|string|max:255',
            'shop_address' => 'required|string|max:500',
            'opening_time' => 'required|string',
            'closing_time' => 'required|string',
            'is_closed' => 'nullable|boolean',
        ]);

        $data = $request->only(['shop_name', 'owner_name', 'shop_address', 'opening_time', 'closing_time', 'is_closed']);
        if ($request->has('is_closed')) {
            $data['is_closed'] = filter_var($request->input('is_closed'), FILTER_VALIDATE_BOOLEAN);
        }
        $updatedVendor = $this->vendorRepository->update($vendorId, $data);

        return $this->successResponse(new \App\Http\Resources\VendorResource($updatedVendor), 'Profile updated successfully.');
    }

    public function uploadShopPhoto(Request $request)
    {
        $vendorId = $request->user()->id;
        $request->validate([
            'photo' => 'required|image|max:2048',
        ]);

        $vendor = $request->user();
        if ($vendor->shop_photo) {
            Storage::disk('public')->delete($vendor->shop_photo);
        }

        $path = $request->file('photo')->store('vendors', 'public');
        $updatedVendor = $this->vendorRepository->update($vendorId, ['shop_photo' => $path]);

        return $this->successResponse([
            'shop_photo' => asset('storage/' . $path)
        ], 'Shop photo uploaded.');
    }

    // ==========================================
    // FLUTTER API COMPATIBILITY ALIASES
    // ==========================================
    public function toggleStatusApi(Request $request)
    {
        $vendorId = (int) $request->user()->id;
        $id = $request->input('id');
        $product = $this->productRepository->findById($id);

        if (!$product || (int) $product->vendor_id !== $vendorId) {
            return $this->errorResponse('Product not found.', 404);
        }

        $newStatus = $product->status === 'active' ? 'inactive' : 'active';
        $updatedProduct = $this->productRepository->update($id, ['status' => $newStatus]);

        return $this->successResponse(new ProductResource($updatedProduct), "Product status updated to {$newStatus}.");
    }

    public function updatePriceApi(Request $request)
    {
        $vendorId = (int) $request->user()->id;
        $id = $request->input('id');
        $product = $this->productRepository->findById($id);

        if (!$product || (int) $product->vendor_id !== $vendorId) {
            return $this->errorResponse('Product not found.', 404);
        }

        $price = $request->input('price');
        $updatedProduct = $this->productRepository->updatePrice($id, $price);

        return $this->successResponse(new ProductResource($updatedProduct), 'Product price updated successfully.');
    }

    public function updateOrderStatusApi(Request $request)
    {
        $id = $request->input('id');
        $status = $request->input('status');
        
        $mappedStatus = strtolower($status);
        if ($mappedStatus === 'ready for pickup') {
            $mappedStatus = 'ready_for_pickup';
        }
        
        // Merge the normalized status back so the validation and repository use it
        $request->merge(['status' => $mappedStatus]);

        return $this->updateOrderStatus($request, $id);
    }

    public function updateProductPut(Request $request)
    {
        $vendorId = $request->user()->id;
        $id = $request->input('id');
        $product = $this->productRepository->findById($id);

        if (!$product || $product->vendor_id !== $vendorId) {
            return $this->errorResponse('Product not found.', 404);
        }

        // Validate basic inputs manually to allow flexible JSON or form-data payloads
        $data = [];
        if ($request->has('name')) $data['name'] = $request->input('name');
        if ($request->has('category_id')) $data['category_id'] = $request->input('category_id');
        if ($request->has('today_price')) $data['today_price'] = $request->input('today_price');
        if ($request->has('unit')) $data['unit'] = $request->input('unit');

        if ($request->hasFile('image')) {
            if ($product->image) {
                Storage::disk('public')->delete($product->image);
            }
            $data['image'] = $request->file('image')->store('products', 'public');
        }

        $updatedProduct = $this->productRepository->update($id, $data);

        return $this->successResponse(new ProductResource($updatedProduct), 'Product updated successfully.');
    }

    public function updateOrderItemPrice(Request $request)
    {
        $vendorId = (int) $request->user()->id;
        $orderItemId = $request->input('order_item_id');
        $newPrice = (double) $request->input('price');

        $orderItem = \App\Models\OrderItem::findOrFail($orderItemId);
        $order = $orderItem->order;

        if ((int) $order->vendor_id !== $vendorId) {
            return $this->errorResponse('Unauthorized.', 403);
        }

        $orderItem->price = $newPrice;
        $orderItem->total_price = $newPrice * $orderItem->quantity;
        $orderItem->save();

        $subtotal = $order->items()->sum('total_price');
        $order->subtotal = $subtotal;
        $order->total = $subtotal + $order->delivery_charge + $order->handling_charge + $order->platform_fee;
        $order->save();

        $order->load(['customer', 'items', 'vendor']);

        return $this->successResponse(new OrderResource($order), 'Item price updated successfully.');
    }
}
