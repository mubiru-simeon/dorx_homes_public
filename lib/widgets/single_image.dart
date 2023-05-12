import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import '../constants/basic.dart';
import 'widgets.dart';

class SingleImage extends StatelessWidget {
  final dynamic image;
  final double height;
  final BoxFit fit;
  final Widget placeHolderWidget;
  final String placeholderText;
  final bool darken;
  final double width;
  const SingleImage({
    Key key,
    @required this.image,
    this.height,
    this.placeholderText = capitalizedAppName,
    this.placeHolderWidget,
    this.darken = false,
    this.fit = BoxFit.cover,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image == null
        ? SizedBox()
        : Image(
            image: UIServices().getImageProvider(image),
            height: height,
            width: width,
            fit: fit,
            colorBlendMode: darken ? BlendMode.darken : BlendMode.clear,
            color: darken
                ? Colors.black.withOpacity(
                    darken ? 0.6 : 0.0,
                  )
                : null,
            loadingBuilder: (context, b, n) {
              if (n == null) return b;

              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey,
                child: Center(
                  child: LoadingWidget(),
                ),
              );
            },
          );
  }
}
