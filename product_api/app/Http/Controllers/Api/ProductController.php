<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ProductController extends Controller
{
    // Lấy danh sách tất cả product (kèm category)
    public function index()
    {
        $products = Cache::remember('products', 60, function () {
            return Product::with('category')->get();
        });
        return response()->json($products, 200);
    }

    // Tạo mới product
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
        ]);

        $product = Product::create($request->all());
        Cache::forget('products');
        return response()->json($product, 201);
    }

    // Lấy chi tiết product (kèm category)
    public function show($id)
    {
        $product = Product::with('category')->findOrFail($id);
        return response()->json($product, 200);
    }

    // Cập nhật product
    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'price' => 'sometimes|numeric',
            'description' => 'nullable|string',
            'category_id' => 'sometimes|exists:categories,id',
        ]);

        $product = Product::findOrFail($id);
        $product->update($request->all());
        Cache::forget('products');
        return response()->json($product, 200);
    }

    // Xóa product
    public function destroy($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
        Cache::forget('products');
        return response()->json(['message' => 'Product deleted successfully'], 200);
    }
}
