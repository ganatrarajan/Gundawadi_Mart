<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('customers')->onDelete('cascade');
            $table->string('full_name');
            $table->string('mobile');
            $table->string('house_number');
            $table->string('street');
            $table->string('area');
            $table->string('landmark')->nullable();
            $table->string('city')->default('Rajkot');
            $table->string('pincode')->nullable();
            $table->decimal('delivery_km', 8, 2)->nullable();
            $table->decimal('delivery_charge', 8, 2)->nullable();
            $table->string('status')->default('pending'); // pending, approved, rejected, replaced
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('addresses');
    }
};
