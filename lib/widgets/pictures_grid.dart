import 'package:dorx/widgets/single_image.dart';
import 'package:flutter/material.dart';
import 'package:dorx/widgets/loading_widget.dart';
import '../constants/ui.dart';

class PicturesGrid extends StatelessWidget {
  final List images;
  const PicturesGrid({
    Key key,
    @required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return singlePicGroup(
      images,
      context,
    );
  }

  imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey,
      child: Center(child: LoadingWidget()),
    );
  }

  singlePicGroup(
    List images,
    BuildContext context,
  ) {
    return images.isEmpty
        ? SizedBox()
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: standardBorderRadius,
              child: images.length == 1
                  ? singlePic(
                      images[0],
                    )
                  : images.length == 2
                      ? Row(
                          children: [
                            Expanded(
                              child: singlePic(
                                images[0],
                              ),
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: singlePic(
                                images[1],
                              ),
                            ),
                          ],
                        )
                      : images.length == 3
                          ? Row(
                              children: [
                                Expanded(
                                  child: singlePic(
                                    images[0],
                                  ),
                                ),
                                SizedBox(width: 2),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: singlePic(
                                          images[1],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Expanded(
                                        child: singlePic(
                                          images[2],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          : images.length == 4
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: singlePic(
                                              images[0],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Expanded(
                                            child: singlePic(
                                              images[1],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: singlePic(
                                              images[2],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Expanded(
                                            child: singlePic(
                                              images[3],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: singlePic(
                                              images[0],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Expanded(
                                            child: singlePic(
                                              images[1],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: singlePic(
                                              images[2],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                singlePic(
                                                  images[3],
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 25,
                                                        ),
                                                        Text(
                                                          (images.length - 3)
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 25,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
            ),
          );
  }

  Widget singlePic(
    dynamic image,
  ) {
    return SingleImage(
      image: image,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    );
  }
}
