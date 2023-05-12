import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/models.dart';
import '../views/views.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text("Error 404. No data found"),
      ),
    );
  },
  routes: [
    //splash
    GoRoute(
      name: RouteConstants.splash,
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: SplashScreenView(),
        );
      },
    ),
    //about us
    GoRoute(
      name: RouteConstants.aboutUs,
      path: "/${RouteConstants.aboutUs}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AboutUs(),
        );
      },
    ),
    //onboarding1
    GoRoute(
      name: RouteConstants.onboarding1,
      path: "/${RouteConstants.onboarding1}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: Onboarding1(),
        );
      },
    ),
    //onboarding2
    GoRoute(
      name: RouteConstants.onboarding2,
      path: "/${RouteConstants.onboarding2}/:name",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: Onboarding2(
            name: state.params["name"],
          ),
        );
      },
    ),
    //onboarding3
    GoRoute(
      name: RouteConstants.onboarding3,
      path: "/${RouteConstants.onboarding3}/:name",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: Onboarding3(
            name: state.params["name"],
          ),
        );
      },
    ),
    //all schools
    GoRoute(
      name: RouteConstants.allSchools,
      path: "/${RouteConstants.allSchools}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllSchoolsView(),
        );
      },
    ),
    //detailed category
    GoRoute(
      name: RouteConstants.detailedCategory,
      path: "/${RouteConstants.detailedCategory}/:id",
      pageBuilder: (context, state) {
        EntityCategory cc;

        if (state.extra != null) {
          cc = state.extra as EntityCategory;
        }

        return MaterialPage(
          child: DetailedCategory(
            category: cc,
            categoryID: state.params["id"],
          ),
        );
      },
    ),
    //category
    GoRoute(
      name: RouteConstants.categories,
      path: "/${RouteConstants.categories}",
      pageBuilder: (context, state) {
        String ss = state.queryParams["selectable"] ?? "false";
        bool selectable = ss == "true" ? true : false;

        return MaterialPage(
          child: CategoriesView(
            selectable: selectable,
          ),
        );
      },
    ),
    //dash and home
    GoRoute(
      name: RouteConstants.home,
      path: "/${RouteConstants.home}",
      pageBuilder: (context, state) {
        dynamic params = state.queryParams ?? {};

        bool showDialog = params["showDialog"] == "true" ? true : false;

        return MaterialPage(
          child: Dashboard(
            showDialog: showDialog,
          ),
        );
      },
    ),
    //detailed image
    GoRoute(
      name: RouteConstants.image,
      path: "/${RouteConstants.image}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: DetailedImage(
            images: state.extra,
          ),
        );
      },
    ),
    //detailed property
    GoRoute(
      name: RouteConstants.property,
      path: "/${RouteConstants.property}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: DetailedPropertyView(
            property: state.extra as Property,
            propertyID: state.params["id"],
          ),
        );
      },
    ),
    //book a room
    GoRoute(
      name: RouteConstants.bookARoom,
      path: "/${RouteConstants.bookARoom}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: BookARoomView(
            property: state.extra as Property,
            propertyID: state.params["id"],
          ),
        );
      },
    ),
    //explore nearby properties
    GoRoute(
      name: RouteConstants.explore,
      path: "/${RouteConstants.explore}",
      pageBuilder: (context, state) {
        Map pp = (state.extra as Map) ?? {};

        List<String> categories = pp["categories"] ?? [];
        LatLng loc = pp["location"];

        return MaterialPage(
          child: ExploreNearbyPropertiesView(
            categories: categories,
            centerArea: loc,
          ),
        );
      },
    ),
    //bedspace requests
    GoRoute(
      name: RouteConstants.bedspaces,
      path: "/${RouteConstants.bedspaces}",
      pageBuilder: (context, state) {
        String ss = state.queryParams["selling"] ?? "false";
        String bb = state.queryParams["buying"] ?? "true";

        bool selling = ss == "false" ? false : true;
        bool buying = bb == "false" ? false : true;

        return MaterialPage(
          child: HostelBedspacesView(
            sellingABedpace: selling,
            needABedspace: buying,
          ),
        );
      },
    ),
    //roomie requests
    GoRoute(
      name: RouteConstants.roommateRequests,
      path: "/${RouteConstants.roommateRequests}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllRoommateRequests(),
        );
      },
    ),
    //notifications
    GoRoute(
      name: RouteConstants.notifications,
      path: "/${RouteConstants.notifications}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: NotificationsView(),
        );
      },
    ),
    //user
    GoRoute(
      name: RouteConstants.user,
      path: "/${RouteConstants.user}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: UserProfileView(
            user: state.extra,
            uid: state.params["id"],
          ),
        );
      },
    ),
    //hostels near university
    GoRoute(
      name: RouteConstants.hostelsNearUniversity,
      path: "/${RouteConstants.hostelsNearUniversity}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: HostelsNearUniversity(
            universityID: state.params["id"],
          ),
        );
      },
    ),
  ],
);

class RouteConstants {
  static String aboutUs = "aboutUs";
  static String roommateRequests = "roommateRequests";
  static String allSchools = "allSchools";
  static String categories = "categories";
  static String bookARoom = "bookARoom";
  static String detailedCategory = "category";
  static String onboarding1 = "onboarding1";
  static String onboarding2 = "onboarding2";
  static String onboarding3 = "onboarding3";
  static String splash = "splash";
  static String image = "image";
  static String property = "property";
  static String explore = "explore";
  static String home = "home";
  static String bedspaces = "bedspaces";
  static String hostelsNearUniversity = "hostelsNearUniversity";
  static String nearbyAccomodation = "nearbyAccomodation";
  static String manageBookings = "manageBookings";
  static String notifications = "notifications";
  static String user = "user";
  static String whereAreYou = "whereAreYou";
}
