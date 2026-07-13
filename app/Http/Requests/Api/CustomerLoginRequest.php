<?php

namespace App\Http\Requests\Api;

class CustomerLoginRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'mobile' => 'required|string|min:10|max:15',
        ];
    }
}
