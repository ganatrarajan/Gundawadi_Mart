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
        Schema::create('customers', function (Blueprint $table) {
            $table->id();
            $table->string('name')->nullable();
            $table->string('mobile')->unique();
            $table->string('password')->nullable();
            $table->string('status')->default('pending_approval'); // pending_approval, approved, rejected, inactive
            $table->text('rejection_reason')->nullable();
            $table->decimal('delivery_km', 8, 2)->nullable();
            $table->decimal('delivery_charge', 8, 2)->nullable();
            $table->string('profile_photo')->nullable();
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
        Schema::dropIfExists('customers');
    }
};
