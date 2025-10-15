import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RichText Demo',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("RichText"),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: RichTextExample(),
        ),
      ),
    );
  }
}

class RichTextExample extends StatelessWidget {
  const RichTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dòng 1
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Hello ",
                style: TextStyle(color: Colors.teal, fontSize: 22),
              ),
              TextSpan(
                text: "World",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dòng 2
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Hello ",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "World ",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "👋",
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Email clickable
        RichText(
          text: TextSpan(
            text: "Contact me via: ",
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              WidgetSpan(
                child: Icon(Icons.email, color: Colors.blue, size: 18),
              ),
              TextSpan(
                text: " Email",
                style: const TextStyle(color: Colors.blue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("mailto:example@gmail.com"));
                  },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Phone clickable
        RichText(
          text: TextSpan(
            text: "Call Me: ",
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: "+1234987654321",
                style: const TextStyle(color: Colors.blue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("tel:+1234987654321"));
                  },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Blog clickable
        RichText(
          text: TextSpan(
            text: "Read My Blog ",
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: "HERE",
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("https://yourblog.com"));
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
