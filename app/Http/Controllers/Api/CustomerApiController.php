<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreAddressRequest;
use App\Http\Requests\Api\StoreOrderRequest;
use App\Http\Resources\AddressResource;
use App\Http\Resources\OrderResource;
use App\Http\Resources\ProductResource;
use App\Http\Resources\VendorResource;
use App\Models\Address;
use App\Models\Order;
use App\Models\Product;
use App\Models\Vendor;
use App\Repositories\Contracts\AddressRepositoryInterface;
use App\Repositories\Contracts\CustomerRepositoryInterface;
use App\Repositories\Contracts\OrderRepositoryInterface;
use App\Repositories\Contracts\ProductRepositoryInterface;
use App\Repositories\Contracts\VendorRepositoryInterface;
use App\Services\FcmService;
use App\Traits\ApiResponder;
use Illuminate\Http\Request;

class CustomerApiController extends Controller
{
    use ApiResponder;

    protected $vendorRepository;
    protected $productRepository;
    protected $addressRepository;
    protected $orderRepository;
    protected $customerRepository;

    public function __construct(
        VendorRepositoryInterface $vendorRepository,
        ProductRepositoryInterface $productRepository,
        AddressRepositoryInterface $addressRepository,
        OrderRepositoryInterface $orderRepository,
        CustomerRepositoryInterface $customerRepository
    ) {
        $this->vendorRepository = $vendorRepository;
        $this->productRepository = $productRepository;
        $this->addressRepository = $addressRepository;
        $this->orderRepository = $orderRepository;
        $this->customerRepository = $customerRepository;
    }

    public function getVendors()
    {
        $vendors = $this->vendorRepository->allActive();
        return $this->successResponse(VendorResource::collection($vendors), 'Vendors fetched.');
    }

    public function getVendorDetails($vendorId)
    {
        $vendor = $this->vendorRepository->findById($vendorId);
        if (!$vendor || $vendor->status !== 'active') {
            return $this->errorResponse('Vendor not found or inactive.', 404);
        }

        $products = $this->productRepository->getVendorProducts($vendorId, ['status' => 'active']);

        return $this->successResponse([
            'vendor' => new VendorResource($vendor),
            'products' => ProductResource::collection($products)
        ], 'Vendor details fetched.');
    }

    public function getAddresses(Request $request)
    {
        $customerId = $request->user()->id;
        $addresses = $this->addressRepository->getCustomerAddresses($customerId);
        return $this->successResponse(AddressResource::collection($addresses), 'Addresses fetched.');
    }

    public function storeAddress(StoreAddressRequest $request)
    {
        $customerId = $request->user()->id;
        $data = $request->validated();
        $data['customer_id'] = $customerId;
        $data['status'] = 'pending'; // Always pending change request

        // Delete any existing pending address change requests for this customer
        \App\Models\Address::where('customer_id', $customerId)->where('status', 'pending')->delete();

        $address = \App\Models\Address::create($data);

        return $this->successResponse(new AddressResource($address), 'Address change request submitted successfully. Pending Admin review.', 201);
    }

    public function storeOrder(StoreOrderRequest $request)
    {
        $customer = $request->user();

        // Enforce ordering permission rule
        if ($customer->status !== 'approved') {
            return $this->errorResponse('Your account is not approved yet. You cannot place orders.', 403);
        }
        if (is_null($customer->delivery_km) || is_null($customer->delivery_charge)) {
            return $this->errorResponse('Delivery details have not been assigned by admin yet. You cannot place orders.', 403);
        }

        $vendorId = $request->input('vendor_id');
        $inputItems = $request->input('items');
        $specialNote = $request->input('special_note');
        $deliverySlot = $request->input('delivery_slot');

        $vendor = $this->vendorRepository->findById($vendorId);
        if (!$vendor || $vendor->status !== 'active') {
            return $this->errorResponse('Vendor is not active or does not exist.', 422);
        }

        // Always use the approved address for order delivery
        $address = $customer->addresses()->where('status', 'approved')->first();
        if (!$address) {
            return $this->errorResponse('No approved delivery address found.', 422);
        }
        $addressId = $address->id;

        // Format delivery address text snapshot
        $addressSnapshot = sprintf(
            "%s, Mobile: %s\nH.No: %s, %s, %s, %s, %s\nLandmark: %s",
            $address->full_name,
            $address->mobile,
            $address->house_number,
            $address->street,
            $address->area,
            $address->city,
            $address->pincode ?? '',
            $address->landmark ?? 'N/A'
        );

        $subtotal = 0;
        $itemsData = [];

        foreach ($inputItems as $item) {
            $product = $this->productRepository->findById($item['product_id']);
            if (!$product || $product->vendor_id !== (int) $vendorId || $product->status !== 'active') {
                return $this->errorResponse("Product ID {$item['product_id']} is not available from this vendor.", 422);
            }

            $price = isset($item['price']) ? (float) $item['price'] : (float) $product->today_price;
            $unit = isset($item['unit']) ? $item['unit'] : $product->unit;
            $quantity = (int) $item['quantity'];
            $totalPrice = $price * $quantity;

            $subtotal += $totalPrice;

            $itemsData[] = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'price' => $price,
                'unit' => $unit,
                'quantity' => $quantity,
                'total_price' => $totalPrice,
            ];
        }

        $showHandling = \App\Models\Setting::getValue('show_handling_charge', 'yes') === 'yes';
        $showPlatform = \App\Models\Setting::getValue('show_platform_fee', 'yes') === 'yes';
        
        $handlingCharge = $showHandling ? (double) \App\Models\Setting::getValue('handling_charge', 5.0) : 0.0;
        $platformFee = $showPlatform ? (double) \App\Models\Setting::getValue('platform_fee', 10.0) : 0.0;

        // Order primary data using the customer's assigned delivery charge
        $orderData = [
            'customer_id' => $customer->id,
            'vendor_id' => $vendorId,
            'delivery_address' => $addressSnapshot,
            'address_id' => $addressId,
            'subtotal' => $subtotal,
            'delivery_charge' => $customer->delivery_charge,
            'handling_charge' => $handlingCharge,
            'platform_fee' => $platformFee,
            'total' => $subtotal + $customer->delivery_charge + $handlingCharge + $platformFee,
            'status' => 'pending',
            'special_note' => $specialNote,
            'delivery_slot' => $deliverySlot,
        ];

        $order = $this->orderRepository->create($orderData, $itemsData);

        // Update customer name if it is empty
        if (empty($customer->name)) {
            $this->customerRepository->update($customer->id, [
                'name' => $address->full_name
            ]);
        }

        // Send Notification to Vendor
        FcmService::send(
            'vendor',
            $vendor->id,
            $vendor->device_token,
            'New Order Received',
            "New order #{$order->id} from {$address->full_name} for Amount: ₹{$order->total}."
        );

        // Send self notification to Customer
        FcmService::send(
            'customer',
            $customer->id,
            $customer->device_token,
            'Order Placed successfully',
            "Your order #{$order->id} at {$vendor->shop_name} has been placed. Waiting for shop acceptance."
        );

        return $this->successResponse(new OrderResource($order), 'Order placed successfully.', 201);
    }

    public function getOrders(Request $request)
    {
        $customerId = $request->user()->id;
        $orders = $this->orderRepository->getCustomerOrders($customerId);
        return $this->successResponse(OrderResource::collection($orders), 'Orders history fetched.');
    }

    public function getOrderDetails($orderId, Request $request)
    {
        $customerId = $request->user()->id;
        $order = $this->orderRepository->findById($orderId);

        if (!$order || $order->customer_id !== $customerId) {
            return $this->errorResponse('Order not found.', 404);
        }

        return $this->successResponse(new OrderResource($order), 'Order details fetched.');
    }

    public function reorder($orderId, Request $request)
    {
        $customer = $request->user();
        $customerId = $customer->id;

        // Enforce ordering permission rule
        if ($customer->status !== 'approved') {
            return $this->errorResponse('Your account is not approved yet. You cannot place orders.', 403);
        }
        if (is_null($customer->delivery_km) || is_null($customer->delivery_charge)) {
            return $this->errorResponse('Delivery details have not been assigned by admin yet. You cannot place orders.', 403);
        }

        $oldOrder = $this->orderRepository->findById($orderId);

        if (!$oldOrder || $oldOrder->customer_id !== $customerId) {
            return $this->errorResponse('Original order not found.', 404);
        }

        // Always use the approved address for order delivery
        $address = $customer->addresses()->where('status', 'approved')->first();
        if (!$address) {
            return $this->errorResponse('No approved delivery address found.', 422);
        }
        $addressId = $address->id;

        // Format delivery address text snapshot
        $addressSnapshot = sprintf(
            "%s, Mobile: %s\nH.No: %s, %s, %s, %s, %s\nLandmark: %s",
            $address->full_name,
            $address->mobile,
            $address->house_number,
            $address->street,
            $address->area,
            $address->city,
            $address->pincode ?? '',
            $address->landmark ?? 'N/A'
        );

        // Prepare items array
        $itemsData = [];
        $subtotal = 0;
        $vendorId = $oldOrder->vendor_id;

        $vendor = $this->vendorRepository->findById($vendorId);
        if (!$vendor || $vendor->status !== 'active') {
            return $this->errorResponse('Vendor is currently inactive.', 422);
        }

        foreach ($oldOrder->items as $item) {
            $product = $this->productRepository->findById($item->product_id);
            if (!$product || $product->status !== 'active') {
                return $this->errorResponse("Product '{$item->product_name}' is currently unavailable.", 422);
            }

            $price = (float) $product->today_price;
            $quantity = $item->quantity;
            $totalPrice = $price * $quantity;
            $subtotal += $totalPrice;

            $itemsData[] = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'price' => $price,
                'unit' => $product->unit,
                'quantity' => $quantity,
                'total_price' => $totalPrice,
            ];
        }

        $orderData = [
            'customer_id' => $customerId,
            'vendor_id' => $vendorId,
            'address_id' => $addressId,
            'delivery_address' => $addressSnapshot,
            'subtotal' => $subtotal,
            'delivery_charge' => (float) $customer->delivery_charge,
            'total' => $subtotal + (float) $customer->delivery_charge,
            'payment_method' => 'cash_on_delivery',
            'status' => 'pending',
            'special_note' => $oldOrder->special_note,
        ];

        $newOrder = $this->orderRepository->create($orderData, $itemsData);

        // Notify Vendor
        FcmService::send(
            'vendor',
            $vendor->id,
            $vendor->device_token,
            'New Order Received (Reorder)',
            "New reorder #{$newOrder->id} placed. Amount: ₹{$newOrder->total}."
        );

        // Notify Customer
        FcmService::send(
            'customer',
            $customerId,
            $request->user()->device_token,
            'Reorder Placed successfully',
            "Your reorder #{$newOrder->id} at {$vendor->shop_name} has been placed."
        );

        return $this->successResponse(new OrderResource($newOrder), 'Reorder placed successfully.', 201);
    }

    public function updateProfile(Request $request)
    {
        $customerId = $request->user()->id;
        $request->validate([
            'name' => 'required|string|max:255',
            'profile_photo' => 'nullable|image|max:2048', // 2MB Max
        ]);
        
        $data = [
            'name' => $request->input('name')
        ];

        if ($request->hasFile('profile_photo')) {
            $path = $request->file('profile_photo')->store('profiles', 'public');
            $data['profile_photo'] = $path;
        }
        
        $customer = $this->customerRepository->update($customerId, $data);

        return $this->successResponse(new CustomerResource($customer), 'Profile updated successfully.');
    }

    public function updateDeviceToken(Request $request)
    {
        $customerId = $request->user()->id;
        $request->validate(['device_token' => 'required|string']);

        $this->customerRepository->update($customerId, [
            'device_token' => $request->input('device_token')
        ]);

        return $this->successResponse(null, 'Device token updated.');
    }

    public function getProfile(Request $request)
    {
        return $this->successResponse(new CustomerResource($request->user()), 'Profile fetched.');
    }

    public function cancelOrder($id, Request $request)
    {
        $customerId = $request->user()->id;
        $order = \App\Models\Order::where('id', $id)->first();

        if (!$order || $order->customer_id !== $customerId) {
            return $this->errorResponse('Order not found.', 404);
        }

        if (!in_array($order->status, ['pending'])) {
            return $this->errorResponse('Order cannot be cancelled once it has been accepted or processed.', 422);
        }

        $order->update(['status' => 'cancelled']);

        // Notify Vendor about cancellation
        \App\Services\FcmService::send(
            'vendor',
            $order->vendor_id,
            $order->vendor->device_token,
            "Order #{$order->id} Cancelled",
            "Order #{$order->id} has been cancelled by the customer."
        );

        return $this->successResponse(new OrderResource($order), 'Order cancelled successfully.');
    }
}
