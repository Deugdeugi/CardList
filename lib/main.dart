import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const numOfColumn = 3;
const List<Color> colors = [
  Color.fromARGB(255, 8, 196, 243),
  Color.fromARGB(255, 236, 228, 114),
  Color.fromARGB(255, 140, 243, 23),
  Color.fromARGB(255, 209, 136, 238),
  Color.fromARGB(255, 233, 81, 119),
  Color.fromARGB(255, 223, 92, 201),
  Color.fromARGB(255, 76, 238, 162),
];

void main() {
  runApp(const CardListApp());
}

class CardListApp extends StatelessWidget {
  const CardListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Card List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CardList(),
    );
  }
}

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  List<Map<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String>? savedItems = prefs.getStringList('items');
      if (savedItems != null) {
        items = savedItems.map((item) {
          final parts = item.split('|');
          return {'title': parts[0], 'details': parts.length > 1 ? parts[1] : ''};
        }).toList();
      }
    });
  }

  Future<void> _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedItems = items.map((item) => '${item['title']}|${item['details']}').toList();
    prefs.setStringList('items', savedItems);
  }

  void _addItem() {
    setState(() {
      items.add({'title': '새 항목', 'details': '추가 정보'});
      _saveItems();
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      _saveItems();
    });
  }

  void _removeAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말로 모든 리스트 항목을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                setState(() {
                  items.clear();
                  _saveItems();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 리스트 항목이 삭제되었습니다.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _editItem(int index) {
    TextEditingController titleController = TextEditingController(text: '');
    TextEditingController detailsController = TextEditingController(text: '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('항목 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: null,
                controller: titleController,
                decoration: const InputDecoration(hintText: '제목 입력'),
              ),
              TextField(
                maxLines: null,
                controller: detailsController,
                decoration: const InputDecoration(hintText: '추가 정보 입력'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('수정'),
              onPressed: () {
                setState(() {
                  items[index]['title'] = titleController.text;
                  items[index]['details'] = detailsController.text;
                  _saveItems();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 리스트', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
            tooltip: '항목 추가',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeAll(),
            tooltip: '전체 항목 삭제',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: (items.length / numOfColumn).ceil(),
        itemBuilder: (context, index) {
          int startIndex = index * numOfColumn;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(numOfColumn, (i) {
              int itemIndex = startIndex + i;
              if (itemIndex < items.length) {
                return Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(10.0),
                    color: colors.isNotEmpty ? colors[itemIndex % colors.length] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(items[itemIndex]['title']!, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(items[itemIndex]['details']!, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editItem(itemIndex),
                                    tooltip: '항목 수정',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeItem(itemIndex),
                                    tooltip: '항목 삭제',
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Expanded(child: Container());
              }
            }),
          );
        },
      ),
    );
  }
}