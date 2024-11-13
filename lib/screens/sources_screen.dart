import 'package:flutter/material.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sources Used')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Column(
            children: [
              // Source #1 Text
              Text(
                ' • ',
                style: TextStyle(fontSize: 20),
              ),
              // Padding
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}