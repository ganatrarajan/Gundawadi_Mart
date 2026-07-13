<?php

namespace App\Http\Requests\Api;

class UpdateProductPriceRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'today_price' => 'required|numeric|min:0',
        ];
    }
}
