import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:lab4/data/order_model.dart';
import 'package:lab4/data/product_model.dart';
import 'package:lab4/data/product_storage.dart';

// Dữ liệu giả lập cho Dropdown (sử dụng lại từ Bài 2)
const Map<String, List<String>> mockLocationData = {
  'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Đống Đa'],
  'TP Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Quận Tân Bình'],
  'Đà Nẵng': ['Hải Châu', 'Thanh Khê', 'Sơn Trà'],
};

const Map<String, List<String>> mockWardData = {
  'Ba Đình': ['Phúc Xá', 'Trúc Bạch', 'Nguyễn Trung Trực'],
  'Hoàn Kiếm': ['Hàng Bạc', 'Hàng Buồm', 'Tràng Tiền'],
  'Quận 1': ['Bến Nghé', 'Bến Thành', 'Cầu Ông Lãnh'],
  'Hải Châu': ['Hải Châu 1', 'Hải Châu 2', 'Bình Hiên'],
  'Default': ['Phường 1', 'Phường 2', 'Phường 3'],
};

// ====================================================================
// MÀN HÌNH CHÍNH (OrderWizardScreen)
// ====================================================================

class OrderWizardScreen extends StatefulWidget {
  const OrderWizardScreen({super.key});

  @override
  State<OrderWizardScreen> createState() => _OrderWizardScreenState();
}

class _OrderWizardScreenState extends State<OrderWizardScreen> {
  int _currentStep = 0;
  final OrderStorage _orderStorage = OrderStorage();

  // --- STEP 1: Thông tin khách hàng ---
  final _customerFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Trần Văn B');
  final _emailController = TextEditingController(text: 'b@example.com');
  final _phoneController = TextEditingController(text: '0912345678');

  // --- STEP 2: Địa chỉ giao hàng ---
  final _addressFormKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController(text: 'Trần Văn B');
  final _recipientPhoneController = TextEditingController(text: '0912345678');
  final _detailsController = TextEditingController(text: '123 Đường Nguyễn Trãi');
  String? _selectedProvince = 'Hà Nội';
  String? _selectedDistrict = 'Đống Đa';
  String? _selectedWard = 'Phường 1';

  // --- STEP 3: Thanh toán & Xác nhận ---
  final _paymentFormKey = GlobalKey<FormState>();
  String? _paymentMethod = 'Cash'; // Mặc định là Tiền mặt
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _detailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- LOGIC CHUYỂN BƯỚC VÀ XÁC THỰC ---

  // Xử lý khi nhấn nút "Tiếp tục" hoặc "Xác nhận"
  void _onStepContinue() {
    bool isCurrentStepValid = false;

    // Kiểm tra xác thực của từng bước
    switch (_currentStep) {
      case 0:
        isCurrentStepValid = _customerFormKey.currentState!.validate();
        break;
      case 1:
        isCurrentStepValid = _addressFormKey.currentState!.validate();
        break;
      case 2:
        isCurrentStepValid = _paymentFormKey.currentState!.validate();
        break;
    }

    if (isCurrentStepValid) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        // Đã đến bước cuối cùng (Xác nhận)
        _confirmOrder();
      }
    }
  }

  // Xử lý khi nhấn nút "Quay lại"
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  // Xử lý khi xác nhận đơn hàng
  void _confirmOrder() async {
    // 1. Thu thập dữ liệu
    final deliveryAddress = Address(
      recipientName: _recipientNameController.text,
      phoneNumber: _recipientPhoneController.text,
      province: _selectedProvince!,
      district: _selectedDistrict!,
      ward: _selectedWard!,
      addressDetails: _detailsController.text,
    );

    final newOrder = Order(
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      customerPhone: _phoneController.text,
      deliveryAddress: deliveryAddress,
      paymentMethod: _paymentMethod!,
      orderNotes: _notesController.text,
    );

    // 2. Lưu vào local storage
    await _orderStorage.saveOrder(newOrder);

    // 3. Chuyển sang màn hình Chi tiết đơn hàng
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(order: newOrder),
        ),
      );
    }
  }

  // --- XÂY DỰNG CÁC BƯỚC (STEPS) ---

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Khách hàng'),
        subtitle: const Text('Thông tin liên hệ'),
        content: _buildCustomerInfoStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Địa chỉ'),
        subtitle: const Text('Giao hàng'),
        content: _buildAddressStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Thanh toán'),
        subtitle: const Text('Xác nhận'),
        content: _buildPaymentStep(),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Đơn Hàng Mới'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: _buildSteps(),

        // Custom Controls (để thay đổi chữ "CONTINUE" thành "XÁC NHẬN" ở bước cuối)
        controlsBuilder: (context, details) {
          final isLastStep = details.currentStep == _buildSteps().length - 1;
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                // Nút Tiếp tục / Xác nhận
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isLastStep ? 'XÁC NHẬN ĐƠN' : 'TIẾP TỤC'),
                ),
                const SizedBox(width: 10),
                // Nút Quay lại / Hủy
                if (details.currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('QUAY LẠI', style: TextStyle(color: Colors.black54)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CHO BƯỚC 1: Thông tin khách hàng ---
  Widget _buildCustomerInfoStep() {
    return Form(
      key: _customerFormKey,
      child: Column(
        children: <Widget>[
          _buildTextField('Tên khách hàng', _nameController),
          _buildTextField('Email', _emailController,
              keyboardType: TextInputType.emailAddress, isEmail: true),
          _buildTextField('Số điện thoại', _phoneController,
              keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  // --- WIDGET CHO BƯỚC 2: Địa chỉ giao hàng (Tái sử dụng logic Bài 2) ---
  Widget _buildAddressStep() {
    return Form(
      key: _addressFormKey,
      child: Column(
        children: <Widget>[
          _buildTextField('Tên người nhận', _recipientNameController),
          _buildTextField('SĐT người nhận', _recipientPhoneController,
              keyboardType: TextInputType.phone),

          // Tỉnh/Thành phố
          _buildDropdown('Tỉnh/Thành phố', _selectedProvince,
              mockLocationData.keys.toList(), (value) {
                setState(() {
                  _selectedProvince = value;
                  _selectedDistrict = null;
                  _selectedWard = null;
                });
              }),

          // Quận/Huyện (Phụ thuộc Tỉnh)
          _buildDropdown('Quận/Huyện', _selectedDistrict,
              _selectedProvince != null ? mockLocationData[_selectedProvince] ?? [] : [], (value) {
                setState(() {
                  _selectedDistrict = value;
                  _selectedWard = null;
                });
              }),

          // Phường/Xã (Phụ thuộc Quận)
          _buildDropdown('Phường/Xã', _selectedWard,
              _selectedDistrict != null ? mockWardData[_selectedDistrict] ?? mockWardData['Default']! : [], (value) {
                setState(() {
                  _selectedWard = value;
                });
              }),

          _buildMultilineTextField('Địa chỉ chi tiết', _detailsController),
        ],
      ),
    );
  }

  // --- WIDGET CHO BƯỚC 3: Thanh toán & Xác nhận ---
  Widget _buildPaymentStep() {
    return Form(
      key: _paymentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Chọn Phương Thức Thanh Toán', style: TextStyle(fontWeight: FontWeight.bold)),
          // Chọn Tiền mặt
          RadioListTile<String>(
            title: const Text('Tiền mặt (COD)'),
            value: 'Cash',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value),
            activeColor: Colors.indigo,
          ),
          // Chọn Thẻ
          RadioListTile<String>(
            title: const Text('Thanh toán bằng Thẻ'),
            value: 'Card',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value),
            activeColor: Colors.indigo,
          ),

          const SizedBox(height: 20),
          _buildMultilineTextField('Ghi chú đơn hàng (Tùy chọn)', _notesController, isRequired: false),

          // Tóm tắt đơn hàng (Giả lập)
          const Divider(),
          const Text('Tóm tắt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền hàng:'),
              Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(500000)),
            ],
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM HỖ TRỢ CHUNG (Tái sử dụng) ---

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label.';
          }
          if (isEmail && !value.contains('@')) {
            return 'Email không hợp lệ.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMultilineTextField(String label, TextEditingController controller,
      {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Vui lòng nhập $label.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue,
      List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
    );
  }
}

// ====================================================================
// MÀN HÌNH 4: CHI TIẾT ĐƠN HÀNG (OrderDetailScreen)
// ====================================================================

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Đơn Hàng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 10),
                  const Text('ĐẶT HÀNG THÀNH CÔNG!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  Text('Mã đơn hàng: ${order.orderId}',
                      style: const TextStyle(fontSize: 16)),
                  Text(
                      'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)}'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Divider(),
            _buildSectionTitle('1. Thông tin Khách hàng'),
            _buildDetailRow('Tên:', order.customerName),
            _buildDetailRow('Email:', order.customerEmail),
            _buildDetailRow('SĐT:', order.customerPhone),

            const Divider(),
            _buildSectionTitle('2. Địa chỉ Giao hàng'),
            _buildDetailRow('Người nhận:', order.deliveryAddress.recipientName),
            _buildDetailRow('SĐT nhận:', order.deliveryAddress.phoneNumber),
            _buildDetailRow('Địa chỉ:',
                '${order.deliveryAddress.addressDetails}, ${order.deliveryAddress.ward}, ${order.deliveryAddress.district}, ${order.deliveryAddress.province}'),

            const Divider(),
            _buildSectionTitle('3. Thanh toán & Ghi chú'),
            _buildDetailRow('Phương thức:', order.paymentMethod == 'Cash' ? 'Tiền mặt (COD)' : 'Thẻ/Chuyển khoản'),
            _buildDetailRow('Tổng tiền:', NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            _buildDetailRow('Ghi chú:', order.orderNotes.isEmpty ? '(Không có)' : order.orderNotes),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Quay về màn hình danh sách sản phẩm/trang chủ
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Quay về Trang chủ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
              child: Text(value, style: style ?? const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}