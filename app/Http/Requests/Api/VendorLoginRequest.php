<?php

namespace App\Http\Requests\Api;

class VendorLoginRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'mobile' => 'required|string|exists:vendors,mobile_number',
        ];
    }

    public function messages(): array
    {
        return [
            'mobile.exists' => 'Vendor is not registered with this mobile number. Please contact Admin.',
        ];
    }
}
