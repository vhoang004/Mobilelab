import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhập thông tin sinh viên',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Sử dụng một font chữ hiện đại, rõ ràng
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5), // Màu xanh AppBar
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Cấu hình màu cho InputDecoration
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // Ban đầu không có border visible
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
      ),
      home: const StudentFormScreen(),
    );
  }
}

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  // Key để quản lý trạng thái của Form và kích hoạt validation
  final _formKey = GlobalKey<FormState>();

  // Controllers để quản lý và lấy dữ liệu từ các trường nhập liệu
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút "Ghi"
  void _saveStudentInfo() {
    // Kiểm tra và kích hoạt validation của toàn bộ form
    if (_formKey.currentState!.validate()) {
      // Nếu form hợp lệ, in ra dữ liệu (hoặc lưu vào database)
      print('--- DỮ LIỆU ĐƯỢC GHI ---');
      print('Họ và tên: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Điện thoại: ${_phoneController.text}');
      print('Địa chỉ: ${_addressController.text}');
      print('Thành phố: ${_cityController.text}');

      // Hiển thị thông báo thành công (thay thế cho alert())
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu thông tin sinh viên thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Form không hợp lệ, validation messages đã được hiển thị
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ và chính xác thông tin.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm xây dựng trường nhập liệu chung (TextFormField)
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String validationMessage,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          // Decoration mô phỏng giao diện trong hình ảnh
          decoration: InputDecoration(
            hintText: labelText,
            prefixIcon: Icon(icon, color: Colors.blueGrey.shade400),
            // Định nghĩa style cho border khi có lỗi (màu đỏ như trong ảnh)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            // Border khi trường được focus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          // Logic Validation
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            // Thêm kiểm tra định dạng email cơ bản
            if (labelText == 'Email' && !value.contains('@')) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        // Điều chỉnh khoảng cách giữa TextFormField và validation error message
        // Error message style được định nghĩa tự động, đây chỉ là khoảng cách
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập thông tin sinh viên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // 1. Họ và tên
              _buildTextField(
                controller: _nameController,
                labelText: 'Họ và tên',
                icon: Icons.person_outline,
                validationMessage: 'Hãy nhập họ và tên',
                // Hỗ trợ nhập tiếng Việt có dấu
                keyboardType: TextInputType.name,
              ),

              // 2. Email
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email_outlined,
                validationMessage: 'Hãy nhập email',
                keyboardType: TextInputType.emailAddress,
              ),

              // 3. Điện thoại
              _buildTextField(
                controller: _phoneController,
                labelText: 'Điện thoại',
                icon: Icons.phone_android_outlined,
                validationMessage: 'Hãy nhập điện thoại',
                keyboardType: TextInputType.phone,
              ),

              // 4. Địa chỉ
              _buildTextField(
                controller: _addressController,
                labelText: 'Địa chỉ',
                icon: Icons.location_on_outlined,
                validationMessage: 'Hãy nhập địa chỉ',
              ),

              // 5. Thành phố
              _buildTextField(
                controller: _cityController,
                labelText: 'Thành phố',
                icon: Icons.location_city_outlined,
                validationMessage: 'Hãy nhập thành phố',
              ),

              const SizedBox(height: 25),

              // Nút "Ghi"
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveStudentInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3), // Màu xanh dương
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Ghi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
