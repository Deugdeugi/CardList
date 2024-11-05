import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_model.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  Future<void> loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedItems = prefs.getStringList('items');
    if (savedItems != null) {
      _items = savedItems.map((item) {
        final parts = item.split('|');
        return Item(title: parts[0], details: parts.length > 1 ? parts[1] : '');
      }).toList();
    }
    notifyListeners();
  }

  Future<void> saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedItems = _items.map((item) => '${item.title}|${item.details}').toList();
    prefs.setStringList('items', savedItems);
  }

  void addItem() {
    _items.add(Item(title: '새 항목', details: '추가 정보'));
    saveItems();
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    saveItems();
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    saveItems();
    notifyListeners();
  }

  void editItem(int index, String title, String details) {
    _items[index].title = title;
    _items[index].details = details;
    saveItems();
    notifyListeners();
  }
}