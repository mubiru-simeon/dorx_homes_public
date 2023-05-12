import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/user_location_search_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

class WhereWhenDisplayer extends StatelessWidget {
  final String where;
  final String when;
  final String who;
  const WhereWhenDisplayer({
    Key key,
    @required this.when,
    @required this.where,
    @required this.who,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UIServices().showDatSheet(
          UserLocationSearchOptionsBottomSheet(),
          true,
          context,
        );
      },
      child: Material(
        elevation: standardElevation,
        borderRadius: standardBorderRadius,
        child: Container(
          margin: EdgeInsets.all(3),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: standardBorderRadius,
          ),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(
                  Icons.search,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We have a home for any occasion.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Press here and let's find you a home.",
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Where?",
                          ),
                        ),
                        divider(),
                        Expanded(
                          child: Text(
                            "When?",
                          ),
                        ),
                        divider(),
                        Expanded(
                          child: Text(
                            "Who?",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  divider() {
    return Container(
      height: 2,
      color: Colors.grey,
    );
  }
}
