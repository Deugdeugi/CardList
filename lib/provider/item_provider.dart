import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_model.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  List<Item> get items => _items;
 
  final List<String> colors = [
    'FF08C4F3',
    'FFECE472',
    'FF8CF317',
    'FFD188EE',
    'FFE95177',
    'FFDF5CC9',
    'FF4CEEA2',
  ];

  String getRandomColor(List<String> colors) {
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  Future<void> loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedItems = prefs.getStringList('items');
    if (savedItems != null) {
      _items = savedItems.map((item) {
        final parts = item.split('|');

        return Item(
          title: parts[0], 
          details: parts.length > 1 ? parts[1] : '', 
          color: parts.length > 2 ? parts[2] : 'FFFFFFFF',
          kind: parts.length > 3 ? parts[3] : '미분류'
        );
      }).toList();
    }
    notifyListeners();
  }

  Future<void> saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedItems = _items.map((item) => '${item.title}|${item.details}|${item.color}|${item.kind}').toList();
    prefs.setStringList('items', savedItems);
  }

  void addItem() {
    _items.add(Item(title: '새 항목', details: '추가 정보', color: getRandomColor(colors), kind: '미분류'));
    saveItems();
    notifyListeners();
  }

  Item removeItem(int index) {
    Item deleteItem = _items.removeAt(index);
    saveItems();
    notifyListeners();

    return deleteItem;
  }

  void clearItems() {
    _items.clear();
    saveItems();
    notifyListeners();
  }

  void editItem({required int index, required String title, String? kind, String? details}) {
    _items[index].title = title;
    if (kind != null) _items[index].kind = kind;
    if (details != null) _items[index].details = details;
    saveItems();
    notifyListeners();
  }

  void insertItem(int newIndex, Item item) {
    _items.insert(newIndex, item);
    saveItems();
    notifyListeners();
  }
}