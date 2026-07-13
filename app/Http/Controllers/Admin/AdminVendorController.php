<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminVendorController extends Controller
{
    public function index()
    {
        $vendors = Vendor::all();
        return view('admin.vendors.index', compact('vendors'));
    }

    public function create()
    {
        $categories = \App\Models\Category::all();
        return view('admin.vendors.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'shop_name' => 'required|string|max:255',
            'owner_name' => 'required|string|max:255',
            'mobile_number' => 'required|string|max:15|unique:vendors,mobile_number',
            'password' => 'required|string|min:6',
            'shop_address' => 'required|string|max:500',
            'status' => 'required|in:active,inactive',
            'shop_photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'category_id' => 'required|exists:categories,id',
            'opening_time' => 'required|string',
            'closing_time' => 'required|string',
        ]);

        if ($request->hasFile('shop_photo')) {
            $data['shop_photo'] = $request->file('shop_photo')->store('vendors', 'public');
        }

        $data['password'] = bcrypt($request->password);

        $vendor = Vendor::create($data);

        // Seed default dummy products based on vendor category
        $category = \App\Models\Category::find($request->category_id);
        $categoryName = $category ? $category->name : '';

        $defaultProducts = [
            'Vegetables' => [
                ['name' => 'Potato (आलू)', 'unit' => '1kg', 'today_price' => 30.00, 'image' => 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Tomato (टमाटर)', 'unit' => '1kg', 'today_price' => 40.00, 'image' => 'https://images.unsplash.com/photo-1595855759920-86582396756a?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Onion (प्याज़)', 'unit' => '1kg', 'today_price' => 35.00, 'image' => 'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Cabbage (पत्ता गोभी)', 'unit' => '1 piece', 'today_price' => 20.00, 'image' => 'https://images.unsplash.com/photo-1581057997547-ab8e6ebc8c19?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Cauliflower (फूलगोभी)', 'unit' => '1 piece', 'today_price' => 25.00, 'image' => 'https://images.unsplash.com/photo-1568584711271-6c929fb49b60?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Spinach (पालक)', 'unit' => '1 bunch', 'today_price' => 15.00, 'image' => 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Carrot (गाजर)', 'unit' => '1kg', 'today_price' => 45.00, 'image' => 'https://images.unsplash.com/photo-1447124477390-f09df9016ebd?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Green Chillies (हरी मिर्च)', 'unit' => '250g', 'today_price' => 15.00, 'image' => 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Coriander (धनिया)', 'unit' => '1 bunch', 'today_price' => 10.00, 'image' => 'https://images.unsplash.com/photo-1514944224746-6bba5b09e5c2?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Garlic (लहसुन)', 'unit' => '250g', 'today_price' => 50.00, 'image' => 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Ginger (अदरक)', 'unit' => '250g', 'today_price' => 40.00, 'image' => 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Lemon (नींबू)', 'unit' => '1 packet', 'today_price' => 20.00, 'image' => 'https://images.unsplash.com/photo-1590502593747-42a996133562?auto=format&fit=crop&q=80&w=400'],
            ],
            'Fruits' => [
                ['name' => 'Apple (सेब)', 'unit' => '1kg', 'today_price' => 120.00, 'image' => 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Banana (केला)', 'unit' => '1 dozen', 'today_price' => 50.00, 'image' => 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Mango (आम)', 'unit' => '1kg', 'today_price' => 80.00, 'image' => 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Orange (संतरा)', 'unit' => '1kg', 'today_price' => 70.00, 'image' => 'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Grapes (अंगूर)', 'unit' => '1kg', 'today_price' => 90.00, 'image' => 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&q=80&w=400'],
                ['name' => 'Watermelon (तरबूज)', 'unit' => '1 piece', 'today_price' => 60.00, 'image' => 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&q=80&w=400'],
            ]
        ];

        $seededProducts = [];
        if (stripos($categoryName, 'vegetable') !== false) {
            $seededProducts = $defaultProducts['Vegetables'];
        } elseif (stripos($categoryName, 'fruit') !== false) {
            $seededProducts = $defaultProducts['Fruits'];
        }

        foreach ($seededProducts as $prod) {
            \App\Models\Product::create([
                'vendor_id' => $vendor->id,
                'category_id' => $category->id,
                'name' => $prod['name'],
                'image' => $prod['image'],
                'today_price' => $prod['today_price'],
                'unit' => $prod['unit'],
                'status' => 'active',
            ]);
        }

        return redirect()->route('admin.vendors.index')->with('success', 'Vendor created and dummy catalog products auto-added successfully.');
    }

    public function edit($id)
    {
        $vendor = Vendor::findOrFail($id);
        $categories = \App\Models\Category::all();
        return view('admin.vendors.edit', compact('vendor', 'categories'));
    }

    public function update(Request $request, $id)
    {
        $vendor = Vendor::findOrFail($id);

        $data = $request->validate([
            'shop_name' => 'required|string|max:255',
            'owner_name' => 'required|string|max:255',
            'mobile_number' => 'required|string|max:15|unique:vendors,mobile_number,' . $id,
            'password' => 'nullable|string|min:6',
            'shop_address' => 'required|string|max:500',
            'status' => 'required|in:active,inactive',
            'shop_photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'category_id' => 'required|exists:categories,id',
            'opening_time' => 'required|string',
            'closing_time' => 'required|string',
        ]);

        if ($request->hasFile('shop_photo')) {
            if ($vendor->shop_photo) {
                Storage::disk('public')->delete($vendor->shop_photo);
            }
            $data['shop_photo'] = $request->file('shop_photo')->store('vendors', 'public');
        }

        if ($request->filled('password')) {
            $data['password'] = bcrypt($request->password);
        } else {
            unset($data['password']);
        }

        $vendor->update($data);

        return redirect()->route('admin.vendors.index')->with('success', 'Vendor updated successfully.');
    }

    public function destroy($id)
    {
        $vendor = Vendor::findOrFail($id);
        if ($vendor->shop_photo) {
            Storage::disk('public')->delete($vendor->shop_photo);
        }
        $vendor->delete();

        return redirect()->route('admin.vendors.index')->with('success', 'Vendor deleted successfully.');
    }
}
