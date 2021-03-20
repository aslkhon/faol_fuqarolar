import 'package:faol_fuqarolar/Notifications/serverSocket.dart';
import 'package:faol_fuqarolar/Pages/mainPage.dart';
import 'package:faol_fuqarolar/Providers/auth.dart';
import 'package:faol_fuqarolar/Widgets/buttons.dart';
import 'package:faol_fuqarolar/Widgets/fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart' as globals;
import '../main.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();

  RegistrationPage();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController surname = TextEditingController();

  bool _isLoading = false;

  var borderName = false;
  var borderSurname = false;

  _RegistrationPageState();

  Future<void> _sendUser(String name, String surname) async {
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String phoneNumber = preferences.getString('phone');
      final int _status = await Auth().formUser(
          name, surname, phoneNumber
      );
      if (_status == 200) {
        final SocketService socketService = injector.get<SocketService>();
        socketService.createSocketConnection();
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              content: Row(
                children: [
                  FaIcon(FontAwesomeIcons.wifi, color: AppColors.reject),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(globals.currentLang['WifiAlert']),
                  )
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
              ),
            )
        );
      }
    } catch (error) {
      print(error);
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            content: Row(
              children: [
                FaIcon(FontAwesomeIcons.wifi, color: AppColors.reject),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(globals.currentLang['WifiAlert']),
                )
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
            ),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isLoading ? Center(
          child: CircularProgressIndicator(
            backgroundColor: AppColors.primary,
          ),
        ) : Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.875,
              margin: EdgeInsets.only(top: 82.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/images/logo_primary.svg'),
                  IconButton(
                    color: AppColors.black,
                    icon: FaIcon(FontAwesomeIcons.globe),
                    iconSize: 32.0,
                    onPressed: () {
                      setState(() {
                        globals.changeLang();
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height - 218,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(globals.currentLang['RegistrationLabel'], style: TextStyle(
                            fontSize: 32.0,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w900
                        ),),
                      ),
                      NameInput(controller: name, hint: globals.currentLang['HintName'], error: borderName),
                      NameInput(controller: surname, hint: globals.currentLang['HintSurname'], error: borderSurname),
                    ],
                  ),
                )
            ),
            ApplicationButton(
              onPressed: () {
                setState(() {
                  if (name.text.isEmpty) borderName = true; else borderName = false;
                  if (surname.text.isEmpty) borderSurname = true; else borderSurname = false;
                });
                if (name.text.isNotEmpty && surname.text.isNotEmpty) {
                  _sendUser(name.text, surname.text);
                }
              },
              text: globals.currentLang['IntroButton'],
              buttonStyle: AppButtonStyle.ButtonBlue,
            ),
          ],
        )
    );
  }
}