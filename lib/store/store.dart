import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:authenticator/models/item.dart';

class Store with ChangeNotifier {
  bool _loading = true;
  final _storage = new FlutterSecureStorage();
  List<Item> _items = List();

  Store() {
    load();
  }

  bool get loading => _loading;

  UnmodifiableListView get items => UnmodifiableListView(_items);

  // --

  Future<void> load() async {
    String value = await _storage.read(key: "items");
    if (value != null) {
      _items = List<Item>.from(json.decode(value).map((i) => Item.fromJson(i)));
    }

    _loading = false;
    notifyListeners();
  }

  Item addItem(String uri) {
    try {
      var item = Item.fromUri(uri);
      _items.add(item);
      _storage.write(key: "items", value: jsonEncode(items));

      notifyListeners();
      return item;
    } catch (e) {
      print("That's not a valid QR code");
      throw Exception("That's not a valid QR code");
    }
  }
}
