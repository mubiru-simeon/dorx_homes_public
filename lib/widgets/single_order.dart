
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class SingleOrder extends StatefulWidget {
  final Order order;
  const SingleOrder({
    Key key,
    @required this.order,
  }) : super(key: key);

  @override
  State<SingleOrder> createState() => _SingleOrderState();
}

class _SingleOrderState extends State<SingleOrder> {
  @override
  Widget build(BuildContext context) {
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
              ListTile(
                title: Text(
                    "Order On ${DateService().dateFromMilliseconds(
                      widget.order.date,
                    )}",
                    style: darkTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    CopiableIDThing(id: widget.order.id),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: SingleBigButton(
                    processing: false,
                    color: primaryColor,
                    onPressed: () {
                      // NavigationService().push(
                      //   OrderDetails(
                      //     order: widget.order,
                      //     orderID: widget.order.id,
                      //   ),
                      // );
                    },
                    text: "View Details",
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
