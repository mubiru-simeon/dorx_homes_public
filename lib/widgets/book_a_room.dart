import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widgets.dart';

class BookARoomOnCasa extends StatefulWidget {
  final Property property;
  BookARoomOnCasa({
    Key key,
    @required this.property,
  }) : super(key: key);

  @override
  State<BookARoomOnCasa> createState() => _BookARoomOnCasaState();
}

class _BookARoomOnCasaState extends State<BookARoomOnCasa> {
  List<Widget> pages;
  bool processing = false;
  DateTime startDate;
  DateTime stopDate;
  bool acceptCasaTerms = false;
  bool pickUp = false;
  bool acceptHouseRules = false;

  int adultCount = 1;
  int childrenCount = 0;
  int petcount = 0;
  int infants = 0;

  List<String> _selectedRoom = [];

  PageController pageController = PageController();
  PageController roomTypeController = PageController(viewportFraction: 0.8);
  int _currentIndex = 0;
  bool theresProperty = true;
  double thingCount = 0.0;
  double subTotal = 0.0;
  double dayCount = 0.0;

  @override
  Widget build(BuildContext context) {
    if (startDate != null && stopDate != null) {
      dayCount = DateService().getWeekCountMap(
        startDate.millisecondsSinceEpoch,
        stopDate.millisecondsSinceEpoch,
      )["days"];
    }

    pages = [
      selectDates(),
      selectRoomType(),
      whosComing(),
      spaceRulesAndProhibitions(),
      finaliseBooking(),
    ];

    return WillPopScope(
      onWillPop: () {
        return handleBackButton();
      },
      child: Scaffold(
        body: Column(
          children: [
            BackBar(
              icon: _currentIndex == 0 ? Icons.close : null,
              onPressed: _currentIndex == 0
                  ? null
                  : () {
                      goBack();
                    },
              text: "Book A Room",
            ),
            Row(
              children: pages.map((e) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 1,
                    ),
                    height: 5,
                    color: _currentIndex >= pages.indexOf(e)
                        ? primaryColor
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (v) {
                      setState(() {
                        _currentIndex = v;
                      });
                    },
                    controller: pageController,
                    children: pages.map((e) => e).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: Wrap(
          children: [
            ProceedButton(
              onTap: () {
                checkIfItsSafeToProceed();
              },
              processing: processing,
              borderRadius: standardBorderRadius,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex == pages.length - 1
                        ? "Place A Booking"
                        : "Proceed",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.smallest,
                    height: false,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  whosComing() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomSizedBox(
            sbSize: SBSize.small,
            height: true,
          ),
          StatisticText(
            title: "Who is coming?",
          ),
          MassSelector(
            onAdd: (v) {
              setState(() {
                adultCount = adultCount + v;
              });
            },
            onRemove: (v) {
              setState(() {
                adultCount = adultCount - v < 0 ? 0 : adultCount - v;
              });
            },
            text: "Adults",
            simple: true,
            subTitle: "Ages 13+",
            count: adultCount,
          ),
          MassSelector(
            onAdd: (v) {
              setState(() {
                childrenCount = childrenCount + v;
              });
            },
            onRemove: (v) {
              setState(() {
                childrenCount = childrenCount - v < 0 ? 0 : childrenCount - v;
              });
            },
            text: "Children",
            simple: true,
            subTitle: "Ages 2-12",
            count: childrenCount,
          ),
          MassSelector(
            onAdd: (v) {
              if (widget.property.houseRules.containsKey("Pets")) {
                if (widget.property.houseRules["Pets"][HouseRules.PROHIBITED] ==
                    false) {
                  setState(() {
                    petcount = petcount + v;
                  });
                }
              } else {
                setState(() {
                  petcount = petcount + v;
                });
              }
            },
            onRemove: (v) {
              setState(() {
                petcount = petcount - v < 0 ? 0 : petcount - v;
              });
            },
            text: "Pets",
            onTapSubtitle: () {
              StorageServices().launchTheThing(
                assistanceAnimalsLink,
              );
            },
            simple: true,
            subTitle:
                "Do you have an assistance animal? Asistance animals don't count as pets.",
            count: petcount,
          ),
          CustomSizedBox(
            sbSize: SBSize.small,
            height: true,
          ),
          CustomSwitch(
            text: "I want to be picked up and delivered to the place",
            selected: pickUp,
            onTap: (b) {
              setState(() {
                pickUp = b;
              });
            },
            icon: FontAwesomeIcons.truckDroplet,
          ),
          CustomSwitch(
            text: "I have some property / luggage",
            selected: theresProperty,
            onTap: (b) {
              setState(() {
                theresProperty = b;
              });
            },
            icon: FontAwesomeIcons.cartFlatbedSuitcase,
          ),
        ],
      ),
    );
  }

  checkIfItsSafeToProceed() {
    if (_currentIndex == 0 && (startDate == null || stopDate == null)) {
      CommunicationServices().showSnackBar(
        "Please tell us when you will be needing the space by tapping on the calendar.",
        context,
      );
    } else {
      if (_currentIndex == 1 && _selectedRoom.isEmpty) {
        CommunicationServices().showSnackBar(
          "Please select which room you like.",
          context,
        );
      } else {
        if (_currentIndex == 2 &&
            adultCount == 0 &&
            childrenCount == 0 &&
            petcount == 0) {
          CommunicationServices().showSnackBar(
            "Please tell us how many people are coming (you inclusive).",
            context,
          );
        } else {
          if (_currentIndex == 3 && acceptCasaTerms == false) {
            CommunicationServices().showSnackBar(
              "In order to proceed, please accept the $capitalizedAppName terms and Conditions.",
              context,
            );
          } else {
            if (_currentIndex == 3 &&
                widget.property.houseRules.isNotEmpty &&
                acceptHouseRules == false) {
              CommunicationServices().showSnackBar(
                "In order to proceed, please accept the host's rules and conditions.",
                context,
              );
            } else {
              if (_currentIndex == 3 &&
                  widget.property.houseRules.isNotEmpty &&
                  acceptCasaTerms == false) {
                CommunicationServices().showSnackBar(
                  "In order to proceed, please accept the $capitalizedAppName Guest terms and conditions.",
                  context,
                );
              } else {
                if (_currentIndex == pages.length - 1) {
                  if (AuthProvider.of(context).auth.isSignedIn()) {
                    placeRoomRequest();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return NotLoggedInDialogBox(
                          onLoggedIn: (v) {
                            placeRoomRequest();
                          },
                        );
                      },
                    );
                  }
                } else {
                  goNext();
                }
              }
            }
          }
        }
      }
    }
  }

  spaceRulesAndProhibitions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if ((widget.property.houseRules != null &&
                  widget.property.houseRules.isNotEmpty) ||
              (widget.property.additionalRules != null &&
                  widget.property.additionalRules.isNotEmpty))
            Column(
              children: <Widget>[
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                Text(
                  "Your Host has a few rules they'd like you to follow.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: true,
                ),
              ].followedBy(
                widget.property.houseRules.entries.map<Widget>(
                  (e) {
                    bool accepted = e.value[HouseRules.PROHIBITED] ?? true;

                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: accepted ? Colors.green : Colors.red,
                        ),
                        child: Icon(
                          accepted ? Icons.done : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(e.key),
                    );
                  },
                ),
              ).followedBy(
                widget.property.additionalRules.entries.map<Widget>(
                  (e) {
                    bool accepted = e.value[HouseRules.PROHIBITED] ?? true;

                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: accepted ? Colors.green : Colors.red,
                        ),
                        child: Icon(
                          accepted ? Icons.done : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(e.key),
                    );
                  },
                ),
              ).followedBy(
                [
                  CustomDivider(),
                  CheckboxListTile(
                    title: Text(
                      "I shall respect and abide by the House Rules set by the host for this space.",
                    ),
                    value: acceptHouseRules,
                    onChanged: (v) {
                      setState(() {
                        acceptHouseRules = v;
                      });
                    },
                  ),
                ],
              ).toList(),
            ),
          CustomDivider(),
          CheckboxListTile(
            title: Text(
              "I acknowledge that I shall abide by the $capitalizedAppName guest terms and conditions",
            ),
            value: acceptCasaTerms,
            onChanged: (v) {
              setState(() {
                acceptCasaTerms = v;
              });
            },
          ),
          CustomDivider(),
        ],
      ),
    );
  }

  placeRoomRequest() {
    setState(() {
      processing = true;
    });

    FirebaseFirestore.instance.collection(Booking.DIRECTORY).add(
      {
        Booking.PENDING: true,
        Booking.APPROVED: false,
        Booking.ONGOING: false,
        Booking.CHECKEDIN: false,
        Booking.CANCELLED: false,
        Booking.REJECTED: false,
        Booking.COMPLETE: false,
        Booking.CUSTOMER: AuthProvider.of(context).auth.getCurrentUID(),
        Booking.DATE: DateTime.now().millisecondsSinceEpoch,
        Booking.PROPERTY: widget.property.id,
        Booking.START: startDate.millisecondsSinceEpoch,
        Booking.STOP: stopDate.millisecondsSinceEpoch,
        Booking.SELECTEDROOMS: _selectedRoom,
        Booking.ADULTCOUNT: adultCount,
        Booking.CHILDCOUNT: childrenCount,
        Booking.PETCOUNT: petcount,
        Booking.PAYMENTAMOUNT: subTotal,
        Booking.LUGGAGE: theresProperty,
        Property.FREQUENCY: widget.property.frequency,
        Booking.INEEDALIFT: pickUp,
        Booking.PROPERTYPRICE: widget.property.price,
      },
    ).then(
      (value) {
        if (context.canPop()) {
          Navigator.of(context).pop();
        } else {
          context.pushReplacementNamed(RouteConstants.home);
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CustomDialogBox(
              bodyText:
                  "Your booking has been organised successfully. We shall be in touch shortly.\n\nYour booking ID is ${value.id}",
              buttonText: "Ok, got it",
              onButtonTap: () {},
              showOtherButton: true,
            );
          },
        );
      },
    );
  }

  goNext() {
    pageController.animateToPage(
      (pageController.page + 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  finaliseBooking() {
    return Column(
      children: [
        CustomSizedBox(
          sbSize: SBSize.small,
          height: true,
        ),
        Text(
          "Congratulations. Your Booking request is ready. Tap the proceed button to finish.",
        ),
      ],
    );
  }

  selectRoomType() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          StatisticText(
            title: "Which rooms would you like? [You can select multiple]",
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: PaginateFirestore(
              pageController: roomTypeController,
              scrollDirection: Axis.horizontal,
              onEmpty: NoDataFound(
                  text:
                      "The property owner hasn't added any rooms yet. Check back later."),
              itemBuilder: (context, snapshot, index) {
                RoomType roomType = RoomType.fromSnapshot(snapshot[index]);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedRoom.contains(roomType.id)) {
                        _selectedRoom.remove(roomType.id);
                      } else {
                        _selectedRoom.add(roomType.id);
                      }
                    });
                  },
                  child: SingleRoomType(
                    roomTypeID: roomType.id,
                    roomType: roomType,
                    putExpanded: true,
                    horizontal: false,
                    selected: _selectedRoom.contains(roomType.id),
                  ),
                );
              },
              query: FirebaseFirestore.instance
                  .collection(RoomType.DIRECTORY)
                  .where(
                    RoomType.PROPERTY,
                    isEqualTo: widget.property.id,
                  ),
              itemBuilderType: PaginateBuilderType.pageView,
            ),
          ),
          CustomSizedBox(
            sbSize: SBSize.small,
            height: true,
          ),
        ],
      ),
    );
  }

  selectDates() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatisticText(
            title: "For how long will you need the space?",
          ),
          CustomSizedBox(
            sbSize: SBSize.small,
            height: true,
          ),
          CalendarDatePicker2(
            value: [
              startDate,
              stopDate,
            ],
            onValueChanged: (v) {
              if (v != null) {
                setState(() {
                  if (v.length == 1) {
                    startDate = v[0];
                    stopDate = null;
                  } else {
                    if (v.length == 2) {
                      if (v[0].millisecondsSinceEpoch <
                          v[1].millisecondsSinceEpoch) {
                        startDate = v[0];
                        stopDate = v[1];
                      } else {
                        startDate = v[1];
                        stopDate = v[0];
                      }
                    }
                  }
                });
              }
            },
            config: CalendarDatePicker2Config(
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(
                Duration(
                  days: 5000,
                ),
              ),
              calendarType: CalendarDatePicker2Type.range,
            ),
          ),
          CustomSizedBox(
            sbSize: SBSize.normal,
            height: true,
          ),
          if (startDate != null)
            StatisticText(
              title:
                  "From: ${DateService().dateFromMilliseconds(startDate.millisecondsSinceEpoch)}",
            ),
          if (stopDate != null)
            StatisticText(
              title:
                  "To: ${DateService().dateFromMilliseconds(stopDate.millisecondsSinceEpoch)}",
            ),
          StatisticText(
            title:
                "$thingCount ${widget.property.frequency == PERNIGHT ? "Nights" : widget.property.frequency == PERSEMISTER ? "Semisters" : "Months"}",
          ),
          CustomSizedBox(
            sbSize: SBSize.normal,
            height: true,
          ),
        ],
      ),
    );
  }

  goBack() {
    pageController.animateToPage(
      (pageController.page - 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  handleBackButton() {
    if (_currentIndex != 0) {
      goBack();
    } else {
      if (context.canPop()) {
        Navigator.of(context).pop();
      } else {
        context.pushReplacementNamed(RouteConstants.home);
      }
    }
  }
}
