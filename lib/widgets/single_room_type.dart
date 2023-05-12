import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/constants.dart';
import '../models/room_type.dart';
import '../services/text_service.dart';
import 'widgets.dart';

class SingleRoomType extends StatefulWidget {
  final RoomType roomType;
  final bool selected;
  final bool simple;
  final String roomTypeID;
  final double width;
  final Function onRemoveRoomType;
  final bool putExpanded;
  final bool horizontal;
  final Function onEditRoomType;
  SingleRoomType({
    Key key,
    @required this.roomType,
    this.onRemoveRoomType,
    this.onEditRoomType,
    @required this.roomTypeID,
    this.width,
    this.horizontal = false,
    this.putExpanded = false,
    this.simple = false,
    this.selected = false,
  }) : super(key: key);

  @override
  State<SingleRoomType> createState() => _SingleRoomTypeState();
}

class _SingleRoomTypeState extends State<SingleRoomType> {
  @override
  Widget build(BuildContext context) {
    return widget.roomType == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(RoomType.DIRECTORY)
                .doc(widget.roomTypeID)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "Room Type",
                    thingID: widget.roomTypeID,
                  );
                } else {
                  RoomType model = RoomType.fromSnapshot(snapshot.data);

                  return body(model);
                }
              } else {
                return LoadingWidget();
              }
            },
          )
        : body(
            widget.roomType,
          );
  }

  body(RoomType roomType) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.simple
              ? MediaQuery.of(context).size.height * 0.15
              : MediaQuery.of(context).size.height * 0.52,
        ),
        // ignore: prefer_if_null_operators
        width: widget.width != null
            ? widget.width
            : widget.horizontal
                ? kIsWeb
                    ? 400
                    : MediaQuery.of(context).size.width * 0.65
                : double.infinity,
        decoration: BoxDecoration(
          borderRadius: standardBorderRadius,
          color: widget.selected ? Colors.green : null,
          border: Border.all(
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.simple)
              Expanded(
                child: AutoScrollShowcaser(
                  images: roomType.images.isNotEmpty
                      ? roomType.images
                      : [
                          bedroom,
                        ],
                  placeholderText: capitalizedAppName,
                ),
              ),
            widget.simple
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: childrenses(roomType),
                  )
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: childrenses(
                        roomType,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  List<Widget> childrenses(
    RoomType roomType,
  ) {
    return [
      if (!widget.simple)
        SizedBox(
          height: 5,
        ),
      Text(
        roomType.name,
        style: darkTitle,
      ),
      SizedBox(
        height: 5,
      ),
      if (!widget.simple)
        if (roomType.description != null &&
            roomType.description.trim().isNotEmpty)
          Text(
            roomType.description,
            maxLines: 2,
          ),
      if (!widget.simple) Spacer(),
      Text(
        "This room can take ${roomType.totalGuestCount} people",
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      if (!widget.simple)
        SizedBox(
          height: 5,
        ),
      if (!widget.simple)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (roomType.selfContained)
              Material(
                color: primaryColor,
                borderRadius: standardBorderRadius,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text(
                        "Self Contained",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.toilet,
                        size: 13,
                        color: Colors.white,
                      ),
                      Text(
                        roomType.bathroomCount.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ),
            Spacer(),
            if (widget.onEditRoomType != null)
              IconButton(
                onPressed: () {
                  if (widget.onEditRoomType != null) {
                    widget.onEditRoomType();
                  }
                },
                icon: Icon(
                  Icons.edit,
                ),
              ),
            SizedBox(
              width: 5,
            ),
            if (widget.onRemoveRoomType != null)
              IconButton(
                onPressed: () {
                  if (widget.onRemoveRoomType != null) {
                    widget.onRemoveRoomType();
                  }
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      if (!widget.simple)
        if (widget.putExpanded) Spacer(),
      if (roomType.price != null && roomType.price != 0)
        Text(
          "${TextService().putCommas(roomType.price.toString())} UGX ${roomType.paymentFrequency.capitalizeFirstOfEach}",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: widget.selected ? Colors.white : primaryColor),
        ),
    ];
  }
}
