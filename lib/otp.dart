import 'dart:math';
import 'dart:typed_data';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';

class OTP {
  static String generateTOTPCode(String secret,
      {int digits = 6,
      int interval = 30,
      String algorithm = 'SHA1'}) {
    var time = ((DateTime.now().millisecondsSinceEpoch ~/ 1000).round() ~/ interval).floor();
    var code = _generateCode(secret, time, digits, algorithm);
    return code.toString().padLeft(digits, '0');
  }

  static int _generateCode(
      String secret, int time, int digits, String algorithm) {
    digits = digits == 8 ? 8 : 6;

    var key = base32.decode(secret);

    Hmac hmac = _getHasher(algorithm, key);
    var hash = hmac.convert(_int2bytes(time)).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int code = (hash[offset] & 0x7f) << 24 |
        (hash[offset + 1] & 0xff) << 16 |
        (hash[offset + 2] & 0xff) << 8 |
        (hash[offset + 3] & 0xff);

    return code % pow(10, digits);
  }

  static Uint8List _int2bytes(int long) {
    var byteArray = Uint8List(8);
    for (var index = byteArray.length - 1; index >= 0; index--) {
      var byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }

  static Hmac _getHasher(String algorithm, Uint8List key) {
    switch (algorithm) {
      case 'SHA256':
        return Hmac(sha256, key);
      default:
        return Hmac(sha1, key);
    }
  }
}
