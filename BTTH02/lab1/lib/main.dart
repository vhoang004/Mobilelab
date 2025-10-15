import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đăng Ký Tài Khoản',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Biến lưu trạng thái giới tính được chọn
  String? _selectedGender;
  // Biến lưu trạng thái đồng ý điều khoản
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền nhẹ nhàng cho toàn bộ màn hình
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF485A9A), // màu xanh đậm
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Đăng Ký Tài Khoản',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tạo tài khoản để bắt đầu trải nghiệm',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.person_add, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          // Tạo khung nền trắng bao quanh form
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // Trường Họ & Tên
              _buildTextField('Họ & tên', 'Nguyễn Văn A', Icons.person),
              const SizedBox(height: 15),

              // Trường Email
              _buildTextField('Email', 'example@email.com', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),

              // Trường Số điện thoại
              _buildTextField('Số điện thoại', '0987654321', Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 15),

              // Trường Mật khẩu
              _buildTextField('Mật khẩu', 'Ít nhất 6 ký tự', Icons.lock,
                  obscureText: true),
              const SizedBox(height: 15),

              // Trường Xác nhận mật khẩu
              _buildTextField(
                  'Xác nhận mật khẩu', 'Nhập lại mật khẩu', Icons.lock,
                  obscureText: true),
              const SizedBox(height: 15),

              // Trường Ngày sinh
              _buildDateField('Ngày sinh', 'dd/mm/yyyy'),
              const SizedBox(height: 15),

              // Phần Giới tính
              const Text(
                'Giới tính',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              _buildGenderSelection(),
              const SizedBox(height: 15),

              // Checkbox Điều khoản sử dụng
              _buildTermsAndConditionsCheckbox(),
              const SizedBox(height: 25),

              // Nút Đăng Ký
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agreedToTerms ? () {
                    // Xử lý logic đăng ký ở đây
                    print('Đã nhấn nút Đăng Ký');
                  } : null, // Nút bị vô hiệu hóa nếu chưa đồng ý điều khoản
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF485A9A), // Màu xanh đậm
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Đăng Ký',
                    style: TextStyle(
                      fontSize: 18,
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

  // Hàm xây dựng TextField chung
  Widget _buildTextField(String label, String hint, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFF485A9A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm xây dựng Trường Ngày sinh (Date Field)
  Widget _buildDateField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.grey),
              onPressed: () {
                _selectDate(context); // Mở Date Picker
              },
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFF485A9A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm xử lý chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF485A9A), // Header background color
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF485A9A)), // Selected day color
            buttonTheme:
            const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Logic cập nhật ngày sinh đã chọn (chưa triển khai đầy đủ trong ví dụ này)
      print('Ngày đã chọn: ${picked.day}/${picked.month}/${picked.year}');
    }
  }

  // Hàm xây dựng lựa chọn Giới tính
  Widget _buildGenderSelection() {
    return Row(
      children: <Widget>[
        _buildGenderRadio('Nam'),
        _buildGenderRadio('Nữ'),
        _buildGenderRadio('Khác'),
      ],
    );
  }

  // Hàm xây dựng Radio Button cho giới tính
  Widget _buildGenderRadio(String title) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: title,
            groupValue: _selectedGender,
            activeColor: const Color(0xFF485A9A),
            onChanged: (String? value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          Text(title),
        ],
      ),
    );
  }

  // Hàm xây dựng Checkbox Điều khoản
  Widget _buildTermsAndConditionsCheckbox() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFF485A9A),
        ),
        const Flexible(
          child: Text(
            'Tôi đồng ý với điều khoản sử dụng',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}