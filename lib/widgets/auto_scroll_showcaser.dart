import 'package:flutter/material.dart';

import '../constants/ui.dart';
import 'single_image.dart';

class AutoScrollShowcaser extends StatefulWidget {
  final List images;
  final String placeholderText;
  AutoScrollShowcaser({
    Key key,
    @required this.images,
    @required this.placeholderText,
  }) : super(key: key);

  @override
  State<AutoScrollShowcaser> createState() => _AutoScrollShowcaserState();
}

class _AutoScrollShowcaserState extends State<AutoScrollShowcaser>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  AnimationController _animController;
  Function doIt;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _animController = AnimationController(vsync: this);
    _loadStory(animateToPage: false);
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        doIt(() {
          if (_currentIndex + 1 < widget.images.length) {
            _currentIndex += 1;
            _loadStory();
          } else {
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here
            _currentIndex = 0;
            _loadStory();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (_animController != null) _animController.dispose();
    if (_pageController != null) _pageController.dispose();
    super.dispose();
  }

  void _loadStory({bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = Duration(seconds: 5);
    _animController.forward();

    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: standardBorderRadius,
        child: SizedBox(
          height: 200,
          child: Stack(
            children: [
              PageView(
                onPageChanged: (i) {
                  _currentIndex = i;

                  doIt(() {});

                  _animController.stop();
                  _animController.reset();
                  _animController.duration = Duration(seconds: 5);
                  _animController.forward();
                },
                controller: _pageController,
                children: widget.images
                    .map((e) => SingleImage(
                          image: e,
                          placeholderText: widget.placeholderText,
                        ))
                    .toList(),
              ),
              Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: Row(
                    children: [
                      Expanded(
                        child: StatefulBuilder(builder: (context, setIt) {
                          doIt = setIt;
                          return Row(
                            children: widget.images
                                .asMap()
                                .map((i, e) {
                                  return MapEntry(
                                    i,
                                    AnimatedBar(
                                      animController: _animController,
                                      position: i,
                                      currentIndex: _currentIndex,
                                    ),
                                  );
                                })
                                .values
                                .toList(),
                          );
                        }),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final Color color;
  final int currentIndex;

  const AnimatedBar({
    Key key,
    @required this.animController,
    @required this.position,
    this.color = Colors.white,
    @required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? color
                      : color.withOpacity(
                          0.4,
                        ),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
                            color,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: standardBorderRadius,
      ),
    );
  }
}
