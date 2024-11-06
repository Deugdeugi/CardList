import 'package:cardlist/provider/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'provider/item_provider.dart';

class DetailPage extends StatefulWidget {
  final Item item;
  final int itemIndex;

  const DetailPage({super.key, required this.item, required this.itemIndex});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _detailsController = TextEditingController(text: widget.item.details);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상세', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            tooltip: _isEditing ? '저장' : '수정',
            onPressed: () {
              if (_isEditing) {
                // 아이템 업데이트
                itemProvider.editItem(
                    index: widget.itemIndex,
                    title: _titleController.text, 
                    details: _detailsController.text,
                  );
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리스트 항목이 수정되었습니다.')),
                );
              }
              setState(() {
                _isEditing = !_isEditing; // 수정 모드 전환
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditing
                  ? TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
                    )
                  : Text(
                      _titleController.text,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 10),
              _isEditing
                  ? TextField(
                      controller: _detailsController,
                      maxLines: 15,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(labelText: '상세 내용', border: OutlineInputBorder()),
                    )
                  : Linkify(
                      onOpen: (link) async {
                        if (!await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication)) {
                          debugPrint('Could not launch ${link.url}');
                          //throw Exception('Could not launch ${link.url}');
                        }
                      },
                      text: _detailsController.text,
                      style: const TextStyle(fontSize: 18),
                      linkStyle: const TextStyle(color: Colors.blueAccent),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}