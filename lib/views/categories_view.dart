import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class CategoriesView extends StatefulWidget {
  final bool selectable;
  final bool returnSingle;
  CategoriesView({
    Key key,
    @required this.selectable,
    this.returnSingle = false,
  }) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  EntityCategory selected;
  List selecteds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "My Categories",
          ),
          Expanded(
              child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              EntityCategory category =
                  EntityCategory.fromSnapshot(snapshot[index]);

              return NewCategory(
                onTap: () {
                  if (widget.selectable) {
                    if (widget.returnSingle) {
                      Navigator.of(context).pop(category.id);
                    } else {
                      setState(() {
                        if (selecteds.contains(category.id)) {
                          selecteds.remove(category.id);
                        } else {
                          selecteds.add(category.id);
                        }
                      });
                    }
                  } else {
                    context.pushNamed(
                      RouteConstants.detailedCategory,
                      params: {
                        "id": category.id,
                      },
                      extra: category,
                    );
                  }
                },
                category: category,
                categoryID: category.id,
              );
            },
            itemsPerPage: 5,
            isLive: true,
            query: FirebaseFirestore.instance
                .collection(EntityCategory.DIRECTORY)
                .where(
                  EntityCategory.THINGTYPE,
                  isEqualTo: ThingType.PROPERTY,
                )
                .orderBy(
                  EntityCategory.DATE,
                  descending: true,
                ),
            onEmpty: NoDataFound(
              picSize: null,
              text: "No Categories Found",
            ),
          ))
        ],
      ),
      floatingActionButton: widget.selectable
          ? FloatingActionButton.extended(
              onPressed: () {
                returnCategory();
              },
              label: Text("Done"),
              icon: Icon(
                Icons.done,
              ),
            )
          : null,
    );
  }

  returnCategory() {
    Navigator.of(context).pop(
      widget.returnSingle ? selected : selecteds,
    );
  }
}

class NewCategory extends StatefulWidget {
  final EntityCategory category;
  final String categoryID;
  final bool showDesc;
  final Function onTap;
  const NewCategory({
    Key key,
    @required this.category,
    @required this.categoryID,
    this.showDesc = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<NewCategory> createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  @override
  Widget build(BuildContext context) {
    return widget.category == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(EntityCategory.DIRECTORY)
                .doc(widget.categoryID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              } else {
                EntityCategory category = EntityCategory.fromSnapshot(
                  snapshot.data,
                );

                return body(category);
              }
            },
          )
        : body(
            widget.category,
          );
  }

  body(
    EntityCategory category,
  ) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap();
        } else {
          context.pushNamed(
            RouteConstants.detailedCategory,
            params: {
              "id": category.id,
            },
            extra: category,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 3,
        ),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: standardBorderRadius,
          image: category.image.isEmpty
              ? null
              : UIServices().decorationImage(
                  category.image[0],
                  true,
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: category.image.isEmpty ? darkTitle : whiteTitle,
                  ),
                  if (category.desc != null &&
                      category.desc.trim().isNotEmpty &&
                      widget.showDesc)
                    Text(
                      category.desc,
                      style: TextStyle(
                        color: category.image.isEmpty ? null : Colors.white,
                      ),
                    ),
                  if (category.desc != null &&
                      category.desc.trim().isNotEmpty &&
                      widget.showDesc)
                    SizedBox(
                      height: 10,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
