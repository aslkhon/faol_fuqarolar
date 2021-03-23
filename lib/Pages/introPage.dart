import 'package:faol_fuqarolar/Widgets/buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart' as globals;
import '../languages.dart';
import '../main.dart';
import 'phonePage.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();

  IntroPage();
}

enum ConfirmAction { CONFIRM, CANCEL }

class _IntroPageState extends State<IntroPage> {
  final linkStyle = TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold);
  var introRussian, introUzbek;

  String getIntro(String lang) {
    if (lang == 'uz') {
      if (globals.currentLang == Languages.uzbek) {
        return globals.currentLang['IntroWelcome'];
      } else {
        return '';
      }
    } else {
      if (globals.currentLang == Languages.russian) {
        return globals.currentLang['IntroWelcome'];
      } else {
        return '';
      }
    }
  }

  bool _checkVersion = false;

  void _versionCheck() async {
    setState(() {
      _checkVersion = true;
    });
    final NewVersion newVersion = NewVersion(context: context);
    VersionStatus versionStatus = await newVersion.getVersionStatus();
    if (versionStatus != null && versionStatus.canUpdate) {
      setState(() {
        _checkVersion = false;
      });
      await confirmDialog(
          context: context,
          title: globals.currentLang['PopupTitle'],
          body: Text(
            globals.currentLang['PopupBody'],
            style:
            TextStyle(color: Theme.of(context).textTheme.button.color),
          ),
          acceptButton: globals.currentLang['PopupButton'],
          cancelButton: globals.currentLang['PopupCancel'],)
          .then((ConfirmAction res) async {
        if (res == ConfirmAction.CONFIRM &&
            await canLaunch(versionStatus.appStoreLink)) {
          await launch(versionStatus.appStoreLink, forceWebView: false);
        }
      });
    }
    setState(() {
      _checkVersion = false;
    });
  }

  Future<ConfirmAction> confirmDialog(
      {BuildContext context,
        String title,
        Widget body,
        String acceptButton,
        String cancelButton}) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: <Widget>[
              Text(
                title,
                style:
                TextStyle(color: Theme.of(context).textTheme.button.color),
              )
            ],
          ),
          content: Wrap(
            runSpacing: 10,
            children: <Widget>[
              body,
            ],
          ),
          actions: <Widget>[
            MaterialButton(
              padding: EdgeInsets.all(6),
              child: Text(
                acceptButton,
                style:
                TextStyle(color: Theme.of(context).textTheme.button.color),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(ConfirmAction.CONFIRM);
              },
            ),
            MaterialButton(
              padding: EdgeInsets.all(6),
              child: Text(
                cancelButton,
                style:
                TextStyle(color: Theme.of(context).textTheme.button.color),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(ConfirmAction.CANCEL);
              },
            ),
          ],
        ),
      );

  @override
  void initState() {
    _versionCheck();
    super.initState();
  }

  DateTime currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          FlutterToast(context).showToast(
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.horizontal(
                  left: const Radius.circular(10.0),
                  right: const Radius.circular(10.0),
                ),
              ),
              child: Text(
                globals.currentLang['Exit'],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            toastDuration: Duration(seconds: 2),
          );
          currentBackPressTime = now;
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.primary,
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.875,
                margin: EdgeInsets.only(top: 82.0),
                alignment: Alignment.bottomRight,
                child: IconButton(
                  color: AppColors.white,
                  icon: FaIcon(FontAwesomeIcons.globe),
                  iconSize: 32.0,
                  onPressed: () {
                    setState(() {
                      globals.changeLang();
                    });
                  },
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height - 291,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                        child: Text(getIntro('ru'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: AppColors.white)),
                      ),
                      _checkVersion ? Center(child: CircularProgressIndicator(backgroundColor: AppColors.primary,)) : SvgPicture.asset('assets/images/logo_white.svg'),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                        child: Text(getIntro('uz'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: AppColors.white)),
                      )
                    ],
                  )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(color: AppColors.white, fontSize: 14.0, fontFamily: 'Open Sans'),
                      children: [
                        TextSpan(text: globals.currentLang['IntroFirstLine']),
                        TextSpan(
                            text: globals.currentLang['IntroPrivacy'],
                            style: linkStyle,
                            recognizer: TapGestureRecognizer()..onTap =  () async{
                              var url = "https://faol-fuqarolar.uz/privacy.html";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }
                        ),
                        TextSpan(text: globals.currentLang['IntroAnd']),
                        TextSpan(
                            text: globals.currentLang['IntroTerms'],
                            style: linkStyle,
                            recognizer: TapGestureRecognizer()..onTap =  () async{
                              var url = "https://faol-fuqarolar.uz/terms.html";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }
                        ),
                        TextSpan(text: globals.currentLang['IntroLastLine']),
                      ]
                  ),
                ),
              ),
              ApplicationButton(
                onPressed: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PhonePage(step: MobileStep.number))).then((value) => setState(() {}))
                },
                text: globals.currentLang['IntroButton'],
                buttonStyle: AppButtonStyle.ButtonWhite,
              ),
            ],
          )
      ),
    );
  }
}