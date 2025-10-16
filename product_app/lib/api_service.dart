// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'category.dart';

class ApiService {
  // ⚠️ Lưu ý:
  // - Dùng 10.0.2.2 nếu chạy trên Android emulator
  // - Dùng IP máy thật nếu test trên điện thoại thật
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // -------------------------------
  // 🔹 Lấy danh sách sản phẩm
  // -------------------------------
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);

      // Parse JSON trả về thành danh sách Product
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(
        'Không thể tải danh sách sản phẩm (${response.statusCode})',
      );
    }
  }

  // -------------------------------
  // 🔹 Lấy danh sách danh mục
  // -------------------------------
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception(
        'Không thể tải danh mục (${response.statusCode})',
      );
    }
  }

  // -------------------------------
  // 🔹 Thêm sản phẩm mới
  // -------------------------------
  Future<void> createProduct(Product product) async {
    final Map<String, dynamic> data = {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      // 👇 gửi category_id nếu có
      if (product.category != null) 'category_id': product.category!.id,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      // Laravel có thể trả lỗi validation (422) hoặc lỗi khác
      throw Exception(
        'Không thể tạo sản phẩm (${response.statusCode}): ${response.body}',
      );
    }
  }

  // -------------------------------
  // 🔹 Xóa sản phẩm
  // -------------------------------
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Không thể xóa sản phẩm (mã lỗi ${response.statusCode})',
      );
    }
  }
}

