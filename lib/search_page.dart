import 'package:cardlist/detail_page.dart';
import 'package:cardlist/provider/item_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/item_model.dart';
import 'package:collection/collection.dart';

class SearchPage extends StatefulWidget {
  final String tag;

  const SearchPage({super.key, required this.tag});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    List<int> searchItemsIndex = [];
    List<Item> searchItems = [];

    itemProvider.items.forEachIndexed((index, element) {
      if (element.kind.contains(widget.tag)) {
        searchItemsIndex.add(index);
        searchItems.add(element);
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: const Text('태그 검색',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        body: searchItems.isNotEmpty
            ? ListView(
                children: List.generate(searchItems.length, (index) {
                  return Card(
                    margin: const EdgeInsets.all(10.0),
                    color:
                        Color(int.parse(searchItems[index].color, radix: 16)),
                    child: ListTile(
                      title: Text(searchItems[index].title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      leading: Text(searchItems[index].kind,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(searchItems[index].details,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailPage(
                                  item: itemProvider
                                      .items[searchItemsIndex[index]],
                                  itemIndex: searchItemsIndex[index])),
                        );
                      },
                    ),
                  );
                }),
              )
            : const Center(
                child: Text("검색한 태그에 대한 리스트 항목이 없습니다."),
              ));
  }
}
