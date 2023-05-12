import 'package:flutter/material.dart';
import 'package:dorx/constants/ui.dart';
import 'package:dorx/widgets/loading_widget.dart';
import 'package:dorx/services/ui_services.dart';
import 'package:dorx/services/text_service.dart';

class SingleSelectTile extends StatelessWidget {
  final String asset;
  final String text;
  final Color bgColor;
  final String desc;
  final Widget icon;
  final bool selected;
  final bool processing;
  final Function onTap;
  const SingleSelectTile({
    Key key,
    @required this.onTap,
    this.selected = false,
    this.asset,
    this.desc,
    @required this.text,
    this.icon,
    this.processing = false,
    this.bgColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 3,
        ),
        child: Material(
          borderRadius: standardBorderRadius,
          elevation: standardElevation,
          color: selected ? bgColor : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: selected ? bgColor : null,
              borderRadius: standardBorderRadius,
              image: UIServices().decorationImage(
                asset,
                true,
              ),
            ),
            child: processing
                ? LoadingWidget()
                : Row(
                    children: [
                      if (icon != null) icon,
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text.capitalizeFirstOfEach,
                              style: TextStyle(
                                color: asset != null ? Colors.white : null,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (desc != null)
                              Text(
                                desc,
                                style: TextStyle(
                                  color: asset != null ? Colors.white : null,
                                ),
                              ),
                          ],
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
