import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'not_logged_in_dialog_box.dart';
import 'only_when_logged_in.dart';

class FavoriteButton extends StatefulWidget {
  final String thingID;
  final String thingType;

  FavoriteButton({
    Key key,
    @required this.thingID,
    @required this.thingType,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return OnlyWhenLoggedIn(
      notSignedIn: likedButton(
        false,
        false,
        null,
      ),
      signedInBuilder: (uid) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(SavedItem.DIRECTORY)
              .doc(uid)
              .collection(uid)
              .doc(widget.thingID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return likedButton(false, true, uid);
            } else {
              if (snapshot.data != null && snapshot.data.data() != null) {
                return likedButton(true, true, uid);
              } else {
                return likedButton(false, true, uid);
              }
            }
          },
        );
      },
    );
  }

  likedButton(
    bool liked,
    bool tappable,
    String uid,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (tappable) {
            doIt(liked, uid);
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return NotLoggedInDialogBox(
                  onLoggedIn: () {
                    doIt(liked, uid);
                  },
                );
              },
            );
          }
        },
        child: Icon(
          liked ? Icons.favorite : Icons.favorite_border_outlined,
          color: Colors.red,
          size: 30,
        ),
      ),
    );
  }

  doIt(
    bool liked,
    String uid,
  ) {
    if (liked) {
      StorageServices().unSaveSomething(
        widget.thingType,
        widget.thingID,
        uid,
      );
    } else {
      StorageServices().saveSomething(
        widget.thingType,
        widget.thingID,
        uid,
      );
    }
  }
}
