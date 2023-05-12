import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({Key key}) : super(key: key);

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);

    nameController = TextEditingController();
    nameController.addListener(() {
      if (nameController.text.trim().isEmpty) {
        setState(() {
          enabled = false;
        });
      } else {
        setState(() {
          enabled = true;
        });
      }
    });
  }

  TextEditingController nameController = TextEditingController();
  bool enabled = false;
  Box box;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            showIcon: false,
            icon: null,
            onPressed: () {},
            text: "",
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translation(context).heyThere,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        translation(context).whatsYourName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: translation(context).typeHere,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ProceedButton(
            onTap: () {
              context.pushNamed(
                RouteConstants.onboarding2,
                params: {
                  "name": nameController.text.trim(),
                },
              );
            },
            text: translation(context).pressHereToProceed,
            enabled: enabled,
          ),
        ],
      ),
      bottomNavigationBar: Wrap(
        children: [
          OrDivider(),
          ProceedButton(
            onTap: () {
              UIServices().showLoginSheet(
                (id) {
                  FirebaseFirestore.instance
                      .collection(UserModel.DIRECTORY)
                      .doc(id)
                      .get()
                      .then(
                    (value) {
                      UserModel userModel = UserModel.fromSnapshot(value);

                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );

                      if (userModel.university != null) {
                        box.put(
                          UserModel.UNIVERSITY,
                          userModel.university,
                        );
                      }

                      box.put(
                        DorxSettings.FINISHEDONBOARDING,
                        true,
                      );

                      context.pushReplacementNamed(
                        RouteConstants.home,
                      );
                    },
                  );
                },
                context,
              );
            },
            text: translation(context).signIn,
          ),
        ],
      ),
    );
  }
}

class Onboarding2 extends StatefulWidget {
  final String name;
  const Onboarding2({
    Key key,
    @required this.name,
  }) : super(key: key);

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  String name;
  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
    name = widget.name ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: () {
              if (context.canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pushReplacementNamed(
                  RouteConstants.onboarding1,
                );
              }
            },
            text: "${translation(context).heyThere} $name",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    translation(context).welcomeToDorxHomes,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    translation(context).selectAnOption,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: RowSelector(
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.onboarding3,
                                params: {
                                  "name": name,
                                },
                              );
                            },
                            selected: false,
                            text: translation(context).imAStudent,
                          ),
                        ),
                        Expanded(
                          child: RowSelector(
                            onTap: () {
                              if (context.canPop()) {
                                Navigator.of(context).pop();
                              }

                              box.put(
                                UserModel.USERNAME,
                                name,
                              );

                              box.put(
                                DorxSettings.FINISHEDONBOARDING,
                                true,
                              );

                              context.pushReplacementNamed(
                                RouteConstants.home,
                                queryParams: {
                                  "showDialog": "true",
                                },
                              );
                            },
                            selected: false,
                            text: translation(context).imNotAStudent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Wrap(
        children: [
          OrDivider(),
          ProceedButton(
            onTap: () {
              UIServices().showLoginSheet(
                (id) {
                  FirebaseFirestore.instance
                      .collection(UserModel.DIRECTORY)
                      .doc(id)
                      .get()
                      .then(
                    (value) {
                      UserModel userModel = UserModel.fromSnapshot(value);

                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );

                      if (userModel.university != null) {
                        box.put(
                          UserModel.UNIVERSITY,
                          userModel.university,
                        );
                      }

                      box.put(
                        DorxSettings.FINISHEDONBOARDING,
                        true,
                      );

                      context.pushReplacementNamed(
                        RouteConstants.home,
                      );
                    },
                  );
                },
                context,
              );
            },
            text: translation(context).signIn,
          ),
        ],
      ),
    );
  }
}

class Onboarding3 extends StatefulWidget {
  final String name;
  const Onboarding3({
    Key key,
    @required this.name,
  }) : super(key: key);

  @override
  State<Onboarding3> createState() => _Onboarding3State();
}

class _Onboarding3State extends State<Onboarding3> {
  String selectedUniversity;
  String name;
  bool searchVisible = false;
  bool searching = false;
  List<SearchResult> results = [];

  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
    name = widget.name ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: () {
              if (context.canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pushReplacementNamed(
                  RouteConstants.onboarding1,
                );
              }
            },
            text: "$name, ${translation(context).whichUniversityAreYou}?",
          ),
          Expanded(
            child: Stack(
              children: [
                PaginateFirestore(
                  header: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        InformationalBox(
                          visible: true,
                          onClose: null,
                          message: translation(context).tapYourUniversity,
                        ),
                        if (selectedUniversity != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Text(
                              translation(context).yourSelectedUniversity,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (selectedUniversity != null)
                          SingleSchool(
                            school: null,
                            onTap: () {
                              setState(() {
                                selectedUniversity = null;
                              });
                            },
                            selected: true,
                            schoolID: selectedUniversity,
                          ),
                        if (selectedUniversity != null) Divider(),
                        if (selectedUniversity == null)
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomDialogBox(
                                      bodyText: translation(context)
                                          .weDontAdviseSkippingUni,
                                      buttonText: translation(context)
                                          .iUnderstandSkipUniversitySelection,
                                      onButtonTap: () {
                                        finish(null);
                                      },
                                      showOtherButton: true,
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child:
                                    Text(translation(context).skipUniversity),
                              ),
                            ),
                          ),
                        if (selectedUniversity == null) Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Text(
                            translation(context).allOurUniversities,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isLive: true,
                  itemBuilderType: PaginateBuilderType.listView,
                  itemBuilder: (context, snapshot, index) {
                    SchoolModel school =
                        SchoolModel.fromSnapshot(snapshot[index]);

                    return SingleSchool(
                      school: school,
                      onTap: () {
                        setState(() {
                          selectedUniversity = selectedUniversity == school.id
                              ? null
                              : school.id;
                        });
                      },
                      selected: selectedUniversity == school.id,
                      schoolID: school.id,
                    );
                  },
                  query: FirebaseFirestore.instance
                      .collection(SchoolModel.DIRECTORY)
                      .orderBy(
                        SchoolModel.NAME,
                      ),
                ),
                FloatingSearchWidget(
                  searchVisible: searchVisible,
                  toggleSearchVisible: () {
                    setState(() {
                      searchVisible = !searchVisible;
                    });
                  },
                  results: results,
                  searching: searching,
                  clearList: () {
                    setState(() {
                      searching = false;

                      results.clear();
                    });
                  },
                  search: (v) async {
                    setState(() {
                      searching = true;
                    });

                    results.clear();

                    List<AlgoliaObjectSnapshot> pp =
                        await SearchServices().search(v, allIndex);

                    if (pp.isNotEmpty) {
                      for (var element in pp) {
                        if (element.data["type"] == ThingType.SCHOOL) {
                          SchoolModel schoolModel = SchoolModel.fromMap(
                            element.objectID,
                            element.data,
                          );

                          results.add(
                            SearchResult.fromData(
                              title: schoolModel.name,
                              onTap: () {
                                setState(() {
                                  results.clear();
                                  searching = false;
                                  searchVisible = false;
                                  selectedUniversity = schoolModel.id;
                                });
                              },
                              description: schoolModel.motto,
                              icon: Icons.school,
                              image: schoolModel.image,
                            ),
                          );
                        }
                      }

                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          if (selectedUniversity != null)
            ProceedButton(
              text: translation(context).pressHereToProceed,
              onTap: () {
                finish(selectedUniversity);
              },
            )
        ],
      ),
      bottomNavigationBar: Wrap(
        children: [
          OrDivider(),
          ProceedButton(
            onTap: () {
              UIServices().showLoginSheet(
                (id) {
                  FirebaseFirestore.instance
                      .collection(UserModel.DIRECTORY)
                      .doc(id)
                      .get()
                      .then(
                    (value) {
                      UserModel userModel = UserModel.fromSnapshot(value);

                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );

                      if (userModel.university != null) {
                        box.put(
                          UserModel.UNIVERSITY,
                          userModel.university,
                        );
                      }

                      box.put(
                        DorxSettings.FINISHEDONBOARDING,
                        true,
                      );

                      context.pushReplacementNamed(
                        RouteConstants.home,
                      );
                    },
                  );
                },
                context,
              );
            },
            text: translation(context).signIn,
          ),
        ],
      ),
    );
  }

  finish(String university) {
    box.put(
      UserModel.USERNAME,
      name,
    );

    if (university != null) {
      box.put(
        UserModel.UNIVERSITY,
        university,
      );
    }

    box.put(
      DorxSettings.FINISHEDONBOARDING,
      true,
    );

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );

    context.pushReplacementNamed(
      RouteConstants.home,
      queryParams: {
        "showDialog": "true",
      },
    );
  }
}
