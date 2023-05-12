import 'dart:async';
import 'dart:ui' as ui;
import 'package:dorx/theming/theme_controller.dart';
import 'package:flutter/material.dart';

import '../../services/qr_services.dart';

class PrettyQr extends StatefulWidget {
  ///Widget size
  final double size;

  ///Qr code data
  final String data;

  final int version;

  ///Square color
  final Color elementColor;

  ///Error correct level
  final int errorCorrectLevel;

  ///Round the corners
  final bool roundEdges;

  ///Number of type generation (1 to 40 or null for auto)
  final int typeNumber;

  final ImageProvider image;

  PrettyQr({
    Key key,
    this.size = 100,
    @required this.data,
    this.elementColor,
    this.version,
    this.errorCorrectLevel = QrErrorCorrectLevel.M,
    this.roundEdges = false,
    this.typeNumber,
    this.image,
  }) : super(key: key);

  @override
  State<PrettyQr> createState() => _PrettyQrState();
}

class _PrettyQrState extends State<PrettyQr> {
  Future<ui.Image> _loadImage(BuildContext buildContext) async {
    final completer = Completer<ui.Image>();

    final stream = widget.image.resolve(ImageConfiguration(
      devicePixelRatio: MediaQuery.of(buildContext).devicePixelRatio,
    ));

    stream.addListener(ImageStreamListener((imageInfo, error) {
      completer.complete(imageInfo.image);
    }, onError: (dynamic error, _) {
      completer.completeError(error);
    }));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return widget.image == null
        ? CustomPaint(
            size: Size(widget.size, widget.size),
            painter: PrettyQrCodePainter(
              version: widget.version,
              data: widget.data,
              errorCorrectLevel: widget.errorCorrectLevel,
              elementColor: ThemeBuilder.of(context).getCurrentTheme() ==
                      ui.Brightness.dark
                  ? Colors.white
                  : Colors.black,
              roundEdges: widget.roundEdges,
              typeNumber: widget.typeNumber,
            ),
          )
        : FutureBuilder(
            future: _loadImage(context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: PrettyQrCodePainter(
                    image: snapshot.data,
                    version: widget.version,
                    data: widget.data,
                    errorCorrectLevel: widget.errorCorrectLevel,
                    elementColor: ThemeBuilder.of(context).getCurrentTheme() ==
                            ui.Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    roundEdges: widget.roundEdges,
                    typeNumber: widget.typeNumber,
                  ),
                );
              } else {
                return Container();
              }
            },
          );
  }
}

class PrettyQrCodePainter extends CustomPainter {
  final String data;
  final Color elementColor;
  final int errorCorrectLevel;
  final bool roundEdges;
  final int version;
  ui.Image image;
  QrCode _qrCode;
  int deletePixelCount = 0;

  PrettyQrCodePainter({
    @required this.data,
    this.elementColor = Colors.black,
    this.errorCorrectLevel = QrErrorCorrectLevel.M,
    this.roundEdges = false,
    this.image,
    @required this.version,
    int typeNumber,
  }) {
    if (typeNumber == null) {
      _qrCode = QrCode.fromData(
        data: data,
        version: version,
        errorCorrectLevel: errorCorrectLevel,
      );
    } else {
      _qrCode = QrCode(typeNumber, errorCorrectLevel);
      _qrCode.addData(data);
    }

    _qrCode.make();
  }

  @override
  paint(Canvas canvas, Size size) {
    if (image != null) {
      if (_qrCode.typeNumber <= 2) {
        deletePixelCount = _qrCode.typeNumber + 7;
      } else if (_qrCode.typeNumber <= 4) {
        deletePixelCount = _qrCode.typeNumber + 8;
      } else {
        deletePixelCount = _qrCode.typeNumber + 9;
      }

      var imageSize = Size(image.width.toDouble(), image.height.toDouble());

      var src = Alignment.center.inscribe(imageSize,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));

      var dst = Alignment.center.inscribe(
          Size(size.height / 4, size.height / 4),
          Rect.fromLTWH(size.width / 3, size.height / 3, size.height / 3,
              size.height / 3));

      canvas.drawImageRect(image, src, dst, Paint());
    }

    roundEdges ? _paintRound(canvas, size) : _paintDefault(canvas, size);
  }

  void _paintRound(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = elementColor
      ..isAntiAlias = true;

    var paintBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..isAntiAlias = true;

    List<List> matrix = []..length = _qrCode.moduleCount + 2;
    for (var i = 0; i < _qrCode.moduleCount + 2; i++) {
      matrix[i] = []..length = _qrCode.moduleCount + 2;
    }

    for (int x = 0; x < _qrCode.moduleCount + 2; x++) {
      for (int y = 0; y < _qrCode.moduleCount + 2; y++) {
        matrix[x][y] = false;
      }
    }

    for (int x = 0; x < _qrCode.moduleCount; x++) {
      for (int y = 0; y < _qrCode.moduleCount; y++) {
        if (image != null &&
            x >= deletePixelCount &&
            y >= deletePixelCount &&
            x < _qrCode.moduleCount - deletePixelCount &&
            y < _qrCode.moduleCount - deletePixelCount) {
          matrix[y + 1][x + 1] = false;
          continue;
        }

        if (_qrCode.isDark(y, x)) {
          matrix[y + 1][x + 1] = true;
        } else {
          matrix[y + 1][x + 1] = false;
        }
      }
    }

    double pixelSize = size.width / _qrCode.moduleCount;

    for (int x = 0; x < _qrCode.moduleCount; x++) {
      for (int y = 0; y < _qrCode.moduleCount; y++) {
        if (matrix[y + 1][x + 1]) {
          final Rect squareRect =
              Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize);

          _setShape(x + 1, y + 1, squareRect, paint, matrix, canvas,
              _qrCode.moduleCount);
        } else {
          _setShapeInner(
              x + 1, y + 1, paintBackground, matrix, canvas, pixelSize);
        }
      }
    }
  }

  void _drawCurve(Offset p1, Offset p2, Offset p3, Canvas canvas) {
    Path path = Path();

    path.moveTo(p1.dx, p1.dy);
    path.quadraticBezierTo(p2.dx, p2.dy, p3.dx, p3.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p1.dx, p1.dy);
    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = elementColor);
  }

  void _setShapeInner(
      int x, int y, Paint paint, List matrix, Canvas canvas, double pixelSize) {
    double widthY = pixelSize * (y - 1);
    double heightX = pixelSize * (x - 1);

    //bottom right check
    if (matrix[y + 1][x] && matrix[y][x + 1] && matrix[y + 1][x + 1]) {
      Offset p1 =
          Offset(heightX + pixelSize - (0.25 * pixelSize), widthY + pixelSize);
      Offset p2 = Offset(heightX + pixelSize, widthY + pixelSize);
      Offset p3 =
          Offset(heightX + pixelSize, widthY + pixelSize - (0.25 * pixelSize));

      _drawCurve(p1, p2, p3, canvas);
    }

    //top left check
    if (matrix[y - 1][x] && matrix[y][x - 1] && matrix[y - 1][x - 1]) {
      Offset p1 = Offset(heightX, widthY + (0.25 * pixelSize));
      Offset p2 = Offset(heightX, widthY);
      Offset p3 = Offset(heightX + (0.25 * pixelSize), widthY);

      _drawCurve(p1, p2, p3, canvas);
    }

    //bottom left check
    if (matrix[y + 1][x] && matrix[y][x - 1] && matrix[y + 1][x - 1]) {
      Offset p1 = Offset(heightX, widthY + pixelSize - (0.25 * pixelSize));
      Offset p2 = Offset(heightX, widthY + pixelSize);
      Offset p3 = Offset(heightX + (0.25 * pixelSize), widthY + pixelSize);

      _drawCurve(p1, p2, p3, canvas);
    }

    //top right check
    if (matrix[y - 1][x] && matrix[y][x + 1] && matrix[y - 1][x + 1]) {
      Offset p1 = Offset(heightX + pixelSize - (0.25 * pixelSize), widthY);
      Offset p2 = Offset(heightX + pixelSize, widthY);
      Offset p3 = Offset(heightX + pixelSize, widthY + (0.25 * pixelSize));

      _drawCurve(p1, p2, p3, canvas);
    }
  }

  //Round the corners and paint it
  void _setShape(int x, int y, Rect squareRect, Paint paint, List matrix,
      Canvas canvas, int n) {
    bool bottomRight = false;
    bool bottomLeft = false;
    bool topRight = false;
    bool topLeft = false;

    //if it is dot (arount an empty place)
    if (!matrix[y + 1][x] &&
        !matrix[y][x + 1] &&
        !matrix[y - 1][x] &&
        !matrix[y][x - 1]) {
      canvas.drawRRect(
          RRect.fromRectAndCorners(squareRect,
              bottomRight: Radius.circular(2.5),
              bottomLeft: Radius.circular(2.5),
              topLeft: Radius.circular(2.5),
              topRight: Radius.circular(2.5)),
          paint);
      return;
    }

    //bottom right check
    if (!matrix[y + 1][x] && !matrix[y][x + 1]) {
      bottomRight = true;
    }

    //top left check
    if (!matrix[y - 1][x] && !matrix[y][x - 1]) {
      topLeft = true;
    }

    //bottom left check
    if (!matrix[y + 1][x] && !matrix[y][x - 1]) {
      bottomLeft = true;
    }

    //top right check
    if (!matrix[y - 1][x] && !matrix[y][x + 1]) {
      topRight = true;
    }

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          squareRect,
          bottomRight: bottomRight ? Radius.circular(6.0) : Radius.zero,
          bottomLeft: bottomLeft ? Radius.circular(6.0) : Radius.zero,
          topLeft: topLeft ? Radius.circular(6.0) : Radius.zero,
          topRight: topRight ? Radius.circular(6.0) : Radius.zero,
        ),
        paint);

    //if it is dot (arount an empty place)
    if (!bottomLeft && !bottomRight && !topLeft && !topRight) {
      canvas.drawRect(squareRect, paint);
    }
  }

  void _paintDefault(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = elementColor
      ..isAntiAlias = true;

    ///size of point
    double pixelSize = size.width / _qrCode.moduleCount;

    for (int x = 0; x < _qrCode.moduleCount; x++) {
      for (int y = 0; y < _qrCode.moduleCount; y++) {
        if (image != null &&
            x >= deletePixelCount &&
            y >= deletePixelCount &&
            x < _qrCode.moduleCount - deletePixelCount &&
            y < _qrCode.moduleCount - deletePixelCount) continue;

        if (_qrCode.isDark(y, x)) {
          canvas.drawRect(
              Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
              paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PrettyQrCodePainter oldDelegate) =>
      oldDelegate.data != data;
}
