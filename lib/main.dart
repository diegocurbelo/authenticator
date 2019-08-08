import 'dart:async';
import 'dart:convert';
import 'package:authenticator/detail.dart';
import 'package:authenticator/item.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sentry/sentry.dart';

final SentryClient _sentry = new SentryClient(
    dsn: 'https://eef4e72018df44ab839c8aacda7d51d5@sentry.io/1520834');

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<void> _reportError(dynamic error, dynamic stackTrace) async {
  if (isInDebugMode) {
    print(stackTrace);
    return;
  }
  _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );
}

Future<void> main() async {
  runZoned<Future<void>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

// --

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authenticator',
      theme: ThemeData(
        primaryColor: Color(0xFF507FD4), // BLUE
        canvasColor: Colors.white,
//          primaryColor: Color(0xFFD65E5F), // RED
//          scaffoldBackgroundColor: Colors.white),
      ),
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
  final SlidableController slidableController = SlidableController();

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

      _loading = false;
    });
    if (isInDebugMode) {
      _loadTestData();
    }
  }

  _loadTestData() async {
    setState(() {
      items.add(Item.fromUri(
          'otpauth://totp/Github:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO1'));
      items.add(Item.fromUri(
          'otpauth://totp/Amazon:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO2'));
      items.add(Item.fromUri(
          'otpauth://totp/Facebook:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO3'));
      items.add(Item.fromUri(
          'otpauth://totp/Google:john@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO4'));
      items.add(Item.fromUri(
          'otpauth://totp/Other:john@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBO5'));
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
              padding: EdgeInsets.only(top: 10.0),
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
      child: Column(
        children: <Widget>[
          Container(
            height: 108.0,
            child: DrawerHeader(
              child: Image.asset('assets/issuers/default-icon.png'),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    size: 26,
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    size: 26.0,
                  ),
                  title: Text(
                    'Help',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.feedback,
                          size: 24.0,
                        ),
                        title: Text(
                          'Send feedback',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          Navigator.pop(context);
                        },
                      ),
//                          ListTile(
//                              leading: Image.asset(
//                                  'assets/issuers/default-icon.png'),
//                              title: Text(
//                                'v1.0.0',
//                                textAlign: TextAlign.center,
//                              ))
                    ],
                  ))))
        ],
      ),
    );
  }

  Widget _buildItem(Item item) {
    return Slidable(
      key: Key(item.uri),
      controller: slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.20,
      child: Container(
        color: Colors.white,
        child: ListTile(
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
            }),
      ),
      actions: <Widget>[
        IconSlideAction(
//          color: Colors.blue,
          icon: Icons.archive,
          onTap: () => _showSnackBar(context, 'Archive'),
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          foregroundColor: Colors.black45,
          icon: Icons.edit,
          onTap: () => _showSnackBar(context, 'More'),
        ),
        IconSlideAction(
          icon: Icons.delete,
          foregroundColor: Color(0xFFD65E5F),
          onTap: () {
            print("delte");
          },
        ),
      ],
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
