import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class SingleAmenity extends StatelessWidget {
  final Amenity amenity;
  final bool wrap;
  final String amenityID;
  final Function onTap;
  final bool selected;
  const SingleAmenity({
    Key key,
    @required this.amenity,
    this.selected = false,
    this.onTap,
    @required this.amenityID,
    this.wrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return amenity == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Amenity.DIRECTORY)
                .doc(amenityID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    thingID: amenityID,
                    what: "Amenity",
                  );
                } else {
                  Amenity model = Amenity.fromSnapshot(
                    snapshot.data,
                  );

                  return body(model, context);
                }
              } else {
                return LoadingWidget();
              }
            },
          )
        : body(
            amenity,
            context,
          );
  }

  body(Amenity amenity, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap == null) {
        } else {
          onTap();
        }
      },
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.all(15),
        alignment: wrap ? null : Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: selected ? Colors.green : Colors.grey,
          ),
          image: selected
              ? null
              : UIServices().decorationImage(
                  amenity.image,
                  true,
                ),
          color: selected ? Colors.green : null,
          borderRadius: standardBorderRadius,
        ),
        child: Text(
          amenity.name.capitalizeFirstOfEach,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: amenity.image != null || selected ? Colors.white : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
