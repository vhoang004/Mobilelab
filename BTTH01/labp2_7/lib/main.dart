import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GradientButtonDemo(),
    );
  }
}

class GradientButtonDemo extends StatelessWidget {
  const GradientButtonDemo({super.key});

  Widget buildGradientButton({
    required String text,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Gradient Buttons"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Button 1
          buildGradientButton(
            text: "Click me 1",
            colors: [Colors.green, Colors.teal],
            onPressed: () {
              debugPrint("Click me 1 pressed");
            },
          ),

          // Button 2
          buildGradientButton(
            text: "Click me 2",
            colors: [Colors.red, Colors.orange],
            onPressed: () {
              debugPrint("Click me 2 pressed");
            },
          ),

          // Button 3
          buildGradientButton(
            text: "Click me 3",
            colors: [Colors.blue, Colors.cyan],
            onPressed: () {
              debugPrint("Click me 3 pressed");
            },
          ),

          // Button 4
          buildGradientButton(
            text: "Click me 4",
            colors: [Colors.black87, Colors.grey],
            onPressed: () {
              debugPrint("Click me 4 pressed");
            },
          ),
        ],
      ),
    );
  }
}
