import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import 'widgets.dart';

class RatingDisplayer extends StatelessWidget {
  final String thingID;
  const RatingDisplayer({
    Key key,
    @required this.thingID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref()
          .child(Rating.AVERAGERATINGDIRECTORY)
          .child(thingID)
          .onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return LoadingWidget();
        } else {
          int rating = snapshot == null ||
                  snapshot.data == null ||
                  snapshot.data.snapshot == null ||
                  snapshot.data.snapshot.value == null
              ? 0
              : snapshot.data.snapshot.value;

          return Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.orange,
              ),
              Text(
                rating.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 10,
              )
            ],
          );
        }
      },
    );
  }
}
