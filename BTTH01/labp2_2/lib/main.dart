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
      title: 'Custom Rich Text Example',
      debugShowCheckedModeBanner: false,
      home: const RichTextExamplePage(),
    );
  }
}

class RichTextExamplePage extends StatefulWidget {
  const RichTextExamplePage({super.key});

  @override
  State<RichTextExamplePage> createState() => _RichTextExamplePageState();
}

class _RichTextExamplePageState extends State<RichTextExamplePage> {
  // trạng thái phóng to/thu gọn nội dung
  bool _expanded = false;

  // Tap recognizers (khởi tạo trong initState để có thể dispose)
  late TapGestureRecognizer _phoneRecognizer;
  late TapGestureRecognizer _emailRecognizer;
  late TapGestureRecognizer _urlRecognizer;
  late TapGestureRecognizer _toggleRecognizer;

  @override
  void initState() {
    super.initState();
    _phoneRecognizer = TapGestureRecognizer()..onTap = _onPhoneTap;
    _emailRecognizer = TapGestureRecognizer()..onTap = _onEmailTap;
    _urlRecognizer = TapGestureRecognizer()..onTap = _onUrlTap;
    _toggleRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _expanded = !_expanded;
        });
      };
  }

  @override
  void dispose() {
    _phoneRecognizer.dispose();
    _emailRecognizer.dispose();
    _urlRecognizer.dispose();
    _toggleRecognizer.dispose();
    super.dispose();
  }

  // Hàm mở url (tel:, mailto:, http:)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở: $url')),
      );
    }
  }

  void _onPhoneTap() {
    // Gọi điện (sẽ mở dialer trên thiết bị)
    _launchUrl('tel:+910000210056');
  }

  void _onEmailTap() {
    // Mở email client
    _launchUrl('mailto:test@exampleemail.org');
  }

  void _onUrlTap() {
    // Mở trang web
    _launchUrl('https://www.google.com');
  }

  @override
  Widget build(BuildContext context) {
    // Nội dung gốc
    const String intro =
        'Flutter is an open-source UI software development kit created by Google. '
        'It is used to develop cross platform applications for Android, iOS, Linux, macOS, Windows, Google Fuchsia, '
        'and the web from a single codebase. First described in 2015, Flutter was released in May 2017.\n\n';

    const String contactLine =
        'Contact on +910000210056. Our email address is test@exampleemail.org. '
        'For more details check https://www.google.com.';

    // style mặc định cho TextSpan
    const TextStyle baseStyle = TextStyle(fontSize: 14, color: Colors.black, height: 1.4);

    return Scaffold(
      // Không dùng AppBar, làm header giống hình (bạn muốn AppBar thì thay vào)
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // header xanh giống hình
              Container(
                width: double.infinity,
                color: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text(
                    'Custom Rich Text Example',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Card chứa RichText
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: RichText(
                      text: TextSpan(
                        style: baseStyle,
                        children: [
                          // đoạn giới thiệu luôn hiện
                          const TextSpan(text: intro),

                          // phần mở rộng (liên hệ) chỉ hiện khi _expanded == true
                          if (_expanded) ...[
                            TextSpan(text: 'Contact on '),
                            TextSpan(
                              text: '+910000210056',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              recognizer: _phoneRecognizer,
                            ),
                            const TextSpan(text: '. Our email address is '),
                            TextSpan(
                              text: 'test@exampleemail.org',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              recognizer: _emailRecognizer,
                            ),
                            const TextSpan(text: '. For more details check '),
                            TextSpan(
                              text: 'https://www.google.com',
                              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              recognizer: _urlRecognizer,
                            ),
                            const TextSpan(text: '\n\n'),
                          ],

                          // "Read more" / "Read less" toggler (luôn hiện)
                          TextSpan(
                            text: _expanded ? 'Read less' : 'Read more',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            recognizer: _toggleRecognizer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Phần còn trống giống ảnh (chỗ trắng bên dưới)
              const SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }
}