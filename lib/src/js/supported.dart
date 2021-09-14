@JS()
library js;

import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('window')
external dynamic _window;
@JS('Array')
external dynamic _Array;
@JS('Uint8Array')
external dynamic _Uint8Array;
@JS('Blob')
external dynamic _Blob;

_createArray([List? member]) {
  return callConstructor(_Array, member ?? []);
}

_addAllToArray(array, List? added) {
  if (!instanceof(array, _Array)) return;
  return callMethod(array, 'push', added ?? []);
}

_createUint8ArrayFrom(arrayLike) {
  return callMethod(_Uint8Array, 'from', [arrayLike]);
}

_createBlob(array, [options]) {
  var args = [array];
  if (options != null) args.add(options);
  return callConstructor(_Blob, args);
}

@JS('URL')
class _URL {
  external static String createObjectURL(obj);
}

void printBlob(
  Uint8List byteList, [
  String? mimeType,
  String? fileName,
]) {
  var byteArray = _createArray();
  for (var b in byteList) {
    _addAllToArray(byteArray, [b]);
  }
  var bytes = _createUint8ArrayFrom(byteArray);
  var options = newObject();
  if (mimeType != null) {
    setProperty(options, 'type', mimeType);
  }

  final blob = _createBlob(_createArray([bytes]), options);

  final objectUrl = _URL.createObjectURL(blob);

  var args = [objectUrl];
  if (fileName != null) args.add(fileName);

  callMethod(_window, 'open', args);
}
