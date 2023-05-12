import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../services/services.dart';
import 'widgets.dart';

class FeaturedStays extends StatefulWidget {
  final String university;
  final bool student;
  const FeaturedStays({
    Key key,
    @required this.student,
    @required this.university,
  }) : super(key: key);

  @override
  State<FeaturedStays> createState() => _FeaturedStaysState();
}

class _FeaturedStaysState extends State<FeaturedStays>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  AnimationController _animController;
  List<Property> properties = [];
  Function doIt;
  int _currentIndex = 0;

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
          if (_currentIndex + 1 < properties.length) {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (properties.isNotEmpty) {
                StorageServices().handleClick(
                  ThingType.PROPERTY,
                  properties[_currentIndex].id,
                  context,
                );
              }
            },
            child: PaginateFirestore(
              isLive: true,
              scrollDirection: Axis.horizontal,
              pageController: _pageController,
              onPageChanged: (i) {
                _currentIndex = i;

                doIt(() {});

                _animController.stop();
                _animController.reset();
                _animController.duration = Duration(seconds: 5);
                _animController.forward();
              },
              onLoaded: (v) {
                properties.clear();

                for (var element in v.documentSnapshots) {
                  Property massSuggestion = Property.fromSnapshot(element);

                  properties.add(
                    massSuggestion,
                  );
                }
              },
              itemBuilder: (context, snapshot, index) {
                Property massSuggestion =
                    Property.fromSnapshot(snapshot[index]);

                return SingleImage(
                  width: double.infinity,
                  darken: true,
                  height: double.infinity,
                  image: massSuggestion.images[0],
                  placeholderText: capitalizedAppName,
                );
              },
              itemBuilderType: PaginateBuilderType.pageView,
              query: getQuery(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  stops: [
                    0,
                    0.7,
                  ],
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).canvasColor,
                  ],
                ),
              ),
              child: StatefulBuilder(
                builder: (context, setIt) {
                  doIt = setIt;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (properties.isNotEmpty &&
                                  properties[_currentIndex].name != null)
                                Text(
                                  properties[_currentIndex].name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (properties.isNotEmpty &&
                                  properties[_currentIndex].address != null)
                                Text(
                                  properties[_currentIndex].address,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.bookARoom,
                                extra: properties[_currentIndex],
                                params: {
                                  "id": properties[_currentIndex].id,
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                border: Border.all(
                                  color: primaryColor,
                                ),
                              ),
                              child: Text(
                                "Book now",
                                style: smallWhiteTitle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: properties
                            .asMap()
                            .map(
                              (i, e) {
                                return MapEntry(
                                  i,
                                  AnimatedBar(
                                    animController: _animController,
                                    position: i,
                                    color: primaryColor,
                                    currentIndex: _currentIndex,
                                  ),
                                );
                              },
                            )
                            .values
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  getQuery() {
    Query qq = FirebaseFirestore.instance
        .collection(Property.DIRECTORY)
        .where(
          Property.AVAILABLE,
          isEqualTo: true,
        )
        .where(Property.FEATURED, isEqualTo: true);

    if (widget.university != null) {
      qq = qq.where(
        Property.NEARBYUNIVERSITY,
        isEqualTo: widget.university,
      );
    }

    return qq;
  }
}
