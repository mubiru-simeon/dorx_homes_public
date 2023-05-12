import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class HostelBedspacesView extends StatefulWidget {
  final bool needABedspace;
  final bool sellingABedpace;
  HostelBedspacesView({
    Key key,
    @required this.needABedspace,
    @required this.sellingABedpace,
  }) : super(key: key);

  @override
  State<HostelBedspacesView> createState() => _HostelBedspacesViewState();
}

class _HostelBedspacesViewState extends State<HostelBedspacesView>
    with TickerProviderStateMixin {
  TabController _tabController;
  List<String> categories;

  @override
  void initState() {
    super.initState();
    categories = [
      HallBedspaceRequest.PENDING,
      HallBedspaceRequest.COMPLETED,
    ];

    _tabController = TabController(
      initialIndex: 0,
      length: categories.length,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.needABedspace) {
        UIServices().showDatSheet(
          RequestHallSpaceBottomSheet(requesting: true),
          true,
          context,
        );
      }

      if (widget.sellingABedpace) {
        UIServices().showDatSheet(
          RequestHallSpaceBottomSheet(requesting: false),
          true,
          context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (gh, hg) {
          return [
            CustomSliverAppBar(
              backEnabled: true,
              title: "Hall Bedspaces",
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: MySliverAppBarDelegate(
                TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  unselectedLabelColor: getTabColor(context, false),
                  labelColor: getTabColor(context, true),
                  tabs: categories
                      .map(
                        (e) => Tab(
                          text: e.capitalizeFirstOfEach,
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleSpaceRequestView(
              mode: HallBedspaceRequest.PENDING,
            ),
            SingleSpaceRequestView(
              mode: HallBedspaceRequest.COMPLETED,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          UIServices().showDatSheet(
            RequestHallSpaceBottomSheet(
              requesting: true,
            ),
            true,
            context,
          );
        },
        icon: Icon(Icons.add),
        label: Text(
          "Request For Bedspace",
        ),
      ),
    );
  }
}

class SingleSpaceRequestView extends StatefulWidget {
  final String mode;
  SingleSpaceRequestView({
    Key key,
    @required this.mode,
  }) : super(key: key);

  @override
  State<SingleSpaceRequestView> createState() => _SingleSpaceRequestViewState();
}

class _SingleSpaceRequestViewState extends State<SingleSpaceRequestView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return OnlyWhenLoggedIn(signedInBuilder: (uid) {
      return PaginateFirestore(
        onEmpty: NoDataFound(
          text: "No Requests Yet.",
        ),
        itemsPerPage: 2,
        itemBuilder: (
          context,
          snapshot,
          index,
        ) {
          HallBedspaceRequest package = HallBedspaceRequest.fromSnapshot(
            snapshot[index],
          );

          return SingleRequest(
            requestID: package.id,
            request: package,
          );
        },
        isLive: true,
        query: FirebaseFirestore.instance
            .collection(HallBedspaceRequest.DIRECTORY)
            .where(
              widget.mode,
              isEqualTo: true,
            )
            .where(HallBedspaceRequest.CUSTOMER, isEqualTo: uid),
        itemBuilderType: PaginateBuilderType.listView,
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleRequest extends StatefulWidget {
  final HallBedspaceRequest request;
  final String requestID;
  SingleRequest({
    Key key,
    @required this.request,
    @required this.requestID,
  }) : super(key: key);

  @override
  State<SingleRequest> createState() => _SingleRequestState();
}

class _SingleRequestState extends State<SingleRequest> {
  @override
  Widget build(BuildContext context) {
    return widget.request == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(HallBedspaceRequest.DIRECTORY)
                .doc(widget.requestID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              } else {
                HallBedspaceRequest request =
                    HallBedspaceRequest.fromSnapshot(snapshot.data);

                return body(request);
              }
            },
          )
        : body(widget.request);
  }

  body(HallBedspaceRequest request) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 5,
      ),
      child: Material(
        elevation: 5,
        borderRadius: standardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ExpansionTile(
                title: GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: request.id,
                      ),
                    ).then((value) {
                      CommunicationServices().showToast(
                        "Request ID has been copied",
                        Colors.blue,
                      );
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.copy,
                        size: 15,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          "Request ID: ${request.id}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateService().dateFromMilliseconds(
                        request.date,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Tap here to view details",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: EdgeInsets.symmetric(horizontal: 7),
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gender: ${request.gender}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "University",
                      ),
                      SingleSchool(
                        school: null,
                        onTap: null,
                        selected: false,
                        schoolID: request.university,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SingleBigButton(
                color: Colors.blue,
                onPressed: () {
                  StorageServices().launchTheThing(
                    "tel:$dorxPhoneNumber",
                  );
                },
                text: "Contact $capitalizedAppName Support Team",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
