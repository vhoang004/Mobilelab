import 'package:flutter/material.dart';
import '../api_service.dart';
import '../product.dart';
import '../category.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final ApiService apiService = ApiService();
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _loadingCategories = true;

  // 🧹 Giải phóng controller khi widget bị hủy
  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 💾 Hàm lưu sản phẩm mới
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        price: _priceController.text.trim(),
        category: _selectedCategory,
      );

      try {
        await apiService.createProduct(newProduct);
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Lỗi khi tạo sản phẩm: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final all = await apiService.fetchCategories();
      // Lọc theo 4 tên yêu cầu để hiển thị đúng danh sách nhưng giữ nguyên ID từ DB
      const allowed = {
        'Đồ điện tử',
        'Đồ dân dụng',
        'Dụng cụ dân dụng',
        'Đồ gia dụng',
      };
      final filtered = all.where((c) => allowed.contains(c.name)).toList();
      if (!mounted) return;
      setState(() {
        _categories = filtered.isNotEmpty ? filtered : all;
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh mục: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm sản phẩm mới"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tên sản phẩm
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Tên sản phẩm",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Vui lòng nhập tên" : null,
              ),
              const SizedBox(height: 12),

              // Danh mục (lấy từ API, lọc theo tên yêu cầu)
              _loadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: _categories
                          .map((c) => DropdownMenuItem<Category>(
                                value: c,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null
                          ? 'Vui lòng chọn danh mục'
                          : null,
                    ),
              const SizedBox(height: 12),

              // Mô tả
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Mô tả",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Giá sản phẩm
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Giá",
                  border: OutlineInputBorder(),
                  prefixText: "\$ ",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập giá";
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return "Giá phải là số dương";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.save),
                  label: const Text("Lưu sản phẩm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
