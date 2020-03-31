import 'dart:async';
import 'package:flutter/material.dart';

import 'package:authenticator/models/item.dart';
import 'package:authenticator/utils/otp.dart';

class DetailPage extends StatefulWidget {
  final Item item;

  DetailPage({Key key, @required this.item}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Timer timer;
  String code;
  int countdown = 30;

  @override
  void initState() {
    super.initState();
    code = OTP.generateTOTPCode(widget.item.secret);

    timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => setState(() {
              countdown -= 1;
              var newCode = OTP.generateTOTPCode(widget.item.secret);
              if (newCode != code) {
                code = newCode;
                countdown = 30;
              }
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
        elevation: 2.0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _build(),
              ),
            ),
            Expanded(
              child: Text(
                code,
                style: TextStyle(
                    fontFamily: 'Kameron',
                    fontSize: 80,
                    color: countdown > 5 ? null : Color(0xFFD65E5F)),
              ),
            ),
            _buildCountdownAnimation(countdown),
            Padding(padding: EdgeInsets.only(top: 30.0)),
          ],
        ),
      ),
    );
  }

  Widget _build() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 35.0)),
        _buildIssuerImage(widget.item.issuer),
      ],
    );
  }

  Widget _buildIssuerImage(String issuer) {
    var issuers = ['amazon', 'facebook', 'github', 'google', 'default'];

    var name = issuer.toLowerCase();
    if (!issuers.contains(name)) {
      name = 'default';
    }

    return Image.asset(
      'assets/issuers/$name-icon.png',
      height: 155,
      width: 155,
      color: Color.fromRGBO(255, 255, 255, 0.6),
      colorBlendMode: BlendMode.modulate,
    );
  }

  Widget _buildCountdownAnimation(int countdown) {
    return SizedBox(
      height: 50.0,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              child: CircularProgressIndicator(
                value: (countdown - 0.1) % 30 / 30,
                valueColor: AlwaysStoppedAnimation<Color>(
                    countdown > 5 ? Color(0xFF507FD4) : Color(0xFFD65E5F)),
                strokeWidth: 4.0,
              ),
            ),
          ),
          Center(
              child: Text(countdown.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.bold,
                  ))),
        ],
      ),
    );
  }
}
