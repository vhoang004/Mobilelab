import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'data/product_model.dart';
import 'data/product_storage.dart';
import 'package:intl/intl.dart';

// Import thư viện path_provider, image_picker, uuid đã thêm vào pubspec.yaml

void main() {
  // Cần thêm package intl cho DateFormat nếu muốn định dạng ngày tháng đẹp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Sản Phẩm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ProductListScreen(),
    );
  }
}

// ====================================================================
// MÀN HÌNH 1: DANH SÁCH SẢN PHẨM (ProductListScreen)
// ====================================================================

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductStorage _storage = ProductStorage();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _storage.loadProducts();
    });
  }

  // Hàm mở form thêm/chỉnh sửa
  void _openAddEditForm({Product? product}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    );
    _loadProducts(); // Load lại danh sách sau khi lưu
  }

  // Hàm xóa sản phẩm
  void _deleteProduct(Product product) async {
    // Xóa file ảnh cục bộ trước
    for (var path in product.imagePaths) {
      try {
        await File(path).delete();
      } catch (e) {
        print('Could not delete file: $e');
      }
    }
    // Xóa khỏi Storage
    await _storage.deleteProduct(product.id);
    _loadProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa sản phẩm thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Sản Phẩm'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imagePath = product.imagePaths.isNotEmpty
                  ? product.imagePaths.first
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: imagePath != null && File(imagePath).existsSync()
                        ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.inventory_2_outlined,
                        color: Colors.grey),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                      'Category: ${product.category}\nPrice: \$${product.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openAddEditForm(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Xem chi tiết sản phẩm (chưa triển khai chi tiết)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing ${product.name}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ====================================================================
// MÀN HÌNH 2: FORM THÊM/CHỈNH SỬA SẢN PHẨM (AddEditProductScreen)
// ====================================================================

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductStorage _storage = ProductStorage();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Biến trạng thái
  String? _selectedCategory;
  bool _hasDiscount = false;
  DateTime? _discountEndTime;
  final List<String> _imagePaths = []; // Đường dẫn file ảnh cục bộ

  // Dữ liệu giả lập
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Food',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _descriptionController.text = p.description;
      _selectedCategory = p.category;
      _hasDiscount = p.hasDiscount;
      _discountEndTime = p.discountEndTime;
      _imagePaths.addAll(p.imagePaths);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ ẢNH ---

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      // Lưu file vào thư mục tài liệu của ứng dụng
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'product_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final newPath = '${appDir.path}/$fileName';

      // Sao chép file
      final savedFile = await file.copy(newPath);

      setState(() {
        _imagePaths.add(savedFile.path);
      });
    }
  }

  void _removeImage(String path) {
    setState(() {
      _imagePaths.remove(path);
      // Có thể thêm logic xóa file vật lý ở đây nếu cần,
      // nhưng thường để cho hàm _deleteProduct xử lý.
    });
  }

  // --- LOGIC XỬ LÝ DATE TIME ---

  Future<void> _selectDiscountEndTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _discountEndTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_discountEndTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _discountEndTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // --- LOGIC LƯU DỮ LIỆU ---

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // Xử lý giá trị float từ TextEditingController
      final price = double.tryParse(_priceController.text);
      if (price == null) {
        // Thông báo lỗi nếu giá không hợp lệ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giá không hợp lệ.')),
        );
        return;
      }

      // Tạo đối tượng Product
      final newProduct = Product(
        id: widget.product?.id, // Giữ ID cũ nếu đang chỉnh sửa
        name: _nameController.text,
        price: price,
        description: _descriptionController.text,
        imagePaths: _imagePaths,
        category: _selectedCategory!,
        hasDiscount: _hasDiscount,
        discountEndTime: _hasDiscount ? _discountEndTime : null,
      );

      // Lưu vào local storage
      await _storage.saveProduct(newProduct);
      // Quay lại màn hình danh sách
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Sản phẩm ${widget.product == null ? "đã thêm" : "đã cập nhật"} thành công!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.product == null ? 'Thêm Sản Phẩm Mới' : 'Chỉnh Sửa Sản Phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Tên sản phẩm
              _buildTextField('Tên sản phẩm', _nameController, isRequired: true),

              // 2. Giá (Kiểu số)
              _buildTextField('Giá (\$)', _priceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Giá phải là số.';
                    }
                    return null;
                  }),

              // 3. Mô tả (Multiline)
              _buildTextField('Mô tả', _descriptionController,
                  maxLines: 4, isRequired: true),

              // 4. Hình ảnh sản phẩm
              _buildImagePickerSection(),

              // 5. Danh mục (Dropdown)
              _buildDropdown('Danh mục', _selectedCategory, _categories,
                      (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }),

              // 6. Ưu đãi (Switch)
              _buildSwitch('Ưu đãi / Khuyến mãi', _hasDiscount, (value) {
                setState(() {
                  _hasDiscount = value;
                  if (!value) {
                    _discountEndTime = null;
                  }
                });
              }),

              // 7. Thời gian khuyến mãi (DateTime picker)
              if (_hasDiscount) _buildDiscountTimePicker(),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HỖ TRỢ ---

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        bool isRequired = false,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            validator: validator ??
                    (value) {
                  if (isRequired && (value == null || value.isEmpty)) {
                    return 'Vui lòng nhập $label.';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue,
      List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            value: selectedValue,
            hint: Text('Chọn $label'),
            isExpanded: true,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn $label.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(
      String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTimePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thời gian kết thúc khuyến mãi',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _selectDiscountEndTime,
            icon: const Icon(Icons.calendar_today, color: Colors.indigo),
            label: Text(
              _discountEndTime == null
                  ? 'Chọn ngày và giờ'
                  : DateFormat('dd/MM/yyyy HH:mm')
                  .format(_discountEndTime!),
              style: const TextStyle(color: Colors.indigo),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (_hasDiscount && _discountEndTime == null)
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                'Vui lòng chọn thời gian kết thúc ưu đãi.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hình ảnh sản phẩm',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          Row(
            children: [
              // Nút Upload
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.upload_file),
                label: const Text('Tải ảnh lên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              // Nút Chụp ảnh
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Danh sách Thumbnail đã chọn
          if (_imagePaths.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) {
                  final path = _imagePaths[index];
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeImage(path),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (_imagePaths.isEmpty)
            const Text('Chưa có ảnh nào được chọn.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}