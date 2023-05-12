import 'package:dorx/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dorx/views/views.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/constants.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class DetailedPropertyView extends StatefulWidget {
  final Property property;
  final String propertyID;

  DetailedPropertyView({
    Key key,
    @required this.property,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<DetailedPropertyView> createState() => _DetailedPropertyViewState();
}

class _DetailedPropertyViewState extends State<DetailedPropertyView> {
  int _currentPicIndex = 0;
  PageController pageController = PageController();
  bool start = true;
  bool shareProcessing = false;

  @override
  Widget build(BuildContext context) {
    return widget.property == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Property.DIRECTORY)
                .doc(widget.propertyID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  body: LoadingWidget(),
                );
              } else {
                Property recipe = Property.fromSnapshot(snapshot.data);

                return body(recipe);
              }
            })
        : body(widget.property);
  }

  body(Property property) {
    if (start) {
      StorageServices().saveNewHistory(
        context: context,
        thingID: widget.propertyID,
        analyticType: Analytics.MAXICOUNT,
        type: ThingType.PROPERTY,
      );

      start = false;
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                actions: [
                  FavoriteButton(
                    thingID: property.id,
                    thingType: ThingType.PROPERTY,
                  ),
                ],
                snap: false,
                leading: IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.pushReplacementNamed(
                        RouteConstants.home,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                flexibleSpace: FlexibleSpaceBar(
                  background: property.images.isEmpty
                      ? Image.asset(
                          compound,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.3),
                          colorBlendMode: BlendMode.darken,
                        )
                      : GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.image,
                              extra: property.images,
                            );
                          },
                          child: StatefulBuilder(
                            builder: (context, doIt) {
                              return Stack(
                                children: [
                                  Carousel(
                                    images: property.images
                                        .map(
                                          (e) => SingleImage(
                                            image: e,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                        )
                                        .toList(),
                                    showIndicator: false,
                                    onImageChange: (o, n) {
                                      doIt(() {
                                        _currentPicIndex = n;
                                      });
                                    },
                                  ),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: SafeArea(
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: altColor.withOpacity(0.5),
                                            border: Border.all(
                                                width: 1, color: altColor),
                                            borderRadius: standardBorderRadius),
                                        child: Text(
                                          "${_currentPicIndex + 1}/${property.images.length}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (property.available)
                            InformationalBox(
                              visible: true,
                              onClose: null,
                              message:
                                  "Psssst.. You can use the calculator to help you budget well and plan appropiately",
                            ),
                          Text(
                            property.name ?? "Property",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: property.name == null ? Colors.red : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          if (property.description != null)
                            Text(
                              property.description,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          StatisticText(
                            title: "This property falls under",
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: property.cateogry
                                  .map(
                                    (e) => SizedBox(
                                      width: 200,
                                      child: NewCategory(
                                        showDesc: false,
                                        category: null,
                                        categoryID: e,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            if (property.houseType != null)
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: ChoiceChip(
                                  label: Text(
                                    property.houseType.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: true,
                                ),
                              ),
                            if (property.sharedWithWho != null)
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: ChoiceChip(
                                  label: Text(
                                    property.sharedWithWho.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: true,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (property.images.isNotEmpty)
                        StatisticText(
                          title: "Some pics for you",
                        ),
                      if (property.images.isNotEmpty)
                        SizedBox(
                          height: 5,
                        ),
                      if (property.images.isNotEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.17,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: property.images
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.pushNamed(
                                            RouteConstants.image,
                                            extra: property.images,
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: standardBorderRadius,
                                          child: SingleImage(
                                            image: e,
                                            height: double.infinity,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      if (property.images.isNotEmpty)
                        SizedBox(
                          height: 20,
                        ),
                      if ((property.wellbeingAmenities.isNotEmpty ||
                          property.luxuryAmenities.isNotEmpty ||
                          property.securityAmenities.isNotEmpty))
                        StatisticText(
                          title: "What this place offers",
                        ),
                      if ((property.wellbeingAmenities.isNotEmpty))
                        amenity(
                          property.wellbeingAmenities,
                          "WellBeing",
                        ),
                      if (property.luxuryAmenities.isNotEmpty)
                        amenity(
                          property.luxuryAmenities,
                          "Luxury",
                        ),
                      if (property.securityAmenities.isNotEmpty)
                        amenity(
                          property.securityAmenities,
                          "Security",
                        ),
                      Divider(),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      if (property.lat != null)
                        StatisticText(
                          title: "Where is this place?",
                        ),
                      if (property.lat != null)
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: ClipRRect(
                            borderRadius: standardBorderRadius,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: GestureDetector(
                                onTap: () {
                                  LocationService().openInGoogleMaps(
                                      property.lat, property.long);
                                },
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Image(
                                        image: AssetImage(
                                          mapPic,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Spacer(),
                                        Expanded(
                                          child: Container(
                                            color: altColor,
                                            child: Center(
                                              child: FutureBuilder(
                                                future: LocationService()
                                                    .getAddressFromLatLng(
                                                  LatLng(
                                                    property.lat,
                                                    property.long,
                                                  ),
                                                ),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Text(
                                                      "location loading..\nTap here to get directions",
                                                    );
                                                  } else {
                                                    String place =
                                                        snapshot.data["text"];

                                                    return Text(
                                                      "$place\nTap here to get directions",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: whiteTitle,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (property.lat != null)
                        CustomSizedBox(
                          sbSize: SBSize.small,
                          height: true,
                        ),
                      if (property.saleMode == FORRENT)
                        StatisticText(
                          title: "Where you'll sleep",
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: PaginateFirestore(
                          itemBuilder: (context, snapshot, index) {
                            RoomType roomType =
                                RoomType.fromSnapshot(snapshot[index]);

                            return Column(
                              children: [
                                Expanded(
                                  child: SingleRoomType(
                                    roomType: roomType,
                                    horizontal: true,
                                    roomTypeID: roomType.id,
                                  ),
                                ),
                                ElevatedButton(
                                  child: Text(
                                    "Tap here to book",
                                  ),
                                  onPressed: () {
                                    context.pushNamed(
                                      RouteConstants.bookARoom,
                                      extra: property,
                                      params: {
                                        "id": property.id,
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                          isLive: true,
                          onEmpty: NoDataFound(
                            text: "No Rooms Attached Yet",
                          ),
                          query: FirebaseFirestore.instance
                              .collection(RoomType.DIRECTORY)
                              .where(
                                RoomType.PROPERTY,
                                isEqualTo: property.id,
                              ),
                          itemBuilderType: PaginateBuilderType.listView,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                      if (property.price != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                property.saleMode == FORSALE
                                    ? "For Sale"
                                    : "For Rent",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${TextService().putCommas(property.price.toString())} UGX" ??
                                    "Please provide a price for your Property",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: property.price == null
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (property.price != null)
                        CustomSizedBox(
                          sbSize: SBSize.small,
                          height: true,
                        ),
                      if (property.price != null)
                        CustomSizedBox(
                          sbSize: SBSize.small,
                          height: true,
                        ),
                      if (property.price == null)
                        CustomSizedBox(
                          sbSize: SBSize.small,
                          height: true,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDivider(),
                            ListTile(
                              title: Text(
                                "RATINGS AND REVIEWS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                              ),
                              onTap: () {
                                //TODO: Reviews here
                                // UIServices().showDatSheet(
                                //   ReviewsPage(
                                //     thingID: property.id,
                                //     pushed: true,
                                //     mine: AuthProvider.of(context)
                                //             .auth
                                //             .isSignedIn() &&
                                //         (property.owner ==
                                //             AuthProvider.of(context)
                                //                 .auth
                                //                 .getCurrentUID()),
                                //     thingType: ThingType.PROPERTY,
                                //   ),
                                //   true,
                                //   context,
                                // );
                              },
                            ),
                            CustomDivider(),
                            CustomSizedBox(
                              sbSize: SBSize.small,
                              height: true,
                            ),
                            StatisticText(
                              title: "More like this",
                            ),
                            SizedBox(
                              height: 400,
                              child: PaginateFirestore(
                                itemBuilder: (
                                  context,
                                  snapshot,
                                  index,
                                ) {
                                  Property property = Property.fromSnapshot(
                                    snapshot[index],
                                  );

                                  return SingleProperty(
                                    property: property,
                                    horizontal: true,
                                    selected: false,
                                    selectable: false,
                                    list: true,
                                    onTap: null,
                                    propertyID: property.id,
                                  );
                                },
                                query: FirebaseFirestore.instance
                                    .collection(Property.DIRECTORY)
                                    .where(
                                      Property.AVAILABLE,
                                      isEqualTo: true,
                                    )
                                    .where(
                                      Property.CATEGORY,
                                      arrayContainsAny: property.cateogry,
                                    ),
                                onEmpty: NoDataFound(
                                  text:
                                      "Looks like this one is a one of a kind.",
                                ),
                                itemsPerPage: 2,
                                scrollDirection: Axis.horizontal,
                                itemBuilderType: PaginateBuilderType.listView,
                              ),
                            ),
                            CustomSizedBox(
                              sbSize: SBSize.small,
                              height: true,
                            ),
                            CustomDivider(),
                            ListTile(
                              title: Text(
                                "NEED HELP? Tap Here to talk to $capitalizedAppName Admin",
                              ),
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.aboutUs,
                                );
                              },
                            ),
                            CustomDivider(),
                            CustomSizedBox(
                              sbSize: SBSize.largest,
                              height: true,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 5,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: "share_property",
                        onPressed: () async {
                          setState(() {
                            shareProcessing = true;
                          });
//TODO: dynamic linking

                          // String pp = await DynamicLinkServices().generateLink(
                          //   context: context,
                          //   id: property.id,
                          //   title: property.name,
                          //   desc: property.description ??
                          //       "A lovely venue for you",
                          //   type: ThingType.PROPERTY,
                          //   image: property.images.isEmpty
                          //       ? null
                          //       : property.images[0],
                          //   userID: AuthProvider.of(context).auth.isSignedIn()
                          //       ? AuthProvider.of(context).auth.getCurrentUID()
                          //       : "anon",
                          // );

                          // if (pp != null) {
                          //   Share.share(
                          //     pp,
                          //     subject:
                          //         "Check out this ${ThingType.PROPERTY} from ${appName.capitalizeFirstOfEach}",
                          //   );
                          // }

                          setState(() {
                            shareProcessing = false;
                          });
                        },
                        child: shareProcessing
                            ? CircularProgressIndicator()
                            : Icon(
                                Icons.share,
                              ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  children: [
                    Column(
                      children: [
                        if (property.price != null)
                          Container(
                            padding: EdgeInsets.all(10),
                            color: Theme.of(context).canvasColor,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              property.saleMode == FORSALE
                                                  ? "For Sale"
                                                  : "For Rent",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "${TextService().putCommas(property.price.toString())} UGX  ${property.frequency}" ??
                                                  "0",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: property.price == null
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomSizedBox(
                                        sbSize: SBSize.smallest,
                                        height: true,
                                      ),
                                      Text(
                                        "You can use the calculator to help you budget well and plan appropiately",
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (property.available)
                          Row(
                            children: [
                              Expanded(
                                child: ProceedButton(
                                  text: property.buttonText ?? "Book A Room",
                                  onTap: () {
                                    context.pushNamed(
                                      RouteConstants.bookARoom,
                                      extra: property,
                                      params: {
                                        "id": property.id,
                                      },
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  UIServices().showDatSheet(
                                    SimpleCalculator(
                                      value: property.price != null
                                          ? double.parse(
                                                property.price.toString(),
                                              ) ??
                                              0
                                          : 0,
                                      hideExpression: false,
                                      hideSurroundingBorder: true,
                                      autofocus: true,
                                    ),
                                    true,
                                    context,
                                  );
                                },
                                icon: Icon(
                                  FontAwesomeIcons.calculator,
                                ),
                              )
                            ],
                          ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  amenity(
    List amenities,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatisticText(
            title: text,
          ),
          Wrap(
            children: amenities
                .map(
                  (e) => SingleAmenity(
                    amenity: null,
                    wrap: true,
                    amenityID: e,
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }
}
