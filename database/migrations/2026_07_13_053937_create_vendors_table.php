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
        Schema::create('vendors', function (Blueprint $table) {
            $table->id();
            $table->string('shop_name');
            $table->string('owner_name');
            $table->string('mobile_number')->unique();
            $table->string('shop_photo')->nullable();
            $table->string('password')->nullable();
            $table->string('shop_address');
            $table->string('opening_time')->default('06:00 AM');
            $table->string('closing_time')->default('08:00 PM');
            $table->string('status')->default('active'); // active, inactive
            $table->string('otp')->nullable();
            $table->timestamp('otp_expires_at')->nullable();
            $table->string('device_token')->nullable(); // for FCM notifications
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vendors');
    }
};
