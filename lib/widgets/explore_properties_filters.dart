import 'package:dorx/services/services.dart';
import 'package:dorx/views/categories_view.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import 'widgets.dart';

class ExploreFilterOptions extends StatefulWidget {
  final Map options;
  ExploreFilterOptions({
    Key key,
    @required this.options,
  }) : super(key: key);

  @override
  State<ExploreFilterOptions> createState() => _ExploreFilterOptionsState();
}

class _ExploreFilterOptionsState extends State<ExploreFilterOptions> {
  bool shuttle;
  bool petsAllowed;
  List categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.options != null) {
      shuttle = widget.options[Property.SHUTTLE];
      petsAllowed = widget.options[Property.PETSALLOWED];
      categories = widget.options[Property.CATEGORY] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Filters",
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SingleSelectTile(
                    selected: petsAllowed != null,
                    bgColor: petsAllowed == true ? Colors.green : Colors.red,
                    onTap: () async {
                      bool fg = await UIServices().showDatSheet(
                        PetOptions(
                          petsAllowed: petsAllowed,
                        ),
                        true,
                        context,
                      );

                      setState(() {
                        petsAllowed = fg;
                      });
                    },
                    text: "Pets",
                  ),
                  SingleSelectTile(
                    selected: shuttle != null,
                    bgColor: shuttle == true ? Colors.green : Colors.red,
                    onTap: () async {
                      bool fg = await UIServices().showDatSheet(
                        ShuttleOptions(
                          shuttleAvailable: shuttle,
                        ),
                        true,
                        context,
                      );

                      shuttle = fg;
                    },
                    text: "Shuttle",
                  ),
                  SingleSelectTile(
                    onTap: () async {
                      List fg = await UIServices().showDatSheet(
                        CategoriesView(
                          selectable: true,
                        ),
                        true,
                        context,
                      );

                      if (fg != null) {
                        setState(() {
                          for (var element in fg) {
                            categories.add(element);
                          }
                        });
                      }
                    },
                    text: "Categories",
                  ),
                  if (categories.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: SingleChildScrollView(
                        child: Row(
                          children: categories
                              .map((e) => NewCategory(
                                    category: null,
                                    categoryID: e,
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ProceedButton(
          onTap: () {
            Navigator.of(context).pop({
              Property.SHUTTLE: shuttle,
              Property.PETSALLOWED: petsAllowed,
              Property.CATEGORY: categories,
            });
          },
          text: "Apply Filters",
        ),
      ],
    );
  }
}

class ShuttleOptions extends StatefulWidget {
  final bool shuttleAvailable;
  ShuttleOptions({
    Key key,
    @required this.shuttleAvailable,
  }) : super(key: key);

  @override
  State<ShuttleOptions> createState() => _ShuttleOptionsState();
}

class _ShuttleOptionsState extends State<ShuttleOptions> {
  bool shuttleAvailable;

  @override
  void initState() {
    super.initState();
    shuttleAvailable = widget.shuttleAvailable ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Show me properties where",
        ),
        Expanded(
          child: Column(
            children: [
              SingleSelectTile(
                onTap: () {
                  shuttleAvailable = true;

                  Navigator.of(context).pop(shuttleAvailable);
                },
                selected: shuttleAvailable,
                asset: bus,
                text: "Only show me properties that have a Shuttle.",
              ),
              SingleSelectTile(
                onTap: () {
                  shuttleAvailable = false;

                  Navigator.of(context).pop(shuttleAvailable);
                },
                selected: !shuttleAvailable,
                asset: bedroom,
                text: "Show me those without a shuttle too",
              ),
              SingleSelectTile(
                onTap: () {
                  shuttleAvailable = null;

                  Navigator.of(context).pop(shuttleAvailable);
                },
                selected: shuttleAvailable == null,
                asset: lobby,
                text: "Remove shuttle from search results",
              )
            ],
          ),
        ),
      ],
    );
  }
}

class PetOptions extends StatefulWidget {
  final bool petsAllowed;
  PetOptions({
    Key key,
    @required this.petsAllowed,
  }) : super(key: key);

  @override
  State<PetOptions> createState() => _PetOptionsState();
}

class _PetOptionsState extends State<PetOptions> {
  bool petsAllowed;

  @override
  void initState() {
    super.initState();
    petsAllowed = widget.petsAllowed ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Show me properties where",
        ),
        Expanded(
          child: Column(
            children: [
              SingleSelectTile(
                onTap: () {
                  petsAllowed = true;

                  Navigator.of(context).pop(petsAllowed);
                },
                asset: pet,
                text: "Pets are allowed",
              ),
              SingleSelectTile(
                onTap: () {
                  petsAllowed = false;

                  Navigator.of(context).pop(petsAllowed);
                },
                asset: bedroom,
                text: "No Pets Allowed",
              ),
              SingleSelectTile(
                onTap: () {
                  petsAllowed = null;

                  Navigator.of(context).pop(petsAllowed);
                },
                asset: compound,
                text: "Disable pets from search parameters",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SpaceTypeOptions extends StatefulWidget {
  final String spaceType;
  SpaceTypeOptions({
    Key key,
    @required this.spaceType,
  }) : super(key: key);

  @override
  State<SpaceTypeOptions> createState() => _SpaceTypeOptionsState();
}

class _SpaceTypeOptionsState extends State<SpaceTypeOptions> {
  String spaceType;

  @override
  void initState() {
    super.initState();
    spaceType = widget.spaceType ?? ENTIREPLACE;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Show me properties whereby i get",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleSelectTile(
                  onTap: () {
                    setState(() {
                      spaceType = ENTIREPLACE;
                    });
                  },
                  asset: null,
                  text: "Entire Place",
                ),
                SingleSelectTile(
                  onTap: () {
                    setState(() {
                      spaceType = PRIVATEROOM;
                    });
                  },
                  asset: null,
                  text: "Private Room",
                ),
                SingleSelectTile(
                  onTap: () {
                    setState(() {
                      spaceType = SHAREDROOM;
                    });
                  },
                  asset: null,
                  text: "Shared Room",
                ),
              ],
            ),
          ),
        ),
        ProceedButton(
          text: "Proceed",
          onTap: () {
            Navigator.of(context).pop(spaceType);
          },
        )
      ],
    );
  }
}
