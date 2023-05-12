import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/single_select_tile.dart';
import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../main.dart';
import '../models/models.dart';

class LanguageChangerBottomSheet extends StatefulWidget {
  const LanguageChangerBottomSheet({Key key}) : super(key: key);

  @override
  State<LanguageChangerBottomSheet> createState() =>
      _LanguageChangerBottomSheetState();
}

class _LanguageChangerBottomSheetState
    extends State<LanguageChangerBottomSheet> {
  Box box;
  Locale ll = Locale(Language.languageList()[0].languageCode);

  @override
  void didChangeDependencies() {
    box = Hive.box(DorxSettings.DORXBOXNAME);

    getSavedLocaleFromPrefs(box).then((locale) {
      setState(() {
        ll = locale;
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Change language",
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: Language.languageList()
                  .map(
                    (e) => SingleSelectTile(
                      icon: Text(
                        e.flag,
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      text: e.name.capitalizeFirstOfEach,
                      onTap: () async {
                        Locale locale = await saveLocaleToPrefs(e.languageCode, box);

                        MyApp.setLocale(context, locale);

                        setState(() {
                          ll = Locale(
                            e.languageCode,
                          );
                        });
                      },
                      selected: ll.languageCode == e.languageCode,
                    ),
                  )
                  .toList(),
            ),
          ))
        ],
      ),
    );
  }
}
