import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/explore_world_widget.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const IMAGE = "image";
const KEY = "key";

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String selectedCategory;
  Box box;
  String name;
  ScrollController _scrollController;
  bool isScrolled = false;
  Function doIt;
  Function setBottom;
  PaginateResetChangeListener refreshChangeListener =
      PaginateResetChangeListener();

  void _listenToScrollChange() {
    if (_scrollController.offset >= 100.0) {
      doIt(() {
        isScrolled = true;
      });
    } else {
      doIt(() {
        isScrolled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);
    box = Hive.box(DorxSettings.DORXBOXNAME);
  }

  String university;
  bool student;

  @override
  Widget build(BuildContext context) {
    name = box.get(UserModel.USERNAME);
    super.build(context);

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (gh, hg) {
        return [
          StatefulBuilder(builder: (context, setIt) {
            doIt = setIt;

            return SliverAppBar(
              pinned: true,
              actions: [
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.notifications,
                    );
                  },
                  child: CircleAvatar(
                    child: Icon(
                      Icons.notifications,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
              title: AnimatedOpacity(
                  opacity: isScrolled ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    translation(context).home,
                  )),
              expandedHeight: 300,
              leadingWidth: 0,
              centerTitle: false,
              leading: SizedBox(),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Stack(
                  children: [
                    SingleImage(
                      image: lobby,
                      darken: true,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (AuthProvider.of(context).auth.getCurrentUser() ==
                                        null ||
                                    AuthProvider.of(context)
                                            .auth
                                            .getCurrentUser()
                                            .displayName ==
                                        null)
                                ? name == null
                                    ? "Hello there 😃"
                                    : "Hi $name"
                                : "Hi ${AuthProvider.of(context).auth.getCurrentUser().displayName} 😃",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Find your dream home near you",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          WhereWhenDisplayer(
                            when: null,
                            where: null,
                            who: null,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      StatisticText(
                        title: "Featured Stays",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                FeaturedStays(
                  student: student,
                  university: university,
                ),
                SizedBox(
                  height: 20,
                ),
                GreyDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      StatisticText(
                        title: "Explore the world with $capitalizedAppName",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ExploreWorldWidget(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                GreyDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      StatisticText(
                        title: "Would you like to",
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: Row(
                          children: {
                            "Buy land": {
                              IMAGE: scene,
                              KEY: "buy_land",
                            },
                            "Rent A Space / Room": {
                              IMAGE: bedroom,
                              KEY: "rent_space",
                            },
                          }
                              .entries
                              .map(
                                (e) => Expanded(
                                  child: SingleDashboardCard(
                                    title: e.key,
                                    image: e.value[IMAGE],
                                    onTap: () async {
                                      if (e.value[KEY] == "buy_land") {
                                      } else {
                                        context.pushNamed(
                                          RouteConstants.explore,
                                          extra: {
                                            "categories": [
                                              rentalsCategory,
                                              shopHousesCategory,
                                            ]
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: Row(
                          children: {
                            "Book A Hotel": {
                              IMAGE: lobby,
                              KEY: "book_a_hotel",
                            },
                            "Talk To An Agent": {
                              IMAGE: agent,
                              KEY: "talk_to_a_broker",
                            },
                          }
                              .entries
                              .map(
                                (e) => Expanded(
                                  child: SingleDashboardCard(
                                    title: e.key,
                                    image: e.value[IMAGE],
                                    onTap: () async {
                                      if (e.value[KEY] == "book_a_hotel") {
                                        context.pushNamed(
                                          RouteConstants.explore,
                                          extra: {
                                            "categories": [
                                              hotelCategory,
                                              apartmentsCategory,
                                            ]
                                          },
                                        );
                                      } else {
                                        StorageServices().launchTheThing(
                                          "tel:$dorxPhoneNumber",
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      StatisticText(
                        title: "For you, the Campus Student",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: Row(
                          children: {
                            "Find A Hostel": {
                              IMAGE: campus,
                              KEY: "find_hostel",
                            },
                          }
                              .entries
                              .map(
                                (e) => Expanded(
                                  child: SingleDashboardCard(
                                    title: e.key,
                                    image: e.value[IMAGE],
                                    onTap: () {
                                      UIServices().showDatSheet(
                                        SearchForHostelOptions(
                                          onLocationTap: () async {
                                            context.pushNamed(
                                              RouteConstants.explore,
                                              extra: {
                                                "categories": [
                                                  hostelCategory,
                                                ]
                                              },
                                            );
                                          },
                                          onUniversityTap: () {
                                            context.pushNamed(
                                              RouteConstants.allSchools,
                                            );
                                          },
                                        ),
                                        false,
                                        context,
                                      );
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: Row(
                          children: {
                            "I need bedspace in hall": {
                              IMAGE: bedroom,
                              KEY: "find_bedspace",
                            },
                            "I wanna sell my bedspace": {
                              IMAGE: agent,
                              KEY: "sell_bedspace",
                            },
                          }
                              .entries
                              .map(
                                (e) => Expanded(
                                  child: SingleDashboardCard(
                                    title: e.key,
                                    image: e.value[IMAGE],
                                    onTap: () {
                                      if (e.value[KEY] == "find_bedspace") {
                                        context.pushNamed(
                                          RouteConstants.bedspaces,
                                          queryParams: {
                                            "buying": "true",
                                            "selling": "false",
                                          },
                                        );
                                      } else {
                                        context.pushNamed(
                                          RouteConstants.bedspaces,
                                          queryParams: {
                                            "buying": "false",
                                            "selling": "true",
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: Row(
                          children: {
                            "I'm seeking A Roommate": {
                              IMAGE: campus,
                              KEY: "find_roommate"
                            },
                          }
                              .entries
                              .map(
                                (e) => Expanded(
                                  child: SingleDashboardCard(
                                    title: e.key,
                                    image: e.value[IMAGE],
                                    onTap: () {
                                      if (e.value[KEY] == "find_roommate") {
                                        context.pushNamed(
                                          RouteConstants.roommateRequests,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      HeadLineText(
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.roommateRequests,
                          );
                        },
                        plain: false,
                        text: "People Seeking Roommates",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: PaginateFirestore(
                          onEmpty: NoDataFound(
                            text: "No Pending Roommate Requests.",
                          ),
                          itemBuilder: (context, snapshot, index) {
                            RoommateRequest request =
                                RoommateRequest.fromSnapshot(snapshot[index]);

                            return SingleRoommateRequest(
                              request: request,
                              simple: true,
                              horizontal: true,
                              requestID: request.id,
                            );
                          },
                          query: FirebaseFirestore.instance
                              .collection(RoommateRequest.DIRECTORY)
                              .where(
                                RoommateRequest.MATCHED,
                                isEqualTo: false,
                              )
                              .orderBy(
                                RoommateRequest.TIME,
                                descending: true,
                              ),
                          isLive: true,
                          itemsPerPage: 4,
                          itemBuilderType: PaginateBuilderType.listView,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: MySliverAppBarDelegate(),
          )
        ];
      },
      body: StatefulBuilder(builder: (context, setIt) {
        setBottom = setIt;

        return selectedCategory == null
            ? LoadingWidget()
            : PaginateFirestore(
                onEmpty: Center(
                  child: Text(
                    "No properties yet",
                  ),
                ),
                itemBuilderType: PaginateBuilderType.listView,
                listeners: [
                  refreshChangeListener,
                ],
                query: getQuery(),
                itemBuilder: (context, snapshot, index) {
                  Property property = Property.fromSnapshot(snapshot[index]);

                  return SingleProperty(
                    property: property,
                    propertyID: property.id,
                    horizontal: false,
                    selectable: false,
                    selected: false,
                    onTap: null,
                    list: true,
                  );
                },
              );
      }),
    );
  }

  Query getQuery() {
    Query qq = FirebaseFirestore.instance
        .collection(Property.DIRECTORY)
        .where(
          Property.AVAILABLE,
          isEqualTo: true,
        )
        .where(
          Property.CATEGORY,
          arrayContains: selectedCategory,
        );

    return qq;
  }

  @override
  bool get wantKeepAlive => true;
}

class HomeScreenCustomTabBar extends StatefulWidget {
  final String selected;
  const HomeScreenCustomTabBar({Key key, @required this.selected, }) : super(key: key);

  @override
  State<HomeScreenCustomTabBar> createState() => _HomeScreenCustomTabBarState();
}

class _HomeScreenCustomTabBarState extends State<HomeScreenCustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StatefulBuilder(
          builder: (context, ff) {
            return PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              query: FirebaseFirestore.instance
                  .collection(EntityCategory.DIRECTORY)
                  .where(
                    EntityCategory.THINGTYPE,
                    isEqualTo: ThingType.PROPERTY,
                  ),
              onLoaded: (b) {
                if (selectedCategory == null) {
                  selectedCategory ??= b.documentSnapshots[0].id;
                  Future.delayed(Duration(seconds: 1), () {
                    ff(() {});
                    setBottom(() {});
                  });
                }
              },
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, snapshot, index) {
                EntityCategory category =
                    EntityCategory.fromSnapshot(snapshot[index]);

                return GestureDetector(
                  onTap: () {
                    selectedCategory = category.id;

                    refreshChangeListener.resetPagination(
                      true,
                      getQuery(),
                    );

                    ff(() {});
                    setBottom(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: standardBorderRadius,
                      border: Border.all(
                        color: altColor,
                      ),
                      color: selectedCategory == category.id
                          ? altColor
                          : altColor.withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Spacer(),
                        Text(
                          category.name,
                          style: selectedCategory == category.id
                              ? TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )
                              : TextStyle(
                                  color: Colors.black,
                                ),
                        ),
                        Spacer(),
                        Icon(
                          category.categoryType == Property.RESIDENTIAL
                              ? Icons.hotel
                              : Icons.house,
                          color: selectedCategory == category.id
                              ? Colors.white
                              : null,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        Center(
          child: StackableScrollController(
            controller: exploreController,
          ),
        )
      ],
    );
  }
}

class SingleDashboardCard extends StatelessWidget {
  final String title;
  final String image;
  final Function onTap;
  const SingleDashboardCard({
    Key key,
    @required this.onTap,
    @required this.image,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 4,
      ),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Material(
          elevation: 8,
          borderRadius: standardBorderRadius,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              image: UIServices().decorationImage(
                image,
                true,
              ),
              borderRadius: standardBorderRadius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
