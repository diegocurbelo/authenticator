import 'dart:async';

import 'package:authenticator/item.dart';
import 'package:authenticator/otp.dart';
import 'package:flutter/material.dart';

class Detail extends StatefulWidget {
  final Item item;

  Detail({Key key, @required this.item}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  Timer timer;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => setState(() {
              countdown += 1;
            }));
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.issuer),
      ),
      body: Center(
        child: _buildItem(widget.item),
      ),
    );
  }

  Widget _buildItem(Item item) {
    var code = OTP.generateTOTPCode(item.secret);
    return ListTile(
        leading: _buildAccountLogo(item.account),
        title: Text(
          item.issuer,
        ),
        subtitle: Text(
          code,
          style: TextStyle(fontFamily: 'Karla', fontSize: 47),
        ),
        trailing: CircularProgressIndicator(
          value: 1 - countdown % 30 / 30,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
        ),
        onTap: () {});
  }

  _buildAccountLogo(String account) {
    return Icon(Icons.timelapse, size: 47);
  }
}
