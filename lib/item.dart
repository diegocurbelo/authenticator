import 'package:meta/meta.dart';

class Item {
  String uri;
  String type; // TOTP, HOTP
  String account = '';
  String secret;
  String issuer;
  String algorithm = 'SHA1'; // SHA1 (default), SHA256
  int digits = 6; // 6 (default), 8
  int counter;
  int period = 30; // 30 (default)

  Item(
      {@required this.uri,
      @required this.type,
      this.account,
      @required this.secret,
      this.issuer,
      this.algorithm,
      this.digits,
      this.counter,
      this.period});

  Item.fromUri(this.uri) {
    var u = Uri.parse(uri);
    if (u.scheme != 'otpauth') {
      throw FormatException();
    }
    if (u.host != 'totp') {
      throw FormatException('Invalid type: ${u.host}');
    }
    type = u.host;

    if (u.pathSegments.isNotEmpty) {
      var label = u.pathSegments.first;
      if (label.contains(':')) {
        var aux = label.split(':');
        account = aux[0].trim();
        issuer = aux[1].trim();
      } else {
        account = label.trim();
      }
    }

    secret = u.queryParameters['secret'];
    issuer = u.queryParameters['issuer'] ?? issuer;

    algorithm = (u.queryParameters['algorithm'] ?? 'SHA1').toUpperCase();
    if (algorithm != 'SHA1' && algorithm != 'SHA256') {
      throw FormatException('Invalid algorithm: $algorithm');
    }

    digits = int.tryParse(u.queryParameters['digits'] ?? '6');
    counter = int.tryParse(u.queryParameters['counter'] ?? '0');
    period = int.tryParse(u.queryParameters['period'] ?? '30');
  }

  Item.fromJson(Map<String, dynamic> json)
      : uri = json['uri'],
        type = json['type'],
        account = json['account'],
        secret = json['secret'],
        issuer = json['issuer'],
        algorithm = json['algorithm'],
        digits = json['digits'],
        counter = json['counter'],
        period = json['period'];

  Map<String, dynamic> toJson() => {
        'uri': uri,
        'type': type,
        'account': account,
        'secret': secret,
        'issuer': issuer,
        'algorithm': algorithm,
        'digits': digits,
        'counter': counter,
        'period': period,
      };
}
