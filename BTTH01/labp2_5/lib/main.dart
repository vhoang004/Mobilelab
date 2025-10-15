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
      title: 'Flutter Course UI',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const CoursePage(),
    );
  }
}

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Videos, Description
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình Flutter
              Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png",
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Thông tin khóa học
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Flutter Complete Course",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Created by Dear Programmer",
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 2),
                    Text("55 Videos", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // TabBar (Videos / Description)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.purple,
                  tabs: [
                    Tab(text: "Videos"),
                    Tab(text: "Description"),
                  ],
                ),
              ),

              // Nội dung Tab
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    // Tab 1: Videos
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: const [
                          VideoTile(
                            title: "Introduction to Flutter",
                            duration: "20 min 50 sec",
                          ),
                          VideoTile(
                            title: "Installing Flutter on Windows",
                            duration: "20 min 50 sec",
                          ),
                          VideoTile(
                            title: "Setup Emulator on Windows",
                            duration: "20 min 50 sec",
                          ),
                          VideoTile(
                            title: "Creating Our First App",
                            duration: "20 min 50 sec",
                          ),
                        ],
                      ),
                    ),

                    // Tab 2: Description
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "This Flutter Complete Course is designed for beginners to advanced learners. "
                            "You will learn how to install Flutter, set up an emulator, and build your first app.",
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoTile extends StatelessWidget {
  final String title;
  final String duration;

  const VideoTile({super.key, required this.title, required this.duration});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.play_arrow, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(duration),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
