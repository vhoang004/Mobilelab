import 'dart:convert';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Product {
  final String id;
  String name;
  double price;
  String description;
  List<String> imagePaths; // Danh sách đường dẫn file ảnh cục bộ
  String category;
  bool hasDiscount;
  DateTime? discountEndTime;

  Product({
    String? id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePaths,
    required this.category,
    this.hasDiscount = false,
    this.discountEndTime,
  }) : id = id ?? uuid.v4(); // Tạo ID nếu chưa có

  // Chuyển đối tượng Product sang Map (dùng để lưu vào Shared Preferences/SQLite)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'description': description,
    'imagePaths': imagePaths,
    'category': category,
    'hasDiscount': hasDiscount,
    'discountEndTime': discountEndTime?.toIso8601String(),
  };

  // Tạo đối tượng Product từ Map (đọc từ Shared Preferences/SQLite)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as double,
      description: json['description'] as String,
      imagePaths: (json['imagePaths'] as List<dynamic>).cast<String>(),
      category: json['category'] as String,
      hasDiscount: json['hasDiscount'] as bool,
      discountEndTime: json['discountEndTime'] != null
          ? DateTime.parse(json['discountEndTime'] as String)
          : null,
    );
  }
}