import 'package:flutter/material.dart';

class TextLoader extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  const TextLoader({
    Key key,
    @required this.text,
    @required this.height,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> nms = [];
    nms = text.split(" ");

    return Container(
      width: width,
      height: height,
      color: Colors.grey,
      child: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Positioned(
            right: -20,
            left: -20,
            top: -20,
            bottom: -20,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: nms
                      .map(
                        (e) => Text(
                          e.toUpperCase(),
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
