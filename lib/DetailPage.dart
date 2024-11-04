import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map<String, String> item;

  DetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상세', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['title'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(item['details'] ?? '', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}