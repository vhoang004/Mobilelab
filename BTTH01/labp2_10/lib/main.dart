import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PopMenuListPage(),
  ));
}

class PopMenuListPage extends StatelessWidget {
  const PopMenuListPage({super.key});

  final List<String> names = const ["Liam", "Noah", "Oliver", "William", "Elijah"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pop Menu with List"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          String name = names[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(name[0]),
            ),
            title: Text(name),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value on $name')),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "View",
                  child: Text("View"),
                ),
                const PopupMenuItem(
                  value: "Edit",
                  child: Text("Edit"),
                ),
                const PopupMenuItem(
                  value: "Delete",
                  child: Text("Delete"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
