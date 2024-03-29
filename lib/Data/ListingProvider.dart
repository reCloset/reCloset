import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ListingProvider extends ChangeNotifier {
  /// Internal, private state of the listing.
  final List<Item> _items = [];
  String category = "";
  String condition = "";
  String title = "";
  String secondCategory = "";
  String description = "";

  List<Item> get items => _items;

  void add(Item item, int index) {
    _items.insert(index, item);
    notifyListeners();
  }

  // void addDownloadUrl(String url, int index) {
  //   _items[index].downloadUrl = url;
  //   notifyListeners();
  // }

  /// Removes all items from the listing.
  void removeAll() {
    _items.clear();
    notifyListeners();
  }
}

class Item {
  XFile image;
  // String? downloadUrl;

  Item(this.image);
}
