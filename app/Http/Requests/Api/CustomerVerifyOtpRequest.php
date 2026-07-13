<?php

namespace App\Http\Requests\Api;

class CustomerVerifyOtpRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'mobile' => 'required|string|min:10|max:15',
            'otp' => 'required|string|min:4|max:6',
            'device_token' => 'nullable|string',
        ];
    }
}
