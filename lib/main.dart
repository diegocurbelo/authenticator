import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';

import 'package:authenticator/pages/home.dart';
import 'package:authenticator/store/store.dart';

final SentryClient _sentry = new SentryClient(
    dsn: 'https://eef4e72018df44ab839c8aacda7d51d5@sentry.io/1520834');

Future<void> main() async {
  // This captures errors reported by the Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<void>>(() async {
    runApp(App());
  }, onError: (error, stackTrace) {
    if (isInDebugMode) {
      print(stackTrace);
      return;
    }
    _sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Store()),
        ],
        child: MaterialApp(
          title: 'Authenticator',
          theme: ThemeData(
            primaryColor: Color(0xFF507FD4),
            canvasColor: Colors.white,
          ),
          home: HomePage(),
        ));
  }
}

// --

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}
