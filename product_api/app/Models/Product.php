<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    // Các cột được phép gán giá trị hàng loạt (mass assignment)
    protected $fillable = [
        'name',
        'description',
        'price',
        'category_id', // ✅ thêm dòng này để tránh lỗi 500
    ];

    /**
     * Định nghĩa mối quan hệ: Product thuộc về một Category
     */
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
