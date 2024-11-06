import 'package:cardlist/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/item_provider.dart';
import 'search_page.dart';

const numOfColumn = 1;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ItemProvider()..loadItems(),
      child: const CardListApp(),
    ),
  );
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
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    void saveItems() {
      itemProvider.saveItems();
    }

    void searchItem() {
      TextEditingController tagController = TextEditingController(text: '');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('태그 검색'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLength: 6,
                  controller: tagController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '태그 입력',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pop();
                  tagController.dispose(); // 해제
                },
              ),
              TextButton(
                child: const Text('검색'),
                onPressed: () {
                  if (tagController.text.isEmpty) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('검색할 태그를 입력해 주세요.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchPage(tag: tagController.text)),
                    );
                    tagController.dispose(); // 해제
                  }
                },
              ),
            ],
          );
        },
      );
    }

    void addItem() {
      itemProvider.addItem();
      saveItems();
    }

    void removeItem(int index) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('정말로 이 리스트 항목을 삭제하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('삭제'),
                onPressed: () {
                  itemProvider.removeItem(index);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리스트 항목이 삭제되었습니다.')),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    void removeAll() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('모든 리스트 항목을 삭제하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('삭제'),
                onPressed: () {
                  itemProvider.clearItems();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

    void editItem(int index) {
      TextEditingController titleController =
          TextEditingController(text: itemProvider.items[index].title);
      TextEditingController tagController =
          TextEditingController(text: itemProvider.items[index].kind);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('항목 수정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '제목 입력',
                  ),
                  controller: titleController,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                TextField(
                  maxLength: 6,
                  controller: tagController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '태그 입력',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                  titleController.dispose(); // 해제
                  tagController.dispose(); // 해제
                },
              ),
              TextButton(
                child: const Text('수정'),
                onPressed: () {
                  itemProvider.editItem(
                    index: index,
                    title: titleController.text,
                    kind: tagController.text,
                  );
                  Navigator.of(context).pop();
                  titleController.dispose(); // 해제
                  tagController.dispose(); // 해제
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('할 일 리스트',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: searchItem,
              tooltip: '태그 검색',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: addItem,
              tooltip: '항목 추가',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => removeAll(),
              tooltip: '전체 항목 삭제',
            ),
          ],
        ),
        body: itemProvider.items.isNotEmpty
            ? ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final item = itemProvider.removeItem(oldIndex);
                  itemProvider.insertItem(newIndex, item);
                },
                children: List.generate(itemProvider.items.length, (index) {
                  return Card(
                    key: ValueKey(
                        itemProvider.items[index]), // Unique key for each item
                    margin: const EdgeInsets.all(10.0),
                    color: Color(
                        int.parse(itemProvider.items[index].color, radix: 16)),
                    child: ListTile(
                      title: Text(itemProvider.items[index].title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      leading: Text(itemProvider.items[index].kind,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(itemProvider.items[index].details,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailPage(
                                  item: itemProvider.items[index],
                                  itemIndex: index)),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editItem(index),
                            tooltip: '항목 수정',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeItem(index),
                            tooltip: '항목 삭제',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )
            : const Center(
                child: Text("리스트 항목이 없습니다."),
              ));
  }
}
