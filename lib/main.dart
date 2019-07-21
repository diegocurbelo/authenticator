import 'dart:async';
import 'dart:convert';
import 'package:authenticator/item.dart';
import 'package:authenticator/otp.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authenticator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  List<Item> items = List();
  int timer = 0;
  String barcode = "";

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _load();
    Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => setState(() {
              timer += 1;
            }));
  }

  _load() async {
    Map<String, String> store = await storage.readAll();
    setState(() {
      items =
          store.values.map((item) => Item.fromJson(jsonDecode(item))).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(
//                color: Colors.black,
                  ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItem(item);
              },
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(title: Text('Authenticator'), actions: <Widget>[
      Builder(builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => _scan(context),
        );
      })
    ]);
  }

  Widget _buildItem(Item item) {
    var code = OTP.generateTOTPCode(item.secret);
    return ListTile(
      leading: Icon(Icons.timelapse, size: 47),
      title: Text(
        item.issuer,
      ),
      subtitle: Text(
        code,
        style: TextStyle(fontFamily: 'Karla', fontSize: 47),
      ),
//      trailing: CircularProgressIndicator(
//        value: timer % 30 / 30,
//          valueColor:
//              AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
//      ),
    );
  }

  Future _scan(BuildContext context) async {
    try {
      String uri = await BarcodeScanner.scan();
      _addItem(uri);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showSnackBar(context, 'No camera permission! :(');
      } else {
        _showSnackBar(context, 'Unexpected error: $e');
      }
    } on FormatException {
      _showSnackBar(context,
          'User returned using the "back"-button before scanning anything');
    } catch (e) {
      _showSnackBar(context, 'Unknown error: $e');
    }
  }

  _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {},
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _addItem(String uri) {
    try {
      var item = Item.fromUri(uri);
      setState(() {
        items.add(item);
      });
      storage.write(
          key: (items.length + 1).toString(), value: jsonEncode(item));
    } catch (e) {
      _showSnackBar(context, "That's not a valid QR code");
    }
  }
}
