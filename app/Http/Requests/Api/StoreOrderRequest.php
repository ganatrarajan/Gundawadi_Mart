<?php

namespace App\Http\Requests\Api;

class StoreOrderRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'vendor_id' => 'required|exists:vendors,id',
            'address_id' => 'nullable|exists:addresses,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'nullable|numeric|min:0',
            'items.*.unit' => 'nullable|string|max:55',
            'special_note' => 'nullable|string|max:1000',
            'delivery_slot' => 'nullable|string|max:255',
        ];
    }

    protected function failedValidation(\Illuminate\Contracts\Validation\Validator $validator)
    {
        \Log::info('StoreOrderRequest Validation Failed!', [
            'request_data' => $this->all(),
            'errors' => $validator->errors()->toArray()
        ]);
        parent::failedValidation($validator);
    }
}
