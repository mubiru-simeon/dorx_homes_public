import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BookARoomView extends StatefulWidget {
  final String propertyID;
  final Property property;
  const BookARoomView({
    Key key,
    @required this.property,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<BookARoomView> createState() => _BookARoomViewState();
}

class _BookARoomViewState extends State<BookARoomView> {
  bool theresProperty = true;
  bool pickUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.property != null
          ? body(widget.property)
          : StreamBuilder(
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LoadingWidget();
                } else {
                  if (snapshot.data == null) {
                    return NoDataFound(
                      text: "Sorry. This property doesn't exist",
                    );
                  } else {
                    Property property = Property.fromSnapshot(
                      snapshot.data,
                    );

                    return body(property);
                  }
                }
              },
              stream: FirebaseFirestore.instance
                  .collection(Property.DIRECTORY)
                  .doc(widget.propertyID)
                  .snapshots(),
            ),
    );
  }

  body(
    Property property,
  ) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Book a room",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                SingleProperty(
                  property: property,
                  selectable: false,
                  simple: true,
                  list: true,
                  propertyID: widget.propertyID,
                  selected: false,
                  onTap: () {},
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      CustomDivider(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Your booking is covered by $capitalizedAppName cover",
                        style: titleStyle,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                GreyDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Your trip",
                        style: darkTitle,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RowColumnThing(
                        description: "Tap here to select your date",
                        title: "Dates",
                        trailing: UnderlinedEditButton(
                          text: "Edit",
                          onTap: () {},
                        ),
                      ),
                      RowColumnThing(
                        description: "Tap here to tell us your guests",
                        title: "Guests",
                        trailing: UnderlinedEditButton(
                          text: "Edit",
                          onTap: () {},
                        ),
                      ),
                      CustomSwitch(
                        text:
                            "I want to be picked up and delivered to the place",
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
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                GreyDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Your stay",
                        style: darkTitle,
                      ),
                      if ((property.houseRules != null &&
                              property.houseRules.isNotEmpty) ||
                          (property.additionalRules != null &&
                              property.additionalRules.isNotEmpty))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Your Host has a few rules they'd like you to follow.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ].followedBy(
                            property.houseRules.entries.map<Widget>(
                              (e) {
                                bool accepted =
                                    e.value[HouseRules.PROHIBITED] ?? true;

                                return ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      color:
                                          accepted ? Colors.green : Colors.red,
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
                            property.additionalRules.entries.map<Widget>(
                              (e) {
                                bool accepted =
                                    e.value[HouseRules.PROHIBITED] ?? true;

                                return ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      color:
                                          accepted ? Colors.green : Colors.red,
                                    ),
                                    child: Icon(
                                      accepted ? Icons.done : Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    e.key,
                                  ),
                                );
                              },
                            ),
                          ).toList(),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                GreyDivider(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RowColumnThing extends StatelessWidget {
  final String title;
  final String description;
  final Widget trailing;
  const RowColumnThing({
    Key key,
    @required this.description,
    @required this.title,
    @required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
              ),
            ],
          ),
          Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class UnderlinedEditButton extends StatelessWidget {
  final String text;
  final Function onTap;
  UnderlinedEditButton({
    Key key,
    @required this.text,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
