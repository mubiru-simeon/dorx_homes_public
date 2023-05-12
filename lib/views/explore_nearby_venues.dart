import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'dart:ui' as ui;
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class ExploreNearbyPropertiesView extends StatefulWidget {
  final List<String> categories;
  final LatLng centerArea;
  ExploreNearbyPropertiesView({
    Key key,
    @required this.categories,
    @required this.centerArea,
  }) : super(key: key);

  @override
  State<ExploreNearbyPropertiesView> createState() =>
      _ExploreNearbyPropertiesViewState();
}

class _ExploreNearbyPropertiesViewState
    extends State<ExploreNearbyPropertiesView> {
  Set<Marker> markers = {};
  bool initialisingMap = true;
  Map<String, Property> foundProperties = {};
  final placesService = PlacesService();
  LatLng currentlyViewingCenterLocation;
  Property selectedProperty;
  bool searching = false;
  Map options = {};
  List<PlaceSearch> searchResults;
  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    List category = widget.categories ?? [];
    options.addAll({
      Property.CATEGORY: category,
    });
  }

  @override
  dispose() {
    mapController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              BackBar(
                icon: null,
                onPressed: null,
                action: IconButton(
                  onPressed: () async {
                    Map fg = await UIServices().showDatSheet(
                      ExploreFilterOptions(
                        options: options,
                      ),
                      true,
                      context,
                    );

                    if (fg != null) {
                      options = fg;

                      locateNearbyThings(
                        false,
                        currentlyViewingCenterLocation,
                      );
                    }
                  },
                  icon: Icon(
                    FontAwesomeIcons.arrowDownShortWide,
                  ),
                ),
                text: "Explore Places around you",
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      markers: markers,
                      onCameraIdle: () {
                        if (!initialisingMap) {
                          setState(() {});
                        }
                      },
                      onCameraMove: (v) {
                        if (!initialisingMap) {
                          currentlyViewingCenterLocation = v.target;
                        }
                      },
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      onTap: null,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: const LatLng(0, 0),
                        zoom: 2,
                      ),
                    ),
                    buildFloatingSearchBar(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SingleNeumorphicButton(
                          radius: 8,
                          onTap: () {
                            locateUser(
                              animate: true,
                            );
                          },
                          child: Icon(
                            FontAwesomeIcons.locationCrosshairs,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          if (selectedProperty != null)
            Positioned(
              bottom: 80,
              left: 5,
              right: 5,
              child: Stack(
                children: [
                  SingleProperty(
                    property: selectedProperty,
                    selectable: false,
                    selected: false,
                    simple: true,
                    list: true,
                    propertyID: selectedProperty.id,
                    onTap: null,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedProperty = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 15,
                        child: Icon(
                          Icons.close,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderDouble),
                    topRight: Radius.circular(borderDouble),
                  ),
                  color: Theme.of(context).canvasColor,
                ),
                child: ListView(
                  controller: controller,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Material(
                              color: Colors.grey,
                              elevation: standardElevation,
                              borderRadius: standardBorderRadius,
                              child: SizedBox(
                                height: 5,
                                width: 50,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${foundProperties.length} Places found for you",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    )
                  ].followedBy(
                    [
                      Column(
                        children: foundProperties.entries
                            .map(
                              (e) => SingleProperty(
                                property: e.value,
                                selectable: false,
                                list: true,
                                propertyID: e.key,
                                selected: false,
                                onTap: null,
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  searchPlaces(String searchTerm) async {
    if (searchTerm.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          searching = true;
        });
      }
      await placesService.getAutocomplete(searchTerm).then((value) {
        searchResults = value;
        searching = false;
        if (mounted) setState(() {});
      });
    }
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      onSubmitted: (query) {
        searchPlaces(query);
      },
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      automaticallyImplyBackButton: false,
      progress: searching,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        searchPlaces(query);
      },
      clearQueryOnClose: true,
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: true,
          showIfClosed: false,
          builder: (context, animation) {
            final bar = FloatingSearchAppBar.of(context);

            return ValueListenableBuilder<String>(
              valueListenable: bar.queryNotifer,
              builder: (context, query, _) {
                final isEmpty = query.trim().isEmpty;

                return SearchToClear(
                  isEmpty: isEmpty,
                  size: 24,
                  color: bar.style.iconColor,
                  duration: Duration(milliseconds: 900) * 0.5,
                  onTap: () {
                    if (!isEmpty) {
                      bar.clear();
                      searchResults = null;
                      if (mounted) setState(() {});
                    } else {
                      bar.isOpen =
                          !bar.isOpen || (!bar.hasFocus && bar.isAlwaysOpened);
                    }
                  },
                );
              },
            );
          },
        ),
      ],
      builder: (context, transition) {
        if (searchResults != null) {
          return ClipRRect(
            borderRadius: standardBorderRadius,
            child: Material(
              color: Theme.of(context).canvasColor,
              elevation: standardElevation,
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setSelectedLocation(
                          searchResults[index].placeId,
                          null,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Text(
                          searchResults[index].description,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return SizedBox(
            height: 1,
          );
        }
      },
    );
  }

  setSelectedLocation(
    String placeId,
    LatLng pos,
  ) async {
    var sLocation = await placesService.getPlace(placeId);

    searchResults = null;

    locateNearbyThings(
      true,
      LatLng(
        sLocation.geometry.location.lat,
        sLocation.geometry.location.lng,
      ),
    );
  }

  singleChipThingie(
    String text,
    Function onTap, {
    bool selected,
  }) {
    return Container(
      margin: EdgeInsets.all(5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: selected == true
                ? Colors.green
                : selected == false
                    ? Colors.red
                    : null,
            border: Border.all(
              color: selected == true
                  ? Colors.green
                  : selected == false
                      ? Colors.red
                      : Colors.grey,
            ),
            borderRadius: standardBorderRadius,
          ),
          child: Center(
            child: Row(
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: selected == true || selected == false
                        ? Colors.white
                        : null,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Icon(
                  Icons.expand_more,
                  color: selected == true || selected == false
                      ? Colors.white
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Query getQuery() {
    Query qq = FirebaseFirestore.instance
        .collection(
          Property.DIRECTORY,
        )
        .where(
          Property.AVAILABLE,
          isEqualTo: true,
        );

    List category = options[Property.CATEGORY] ?? [];
    if (category != null && category.isNotEmpty) {
      qq = qq.where(
        Property.CATEGORY,
        arrayContainsAny: category,
      );
    }

    bool petsAllowed = options[Property.PETSALLOWED];
    if (petsAllowed == true) {
      qq = qq.where(
        Property.PETSALLOWED,
        isEqualTo: petsAllowed,
      );
    }

    bool shuttle = options[Property.SHUTTLE];
    if (shuttle == true) {
      qq = qq.where(
        Property.SHUTTLE,
        isEqualTo: true,
      );
    }

    return qq;
  }

  locateNearbyThings(
    bool animate,
    LatLng center,
  ) {
    if (animate) {
      initialisingMap = true;
      animateCamera(center);
      initialisingMap = false;
    }

    Geoflutterfire()
        .collection(collectionRef: getQuery())
        .within(
          center: Geoflutterfire().point(
            latitude: center.latitude,
            longitude: center.longitude,
          ),
          radius: 100,
          field: GeoHashedItem.POSITION,
        )
        .listen((event) async {
      for (var item in event) {
        GeoPoint point = item[GeoHashedItem.POSITION][GeoHashedItem.GEOPOINT];

        Property property = Property.fromSnapshot(item);

        foundProperties.addAll({
          property.id: property,
        });

        markers.add(
          Marker(
            markerId: MarkerId(
              item.id,
            ),
            icon: property.images.isEmpty
                ? await getCustomThingie(lobby)
                : await downloadResizePictureCircle(property.images[0]),
            position: LatLng(
              point.latitude,
              point.longitude,
            ),
            onTap: () {
              setState(() {
                selectedProperty = property;
              });
            },
          ),
        );
      }

      if (mounted) setState(() {});
    });
  }

  static Future<BitmapDescriptor> downloadResizePictureCircle(
    String imageUrl, {
    int size = 150,
    bool addBorder = false,
    Color borderColor = Colors.white,
    double borderSize = 10,
  }) async {
    final File imageFile = await DefaultCacheManager().getSingleFile(imageUrl);

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;

    final double radius = size / 2;

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(100)));
    /* clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(100))); */
    canvas.clipPath(clipPath);

    //paintImage
    final Uint8List imageUint8List = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    if (addBorder) {
      //draw Border
      paint.color = borderColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    //convert canvas as PNG bytes
    final image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<BitmapDescriptor> getCustomThingie(
    String imageUrl, {
    int size = 150,
    bool addBorder = false,
    Color borderColor = Colors.white,
    double borderSize = 10,
  }) async {
    ByteData imageFile = await rootBundle.load(imageUrl);

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;

    final double radius = size / 2;

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(100)));
    /* clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(100))); */
    canvas.clipPath(clipPath);

    //paintImage
    final ui.Codec codec =
        await ui.instantiateImageCodec(imageFile.buffer.asUint8List());
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    if (addBorder) {
      //draw Border
      paint.color = borderColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    //convert canvas as PNG bytes
    final image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas c = Canvas(recorder);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;

    c.drawOval(
      Rect.fromLTRB(0, 0, 160, 80),
      paint,
    );

    TextSpan span = TextSpan(
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      text: title,
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.text = TextSpan(
      text: title.toString(),
      style: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    tp.layout();
    tp.paint(c, Offset(25, 25));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    ui.Picture p = recorder.endRecording();
    ByteData pngBytes =
        await (await p.toImage(tp.width.toInt() + 100, tp.height.toInt() + 100))
            .toByteData(format: ui.ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes.buffer);

    return BitmapDescriptor.fromBytes(data);
  }

  animateCamera(LatLng v) {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          v.latitude,
          v.longitude,
        ),
        12,
      ),
    );

    currentlyViewingCenterLocation = v;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    if (widget.centerArea == null) {
      await locateUser();
    } else {
      locateNearbyThings(
        true,
        widget.centerArea,
      );
    }

    initialisingMap = false;
  }

  locateUser({
    bool animate = false,
  }) async {
    await LocationService().getUserLocation(context).then((v) {
      if (v != null) {
        if (v is LatLng) {
          locateNearbyThings(
            animate,
            LatLng(
              v.latitude,
              v.longitude,
            ),
          );
        } else {
          showDialog(
              context: context,
              builder: (builder) {
                return CustomDialogBox(
                  bodyText: null,
                  buttonText: null,
                  onButtonTap: null,
                  showOtherButton: false,
                  child: Column(
                    children: [
                      Text(
                        v.entries.first.value["message"],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ProceedButton(
                        text: "Open Settings",
                        onTap: () async {
                          await Geolocator.openLocationSettings();
                        },
                      ),
                      ProceedButton(
                        text: "Try Again",
                        onTap: () async {
                          if (context.canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.pushReplacementNamed(RouteConstants.home);
                          }

                          locateUser(
                            animate: animate,
                          );
                        },
                      ),
                      ProceedButton(
                        text: "Close",
                        color: Colors.red,
                        onTap: () async {
                          if (context.canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.pushReplacementNamed(RouteConstants.home);
                          }
                        },
                      ),
                    ],
                  ),
                );
              });
        }
      }
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialogBox(
            showSignInButton: false,
            bodyText: error.toString(),
            buttonText: "Settings",
            onButtonTap: () async {
              if (error ==
                  "Heeyy. We need access to your location so we can find nice venues and events near and around you.. But, your location is turned off.  Please click here and turn on your location") {
                await Geolocator.openLocationSettings();
              } else {
                await Geolocator.openAppSettings();
              }
            },
            showOtherButton: true,
          );
        },
      );
    });
  }
}
