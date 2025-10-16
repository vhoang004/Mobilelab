import 'category.dart';

class Product {
  final int? id; // Có thể null (khi tạo mới)
  final String name;
  final String? description;
  final String price;
  final Category? category;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
  });

  // 🧩 Chuyển dữ liệu JSON -> Object Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''), // ép an toàn
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toString() ?? '0',
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  // 🧩 Chuyển Object Product -> JSON để gửi lên API
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
    };

    // Nếu có category thì thêm category_id vào JSON
    if (category?.id != null) {
      data['category_id'] = category!.id;
    }

    return data;
  }
}

