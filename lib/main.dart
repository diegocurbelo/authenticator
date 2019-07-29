import 'dart:async';
import 'dart:convert';
import 'package:authenticator/detail.dart';
import 'package:authenticator/item.dart';
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
      theme: ThemeData(
          primaryColor: Color(0xFF507FD4), // BLUE
//          primaryColor: Color(0xFFD65E5F), // RED
          scaffoldBackgroundColor: Colors.white),
//      theme: ThemeData(primarySwatch: Colors.deepPurple),
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
  String barcode = "";

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _load() async {
    Map<String, String> store = await storage.readAll();
    setState(() {
      items =
          store.values.map((item) => Item.fromJson(jsonDecode(item))).toList();
      items.add(Item.fromUri(
          'otpauth://totp/Github:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'));
      items.add(Item.fromUri(
          'otpauth://totp/Amazon:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'));
      items.add(Item.fromUri(
          'otpauth://totp/Facebook:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'));
      items.add(Item.fromUri(
          'otpauth://totp/Google:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'));
      items.add(Item.fromUri(
          'otpauth://totp/Google:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItem(item);
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Authenticator'),
      actions: <Widget>[
        Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(
              Icons.add,
//            color: Colors.white,
            ),
            onPressed: () => _scan(context),
          );
        })
      ],
      elevation: 2.0,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Color(0xFF507FD4),
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Item item) {
    return ListTile(
        leading: _buildLogo(item.issuer),
        title: Text(
          item.issuer,
          style: TextStyle(fontFamily: 'Karla', fontSize: 24),
        ),
        subtitle: Text(
          item.account,
          style: TextStyle(fontFamily: 'Karla', fontSize: 18),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Detail(item: item)),
          );
        });
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
        textColor: Color(0xFF507FD4),
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

  _buildLogo(String issuer) {
    var issuers = ['amazon', 'facebook', 'github', 'google', 'default'];

    var name = issuer.toLowerCase();
    if (!issuers.contains(name)) {
      name = 'default';
    }

    return Image.asset('assets/issuers/$name-icon.png');
  }
}
