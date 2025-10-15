import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'product_model.dart';

class ProductStorage {
  static const _key = 'product_list';

  // Lấy tất cả sản phẩm
  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  // Lưu danh sách sản phẩm
  Future<void> _saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  // Thêm hoặc cập nhật sản phẩm
  Future<void> saveProduct(Product product) async {
    final products = await loadProducts();
    final index = products.indexWhere((p) => p.id == product.id);

    if (index != -1) {
      products[index] = product; // Cập nhật
    } else {
      products.add(product); // Thêm mới
    }
    await _saveProducts(products);
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    final products = await loadProducts();
    products.removeWhere((p) => p.id == productId);
    await _saveProducts(products);
  }
}