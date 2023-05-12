import '../models/models.dart';
import 'sq_lite_services.dart';

class MapGeneration {
  generateSearchHistoryMap(String text) {
    return {
      SearchHistoryDBServices.SEARCHHISTORYTEXT: text,
      SearchHistoryDBServices.TIMESEARCHED:
          DateTime.now().millisecondsSinceEpoch,
    };
  }

  generateUserMap(UserModel user) {
    return {
      UserModel.PHONENUMBER: user.phoneNumber,
      UserModel.TIMEOFJOINING: DateTime.now().millisecondsSinceEpoch,
      UserModel.USERNAME: user.userName,
      UserModel.PROFILEPIC: user.profilePic,
      UserModel.ACCOUNTCREATED: true,
      UserModel.EMAIL: user.email,
      UserModel.UNIVERSITY: user.university,
    };
  }

  generateNotificationMap(NotificationModel not) {
    return {
      NotificationModel.TITLE: not.title,
      NotificationModel.BODY: not.body,
      NotificationModel.TIME: not.time,
      NotificationModel.THINGID: not.primaryId,
      NotificationModel.THINGTYPE: not.thingType,
    };
  }
}
