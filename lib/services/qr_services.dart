import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

class QrBitBuffer extends Object with ListMixin<bool> {
  final List<int> _buffer;
  int _length = 0;

  QrBitBuffer() : _buffer = <int>[];

  @override
  void operator []=(int index, bool value) =>
      throw UnsupportedError('cannot change');

  @override
  bool operator [](int index) {
    final bufIndex = index ~/ 8;
    return ((_buffer[bufIndex] >> (7 - index % 8)) & 1) == 1;
  }

  @override
  int get length => _length;

  @override
  set length(int value) => throw UnsupportedError('Cannot change');

  int getByte(int index) => _buffer[index];

  void put(int number, int length) {
    for (var i = 0; i < length; i++) {
      final bit = ((number >> (length - i - 1)) & 1) == 1;
      putBit(bit);
    }
  }

  void putBit(bool bit) {
    final bufIndex = _length ~/ 8;
    if (_buffer.length <= bufIndex) {
      _buffer.add(0);
    }

    if (bit) {
      _buffer[bufIndex] |= 0x80 >> (_length % 8);
    }

    _length++;
  }
}

class QrByte {
  final int mode = mode8bitByte;
  final Uint8List _data;

  factory QrByte(String input) =>
      QrByte.fromUint8List(utf8.encoder.convert(input));

  QrByte.fromUint8List(Uint8List input) : _data = input;

  factory QrByte.fromByteData(ByteData input) =>
      QrByte.fromUint8List(input.buffer.asUint8List());

  int get length => _data.length;

  void write(QrBitBuffer buffer) {
    for (final v in _data) {
      buffer.put(v, 8);
    }
  }
}

/// Encodes numbers (0-9) 10 bits per 3 digits.
class QrNumeric implements QrByte {
  factory QrNumeric.fromString(String numberString) {
    final newList = Uint8List(numberString.length);
    var count = 0;
    for (var char in numberString.codeUnits) {
      if (char < 0x30 || char > 0x39) {
        throw ArgumentError('string can only contain alpha numeric 0-9');
      }
      newList[count++] = char - 0x30;
    }
    return QrNumeric._(newList);
  }

  QrNumeric._(this._data);

  @override
  final Uint8List _data;

  @override
  final int mode = modeNumber;

  @override
  void write(QrBitBuffer buffer) {
    // Walk through the list of number; attempting to encode up to 3 at a time.
    // Write (N *3 + 1) bits.
    final leftOver = _data.length % 3;

    final efficientGrab = _data.length - leftOver;
    for (var i = 0; i < efficientGrab; i += 3) {
      final encoded = _data[i] * 100 + _data[i + 1] * 10 + _data[i + 2];
      buffer.put(encoded, 10);
    }
    if (leftOver > 1) {
      // 2 bytes
      buffer.put(_data[_data.length - 2] * 10 + _data[_data.length - 1], 7);
    } else if (leftOver > 0) {
      // 1 byte
      buffer.put(_data.last, 4);
    }
  }

  // This is still the *number of characters to encode*, not encoded length.
  @override
  int get length => _data.length;
}

class QrErrorCorrectLevel {
  static const int L = 1;
  static const int M = 0;
  static const int Q = 3;
  static const int H = 2;

  // thesee *are* in order of lowest to highest quality...I think
  // all I know for sure: you can create longer messages w/ item N than N+1
  // I assume this correcsponds to more error correction for N+1
  static const List<int> levels = [L, M, Q, H];

  static String getName(int level) {
    switch (level) {
      case L:
        return 'Low';
      case M:
        return 'Medium';
      case Q:
        return 'Quality';
      case H:
        return 'High';
      default:
        throw ArgumentError('level $level not supported');
    }
  }
}

class InputTooLongException implements Exception {
  final int providedInput;
  final int inputLimit;
  final String message;

  factory InputTooLongException(int providedInput, int inputLimit) {
    final message = 'Input too long. $providedInput > $inputLimit';

    return InputTooLongException._internal(providedInput, inputLimit, message);
  }

  InputTooLongException._internal(
      this.providedInput, this.inputLimit, this.message);

  @override
  String toString() => 'QrInputTooLongException: $message';
}

const int pattern000 = 0;
const int pattern001 = 1;
const int pattern010 = 2;
const int pattern011 = 3;
const int pattern100 = 4;
const int pattern101 = 5;
const int pattern110 = 6;
const int pattern111 = 7;

final Uint8List _logTable = _createLogTable();
final Uint8List _expTable = _createExpTable();

int glog(int n) {
  if (n < 1) {
    throw ArgumentError('glog($n)');
  }

  return _logTable[n];
}

int gexp(int n) {
  while (n < 0) {
    n += 255;
  }

  while (n >= 256) {
    n -= 255;
  }

  return _expTable[n];
}

Uint8List _createExpTable() {
  final list = Uint8List(256);
  for (var i = 0; i < 8; i++) {
    list[i] = 1 << i;
  }
  for (var i = 8; i < 256; i++) {
    list[i] = list[i - 4] ^ list[i - 5] ^ list[i - 6] ^ list[i - 8];
  }
  return list;
}

Uint8List _createLogTable() {
  final list = Uint8List(256);
  for (var i = 0; i < 255; i++) {
    list[_expTable[i]] = i;
  }
  return list;
}

const int modeNumber = 1 << 0;
const int modeAlphaNum = 1 << 1;
const int mode8bitByte = 1 << 2;
const int modeKanji = 1 << 3;

class QrPolynomial {
  final Uint8List _values;

  factory QrPolynomial(List<int> thing, int shift) {
    var offset = 0;

    while (offset < thing.length && thing[offset] == 0) {
      offset++;
    }

    final values = Uint8List(thing.length - offset + shift);

    for (var i = 0; i < thing.length - offset; i++) {
      values[i] = thing[i + offset];
    }

    return QrPolynomial._internal(values);
  }

  QrPolynomial._internal(this._values);

  int operator [](int index) => _values[index];

  int get length => _values.length;

  QrPolynomial multiply(QrPolynomial e) {
    final List<int> foo = Uint8List(length + e.length - 1);

    for (var i = 0; i < length; i++) {
      for (var j = 0; j < e.length; j++) {
        foo[i + j] ^= gexp(glog(this[i]) + glog(e[j]));
      }
    }

    return QrPolynomial(foo, 0);
  }

  QrPolynomial mod(QrPolynomial e) {
    if (length - e.length < 0) {
      return this;
    }

    final ratio = glog(this[0]) - glog(e[0]);

    final value = Uint8List(length);

    for (var i = 0; i < length; i++) {
      value[i] = this[i];
    }

    for (var i = 0; i < e.length; i++) {
      value[i] ^= gexp(glog(e[i]) + ratio);
    }

    // recursive call
    return QrPolynomial(value, 0).mod(e);
  }
}

@visibleForTesting
List<List<bool>> qrModules(QrCode qrCode) => qrCode._modules;

class QrCode {
  final int typeNumber;
  final int errorCorrectLevel;
  final int moduleCount;
  final List<List<bool>> _modules;
  List<int> _dataCache;
  final List<QrByte> _dataList = <QrByte>[];

  QrCode(this.typeNumber, this.errorCorrectLevel)
      : moduleCount = typeNumber * 4 + 17,
        _modules = <List<bool>>[] {
    RangeError.checkValueInInterval(typeNumber, 1, 40, 'typeNumber');
    RangeError.checkValidIndex(
        errorCorrectLevel, QrErrorCorrectLevel.levels, 'errorCorrectLevel');

    for (var row = 0; row < moduleCount; row++) {
      _modules.add(List<bool>.filled(moduleCount, null));
    }
  }

  factory QrCode.fromData({
    @required String data,
    @required int errorCorrectLevel,
    @required int version,
  }) {
    final typeNumber = version ??
        _calculateTypeNumberFromData(
          errorCorrectLevel,
          [QrByte(data)],
        );
        
    return QrCode(typeNumber, errorCorrectLevel)..addData(data);
  }

  factory QrCode.fromUint8List({
    @required Uint8List data,
    @required int errorCorrectLevel,
  }) {
    final typeNumber = _calculateTypeNumberFromData(
      errorCorrectLevel,
      [QrByte.fromUint8List(data)],
    );
    return QrCode(typeNumber, errorCorrectLevel)
      .._addToList(QrByte.fromUint8List(data));
  }

  static int _calculateTypeNumberFromData(
    int errorCorrectLevel,
    List<QrByte> dataList,
  ) {
    int typeNumber;
    for (typeNumber = 1; typeNumber < 40; typeNumber++) {
      final rsBlocks = QrRsBlock.getRSBlocks(typeNumber, errorCorrectLevel);

      final buffer = QrBitBuffer();
      var totalDataCount = 0;
      for (var i = 0; i < rsBlocks.length; i++) {
        totalDataCount += rsBlocks[i].dataCount;
      }

      for (var i = 0; i < dataList.length; i++) {
        final data = dataList[i];
        buffer
          ..put(data.mode, 4)
          ..put(data.length, _lengthInBits(data.mode, typeNumber));
        data.write(buffer);
      }
      if (buffer.length <= totalDataCount * 8) break;
    }
    return typeNumber;
  }

  bool isDark(int row, int col) {
    if (row < 0 || moduleCount <= row || col < 0 || moduleCount <= col) {
      throw ArgumentError('$row , $col');
    }
    return _modules[row][col];
  }

  void addData(String data) => _addToList(QrByte(data));

  void addByteData(ByteData data) => _addToList(QrByte.fromByteData(data));

  /// Add QR Numeric Mode data from a string of digits.
  ///
  /// It is an error if the [numberString] contains anything other than the
  /// digits 0 through 9.
  void addNumeric(String numberString) =>
      _addToList(QrNumeric.fromString(numberString));

  void _addToList(QrByte data) {
    _dataList.add(data);
    _dataCache = null;
  }

  void make([int maskPattern]) {
    assert(maskPattern == null || (maskPattern >= 0 && maskPattern <= 7));
    _makeImpl(false, maskPattern ?? _getBestMaskPattern());
  }

  void _setupPositionProbePattern(int row, int col) {
    for (var r = -1; r <= 7; r++) {
      if (row + r <= -1 || moduleCount <= row + r) continue;

      for (var c = -1; c <= 7; c++) {
        if (col + c <= -1 || moduleCount <= col + c) continue;

        if ((0 <= r && r <= 6 && (c == 0 || c == 6)) ||
            (0 <= c && c <= 6 && (r == 0 || r == 6)) ||
            (2 <= r && r <= 4 && 2 <= c && c <= 4)) {
          _modules[row + r][col + c] = true;
        } else {
          _modules[row + r][col + c] = false;
        }
      }
    }
  }

  int _getBestMaskPattern() {
    var minLostPoint = 0.0;
    var pattern = 0;

    for (var i = 0; i < 8; i++) {
      _makeImpl(true, i);

      final lostPoint = _lostPoint(this);

      if (i == 0 || minLostPoint > lostPoint) {
        minLostPoint = lostPoint;
        pattern = i;
      }
    }

    return pattern;
  }

  void _setupTimingPattern() {
    for (var r = 8; r < moduleCount - 8; r++) {
      if (_modules[r][6] != null) {
        continue;
      }
      _modules[r][6] = r.isEven;
    }

    for (var c = 8; c < moduleCount - 8; c++) {
      if (_modules[6][c] != null) {
        continue;
      }
      _modules[6][c] = c.isEven;
    }
  }

  void _setupPositionAdjustPattern() {
    final pos = patternPosition(typeNumber);

    for (var i = 0; i < pos.length; i++) {
      for (var j = 0; j < pos.length; j++) {
        final row = pos[i];
        final col = pos[j];

        if (_modules[row][col] != null) {
          continue;
        }

        for (var r = -2; r <= 2; r++) {
          for (var c = -2; c <= 2; c++) {
            if (r == -2 || r == 2 || c == -2 || c == 2 || (r == 0 && c == 0)) {
              _modules[row + r][col + c] = true;
            } else {
              _modules[row + r][col + c] = false;
            }
          }
        }
      }
    }
  }

  void _setupTypeNumber(bool test) {
    final bits = bchTypeNumber(typeNumber);

    for (var i = 0; i < 18; i++) {
      final mod = !test && ((bits >> i) & 1) == 1;
      _modules[i ~/ 3][i % 3 + moduleCount - 8 - 3] = mod;
    }

    for (var i = 0; i < 18; i++) {
      final mod = !test && ((bits >> i) & 1) == 1;
      _modules[i % 3 + moduleCount - 8 - 3][i ~/ 3] = mod;
    }
  }

  void _setupTypeInfo(bool test, int maskPattern) {
    final data = (errorCorrectLevel << 3) | maskPattern;
    final bits = bchTypeInfo(data);

    int i;
    bool mod;

    // vertical
    for (i = 0; i < 15; i++) {
      mod = !test && ((bits >> i) & 1) == 1;

      if (i < 6) {
        _modules[i][8] = mod;
      } else if (i < 8) {
        _modules[i + 1][8] = mod;
      } else {
        _modules[moduleCount - 15 + i][8] = mod;
      }
    }

    // horizontal
    for (i = 0; i < 15; i++) {
      mod = !test && ((bits >> i) & 1) == 1;

      if (i < 8) {
        _modules[8][moduleCount - i - 1] = mod;
      } else if (i < 9) {
        _modules[8][15 - i - 1 + 1] = mod;
      } else {
        _modules[8][15 - i - 1] = mod;
      }
    }

    // fixed module
    _modules[moduleCount - 8][8] = !test;
  }

  void _mapData(List<int> data, int maskPattern) {
    var inc = -1;
    var row = moduleCount - 1;
    var bitIndex = 7;
    var byteIndex = 0;

    for (var col = moduleCount - 1; col > 0; col -= 2) {
      if (col == 6) col--;

      for (;;) {
        for (var c = 0; c < 2; c++) {
          if (_modules[row][col - c] == null) {
            var dark = false;

            if (byteIndex < data.length) {
              dark = ((data[byteIndex] >> bitIndex) & 1) == 1;
            }

            final mask = _mask(maskPattern, row, col - c);

            if (mask) {
              dark = !dark;
            }

            _modules[row][col - c] = dark;
            bitIndex--;

            if (bitIndex == -1) {
              byteIndex++;
              bitIndex = 7;
            }
          }
        }

        row += inc;

        if (row < 0 || moduleCount <= row) {
          row -= inc;
          inc = -inc;
          break;
        }
      }
    }
  }

  void _makeImpl(bool test, int maskPattern) {
    _setupPositionProbePattern(0, 0);
    _setupPositionProbePattern(moduleCount - 7, 0);
    _setupPositionProbePattern(0, moduleCount - 7);
    _setupPositionAdjustPattern();
    _setupTimingPattern();
    _setupTypeInfo(test, maskPattern);

    if (typeNumber >= 7) {
      _setupTypeNumber(test);
    }

    _dataCache ??= _createData(typeNumber, errorCorrectLevel, _dataList);

    _mapData(_dataCache, maskPattern);
  }
}

const int _pad0 = 0xEC;
const int _pad1 = 0x11;

List<int> _createData(
    int typeNumber, int errorCorrectLevel, List<QrByte> dataList) {
  final rsBlocks = QrRsBlock.getRSBlocks(typeNumber, errorCorrectLevel);

  final buffer = QrBitBuffer();

  for (var i = 0; i < dataList.length; i++) {
    final data = dataList[i];
    buffer
      ..put(data.mode, 4)
      ..put(data.length, _lengthInBits(data.mode, typeNumber));
    data.write(buffer);
  }

  // HUH?
  // ç≈ëÂÉfÅ[É^êîÇåvéZ
  var totalDataCount = 0;
  for (var i = 0; i < rsBlocks.length; i++) {
    totalDataCount += rsBlocks[i].dataCount;
  }

  final totalByteCount = totalDataCount * 8;
  if (buffer.length > totalByteCount) {
    throw InputTooLongException(buffer.length, totalByteCount);
  }

  // HUH?
  // èIí[ÉRÅ[Éh
  if (buffer.length + 4 <= totalByteCount) {
    buffer.put(0, 4);
  }

  // padding
  while (buffer.length % 8 != 0) {
    buffer.putBit(false);
  }

  // padding
  for (;;) {
    if (buffer.length >= totalDataCount * 8) {
      break;
    }
    buffer.put(_pad0, 8);

    if (buffer.length >= totalDataCount * 8) {
      break;
    }
    buffer.put(_pad1, 8);
  }

  return _createBytes(buffer, rsBlocks);
}

List<int> _createBytes(QrBitBuffer buffer, List<QrRsBlock> rsBlocks) {
  var offset = 0;

  var maxDcCount = 0;
  var maxEcCount = 0;

  final dcData = List<List<int>>.filled(rsBlocks.length, null);
  final ecData = List<List<int>>.filled(rsBlocks.length, null);

  for (var r = 0; r < rsBlocks.length; r++) {
    final dcCount = rsBlocks[r].dataCount;
    final ecCount = rsBlocks[r].totalCount - dcCount;

    maxDcCount = math.max(maxDcCount, dcCount);
    maxEcCount = math.max(maxEcCount, ecCount);

    final dcItem = dcData[r] = Uint8List(dcCount);

    for (var i = 0; i < dcItem.length; i++) {
      dcItem[i] = 0xff & buffer.getByte(i + offset);
    }
    offset += dcCount;

    final rsPoly = _errorCorrectPolynomial(ecCount);
    final rawPoly = QrPolynomial(dcItem, rsPoly.length - 1);

    final modPoly = rawPoly.mod(rsPoly);
    final ecItem = ecData[r] = Uint8List(rsPoly.length - 1);

    for (var i = 0; i < ecItem.length; i++) {
      final modIndex = i + modPoly.length - ecItem.length;
      ecItem[i] = (modIndex >= 0) ? modPoly[modIndex] : 0;
    }
  }

  final data = <int>[];

  for (var i = 0; i < maxDcCount; i++) {
    for (var r = 0; r < rsBlocks.length; r++) {
      if (i < dcData[r].length) {
        data.add(dcData[r][i]);
      }
    }
  }

  for (var i = 0; i < maxEcCount; i++) {
    for (var r = 0; r < rsBlocks.length; r++) {
      if (i < ecData[r].length) {
        data.add(ecData[r][i]);
      }
    }
  }

  return data;
}

bool _mask(int maskPattern, int i, int j) {
  switch (maskPattern) {
    case pattern000:
      return (i + j).isEven;
    case pattern001:
      return i.isEven;
    case pattern010:
      return j % 3 == 0;
    case pattern011:
      return (i + j) % 3 == 0;
    case pattern100:
      return ((i ~/ 2) + (j ~/ 3)).isEven;
    case pattern101:
      return (i * j) % 2 + (i * j) % 3 == 0;
    case pattern110:
      return ((i * j) % 2 + (i * j) % 3).isEven;
    case pattern111:
      return ((i * j) % 3 + (i + j) % 2).isEven;
    default:
      throw ArgumentError('bad maskPattern:$maskPattern');
  }
}

int _lengthInBits(int mode, int type) {
  if (1 <= type && type < 10) {
    // 1 - 9
    switch (mode) {
      case modeNumber:
        return 10;
      case modeAlphaNum:
        return 9;
      case mode8bitByte:
        return 8;
      case modeKanji:
        return 8;
      default:
        throw ArgumentError('mode:$mode');
    }
  } else if (type < 27) {
    // 10 - 26
    switch (mode) {
      case modeNumber:
        return 12;
      case modeAlphaNum:
        return 11;
      case mode8bitByte:
        return 16;
      case modeKanji:
        return 10;
      default:
        throw ArgumentError('mode:$mode');
    }
  } else if (type < 41) {
    // 27 - 40
    switch (mode) {
      case modeNumber:
        return 14;
      case modeAlphaNum:
        return 13;
      case mode8bitByte:
        return 16;
      case modeKanji:
        return 12;
      default:
        throw ArgumentError('mode:$mode');
    }
  } else {
    throw ArgumentError('type:$type');
  }
}

double _lostPoint(QrCode qrCode) {
  final moduleCount = qrCode.moduleCount;

  var lostPoint = 0.0;
  int row, col;

  // LEVEL1
  for (row = 0; row < moduleCount; row++) {
    for (col = 0; col < moduleCount; col++) {
      var sameCount = 0;
      final dark = qrCode.isDark(row, col);

      for (var r = -1; r <= 1; r++) {
        if (row + r < 0 || moduleCount <= row + r) {
          continue;
        }

        for (var c = -1; c <= 1; c++) {
          if (col + c < 0 || moduleCount <= col + c) {
            continue;
          }

          if (r == 0 && c == 0) {
            continue;
          }

          if (dark == qrCode.isDark(row + r, col + c)) {
            sameCount++;
          }
        }
      }

      if (sameCount > 5) {
        lostPoint += 3 + sameCount - 5;
      }
    }
  }

  // LEVEL2
  for (row = 0; row < moduleCount - 1; row++) {
    for (col = 0; col < moduleCount - 1; col++) {
      var count = 0;
      if (qrCode.isDark(row, col)) count++;
      if (qrCode.isDark(row + 1, col)) count++;
      if (qrCode.isDark(row, col + 1)) count++;
      if (qrCode.isDark(row + 1, col + 1)) count++;
      if (count == 0 || count == 4) {
        lostPoint += 3;
      }
    }
  }

  // LEVEL3
  for (row = 0; row < moduleCount; row++) {
    for (col = 0; col < moduleCount - 6; col++) {
      if (qrCode.isDark(row, col) &&
          !qrCode.isDark(row, col + 1) &&
          qrCode.isDark(row, col + 2) &&
          qrCode.isDark(row, col + 3) &&
          qrCode.isDark(row, col + 4) &&
          !qrCode.isDark(row, col + 5) &&
          qrCode.isDark(row, col + 6)) {
        lostPoint += 40;
      }
    }
  }

  for (col = 0; col < moduleCount; col++) {
    for (row = 0; row < moduleCount - 6; row++) {
      if (qrCode.isDark(row, col) &&
          !qrCode.isDark(row + 1, col) &&
          qrCode.isDark(row + 2, col) &&
          qrCode.isDark(row + 3, col) &&
          qrCode.isDark(row + 4, col) &&
          !qrCode.isDark(row + 5, col) &&
          qrCode.isDark(row + 6, col)) {
        lostPoint += 40;
      }
    }
  }

  // LEVEL4
  var darkCount = 0;

  for (col = 0; col < moduleCount; col++) {
    for (row = 0; row < moduleCount; row++) {
      if (qrCode.isDark(row, col)) {
        darkCount++;
      }
    }
  }

  final ratio = (100 * darkCount / moduleCount / moduleCount - 50).abs() / 5;
  return lostPoint + ratio * 10;
}

QrPolynomial _errorCorrectPolynomial(int errorCorrectLength) {
  var a = QrPolynomial([1], 0);

  for (var i = 0; i < errorCorrectLength; i++) {
    a = a.multiply(QrPolynomial([1, gexp(i)], 0));
  }

  return a;
}

class QrRsBlock {
  final int totalCount;
  final int dataCount;

  QrRsBlock._(this.totalCount, this.dataCount);

  static List<QrRsBlock> getRSBlocks(int typeNumber, int errorCorrectLevel) {
    final rsBlock = _getRsBlockTable(typeNumber, errorCorrectLevel);

    final length = rsBlock.length ~/ 3;

    final list = <QrRsBlock>[];

    for (var i = 0; i < length; i++) {
      final count = rsBlock[i * 3 + 0];
      final totalCount = rsBlock[i * 3 + 1];
      final dataCount = rsBlock[i * 3 + 2];

      for (var j = 0; j < count; j++) {
        list.add(QrRsBlock._(totalCount, dataCount));
      }
    }

    return list;
  }
}

List<int> _getRsBlockTable(int typeNumber, int errorCorrectLevel) {
  switch (errorCorrectLevel) {
    case QrErrorCorrectLevel.L:
      return _rsBlockTable[(typeNumber - 1) * 4 + 0];
    case QrErrorCorrectLevel.M:
      return _rsBlockTable[(typeNumber - 1) * 4 + 1];
    case QrErrorCorrectLevel.Q:
      return _rsBlockTable[(typeNumber - 1) * 4 + 2];
    case QrErrorCorrectLevel.H:
      return _rsBlockTable[(typeNumber - 1) * 4 + 3];
    default:
      throw ArgumentError(
          'bad rs block @ typeNumber: $typeNumber/errorCorrectLevel:$errorCorrectLevel');
  }
}

const List<List<int>> _rsBlockTable = [
  // L
  // M
  // Q
  // H
  // 1
  [1, 26, 19],
  [1, 26, 16],
  [1, 26, 13],
  [1, 26, 9],

  // 2
  [1, 44, 34],
  [1, 44, 28],
  [1, 44, 22],
  [1, 44, 16],

  // 3
  [1, 70, 55],
  [1, 70, 44],
  [2, 35, 17],
  [2, 35, 13],

  // 4
  [1, 100, 80],
  [2, 50, 32],
  [2, 50, 24],
  [4, 25, 9],

  // 5
  [1, 134, 108],
  [2, 67, 43],
  [2, 33, 15, 2, 34, 16],
  [2, 33, 11, 2, 34, 12],

  // 6
  [2, 86, 68],
  [4, 43, 27],
  [4, 43, 19],
  [4, 43, 15],

  // 7
  [2, 98, 78],
  [4, 49, 31],
  [2, 32, 14, 4, 33, 15],
  [4, 39, 13, 1, 40, 14],

  // 8
  [2, 121, 97],
  [2, 60, 38, 2, 61, 39],
  [4, 40, 18, 2, 41, 19],
  [4, 40, 14, 2, 41, 15],

  // 9
  [2, 146, 116],
  [3, 58, 36, 2, 59, 37],
  [4, 36, 16, 4, 37, 17],
  [4, 36, 12, 4, 37, 13],

  // 10
  [2, 86, 68, 2, 87, 69],
  [4, 69, 43, 1, 70, 44],
  [6, 43, 19, 2, 44, 20],
  [6, 43, 15, 2, 44, 16],

  // 11
  [4, 101, 81],
  [1, 80, 50, 4, 81, 51],
  [4, 50, 22, 4, 51, 23],
  [3, 36, 12, 8, 37, 13],

  // 12
  [2, 116, 92, 2, 117, 93],
  [6, 58, 36, 2, 59, 37],
  [4, 46, 20, 6, 47, 21],
  [7, 42, 14, 4, 43, 15],

  // 13
  [4, 133, 107],
  [8, 59, 37, 1, 60, 38],
  [8, 44, 20, 4, 45, 21],
  [12, 33, 11, 4, 34, 12],

  // 14
  [3, 145, 115, 1, 146, 116],
  [4, 64, 40, 5, 65, 41],
  [11, 36, 16, 5, 37, 17],
  [11, 36, 12, 5, 37, 13],

  // 15
  [5, 109, 87, 1, 110, 88],
  [5, 65, 41, 5, 66, 42],
  [5, 54, 24, 7, 55, 25],
  [11, 36, 12],

  // 16
  [5, 122, 98, 1, 123, 99],
  [7, 73, 45, 3, 74, 46],
  [15, 43, 19, 2, 44, 20],
  [3, 45, 15, 13, 46, 16],

  // 17
  [1, 135, 107, 5, 136, 108],
  [10, 74, 46, 1, 75, 47],
  [1, 50, 22, 15, 51, 23],
  [2, 42, 14, 17, 43, 15],

  // 18
  [5, 150, 120, 1, 151, 121],
  [9, 69, 43, 4, 70, 44],
  [17, 50, 22, 1, 51, 23],
  [2, 42, 14, 19, 43, 15],

  // 19
  [3, 141, 113, 4, 142, 114],
  [3, 70, 44, 11, 71, 45],
  [17, 47, 21, 4, 48, 22],
  [9, 39, 13, 16, 40, 14],

  // 20
  [3, 135, 107, 5, 136, 108],
  [3, 67, 41, 13, 68, 42],
  [15, 54, 24, 5, 55, 25],
  [15, 43, 15, 10, 44, 16],

  // 21
  [4, 144, 116, 4, 145, 117],
  [17, 68, 42],
  [17, 50, 22, 6, 51, 23],
  [19, 46, 16, 6, 47, 17],

  // 22
  [2, 139, 111, 7, 140, 112],
  [17, 74, 46],
  [7, 54, 24, 16, 55, 25],
  [34, 37, 13],

  // 23
  [4, 151, 121, 5, 152, 122],
  [4, 75, 47, 14, 76, 48],
  [11, 54, 24, 14, 55, 25],
  [16, 45, 15, 14, 46, 16],

  // 24
  [6, 147, 117, 4, 148, 118],
  [6, 73, 45, 14, 74, 46],
  [11, 54, 24, 16, 55, 25],
  [30, 46, 16, 2, 47, 17],

  // 25
  [8, 132, 106, 4, 133, 107],
  [8, 75, 47, 13, 76, 48],
  [7, 54, 24, 22, 55, 25],
  [22, 45, 15, 13, 46, 16],

  // 26
  [10, 142, 114, 2, 143, 115],
  [19, 74, 46, 4, 75, 47],
  [28, 50, 22, 6, 51, 23],
  [33, 46, 16, 4, 47, 17],

  // 27
  [8, 152, 122, 4, 153, 123],
  [22, 73, 45, 3, 74, 46],
  [8, 53, 23, 26, 54, 24],
  [12, 45, 15, 28, 46, 16],

  // 28
  [3, 147, 117, 10, 148, 118],
  [3, 73, 45, 23, 74, 46],
  [4, 54, 24, 31, 55, 25],
  [11, 45, 15, 31, 46, 16],

  // 29
  [7, 146, 116, 7, 147, 117],
  [21, 73, 45, 7, 74, 46],
  [1, 53, 23, 37, 54, 24],
  [19, 45, 15, 26, 46, 16],

  // 30
  [5, 145, 115, 10, 146, 116],
  [19, 75, 47, 10, 76, 48],
  [15, 54, 24, 25, 55, 25],
  [23, 45, 15, 25, 46, 16],

  // 31
  [13, 145, 115, 3, 146, 116],
  [2, 74, 46, 29, 75, 47],
  [42, 54, 24, 1, 55, 25],
  [23, 45, 15, 28, 46, 16],

  // 32
  [17, 145, 115],
  [10, 74, 46, 23, 75, 47],
  [10, 54, 24, 35, 55, 25],
  [19, 45, 15, 35, 46, 16],

  // 33
  [17, 145, 115, 1, 146, 116],
  [14, 74, 46, 21, 75, 47],
  [29, 54, 24, 19, 55, 25],
  [11, 45, 15, 46, 46, 16],

  // 34
  [13, 145, 115, 6, 146, 116],
  [14, 74, 46, 23, 75, 47],
  [44, 54, 24, 7, 55, 25],
  [59, 46, 16, 1, 47, 17],

  // 35
  [12, 151, 121, 7, 152, 122],
  [12, 75, 47, 26, 76, 48],
  [39, 54, 24, 14, 55, 25],
  [22, 45, 15, 41, 46, 16],

  // 36
  [6, 151, 121, 14, 152, 122],
  [6, 75, 47, 34, 76, 48],
  [46, 54, 24, 10, 55, 25],
  [2, 45, 15, 64, 46, 16],

  // 37
  [17, 152, 122, 4, 153, 123],
  [29, 74, 46, 14, 75, 47],
  [49, 54, 24, 10, 55, 25],
  [24, 45, 15, 46, 46, 16],

  // 38
  [4, 152, 122, 18, 153, 123],
  [13, 74, 46, 32, 75, 47],
  [48, 54, 24, 14, 55, 25],
  [42, 45, 15, 32, 46, 16],

  // 39
  [20, 147, 117, 4, 148, 118],
  [40, 75, 47, 7, 76, 48],
  [43, 54, 24, 22, 55, 25],
  [10, 45, 15, 67, 46, 16],

  // 40
  [19, 148, 118, 6, 149, 119],
  [18, 75, 47, 31, 76, 48],
  [34, 54, 24, 34, 55, 25],
  [20, 45, 15, 61, 46, 16]
];

const List<List<int>> _patternPositionTable = [
  [],
  [6, 18],
  [6, 22],
  [6, 26],
  [6, 30],
  [6, 34],
  [6, 22, 38],
  [6, 24, 42],
  [6, 26, 46],
  [6, 28, 50],
  [6, 30, 54],
  [6, 32, 58],
  [6, 34, 62],
  [6, 26, 46, 66],
  [6, 26, 48, 70],
  [6, 26, 50, 74],
  [6, 30, 54, 78],
  [6, 30, 56, 82],
  [6, 30, 58, 86],
  [6, 34, 62, 90],
  [6, 28, 50, 72, 94],
  [6, 26, 50, 74, 98],
  [6, 30, 54, 78, 102],
  [6, 28, 54, 80, 106],
  [6, 32, 58, 84, 110],
  [6, 30, 58, 86, 114],
  [6, 34, 62, 90, 118],
  [6, 26, 50, 74, 98, 122],
  [6, 30, 54, 78, 102, 126],
  [6, 26, 52, 78, 104, 130],
  [6, 30, 56, 82, 108, 134],
  [6, 34, 60, 86, 112, 138],
  [6, 30, 58, 86, 114, 142],
  [6, 34, 62, 90, 118, 146],
  [6, 30, 54, 78, 102, 126, 150],
  [6, 24, 50, 76, 102, 128, 154],
  [6, 28, 54, 80, 106, 132, 158],
  [6, 32, 58, 84, 110, 136, 162],
  [6, 26, 54, 82, 110, 138, 166],
  [6, 30, 58, 86, 114, 142, 170]
];

const int _g15 =
    (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0);
const int _g18 = (1 << 12) |
    (1 << 11) |
    (1 << 10) |
    (1 << 9) |
    (1 << 8) |
    (1 << 5) |
    (1 << 2) |
    (1 << 0);
const _g15Mask = (1 << 14) | (1 << 12) | (1 << 10) | (1 << 4) | (1 << 1);

int bchTypeInfo(int data) {
  var d = data << 10;
  while (_bchDigit(d) - _bchDigit(_g15) >= 0) {
    d ^= _g15 << (_bchDigit(d) - _bchDigit(_g15));
  }
  return ((data << 10) | d) ^ _g15Mask;
}

int bchTypeNumber(int data) {
  var d = data << 12;
  while (_bchDigit(d) - _bchDigit(_g18) >= 0) {
    d ^= _g18 << (_bchDigit(d) - _bchDigit(_g18));
  }
  return (data << 12) | d;
}

int _bchDigit(int data) {
  var digit = 0;

  while (data != 0) {
    digit++;
    data >>= 1;
  }

  return digit;
}

List<int> patternPosition(int typeNumber) =>
    _patternPositionTable[typeNumber - 1];
