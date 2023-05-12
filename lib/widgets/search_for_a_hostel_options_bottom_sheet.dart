import 'package:dorx/constants/images.dart';
import 'package:dorx/widgets/single_select_tile.dart';
import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';

class SearchForHostelOptions extends StatefulWidget {
  final Function onUniversityTap;
  final Function onLocationTap;
  SearchForHostelOptions({
    Key key,
    @required this.onLocationTap,
    @required this.onUniversityTap,
  }) : super(key: key);

  @override
  State<SearchForHostelOptions> createState() => _SearchForHostelOptionsState();
}

class _SearchForHostelOptionsState extends State<SearchForHostelOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Find A Hostel",
        ),
        SingleSelectTile(
          onTap: () {
            widget.onUniversityTap();
          },
          selected: false,
          asset: campus,
          text: "Search For Hostels By University",
        ),
        SingleSelectTile(
          onTap: () {
            widget.onLocationTap();
          },
          selected: false,
          asset: compound,
          text: "Show Me Hostels Near Me",
        ),
      ],
    );
  }
}
