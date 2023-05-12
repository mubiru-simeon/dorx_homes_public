import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class ManageBookingView extends StatefulWidget {
  const ManageBookingView({
    Key key,
  }) : super(key: key);

  @override
  State<ManageBookingView> createState() => _ManageBookingViewState();
}

class _ManageBookingViewState extends State<ManageBookingView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            StatisticText(
              title: "Your Bookings",
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: OnlyWhenLoggedIn(
                signedInBuilder: (uid) {
                  return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(Booking.DIRECTORY)
                          .where(
                            Booking.CUSTOMER,
                            isEqualTo: uid,
                          )
                          .where(
                            Booking.CANCELLED,
                            isEqualTo: false,
                          )
                          .where(
                            Booking.REJECTED,
                            isEqualTo: false,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return LoadingWidget();
                        } else {
                          List bookings = [];

                          snapshot.data.docs.forEach((v) {
                            bookings.add(Booking.fromSnapshot(v));
                          });

                          if (bookings.isEmpty) {
                            return NoDataFound(
                              text: "You don't have any ongoing bookings",
                            );
                          } else {
                            return DefaultTabController(
                              length: bookings.length,
                              child: NestedScrollView(
                                headerSliverBuilder: (gh, hg) {
                                  return [
                                    SliverPersistentHeader(
                                      delegate: MySliverAppBarDelegate(
                                        TabBar(
                                          isScrollable: true,
                                          labelColor:
                                              getTabColor(context, true),
                                          unselectedLabelColor:
                                              getTabColor(context, false),
                                          tabs: bookings
                                              .map(
                                                (e) => Tab(
                                                  text:
                                                      "Booking #${bookings.indexOf(e) + 1}",
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  ];
                                },
                                body: TabBarView(
                                  children: bookings
                                      .map(
                                        (e) => SingleBookingView(
                                          booking: e,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            );
                          }
                        }
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleBookingView extends StatefulWidget {
  final Booking booking;
  const SingleBookingView({
    Key key,
    @required this.booking,
  }) : super(key: key);

  @override
  State<SingleBookingView> createState() => _SingleBookingViewState();
}

class _SingleBookingViewState extends State<SingleBookingView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InformationalBox(
          visible: true,
          onClose: null,
          message: widget.booking.pending
              ? "Pending Approval"
              : widget.booking.ongoing
                  ? "Ongoing"
                  : widget.booking.cancelled
                      ? "Cancelled"
                      : widget.booking.rejected
                          ? "Rejected"
                          : widget.booking.complete
                              ? "Completed"
                              : widget.booking.checkedIn
                                  ? "Checked In"
                                  : widget.booking.approved
                                      ? "Approved"
                                      : capitalizedAppName,
        ),
        SizedBox(
          height: 400,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.booking.roomsRequested.map((e) {
                return SingleRoomType(
                  roomType: null,
                  horizontal: true,
                  roomTypeID: e,
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}
