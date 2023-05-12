import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class MyQrCodes extends StatefulWidget {
  MyQrCodes({Key key}) : super(key: key);

  @override
  State<MyQrCodes> createState() => _MyQrCodesState();
}

class _MyQrCodesState extends State<MyQrCodes> {
  String userLink;
  final GlobalKey genKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OnlyWhenLoggedIn(
      signedInBuilder: (uid) {
        return Column(
          children: [
            CustomSizedBox(
              sbSize: SBSize.normal,
              height: true,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSizedBox(
                      sbSize: SBSize.small,
                      height: false,
                    ),
                    GestureDetector(
                      onTap: () {
                        takePicture();
                      },
                      child: RepaintBoundary(
                        key: genKey,
                        child: PrettyQr(
                          image: AssetImage(
                            dorxLogo,
                          ),
                          typeNumber: 5,
                          size: 200,
                          data: json.encode(
                            {
                              QRCodeScannerResult.THINGTYPE: ThingType.USER,
                              QRCodeScannerResult.THINGID:
                                  AuthProvider.of(context).auth.getCurrentUID(),
                            },
                          ),
                          errorCorrectLevel: QrErrorCorrectLevel.M,
                          roundEdges: true,
                        ),
                      ),
                    ),
                    CustomSizedBox(
                      sbSize: SBSize.normal,
                      height: false,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            if (userLink != null)
              Text(
                userLink,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            CustomSizedBox(
              sbSize: SBSize.small,
              height: true,
            ),
            InformationalBox(
              visible: true,
              onClose: null,
              message:
                  "The $capitalizedAppName Code helps people find you easier on the platform and, it lets them send you money on your wallet.",
            ),
            CustomSizedBox(
              sbSize: SBSize.small,
              height: true,
            ),
          ],
        );
      }
    );
  }

  Future<void> takePicture() async {
    RenderRepaintBoundary boundary = genKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();

    final directory = (await getExternalStorageDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    File imgFile = File('$directory/photo.png');
    imgFile.writeAsBytes(pngBytes);

    Share.shareFiles([
      imgFile.path,
    ]);
  }
}
