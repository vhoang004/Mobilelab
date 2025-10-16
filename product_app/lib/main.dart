import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart'; // màn hình danh sách sản phẩm

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // tắt banner debug
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 🔹 Màn hình mặc định khi mở app
      home: const ProductListScreen(),

      // 🔹 (Tùy chọn) Định nghĩa route nếu muốn điều hướng sau này
      // routes: {
      //   '/add': (context) => const AddProductScreen(),
      //   '/list': (context) => const ProductListScreen(),
      // },
    );
  }
}
