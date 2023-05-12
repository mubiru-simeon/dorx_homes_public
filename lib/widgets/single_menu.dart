import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dorx/models/menu.dart';
import '../constants/ui.dart';
import '../services/ui_services.dart';

class SingleMenu extends StatefulWidget {
  final Menu menu;
  final bool horizontal;
  final String menuID;
  const SingleMenu({
    Key key,
    @required this.menu,
    this.horizontal = true,
    @required this.menuID,
  }) : super(key: key);

  @override
  State<SingleMenu> createState() => _SingleMenuState();
}

class _SingleMenuState extends State<SingleMenu> {
  @override
  Widget build(BuildContext context) {
    return widget.menu == null
        ? StreamBuilder(builder: (context, snapshot) {
            Menu menu = Menu.fromSnapshot(snapshot.data);

            return body(menu);
          })
        : body(widget.menu);
  }

  body(Menu menu) {
    return GestureDetector(
      onTap: () {
        // NavigationService().push(
        //   // DetailedMenuView(
        //   //   testing: false,
        //   //   menu: menu,
        //   // ),
        // );
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Material(
          borderRadius: standardBorderRadius,
          elevation: 8,
          child: ClipRRect(
            borderRadius: standardBorderRadius,
            child: Container(
              width: widget.horizontal
                  ? kIsWeb
                      ? 300
                      : MediaQuery.of(context).size.width * 0.4
                  : null,
              decoration: menu.images.isEmpty
                  ? null
                  : BoxDecoration(
                      image: UIServices().decorationImage(
                        menu.images[0],
                        true,
                      ),
                    ),
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (menu.name != null)
                    Text(
                      menu.name,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: menu.images.isNotEmpty ? Colors.white : null,
                      ),
                    ),
                  if (menu.description != null &&
                      menu.images.isEmpty &&
                      !widget.horizontal)
                    Text(
                      menu.description,
                      style: TextStyle(
                        color: menu.images.isNotEmpty ? Colors.white : null,
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
