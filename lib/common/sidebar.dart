import 'package:flutter/material.dart';

import 'package:authenticator/pages/help.dart';
import 'package:authenticator/pages/send_feedback.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    Icons.help_outline,
                    size: 26.0,
                  ),
                  title: Text(
                    'Help',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpPage()),
                    );
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
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SendFeedbackPage()),
                          );
                        },
                      ),
                    ],
                  ))))
        ],
      ),
    );
  }
}
