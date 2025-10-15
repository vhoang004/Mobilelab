import 'package:flutter/material.dart';
import 'dart:math';

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

// Model cho Địa chỉ
class Address {
  String id;
  String recipientName;
  String phoneNumber;
  String province;
  String district;
  String ward;
  String addressDetails;
  double? latitude;
  double? longitude;

  Address({
    required this.recipientName,
    required this.phoneNumber,
    required this.province,
    required this.district,
    required this.ward,
    required this.addressDetails,
    this.latitude,
    this.longitude,
    String? customId,
  }) : id = customId ?? Random().nextInt(100000).toString(); // Gán customId hoặc tạo mới

  Address copyWith({
    String? recipientName,
    String? phoneNumber,
    String? province,
    String? district,
    String? ward,
    String? addressDetails,
    double? latitude,
    double? longitude,
    String? newId,
  }) {
    return Address(
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      addressDetails: addressDetails ?? this.addressDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      // Khi tạo Address mới, truyền ID cũ hoặc ID mới thông qua customId:
      customId: newId ?? this.id,
    );
  }
}


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Địa Chỉ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AddressListScreen(),
    );
  }
}

// ====================================================================
// MÀN HÌNH 1: DANH SÁCH ĐỊA CHỈ (AddressListScreen)
// ====================================================================

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<Address> addresses = [
    Address(
      recipientName: 'Nguyễn Văn A',
      phoneNumber: '0987654321',
      province: 'TP Hồ Chí Minh',
      district: 'Quận 1',
      ward: 'Bến Nghé',
      addressDetails: '123 Đường Lê Lợi',
    )
  ];

  // Hàm thêm/cập nhật địa chỉ
  void _saveAddress(Address newAddress, {Address? oldAddress}) {
    setState(() {
      if (oldAddress != null) {
        // Cập nhật địa chỉ cũ
        final index = addresses.indexWhere((addr) => addr.id == oldAddress.id);
        if (index != -1) {
          // Đổi tên tham số từ id thành newId (hoặc tên bạn đã chọn)
          addresses[index] = newAddress.copyWith(newId: oldAddress.id);
        }
      } else {
        // Thêm địa chỉ mới
        addresses.add(newAddress);
      }
    });
  }

  // Hàm xóa địa chỉ
  void _deleteAddress(String id) {
    setState(() {
      addresses.removeWhere((addr) => addr.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa địa chỉ thành công!')),
    );
  }

  // Hàm mở form thêm/chỉnh sửa
  void _openAddEditForm({Address? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddAddressForm(
            onSave: (newAddress) {
              _saveAddress(newAddress, oldAddress: address);
              Navigator.pop(context);
            },
            initialAddress: address,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Địa Chỉ'),
      ),
      body: addresses.isEmpty
          ? const Center(
        child: Text('Chưa có địa chỉ nào được lưu.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(address.recipientName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.phoneNumber),
                  Text(
                      '${address.addressDetails}, ${address.ward}, ${address.district}, ${address.province}'),
                  if (address.latitude != null)
                    Text(
                        'Vị trí Map: Lat ${address.latitude!.toStringAsFixed(4)}, Lng ${address.longitude!.toStringAsFixed(4)}',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _openAddEditForm(address: address),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAddress(address.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditForm(),
        label: const Text('Thêm Địa Chỉ Mới'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

// ====================================================================
// MÀN HÌNH 2: FORM THÊM ĐỊA CHỈ MỚI (AddAddressForm)
// ====================================================================

class AddAddressForm extends StatefulWidget {
  final Function(Address) onSave;
  final Address? initialAddress;

  const AddAddressForm({
    super.key,
    required this.onSave,
    this.initialAddress,
  });

  @override
  State<AddAddressForm> createState() => _AddAddressFormState();
}

class _AddAddressFormState extends State<AddAddressForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường Text
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();

  // Biến cho Dropdown và Map
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu nếu là chế độ chỉnh sửa
    if (widget.initialAddress != null) {
      final addr = widget.initialAddress!;
      _nameController.text = addr.recipientName;
      _phoneController.text = addr.phoneNumber;
      _detailsController.text = addr.addressDetails;
      _selectedProvince = addr.province;
      _selectedDistrict = addr.district;
      _selectedWard = addr.ward;
      _latitude = addr.latitude;
      _longitude = addr.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        recipientName: _nameController.text,
        phoneNumber: _phoneController.text,
        province: _selectedProvince!,
        district: _selectedDistrict!,
        ward: _selectedWard!,
        addressDetails: _detailsController.text,
        latitude: _latitude,
        longitude: _longitude,
      );
      widget.onSave(newAddress);
    }
  }

  // Hàm mở màn hình chọn Map
  void _openMapPicker() async {
    final result = await Navigator.of(context).push<Map<String, double>>(
      MaterialPageRoute(
        builder: (context) => const MapPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['lat'];
        _longitude = result['lng'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildTextField('Recipient Name', _nameController),
                    _buildTextField('Phone Number', _phoneController,
                        keyboardType: TextInputType.phone),
                    _buildDropdown(
                        'Province/City',
                        _selectedProvince,
                        mockLocationData.keys.toList(), (value) {
                      setState(() {
                        _selectedProvince = value;
                        _selectedDistrict = null; // Reset Quận/Huyện
                        _selectedWard = null; // Reset Phường/Xã
                      });
                    }),
                    _buildDropdown(
                        'District',
                        _selectedDistrict,
                        _selectedProvince != null
                            ? mockLocationData[_selectedProvince] ?? []
                            : [], (value) {
                      setState(() {
                        _selectedDistrict = value;
                        _selectedWard = null; // Reset Phường/Xã
                      });
                    }),
                    _buildDropdown(
                        'Ward',
                        _selectedWard,
                        _selectedDistrict != null
                            ? mockWardData[_selectedDistrict] ??
                            mockWardData['Default']!
                            : [], (value) {
                      setState(() {
                        _selectedWard = value;
                      });
                    }),
                    _buildMultilineTextField(
                        'Address Details', _detailsController),
                    _buildMapSelection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  // Tiêu đề của Modal
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.initialAddress != null
                ? 'Edit Address'
                : 'Add New Address',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Widget cho TextFormField một dòng
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(10),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập $label.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Widget cho TextFormField nhiều dòng
  Widget _buildMultilineTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(10),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập $label.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Widget cho Dropdown
  Widget _buildDropdown(
      String label,
      String? selectedValue,
      List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            value: selectedValue,
            hint: Text('Select $label'),
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

  // Widget Chọn vị trí trên bản đồ
  Widget _buildMapSelection() {
    final isLocationSelected = _latitude != null && _longitude != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location on Map', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _openMapPicker,
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text('Select on Map',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isLocationSelected
                    ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}'
                    : 'No location selected',
                style: TextStyle(
                    color: isLocationSelected ? Colors.green : Colors.black54),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Chân trang với các nút
  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(widget.initialAddress != null ? 'Save Changes' : 'Save Address'),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// MÀN HÌNH 3: CHỌN VỊ TRÍ TRÊN BẢN ĐỒ (MapPickerScreen)
// ====================================================================

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Giá trị tọa độ giả lập được chọn
  double _tempLat = 21.0278; // Giả lập Hà Nội
  double _tempLng = 105.8342;

  void _confirmLocation() {
    // Trả về tọa độ cho form trước
    Navigator.of(context).pop({'lat': _tempLat, 'lng': _tempLng});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildMapHeader(),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    // Đây là nơi bạn sẽ đặt widget GoogleMap()
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Map would be displayed here',
                        style: TextStyle(color: Colors.black38)),
                  ),
                  // Giả lập pin ở giữa bản đồ
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  )
                ],
              ),
            ),
            _buildMapSearchAndActions(),
          ],
        ),
      ),
    );
  }

  // Tiêu đề của màn hình Map Picker
  Widget _buildMapHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Location on Map',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Thanh tìm kiếm và các nút hành động của Map Picker
  Widget _buildMapSearchAndActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Logic tìm kiếm
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Confirm Location'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}