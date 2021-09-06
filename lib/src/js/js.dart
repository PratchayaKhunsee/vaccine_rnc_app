@JS()
library js;

import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
external dynamic window;

createArray([List? member]) {
  return callConstructor(getProperty(window, 'Array'), member ?? []);
}

addAllToArray(array, List? added) {
  if (!instanceof(array, getProperty(window, 'Array'))) return;
  return callMethod(array, 'push', added ?? []);
}

createArrayFrom(arrayLike) {
  return callMethod(getProperty(window, 'Array'), 'from',
      arrayLike != null ? [arrayLike] : []);
}

createUint8ArrayFrom(arrayLike) {
  return callMethod(getProperty(window, 'Uint8Array'), 'from', [arrayLike]);
}

createBlob(array, [options]) {
  var args = [array];
  if (options != null) args.add(options);
  return callConstructor(getProperty(window, 'Blob'), args);
}

@JS('URL')
class URL {
  external static String createObjectURL(obj);
}

void printBlob(
  Uint8List byteList, [
  String? mimeType,
  String? fileName,
]) {
  var byteArray = createArray();
  for (var b in byteList) {
    addAllToArray(byteArray, [b]);
  }
  var bytes = createUint8ArrayFrom(byteArray);
  var options = newObject();
  if (mimeType != null) {
    setProperty(options, 'type', mimeType);
  }

  final blob = createBlob(createArray([bytes]), options);

  final objectUrl = URL.createObjectURL(blob);

  var args = [objectUrl];
  if (fileName != null) args.add(fileName);

  callMethod(window, 'open', args);
}
