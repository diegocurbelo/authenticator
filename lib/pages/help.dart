import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
        elevation: 1,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text('Help', style: TextStyle(fontSize: 18.0)),
            subtitle: Text('Example text'),
            trailing: Icon(Icons.chevron_right, size: 32.0),
            onTap: () {},
          ),
          ListTile(
            title: Text('Help', style: TextStyle(fontSize: 18.0)),
            subtitle: Text('Example text'),
            trailing: Icon(Icons.chevron_right, size: 32.0),
            onTap: () {},
          ),
          ListTile(
            title: Text('Help', style: TextStyle(fontSize: 18.0)),
            subtitle: Text('Example text'),
            trailing: Icon(Icons.chevron_right, size: 32.0),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
