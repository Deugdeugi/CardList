import 'package:cardlist/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/item_provider.dart';

const numOfColumn = 1;
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
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('삭제'),
                onPressed: () {
                  setState(() {
                    itemProvider.removeItem(index);
                    saveItems();
                  });
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
                    itemProvider.clearItems();
                    saveItems();
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

    void editItem(int index) {
      TextEditingController titleController = TextEditingController(text: /*items[index]['title']*/'');
      TextEditingController detailsController = TextEditingController(text: /*items[index]['details']*/'');
      
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
                const SizedBox(height: 30.0,),
                TextField(
                  minLines: 1,
                  maxLines: 8,
                  controller: detailsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '추가 정보 입력',
                  ),
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
                  itemProvider.editItem(index, titleController.text, detailsController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 리스트', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
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
      body: ListView.builder(
        itemCount: (itemProvider.items.length / numOfColumn).ceil(),
        itemBuilder: (context, index) {
          int startIndex = index * numOfColumn;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(numOfColumn, (i) {
              int itemIndex = startIndex + i;
              if (itemIndex < itemProvider.items.length) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () { 
                      Navigator.push( 
                        context, 
                        MaterialPageRoute(builder: (context) => DetailPage(item: itemProvider.items[itemIndex])), 
                      ); 
                    },
                    child: Card(
                      margin: const EdgeInsets.all(10.0),
                      color: colors.isNotEmpty ? colors[itemIndex % colors.length] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemProvider.items[itemIndex].title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(itemProvider.items[itemIndex].details, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => editItem(itemIndex),
                                  tooltip: '항목 수정',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => removeItem(itemIndex),
                                  tooltip: '항목 삭제',
                                ),
                              ],
                            ),
                          ],
                        )
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