import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String tag;

  const SearchPage({super.key, required this.tag});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    //final itemProvider = Provider.of<ItemProvider>(context);
    print(widget.tag);

    return Scaffold(
      appBar: AppBar(
        title: const Text('태그 검색', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: ListView(),
    );
  }
}