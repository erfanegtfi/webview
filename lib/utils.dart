import 'dart:convert';
import 'package:flutter/services.dart';

Future<String> getBase64Resource(String imagePath) async {
  final ByteData bytes = await rootBundle.load(imagePath);
  return base64Encode(bytes.buffer.asUint8List());
}
