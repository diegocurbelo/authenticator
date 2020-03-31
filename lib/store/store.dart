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

//    Map<String, String> store = await storage.readAll();
//    items =
//        store.values.map((item) => Item.fromJson(jsonDecode(item))).toList();

  bool get loading => _loading;

  UnmodifiableListView get items => UnmodifiableListView(_items);

  // --

  Future<void> load() async {
    await _storage.write(key: "items", value: jsonEncode(items));

    String value = await _storage.read(key: "items");
    print(value);

//    if (value != null) {
      _items = List<Item>.from(json.decode(value).map((i) => Item.fromJson(i)));
//    }
//    _items.add(Item.fromUri(
//        'otpauth://totp/Github:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO1'));
//    _items.add(Item.fromUri(
//        'otpauth://totp/Amazon:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO2'));
//    _items.add(Item.fromUri(
//        'otpauth://totp/Facebook:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO3'));
//    _items.add(Item.fromUri(
//        'otpauth://totp/Google:john@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO4'));
//    _items.add(Item.fromUri(
//        'otpauth://totp/Other:john@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO5'));

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
