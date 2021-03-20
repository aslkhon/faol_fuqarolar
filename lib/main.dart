import 'package:faol_fuqarolar/Notifications/appInitializer.dart';
import 'package:faol_fuqarolar/Notifications/dependencyInjection.dart';
import 'package:faol_fuqarolar/Notifications/serverSocket.dart';
import 'package:faol_fuqarolar/Pages/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'Pages/introPage.dart';
import 'globals.dart' as globals;
import 'languages.dart';

Injector injector;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ignore: deprecated_member_use
  DependencyInjection().initialize(Injector.getInjector());
  // ignore: deprecated_member_use
  injector = Injector.getInjector();
  await AppInitializer().initialise(injector);

  SharedPreferences preferences = await SharedPreferences.getInstance();
  String phone = preferences.getString('phone');
  if (phone != null) {
    final SocketService socketService = injector.get<SocketService>();
    socketService.createSocketConnection();
  }

  globals.setLang();

  runApp(MyApp(phone));
}

_setLangFirstTime() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString('lang') == null) {
    sharedPreferences.setString('lang', 'uz');
  }
}

class MyApp extends StatelessWidget {
  final String phoneNumber;
  const MyApp(this.phoneNumber);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    if (globals.currentLang == null) {
      globals.currentLang = Languages.uzbek;
      _setLangFirstTime();
    } else {
      globals.setLang();
    }
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Open Sans',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: phoneNumber == null ? IntroPage() : MainPage(),
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF06727D);
  static const Color black = Color(0xFF2C2C2C);
  static const Color grey = Color(0xFF969696);
  static const Color sent = Color(0xFF00BCD4);
  static const Color process = Color(0xFFFDD45A);
  static const Color success = Color(0xFF198754);
  static const Color reject = Color(0xFFDC3545);
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x19000000);
  static const Color background = Color(0xFFFCFCFF);
  static const Color chips = Color(0x40B8B8D1);
}