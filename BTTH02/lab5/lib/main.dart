import 'package:flutter/material.dart';
import 'package:flutter/src/material/icons.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. MODEL DỮ LIỆU SẢN PHẨM ---
class Product {
  final String name;
  final double price;
  final String category;
  final DateTime dateAdded;

  Product(
      {required this.name,
        required this.price,
        required this.category,
        required this.dateAdded});
}

// --- 2. ỨNG DỤNG CHÍNH ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lọc & Hiển Thị Sản Phẩm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF37474F), // Màu xanh xám đậm
            elevation: 0,
          )
      ),
      home: const FilterScreen(),
    );
  }
}

// --- 3. MÀN HÌNH LỌC SẢN PHẨM ---
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // --- A. CONTROLLERS VÀ CẤU HÌNH ---
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _availableCategories = [
    'Điện thoại',
    'Thời trang',
    'Gia dụng',
    'Sách',
    'Phụ kiện'
  ];
  final List<String> _sortOptions = ['Giá tăng', 'Giá giảm', 'Mới nhất'];

  // --- B. TRẠNG THÁI LỌC HIỆN TẠI (Được khởi tạo theo mặc định) ---
  Set<String> _selectedCategories = {};
  String _selectedSortOption = 'Mới nhất';

  // --- C. DỮ LIỆU VÀ KẾT QUẢ ---
  List<Product> _initialProducts = [];
  List<Product> _filteredProducts = [];

  // --- D. TRẠNG THÁI GIAO DIỆN VÀ PHÂN TRANG ---
  static const int _pageSize = 5;
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Tạo dữ liệu giả định
    _initialProducts = _generateDummyData();
    // 2. Áp dụng bộ lọc lần đầu (hiển thị tất cả)
    _filterProducts(initialLoad: true);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  // Hàm tạo dữ liệu sản phẩm giả
  List<Product> _generateDummyData() {
    final now = DateTime.now();
    return List<Product>.generate(
        17, // Tạo 17 sản phẩm để thử nghiệm phân trang (17/5 = 4 trang)
            (i) => Product(
          name: 'Sản phẩm số ${i + 1}',
          price: 50000 + (i % 7) * 80000.0 + (i * 5000.0),
          category: _availableCategories[i % _availableCategories.length],
          dateAdded: now.subtract(Duration(days: i * 3)), // Ngày cũ dần
        ));
  }

  // --- E. LOGIC LỌC SẢN PHẨM ---
  void _filterProducts({bool initialLoad = false}) {
    if (!initialLoad && _formKey.currentState!.validate() == false) return;

    setState(() {
      _isLoading = true;
    });

    // Mô phỏng độ trễ tìm kiếm để người dùng thấy loading
    Future.delayed(const Duration(milliseconds: 700), () {
      List<Product> results = List.from(_initialProducts);

      // Lấy giá trị lọc
      final minPrice = double.tryParse(_minPriceController.text) ?? 0.0;
      // Nếu maxPrice bị trống, coi như không giới hạn, nếu có nhập thì parse
      final maxPrice = _maxPriceController.text.isEmpty
          ? double.infinity
          : (double.tryParse(_maxPriceController.text) ?? double.infinity);

      // 1. Lọc theo Khoảng giá
      results = results.where((p) => p.price >= minPrice && p.price <= maxPrice).toList();

      // 2. Lọc theo Danh mục
      if (_selectedCategories.isNotEmpty) {
        results = results.where((p) => _selectedCategories.contains(p.category)).toList();
      }

      // 3. Sắp xếp
      results.sort((a, b) {
        if (_selectedSortOption == 'Giá tăng') {
          return a.price.compareTo(b.price);
        } else if (_selectedSortOption == 'Giá giảm') {
          return b.price.compareTo(a.price);
        } else if (_selectedSortOption == 'Mới nhất') {
          return b.dateAdded.compareTo(a.dateAdded); // Mới nhất là ngày lớn nhất
        }
        return 0;
      });

      setState(() {
        _filteredProducts = results;
        _currentPage = 1; // Reset về trang 1 sau khi lọc
        _isLoading = false;
      });
    });
  }

  // --- F. LOGIC ĐẶT LẠI (RESET) ---
  void _resetFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedCategories.clear();
      _selectedSortOption = 'Mới nhất';
      _currentPage = 1;
    });
    // Áp dụng bộ lọc mặc định (hiển thị lại tất cả)
    _filterProducts();
  }

  // --- G. LOGIC PHÂN TRANG ---
  List<Product> _getCurrentPageResults() {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= _filteredProducts.length) {
      return [];
    }

    return _filteredProducts.sublist(
      startIndex,
      endIndex.clamp(0, _filteredProducts.length),
    );
  }

  void _goToPage(int page) {
    if (page < 1 || page > (_filteredProducts.length / _pageSize).ceil()) return;
    setState(() {
      _currentPage = page;
      // Scroll lên đầu trang khi chuyển trang
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
    });
  }

  // --- H. UI BUILDERS ---

  Widget _buildPriceInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF37474F))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: (value) {
            // Kiểm tra chỉ khi không rỗng
            if (value != null && value.isNotEmpty) {
              if (double.tryParse(value) == null) {
                return 'Phải là số';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'VD: 500000',
            // SỬA LỖI Ở ĐÂY: Thay 'currency_vnd' bằng một icon hợp lệ như 'monetization_on'
            // và bỏ 'const' vì controller không phải là hằng số.
            prefixIcon: Icon(Icons.monetization_on, size: 20, color: Colors.blueGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey.shade50,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('3. Danh mục (Chọn nhiều)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              backgroundColor: Colors.grey.shade200,
              selectedColor: const Color(0xFF37474F),
              checkmarkColor: Colors.white,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('4. Xếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.blueGrey.shade100)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSortOption,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF37474F)),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSortOption = newValue;
                  });
                }
              },
              items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: BorderRadius.circular(8)
          ),
          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF37474F), size: 28),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Danh mục: ${product.category}', style: TextStyle(color: Colors.grey.shade600)),
            Text('Ngày thêm: ${product.dateAdded.day}/${product.dateAdded.month}/${product.dateAdded.year}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        trailing: Text(
          '${product.price.toStringAsFixed(0)} VNĐ',
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_filteredProducts.length / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: _currentPage > 1 ? const Color(0xFF37474F) : Colors.grey,
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang $_currentPage / $totalPages',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF37474F)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            color: _currentPage < totalPages ? const Color(0xFF37474F) : Colors.grey,
            onPressed: _currentPage < totalPages ? () => _goToPage(_currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPageResults = _getCurrentPageResults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LỌC SẢN PHẨM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- KHU VỰC LỌC (FILTER FORM) ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. Khoảng giá (VNĐ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildPriceInput('Từ giá', _minPriceController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPriceInput('Đến giá', _maxPriceController)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. DANH MỤC
                      _buildCategoryFilter(),
                      const SizedBox(height: 20),

                      // 4. XẾP THEO
                      _buildSortDropdown(),
                      const SizedBox(height: 30),

                      // 5. NÚT ÁP DỤNG VÀ ĐẶT LẠI
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.cached, size: 20),
                              label: const Text('Đặt lại'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(color: Colors.grey.shade400)
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _filterProducts(),
                              icon: const Icon(Icons.filter_alt, color: Colors.white, size: 20),
                              label: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF37474F),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text('KẾT QUẢ SẢN PHẨM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Divider(thickness: 2, color: Color(0xFF37474F)),

            // --- KHU VỰC HIỂN THỊ KẾT QUẢ ĐỘNG ---
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFF37474F)),
              ))
            else if (_filteredProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text('Không tìm thấy sản phẩm nào.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Hiển thị tổng số kết quả
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Tìm thấy ${_filteredProducts.length} sản phẩm (Trang $_currentPage)',
                      style: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Danh sách sản phẩm (chỉ hiển thị theo trang)
                  ...currentPageResults.map(_buildResultItem).toList(),

                  // Thanh điều khiển phân trang
                  _buildPaginationControls(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
