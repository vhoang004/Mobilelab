import 'dart:convert';
import 'dart:math';

// Model cho Địa chỉ (Sử dụng lại từ bài 2, hoặc định nghĩa lại nếu cần)
class Address {
  final String recipientName;
  final String phoneNumber;
  final String province;
  final String district;
  final String ward;
  final String addressDetails;

  Address({
    required this.recipientName,
    required this.phoneNumber,
    required this.province,
    required this.district,
    required this.ward,
    required this.addressDetails,
  });

  Map<String, dynamic> toJson() => {
    'recipientName': recipientName,
    'phoneNumber': phoneNumber,
    'province': province,
    'district': district,
    'ward': ward,
    'addressDetails': addressDetails,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    recipientName: json['recipientName'],
    phoneNumber: json['phoneNumber'],
    province: json['province'],
    district: json['district'],
    ward: json['ward'],
    addressDetails: json['addressDetails'],
  );
}


class Order {
  final String orderId;
  final DateTime orderDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Address deliveryAddress;
  final String paymentMethod; // "Cash" hoặc "Card"
  final String orderNotes;
  final String status; // Ví dụ: "Pending", "Confirmed", "Delivered"

  // Giả lập tổng tiền để hiển thị trong chi tiết đơn hàng
  final double totalAmount = 500000;

  Order({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.orderNotes,
    this.status = 'Pending',
  })  : orderId = 'ORD-${Random().nextInt(999999)}',
        orderDate = DateTime.now();

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'orderDate': orderDate.toIso8601String(),
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerPhone': customerPhone,
    'deliveryAddress': deliveryAddress.toJson(),
    'paymentMethod': paymentMethod,
    'orderNotes': orderNotes,
    'status': status,
    'totalAmount': totalAmount,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    customerName: json['customerName'],
    customerEmail: json['customerEmail'],
    customerPhone: json['customerPhone'],
    deliveryAddress: Address.fromJson(json['deliveryAddress']),
    paymentMethod: json['paymentMethod'],
    orderNotes: json['orderNotes'],
  );
}

// Lưu ý: Cần thêm logic lưu trữ Order vào ProductStorage hoặc tạo OrderStorage riêng
// Dưới đây là OrderStorage đơn giản
class OrderStorage {
  static const _key = 'order_list';

  Future<List<Order>> loadOrders() async {
    // (Logic load đơn hàng từ SharedPreferences)
    return []; // Giả lập chưa có đơn hàng
  }

  Future<void> saveOrder(Order order) async {
    // (Logic lưu đơn hàng vào SharedPreferences)
    print('Đã lưu đơn hàng ${order.orderId} vào Local Storage.');
  }
}