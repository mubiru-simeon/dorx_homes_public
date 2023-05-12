import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import 'services.dart';

class StorageServices {
  launchTheThing(String uri) {
    launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.externalApplication,
    );
  }

  saveNewHistory({
    @required String thingID,
    @required String type,
    @required BuildContext context,
    @required String analyticType,
  }) {
    if (AuthProvider.of(context).auth.isSignedIn()) {
      FirebaseFirestore.instance
          .collection(PreviousItem.DIRECTORY)
          .doc(AuthProvider.of(context).auth.getCurrentUID())
          .collection(AuthProvider.of(context).auth.getCurrentUID())
          .doc(thingID)
          .set(
        {
          PreviousItem.THINGID: thingID,
          PreviousItem.TIME: DateTime.now().millisecondsSinceEpoch,
          PreviousItem.TYPE: type,
        },
      );
    }
  }

  Future<bool> unSaveSomething(
    String thingType,
    String thingID,
    String userID,
  ) {
    return FirebaseFirestore.instance
        .collection(SavedItem.DIRECTORY)
        .doc(userID)
        .collection(userID)
        .doc(thingID)
        .delete()
        .then((value) {
      return true;
    });
  }

  Future<bool> saveSomething(
    String thingType,
    String thingID,
    String userID,
  ) {
    return FirebaseFirestore.instance
        .collection(SavedItem.DIRECTORY)
        .doc(userID)
        .collection(userID)
        .doc(thingID)
        .set({
      SavedItem.TIME: DateTime.now().millisecondsSinceEpoch,
      SavedItem.TYPE: thingType,
    }).then((value) {
      return true;
    });
  }

  handleClick(
    String type,
    String id,
    BuildContext context,
  ) async {
    if (type == ThingType.PROPERTY) {
      context.pushNamed(
        RouteConstants.property,
        params: {
          "id": id,
        },
      );
    }
  }

  sendVerifyingEmailNotification(
    String uid,
    String email,
  ) {
    NotificationModel not = NotificationModel.fromData(
      uid,
      "Verify Your Account.",
      "We have sent you an email to your email address $email with a link for you to verify your account. Tap on that link to verify your account and enjoy $capitalizedAppName. If you can't see the email, check your spam folder.",
      DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection(NotificationModel.DIRECTORY)
        .doc(uid)
        .collection(uid)
        .add(
          MapGeneration().generateNotificationMap(
            not,
          ),
        );
  }

  createNewUser({
    @required String token,
    @required String phoneNumber,
    @required String email,
    @required String uid,
    @required String userName,
    @required List images,
    @required String university,
  }) {
    UserModel user = UserModel.fromData(
      phoneNumber: phoneNumber,
      username: userName,
      images: images,
      profilePic: images.isEmpty ? null : images[0],
      email: email,
      university: university,
    );

    sendVerifyingEmailNotification(
      uid,
      email,
    );

    FirebaseFirestore.instance
        .collection(UserModel.DIRECTORY)
        .doc(uid)
        .set(
          MapGeneration().generateUserMap(user),
        )
        .then(
      (value) {
        updateFCMToken(
          uid,
          token,
        );

        updateLastLogin(uid);

        NotificationModel not = NotificationModel.fromData(
          uid,
          "Welcome To $capitalizedAppName",
          "I'd like to cordially, warmly and ..uhmmm *insert some nice warm word* -ly welcome you to $capitalizedAppName. Feel free to explore the stuff here, interact with the community and enjoy the food. I just hope you like it generally. I Spent a lot of time working on it, tryna make it perfect for you. Feel free to provide any feedback, whether positive or negative.\n\n-Simeon.",
          DateTime.now(),
        );

        FirebaseFirestore.instance
            .collection(NotificationModel.DIRECTORY)
            .doc(uid)
            .collection(uid)
            .add(
              MapGeneration().generateNotificationMap(
                not,
              ),
            );
      },
    );
  }

  scanQRCode(
    String expectedType,
    Function(Map) whatToDo,
    BuildContext context,
  ) async {
    await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      "Cancel",
      true,
      ScanMode.QR,
    ).then((value) {
      if (value != null) {
        if (value.length <= 4) {
          CommunicationServices().showToast(
            "No data detected. Please try again.",
            Colors.red,
          );
        } else {
          Map pp = json.decode(value.toString());

          String type = pp[QRCodeScannerResult.THINGTYPE];
          String id = pp[QRCodeScannerResult.THINGID];

          if (expectedType != null && type != expectedType) {
            CommunicationServices().showToast(
              "Error Invalid QR Code: The QR Code scanned is for a $type.",
              Colors.red,
            );
          } else {
            if (whatToDo != null) {
              whatToDo(pp);
            } else {
              handleClick(
                type,
                id,
                context,
              );
            }
          }
        }
      } else {
        CommunicationServices().showToast(
          "No Data Provided. Please scan again.",
          Colors.red,
        );
      }
    });
  }

  String getEmailLink(
    String email,
    String header,
    String body,
  ) {
    return "mailto:$email?subject=$header&body=$body";
  }

  launchSocialLink(
    String link,
    String lead,
  ) {
    String top;
    if (lead.startsWith("@")) {
      top = link.replaceFirst(RegExp(r'@'), "");

      top = "$lead$top";
    } else {
      if (link.startsWith("www")) {
        top = link;
      } else {
        top = lead;
      }
    }

    StorageServices().launchTheThing(top);
  }

  increaseAnalytics(
    String date,
    String ss,
    String type,
    String ff,
  ) {}

  int getPrice(String priceText, {double deMoney}) {
    int price = deMoney == null
        ? double.parse(priceText.trim()).toInt()
        : deMoney.toInt();

    int pricetoShow = price;

    return pricetoShow;
  }

  removeFCMToken(String userID) {
    FirebaseDatabase.instance.ref().child(UserModel.FCMTOKENS).update({
      userID: null,
    });

    updateLastLogout(userID);
  }

  updateFCMToken(String userID, String token) {
    FirebaseDatabase.instance.ref().child(UserModel.FCMTOKENS).update(
      {
        userID: token,
      },
    );
  }

  updateLastLogin(String uid) {
    FirebaseDatabase.instance
        .ref()
        .child(UserModel.LASTLOGINTIME)
        .child(uid)
        .update({
      DateTime.now().millisecondsSinceEpoch.toString(): true,
    });
  }

  updateLastLogout(String uid) {
    FirebaseDatabase.instance
        .ref()
        .child(UserModel.LASTLOGOUTTIME)
        .child(uid)
        .update({
      DateTime.now().millisecondsSinceEpoch.toString(): true,
    });
  }

  notifyAboutLogin(
    String uid,
  ) {
    NotificationModel not = NotificationModel.fromData(
      uid,
      "New Login",
      "Your account has just been logged-in in the Dorx app.",
      DateTime.now(),
    );

    sendInAppNotification(not);
  }

  sendInAppNotification(NotificationModel notificationModel) {
    FirebaseFirestore.instance
        .collection(NotificationModel.DIRECTORY)
        .doc(notificationModel.recepient)
        .collection(notificationModel.recepient)
        .add(
          MapGeneration().generateNotificationMap(
            notificationModel,
          ),
        );
  }
}
