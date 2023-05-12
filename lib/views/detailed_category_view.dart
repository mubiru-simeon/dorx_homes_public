import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class DetailedCategory extends StatefulWidget {
  final EntityCategory category;
  final String categoryID;

  DetailedCategory({
    Key key,
    @required this.category,
    @required this.categoryID,
  }) : super(key: key);

  @override
  State<DetailedCategory> createState() => _DetailedCategoryState();
}

class _DetailedCategoryState extends State<DetailedCategory>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.category == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(EntityCategory.DIRECTORY)
                .doc(widget.categoryID)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              } else {
                EntityCategory category =
                    EntityCategory.fromSnapshot(snapshot.data);

                return body(category);
              }
            })
        : body(
            widget.category,
          );
  }

  body(EntityCategory category) {
    return Scaffold(
      body: Column(children: [
        BackBar(
          icon: null,
          text: category.name,
          onPressed: null,
        ),
        Expanded(
            child: PaginateFirestore(
          onEmpty: NoDataFound(
            text: "No Items Found.",
          ),
          isLive: true,
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (
            context,
            snapshot,
            index,
          ) {
            Property product = Property.fromSnapshot(
              snapshot[index],
            );

            return SingleProperty(
              property: product,
              selectable: false,
              list: true,
              propertyID: product.id,
              selected: false,
              onTap: null,
            );
          },
          query: FirebaseFirestore.instance
              .collection(
                Property.DIRECTORY,
              )
              .where(
                Property.AVAILABLE,
                isEqualTo: true,
              )
              .where(
                Property.CATEGORY,
                arrayContains: category.id,
              ),
        )),
      ]),
    );
  }
}
