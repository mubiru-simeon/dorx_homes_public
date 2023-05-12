import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../services/services.dart';
import 'widgets.dart';

class SingleThing extends StatelessWidget {
  final bool current;
  final int index;
  final int currentPage;
  final List images;
  final PageController controller;
  SingleThing({
    Key key,
    @required this.current,
    @required this.controller,
    @required this.currentPage,
    @required this.index,
    @required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value;
        if (controller.position.haveDimensions) {
          value = controller.page - index;
        } else {
          // If haveDimensions is false, use _currentPage to calculate value.
          value = (currentPage - index).toDouble();
        }

        value = (1 - (value.abs() * .5)).clamp(0, 1).toDouble();

        value = Curves.easeOut.transform(value);

        return Transform(
          transform: Matrix4.diagonal3Values(1.0, value, 1.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: standardBorderRadius,
              child: GestureDetector(
                onTap: () {},
                child: ParallaxImage(
                  image: UIServices().getImageProvider(
                    images.isEmpty ? lobby : images[0],
                  ),
                  color: Colors.black.withOpacity(0.5),
                  extent: MediaQuery.of(context).size.width * 0.9,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
