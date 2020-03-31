import 'package:flutter/material.dart';

class SendFeedbackPage extends StatelessWidget {
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
        elevation: 2.0,
      ),
      body: Text("Describe the issue or idea"),
    );
  }

  Future _send(BuildContext context) async {
  }
}
