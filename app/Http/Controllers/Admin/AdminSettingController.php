<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class AdminSettingController extends Controller
{
    public function index()
    {
        $handlingCharge = Setting::getValue('handling_charge', '5.00');
        $platformFee = Setting::getValue('platform_fee', '10.00');
        $showHandlingCharge = Setting::getValue('show_handling_charge', 'yes');
        $showPlatformFee = Setting::getValue('show_platform_fee', 'yes');

        $deliverySlots = \App\Models\DeliverySlot::all();
        if ($deliverySlots->isEmpty()) {
            $defaults = [
                ['start_time' => '09:00 AM', 'end_time' => '12:00 PM', 'is_active' => true],
                ['start_time' => '12:00 PM', 'end_time' => '03:00 PM', 'is_active' => true],
                ['start_time' => '03:00 PM', 'end_time' => '06:00 PM', 'is_active' => true],
                ['start_time' => '06:00 PM', 'end_time' => '09:00 PM', 'is_active' => true],
            ];
            foreach ($defaults as $d) {
                \App\Models\DeliverySlot::create($d);
            }
            $deliverySlots = \App\Models\DeliverySlot::all();
        }

        return view('admin.settings.index', compact(
            'handlingCharge',
            'platformFee',
            'showHandlingCharge',
            'showPlatformFee',
            'deliverySlots'
        ));
    }

    public function update(Request $request)
    {
        $request->validate([
            'handling_charge' => 'required|numeric|min:0',
            'platform_fee' => 'required|numeric|min:0',
            'show_handling_charge' => 'required|in:yes,no',
            'show_platform_fee' => 'required|in:yes,no',
        ]);

        Setting::setValue('handling_charge', $request->input('handling_charge'));
        Setting::setValue('platform_fee', $request->input('platform_fee'));
        Setting::setValue('show_handling_charge', $request->input('show_handling_charge'));
        Setting::setValue('show_platform_fee', $request->input('show_platform_fee'));

        return redirect()->route('admin.settings.index')->with('success', 'System settings updated successfully.');
    }

    public function storeSlot(Request $request)
    {
        $request->validate([
            'start_time' => 'required|string',
            'end_time' => 'required|string',
        ]);

        \App\Models\DeliverySlot::create([
            'start_time' => $request->input('start_time'),
            'end_time' => $request->input('end_time'),
            'is_active' => $request->has('is_active') ? true : false,
        ]);

        return redirect()->route('admin.settings.index')->with('success', 'Delivery slot added successfully.');
    }

    public function toggleSlot($id)
    {
        $slot = \App\Models\DeliverySlot::findOrFail($id);
        $slot->update(['is_active' => !$slot->is_active]);

        return redirect()->route('admin.settings.index')->with('success', 'Delivery slot status updated successfully.');
    }

    public function deleteSlot($id)
    {
        $slot = \App\Models\DeliverySlot::findOrFail($id);
        $slot->delete();

        return redirect()->route('admin.settings.index')->with('success', 'Delivery slot deleted successfully.');
    }
}
