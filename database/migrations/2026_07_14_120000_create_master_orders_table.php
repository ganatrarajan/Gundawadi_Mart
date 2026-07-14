<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('master_orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('customers')->onDelete('cascade');
            $table->foreignId('address_id')->nullable()->constrained('addresses')->onDelete('set null');
            $table->text('delivery_address');
            $table->decimal('subtotal', 8, 2);
            $table->decimal('delivery_charge', 8, 2)->default(0.00);
            $table->decimal('handling_charge', 8, 2)->default(0.00);
            $table->decimal('platform_fee', 8, 2)->default(0.00);
            $table->decimal('total', 8, 2);
            $table->string('payment_method')->default('cash_on_delivery');
            $table->string('delivery_slot')->nullable();
            $table->string('status')->default('pending');
            $table->text('special_note')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('master_orders');
    }
};
