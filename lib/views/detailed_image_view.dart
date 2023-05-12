import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/constants.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class DetailedImage extends StatefulWidget {
  final List images;
  DetailedImage({
    Key key,
    @required this.images,
  }) : super(key: key);

  @override
  State<DetailedImage> createState() => _DetailedImageState();
}

class _DetailedImageState extends State<DetailedImage> {
  int count = 0;
  bool shareProcessing = false;
  ScreenshotController controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      Future.delayed(Duration(seconds: 1), () {
        CommunicationServices().showToast(
          "No images detected",
          Colors.red,
        );

        if (context.canPop()) {
          Navigator.of(context).pop();
        } else {
          context.pushReplacementNamed(
            RouteConstants.home,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: widget.images.isEmpty
          ? Center(
              child: LoadingWidget(),
            )
          : SafeArea(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      child: Screenshot(
                        controller: controller,
                        child: Image.network(
                          widget.images[count],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, v, b) {
                            if (b == null) return v;

                            return Pulser(
                              child: TextLoader(
                                text: capitalizedAppName,
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    left: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              if (context.canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                context
                                    .pushReplacementNamed(RouteConstants.home);
                              }
                            },
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: shareProcessing
                              ? CircularProgressIndicator()
                              : IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                    downloadImage(
                                      widget.images[count],
                                    );
                                  }),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Center(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.images.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    count = index;
                                  });
                                }
                              },
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: count == index ? 2 : 0,
                                        color: Colors.white)),
                                child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Image.network(
                                      widget.images[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, b, n) {
                                        if (n == null) return b;

                                        return Pulser(
                                          child: TextLoader(
                                            text: capitalizedAppName,
                                            height: 100,
                                            width: 50,
                                          ),
                                        );
                                      },
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  downloadImage(String image) async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialogBox(
            bodyText: null,
            buttonText: null,
            onButtonTap: null,
            showOtherButton: null,
            child: Column(
              children: [
                Text(
                  "Downloading the Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                LoadingWidget(),
              ],
            ),
          );
        },
      );

      await controller
          .capture(
        delay: Duration(seconds: 10),
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      )
          .then(
        (Uint8List image) async {
          Navigator.of(context).pop();

          final directory = await getApplicationDocumentsDirectory();
          String time = DateTime.now().millisecondsSinceEpoch.toString();
          final imagePath = await File('${directory.path}/$time.png').create();

          await imagePath.writeAsBytes(image);

          if (shareProcessing) {
            Share.shareFiles(
              [imagePath.path],
              text: "Hey. Check out this image I found on $capitalizedAppName",
              subject:
                  "Hey. Check out this image I found on $capitalizedAppName",
            );
          }
        },
      );

      CommunicationServices().showToast(
        "Image saved to Pictures folder",
        primaryColor,
      );
    } catch (e) {
      Navigator.of(context).pop();

      CommunicationServices().showToast(
        "There was an error downloading the image : $e",
        Colors.red,
      );
    }
  }
}
