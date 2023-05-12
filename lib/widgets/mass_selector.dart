import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';

import '../constants/ui.dart';
import 'custom_sized_box.dart';

class MassSelector extends StatefulWidget {
  final bool maxWidth;
  final String text;
  final String subTitle;
  final bool simple;
  final Function onTapSubtitle;
  final int count;
  final Function(int v) onAdd;
  final Function(int v) onRemove;
  MassSelector({
    Key key,
    @required this.onAdd,
    @required this.onRemove,
    @required this.text,
    this.maxWidth = false,
    this.simple = false,
    @required this.count,
    this.subTitle,
    this.onTapSubtitle,
  }) : super(key: key);

  @override
  State<MassSelector> createState() => _MassSelectorState();
}

class _MassSelectorState extends State<MassSelector> {
  List<int> options = [
    1,
    2,
    5,
    10,
    20,
    50,
    100,
    1000,
    10000,
    100000,
    1000000,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 5,
      ),
      child: Material(
        elevation: standardElevation,
        borderRadius: standardBorderRadius,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.subTitle != null)
                            GestureDetector(
                              onTap: () {
                                if (widget.onTapSubtitle != null) {
                                  widget.onTapSubtitle();
                                }
                              },
                              child: Text(
                                widget.subTitle,
                                style: TextStyle(
                                  decorationStyle: TextDecorationStyle.wavy,
                                  fontWeight: widget.onTapSubtitle != null
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CustomSizedBox(
                          sbSize: SBSize.small,
                          height: false,
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onRemove(1);
                          },
                          child: Icon(
                            Icons.remove_circle_outline,
                            size: 32,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              TextService().putCommas(widget.count.toString()),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 20),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onAdd(1);
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.simple)
              Container(
                width: widget.maxWidth ? double.infinity : null,
                padding: const EdgeInsets.all(2),
                child: Wrap(
                    alignment: WrapAlignment.center,
                    children: options.map<Widget>((e) {
                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: GestureDetector(
                          onTap: () {
                            widget.onAdd(e);
                          },
                          child: Chip(
                            elevation: standardElevation,
                            onDeleted: () {
                              widget.onRemove(e);
                            },
                            clipBehavior: Clip.hardEdge,
                            label: Text(
                              TextService().putCommas(e.toString()),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
              ),
          ],
        ),
      ),
    );
  }
}
