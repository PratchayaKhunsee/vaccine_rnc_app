@JS()
library JS;

import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('Blob')
class Blob {
  external Blob(array, [options]);
}

@JS('URL')
class URL {
  external static String createObjectURL(data);
}

@JS('Array')
class Array {
  external static bool isArray(value);
  external static Array from(arrayLike);
  external int get length;
}

@JS('Uint8Array')
class Uint8Array {
  external Uint8Array(length);
  external static Uint8Array from(arrayLike);
}

@JS('open')
external dynamic open(String url, [String? windowName, String? windowFeatures]);

void printBlob(
  Uint8List byteList, [
  String? mimeType,
]) {
  Array byteArray = Array();

  for (int b in byteList) {
    callMethod(byteArray, 'push', [b]);
  }

  Uint8Array bytes = Uint8Array.from(byteArray);
  Array array = Array();
  callMethod(array, 'push', [bytes]);
  var options = newObject();
  if (mimeType != null) {
    setProperty(options, 'type', mimeType);
  }

  final blob = Blob(array, options);

  open(URL.createObjectURL(blob));
}
