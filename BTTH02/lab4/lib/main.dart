import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Đảm bảo đã cài đặt package này
import 'package:lab4/screen/oder_wizard_screen.dart';
import 'package:lab4/data/order_model.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng Dụng Đặt Hàng',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Dùng OrderWizardScreen làm màn hình chính
      home: const OrderWizardScreen(),
    );
  }
}