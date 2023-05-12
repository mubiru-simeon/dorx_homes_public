import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class SingleProperty extends StatefulWidget {
  final Property property;
  final bool selectable;
  final bool simple;
  final String propertyID;
  final dynamic price;
  final bool horizontal;
  final bool selected;
  final Function onTap;
  final bool list;
  SingleProperty({
    Key key,
    @required this.property,
    @required this.selectable,
    @required this.list,
    @required this.propertyID,
    this.price,
    @required this.selected,
    @required this.onTap,
    this.simple = false,
    this.horizontal,
  }) : super(key: key);

  @override
  State<SingleProperty> createState() => _SinglePropertyState();
}

class _SinglePropertyState extends State<SingleProperty> {
  int imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.property == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Property.DIRECTORY)
                .doc(widget.propertyID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: DeletedItem(
                      what: "Property",
                      thingID: widget.propertyID,
                    ),
                  );
                } else {
                  Property model = Property.fromSnapshot(
                    snapshot.data,
                  );

                  return body(model);
                }
              } else {
                return LoadingWidget();
              }
            })
        : body(
            widget.property,
          );
  }

  body(Property property) {
    if (widget.simple) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        margin: EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () {
            if (widget.selectable) {
              widget.onTap();
            } else {
              if (widget.onTap != null) {
                widget.onTap();
              } else {
                context.pushNamed(
                  RouteConstants.property,
                  extra: property,
                  params: {
                    "id": property.id,
                  },
                );
              }
            }
          },
          child: ClipRRect(
            borderRadius: standardBorderRadius,
            child: Material(
              borderRadius: standardBorderRadius,
              elevation: standardElevation,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleImage(
                      height: double.infinity,
                      image:
                          property.images.isEmpty ? lobby : property.images[0],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            property.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (property.description != null)
                            Text(
                              property.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (property.address != null)
                            Text(
                              property.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          Spacer(),
                          if (property.price != null)
                            Text(
                              "UGX ${TextService().putCommas(
                                widget.price.toString(),
                              )}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          if (property.firstPrice != null)
                            Text(
                              "from UGX ${TextService().putCommas(
                                property.firstPrice.toString(),
                              )} to UGX ${TextService().putCommas(
                                property.lastPrice.toString(),
                              )}",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  FavoriteButton(
                    thingID: widget.propertyID,
                    thingType: ThingType.PROPERTY,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: widget.horizontal != null && widget.horizontal
            ? MediaQuery.of(context).size.width * 0.7
            : null,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        margin: EdgeInsets.all(4),
        child: Material(
          elevation: standardElevation,
          borderRadius: standardBorderRadius,
          child: GestureDetector(
              onTap: () {
                if (widget.selectable) {
                  widget.onTap();
                } else {
                  if (widget.onTap != null) {
                    widget.onTap();
                  } else {
                    context.pushNamed(
                      RouteConstants.property,
                      extra: property,
                      params: {
                        "id": property.id,
                      },
                    );
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: standardBorderRadius,
                      child: Container(
                        decoration: BoxDecoration(
                          image: UIServices().decorationImage(
                            property.images.isEmpty
                                ? compound
                                : property.images[0],
                            true,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (property.images.isNotEmpty)
                              Carousel(
                                dotSpacing: 15,
                                dotIncreaseSize: 1.3,
                                dotSize: 8,
                                autoplay: false,
                                dotColor: Colors.grey,
                                dotIncreasedColor: Colors.white,
                                onImageChange: (v, b) {
                                  setState(() {
                                    imageIndex = b;
                                  });
                                },
                                overlayShadow: false,
                                images: property.images
                                    .map(
                                      (e) => SingleImage(
                                        image: e,
                                      ),
                                    )
                                    .toList(),
                              ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FavoriteButton(
                                    thingType: ThingType.PROPERTY,
                                    thingID: widget.propertyID,
                                  ),
                                  if (widget.selected != null &&
                                      widget.selected)
                                    SelectorThingie(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                property.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (property.description != null)
                                Text(
                                  property.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (property.address != null)
                                Text(
                                  property.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              if (property.price != null)
                                Text(
                                  "UGX ${TextService().putCommas(
                                    widget.price.toString(),
                                  )}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (property.price != null)
                                Text(
                                  "UGX ${TextService().putCommas(
                                    widget.price.toString(),
                                  )}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (property.firstPrice != null)
                                SizedBox(
                                  height: 20,
                                ),
                              if (property.firstPrice != null)
                                Text(
                                  "from UGX ${TextService().putCommas(
                                    property.firstPrice.toString(),
                                  )} to UGX ${TextService().putCommas(
                                    property.lastPrice.toString(),
                                  )}",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      RatingDisplayer(
                        thingID: property.id,
                      ),
                    ],
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
              )),
        ),
      );
    }
  }
}
