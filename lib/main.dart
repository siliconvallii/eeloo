import 'package:eeloo/screens/account_settings_screen.dart';
import 'package:eeloo/screens/info_screen.dart';
import 'package:eeloo/services/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:eeloo/screens/home_screen.dart';
import 'package:eeloo/screens/initial_screen.dart';
import 'package:eeloo/screens/sign_in_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// notification arrives when app is in background
Future<void> backgroundHanlder(RemoteMessage message) async {
  FlutterAppBadger.updateBadgeCount(1);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalNotificationService.initialize();

  MobileAds.instance.initialize();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(backgroundHanlder);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) {
      runApp(const Eeloo());
    },
  );
}

class Eeloo extends StatefulWidget {
  const Eeloo({Key? key}) : super(key: key);

  @override
  State<Eeloo> createState() => _EelooState();
}

class _EelooState extends State<Eeloo> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.getAPNSToken();

    // user taps notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage();

    // notification arrives when app is in foreground
    FirebaseMessaging.onMessage.listen(
      (message) {
        FlutterAppBadger.updateBadgeCount(1);
      },
    );

    // users taps notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        FlutterAppBadger.removeBadge();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterAppBadger.removeBadge();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/initial',
      routes: {
        '/home': (BuildContext context) => const HomeScreen(),
        '/initial': (BuildContext context) => const InitialScreen(),
        '/sign_in': (BuildContext context) => const SignInScreen(),
        '/account_settings': (BuildContext context) =>
            const AccountSettingsScreen(),
        '/info': (BuildContext context) => const InfoScreen(),
      },
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xff2E2E2E),
          centerTitle: true,
          elevation: 0,
          foregroundColor: const Color(0xffFFFFFF),
          titleTextStyle: GoogleFonts.alata(
            fontSize: 24,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xff121212),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xffBC91F8),
          onPrimary: Color(0xffFFFFFF),
          secondary: Color(0xff63D7C6),
          onSecondary: Color(0xffFFFFFF),
          error: Color(0xffFFFFFF),
          onError: Color(0xffDC143C),
          background: Color(0xff000000),
          onBackground: Color(0xffFFFFFF),
          surface: Color(0xff1E1E1E),
          onSurface: Color(0xffFFFFFF),
        ),
        textTheme: TextTheme(
          button: GoogleFonts.alata(),
        ),
      ),
    );
  }
}
