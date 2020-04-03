import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:authenticator/common/loading.dart';
import 'package:authenticator/common/sidebar.dart';
import 'package:authenticator/models/item.dart';
import 'package:authenticator/store/store.dart';

import 'detail.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        drawer: Sidebar(),
        body: Consumer<Store>(builder: (context, store, child) {
          if (store.loading) {
            return Loading();
          }
          return ListView.separated(
            padding: EdgeInsets.only(top: 10.0),
            itemCount: store.items.length,
            itemBuilder: (context, index) {
              final item = store.items[index];
              return _buildItem(item);
            },
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey,
            ),
          );
        }));
  }

  // --

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        height: 108.0,
        child: DrawerHeader(
          child: Image.asset(
            'assets/issuers/default-icon.png',
            scale: 13,
          ),
        ),
      ),
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
      elevation: 1,
    );
  }

  Widget _buildItem(Item item) {
    return Container(
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
              MaterialPageRoute(builder: (context) => DetailPage(item: item)),
            );
          }),
    );
  }

  Widget _buildLogo(String issuer) {
    var issuers = ['amazon', 'facebook', 'github', 'google', 'default'];
    var name = issuer.toLowerCase();
    if (!issuers.contains(name)) {
      name = 'default';
    }
    return Image.asset('assets/issuers/$name-icon.png');
  }

  Future _scan(BuildContext context) async {
    try {
      String uri = await BarcodeScanner.scan();
      Item item = Provider.of<Store>(context, listen: false).addItem(uri);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(item: item)),
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showSnackBar(context, 'The user did not grant the camera permission');
      } else if (e.code == BarcodeScanner.UserCanceled) {
        _showSnackBar(context, 'The user cancelled');
      } else {
        _showSnackBar(context, 'Unexpected error: $e');
      }
    } on FormatException {
      _showSnackBar(context, 'User returned using the back button');
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

}
