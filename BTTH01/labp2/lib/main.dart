import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // mặc định tab Workouts

  final List<Widget> _screens = [
    Center(child: Text("Đây là màn hình chính",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    WorkoutScreen(),
    Center(child: Text("Đây là khu vực cài đặt",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Workouts"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class Workout {
  final String title;
  final String subtitle;
  final String duration;
  final String image;
  final Color bgColor;

  Workout({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.image,
    required this.bgColor,
  });
}

class WorkoutScreen extends StatelessWidget {
  final List<Workout> workouts = [
    Workout(
      title: "Yoga",
      subtitle: "3 Exercises\n12 Minutes",
      duration: "0.5",
      image: "assets/images/yoga.jpg",
      bgColor: Colors.grey.shade200,
    ),
    Workout(
      title: "Pilates",
      subtitle: "4 Exercises\n9 Minutes",
      duration: "0.6",
      image: "assets/images/pilates.jpg",
      bgColor: Colors.purple.shade200,
    ),
    Workout(
      title: "Full body",
      subtitle: "3 Exercises\n12 Minutes",
      duration: "0.6",
      image: "assets/images/gym.jpg",
      bgColor: Colors.blue.shade200,
    ),
    Workout(
      title: "Stretching",
      subtitle: "5 Exercises\n16 Minutes",
      duration: "0.6",
      image: "assets/images/yoga.jpg",
      bgColor: Colors.pink.shade200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workouts", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                workout.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(workout.subtitle),
              ),
              trailing: Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: workout.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(workout.image, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}
