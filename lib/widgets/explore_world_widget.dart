import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import 'widgets.dart';

class ExploreWorldWidget extends StatefulWidget {
  const ExploreWorldWidget({Key key}) : super(key: key);

  @override
  State<ExploreWorldWidget> createState() => _ExploreWorldWidgetState();
}

class _ExploreWorldWidgetState extends State<ExploreWorldWidget>
    with AutomaticKeepAliveClientMixin {
  ScrollController exploreController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PaginateFirestore(
            isLive: true,
            scrollController: exploreController,
            query: FirebaseFirestore.instance
                .collection(Vicinity.DIRECTORY)
                .orderBy(
                  Vicinity.DATE,
                  descending: true,
                ),
            itemBuilderType: PaginateBuilderType.listView,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, snapshot, index) {
              Vicinity vicinity = Vicinity.fromSnapshot(snapshot[index]);

              return SizedBox(
                width: 200,
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.explore,
                      extra: {
                        "location": LatLng(
                          vicinity.lat,
                          vicinity.long,
                        ),
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: standardBorderRadius,
                      child: Stack(
                        children: [
                          ParallaxImage(
                            extent: MediaQuery.of(context).size.height * 0.25,
                            image: UIServices().getImageProvider(vicinity
                                    .images.isEmpty
                                ? vicinityBGPics[index % vicinityBGPics.length]
                                : vicinity.images[0]),
                            child: Container(),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black,
                                  ],
                                ),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      vicinity.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    if (vicinity.address != null)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                          ),
                                          Expanded(
                                            child: Text(
                                              vicinity.address,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Center(
            child: StackableScrollController(
              controller: exploreController,
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
