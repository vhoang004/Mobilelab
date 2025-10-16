<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    // Tên bảng (nếu bảng trong DB là 'categories' thì có thể bỏ dòng này)
    protected $table = 'categories';

    // Các cột được phép gán giá trị hàng loạt
    protected $fillable = [
        'name',
    ];

    // Nếu bạn không dùng timestamps (created_at, updated_at)
    // thì có thể bật dòng dưới để tắt tự động
    // public $timestamps = false;

    // Quan hệ 1-nhiều với Product (nếu có)
    public function products()
    {
        return $this->hasMany(Product::class);
    }
}
