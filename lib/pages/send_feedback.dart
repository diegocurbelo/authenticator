import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendFeedbackPage extends StatefulWidget {
  @override
  _SendFeedbackPageState createState() => _SendFeedbackPageState();
}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  var text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Send Feedback"),
          actions: <Widget>[
            Builder(builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.send,
                ),
                onPressed: () => _send(context),
              );
            })
          ],
          elevation: 1,
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(children: [
              Expanded(
                child: TextField(
                  decoration:
                      InputDecoration(hintText: "Describe an issue or idea"),
                  keyboardType: TextInputType.multiline,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  autofocus: true,
                  onChanged: (text) {
                    this.text = text;
                  },
                ),
              )
            ])));
  }

  Future _send(BuildContext context) async {
    Navigator.maybePop(context);

    var map = Map<String, dynamic>();
    map['entry.1579610016'] = 'ID';
    map['entry.16775818'] = text;

    http.Response response = await http.post(
      'https://docs.google.com/forms/u/0/d/e/1FAIpQLScz816s0tpY_l4dn3oGTTPmQBC0pxGRFo1O63T4rP0sWGbxRw/formResponse',
      body: map,
    );
    return true;
  }
}
