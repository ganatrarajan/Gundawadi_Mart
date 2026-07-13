<?php

namespace Database\Seeders;

use App\Models\Admin;
use App\Models\Category;
use App\Models\Vendor;
use App\Models\Product;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed Admin
        Admin::create([
            'name' => 'Gundawadi Admin',
            'email' => 'admin@gundawadimart.com',
            'password' => Hash::make('Password@123'),
        ]);

        // 2. Seed Categories
        $vegetables = Category::create([
            'name' => 'Vegetables',
            'image' => null,
            'status' => 'active',
        ]);

        $fruits = Category::create([
            'name' => 'Fruits',
            'image' => null,
            'status' => 'active',
        ]);

        // 3. Seed Vendors
        $vendor1 = Vendor::create([
            'shop_name' => 'Sardar Vegetable Store',
            'owner_name' => 'Rameshbhai Patel',
            'mobile_number' => '9876543210',
            'password' => Hash::make('123456'),
            'shop_photo' => null,
            'shop_address' => 'Gundawadi Main Road, Rajkot',
            'status' => 'active',
        ]);

        $vendor2 = Vendor::create([
            'shop_name' => 'Krishna Green Mart',
            'owner_name' => 'Kishorbhai Savaliya',
            'mobile_number' => '9988776655',
            'password' => Hash::make('123456'),
            'shop_photo' => null,
            'shop_address' => 'Street No. 3, Gundawadi, Rajkot',
            'status' => 'active',
        ]);

        $vendor3 = Vendor::create([
            'shop_name' => 'Maruti Fruits & Vegetables',
            'owner_name' => 'Mansukhbhai Vora',
            'mobile_number' => '9000000001',
            'password' => Hash::make('123456'),
            'shop_photo' => null,
            'shop_address' => 'Opp. Temple, Gundawadi, Rajkot',
            'status' => 'active',
        ]);

        // 4. Seed Products for each Vendor
        $sampleProducts = [
            [
                'name' => 'Fresh Tomatoes',
                'category_id' => $vegetables->id,
                'today_price' => 40.00,
                'unit' => '1kg',
            ],
            [
                'name' => 'Local Potatoes',
                'category_id' => $vegetables->id,
                'today_price' => 30.00,
                'unit' => '1kg',
            ],
            [
                'name' => 'Red Onions',
                'category_id' => $vegetables->id,
                'today_price' => 35.00,
                'unit' => '1kg',
            ],
            [
                'name' => 'Green Okra (Bhindi)',
                'category_id' => $vegetables->id,
                'today_price' => 25.00,
                'unit' => '500g',
            ],
            [
                'name' => 'Spinach (Palak)',
                'category_id' => $vegetables->id,
                'today_price' => 15.00,
                'unit' => '1 Bunch',
            ],
            [
                'name' => 'Fresh Ginger (Adu)',
                'category_id' => $vegetables->id,
                'today_price' => 20.00,
                'unit' => '250g',
            ],
            [
                'name' => 'Sweet Bananas',
                'category_id' => $fruits->id,
                'today_price' => 50.00,
                'unit' => '1 Dozen',
            ],
            [
                'name' => 'Kesar Mangoes',
                'category_id' => $fruits->id,
                'today_price' => 120.00,
                'unit' => '1kg',
            ]
        ];

        $vendors = [$vendor1, $vendor2, $vendor3];

        foreach ($vendors as $vendor) {
            foreach ($sampleProducts as $productData) {
                Product::create([
                    'vendor_id' => $vendor->id,
                    'category_id' => $productData['category_id'],
                    'name' => $productData['name'],
                    'image' => null,
                    'today_price' => $productData['today_price'] + rand(-5, 5), // dynamic prices per vendor
                    'unit' => $productData['unit'],
                    'status' => 'active',
                ]);
            }
        }
    }
}
