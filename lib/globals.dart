import 'package:faol_fuqarolar/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, String> currentLang;

void changeLang() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString('lang') == 'ru') {
    preferences.setString('lang', 'uz');
    currentLang = Languages.uzbek;
  } else {
    preferences.setString('lang', 'ru');
    currentLang = Languages.russian;
  }
}

void setLang() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString('lang') != null) {
    if (preferences.getString('lang') == 'ru') {
      currentLang = Languages.russian;
    } else {
      currentLang = Languages.uzbek;
    }
  }
}