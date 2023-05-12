import 'package:flutter/material.dart';
import '../services/services.dart';
import 'widgets.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final double height;
  final Color titleColor;
  final bool noLeading;
  final bool backEnabled;
  final List<Widget> actions;
  final FlexibleSpaceBar flexibleSpaceBar;
  const CustomSliverAppBar({
    Key key,
    this.title,
    this.flexibleSpaceBar,
    this.height = 0,
    this.backEnabled = true,
    this.noLeading = false,
    this.actions = const [],
    this.titleColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).canvasColor,
      snap: false,
      flexibleSpace: flexibleSpaceBar,
      floating: false,
      expandedHeight: height,
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                color: titleColor,
              ),
            )
          : null,
      leading: noLeading
          ? SizedBox()
          : GestureDetector(
              onTap: () {
                if (backEnabled) {
                  if (context.canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.pushReplacementNamed(RouteConstants.home);
                  }
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              child: Icon(
                backEnabled ? Icons.arrow_back_ios : Icons.menu,
                color: Colors.grey,
              ),
            ),
      actions: <Widget>[
        NotificationsButton(
          color: null,
        ),
        IconButton(
          onPressed: () {
            FeedbackServices().startFeedingBackward(
              context,
            );
          },
          icon: Icon(
            Icons.feedback,
            color: Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () {
            UIServices().showDatSheet(
              LanguageChangerBottomSheet(),
              true,
              context,
            );
          },
          icon: Icon(
            Icons.language,
            color: Colors.grey,
          ),
        ),
      ]
          .followedBy(
        actions.map((e) => e),
      )
          .followedBy([
        SizedBox(
          width: 10,
        )
      ]).toList(),
    );
  }
}
