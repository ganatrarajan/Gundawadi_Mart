<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->timestamps();
        });

        // Seed default values
        \Illuminate\Support\Facades\DB::table('settings')->insert([
            ['key' => 'handling_charge', 'value' => '5.00', 'created_at' => now(), 'updated_at' => now()],
            ['key' => 'platform_fee', 'value' => '10.00', 'created_at' => now(), 'updated_at' => now()],
            ['key' => 'show_handling_charge', 'value' => 'yes', 'created_at' => now(), 'updated_at' => now()],
            ['key' => 'show_platform_fee', 'value' => 'yes', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};
