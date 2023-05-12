import 'package:dorx/services/new_routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dorx/theming/theme_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'constants/constants.dart';
import 'models/models.dart';
import 'services/auth_service.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(DorxSettings.DORXBOXNAME);
  await Hive.openBox(DorxSettings.SEARCHHISTORY);
  final configurations = Configurations();

  await Firebase.initializeApp(
    name: capitalizedAppName,
    options: FirebaseOptions(
      databaseURL: configurations.databaseUrl,
      apiKey: configurations.apiKey,
      storageBucket: configurations.storageBucket,
      appId: configurations.appId,
      messagingSenderId: configurations.senderID,
      projectId: configurations.projectId,
    ),
  );

  await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale newlocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.changeLocale(newlocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale("en", "");
  Box box;

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    box = Hive.box(DorxSettings.DORXBOXNAME);

    getSavedLocaleFromPrefs(box).then((locale) => {changeLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: AuthService(),
      child: ThemeBuilder(
        builder: (context, brightness) {
          return OverlaySupport(
            child: MaterialApp.router(
              locale: _locale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                FallbackLocalizationDelegate(),
                FallbackSoCupertinoDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              title: capitalizedAppName,
              theme: ThemeData(
                scrollbarTheme: ScrollbarThemeData(
                  radius: Radius.circular(borderDouble),
                  thumbVisibility: MaterialStateProperty.all(true),
                  interactive: true,
                  thickness: MaterialStateProperty.all(8),
                  thumbColor: MaterialStateProperty.all(
                    primaryColor,
                  ),
                ),
                brightness: brightness,
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  foregroundColor: Colors.white,
                  backgroundColor: altColor,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  contentPadding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 10,
                    right: 10,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: altColor,
                    ),
                    borderRadius: standardBorderRadius,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: altColor,
                    ),
                    borderRadius: standardBorderRadius,
                  ),
                ),
                primarySwatch: primaryColor,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: altColor,
                ),
              ),
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}

class FallbackLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      DefaultMaterialLocalizations();
  @override
  bool shouldReload(old) => false;
}

class FallbackSoCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      DefaultCupertinoLocalizations();
  @override
  bool shouldReload(old) => false;
}
