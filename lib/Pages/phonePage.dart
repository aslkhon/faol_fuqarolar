import 'dart:async';
import 'dart:io';

import 'package:faol_fuqarolar/Notifications/serverSocket.dart';
import 'package:faol_fuqarolar/Pages/mainPage.dart';
import 'package:faol_fuqarolar/Pages/registrationPage.dart';
import 'package:faol_fuqarolar/Providers/auth.dart';
import 'package:faol_fuqarolar/Widgets/fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart' as globals;

import '../main.dart';

class PhonePage extends StatefulWidget {
  final step;

  @override
  _PhonePageState createState() => _PhonePageState(step: step);

  PhonePage({@required this.step});
}

class _PhonePageState extends State<PhonePage> {
  var phoneNumber;
  var offset = 230;
  var input;
  var text;
  bool isLoading = false;
  int counter;
  final codeController = TextEditingController();
  final controller = TextEditingController();
  MobileStep step;
  Timer _timer;

  // ignore: missing_return
  Future<bool> backward () {
    switch(step) {
      case MobileStep.code:
        setState(() {
          step = MobileStep.number;
          _timer.cancel();
        });
        break;
      case MobileStep.timeout:
        setState(() {
          step = MobileStep.number;
          _timer.cancel();
        });
        break;
      case MobileStep.wrong:
        setState(() {
          step = MobileStep.number;
          _timer.cancel();
        });
        break;
      case MobileStep.number:
        break;
    }
  }

  void startTimer() {
    counter = 90;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) counter--;
        else {
          counter = 0;
          _timer.cancel();
          step = MobileStep.timeout;
        }
      });
    });
  }

  chooseWords () {
    switch(step) {
      case MobileStep.number:
        return Text(
          globals.currentLang['StepNumber'],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.grey,
              fontSize: 16.0
          ),
        );
      case MobileStep.code:
        return RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(color: AppColors.grey, fontSize: 16.0, fontFamily: 'Open Sans'),
                children: [
                  TextSpan(
                      text: globals.currentLang['StepCodeOne']
                  ),
                  TextSpan(text: '+998 ' + phoneNumber,
                      style: TextStyle(color: AppColors.primary)
                  ),
                  TextSpan(
                      text: globals.currentLang['StepCodeTwo']
                  ),
                  TextSpan(text: '0:' + counter.toString(),
                      style: TextStyle(color: AppColors.primary)
                  ),
                  TextSpan(
                      text: globals.currentLang['StepCodeThree']
                  ),
                ]
            ));
      case MobileStep.timeout:
        return Text(
          globals.currentLang['StepTimeout'],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.process,
              fontSize: 16.0
          ),
        );
      case MobileStep.wrong:
        return Text(
          globals.currentLang['StepWrong'],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.reject,
              fontSize: 16.0
          ),
        );
    }
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    try {
      Auth().signUp('998$phoneNumber');
      step = MobileStep.code;
      codeController.clear();
      startTimer();
    } on HttpException {
    } catch (error) {
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> send(String code) async {
    setState(() {
      isLoading = true;
    });
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      int value = await Auth().verifyCode(int.parse(code), '998$phoneNumber');
      if (value == 200) {
        preferences.setString('phone', '998$phoneNumber');
        final SocketService socketService = injector.get<SocketService>();
        socketService.createSocketConnection();
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
      } else if (value == 202) {
        preferences.setString('phone', '998$phoneNumber');
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage())).then((value) {
          setState(() {
            step = MobileStep.number;
            _timer.cancel();
          });
        });
      }
    } on HttpException {
      counter = 0;
      _timer.cancel();
      step = MobileStep.wrong;
    } catch (error) {
      counter = 0;
      _timer.cancel();
      step = MobileStep.wrong;
    }
    setState(() {
      isLoading = false;
    });
  }

  chooseInput (TextEditingController controller) {
    switch(step) {
      case MobileStep.number:
        return MobileInput(
          isLoading: isLoading,
          onPressed: () {
            if (controller.text.length < 9 || controller.text.isEmpty) {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => AlertDialog(
                    content: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.exclamationCircle, color: AppColors.reject),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                              child: FittedBox(child: Text(globals.currentLang['NumberAlert']), fit: BoxFit.fitWidth,)
                          ),
                        )
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    ),
                  )
              );
            } else {
              phoneNumber = controller.text;
              _submit();
            }
          },
          controller: controller,
        );
      case MobileStep.code:
        if (isLoading) {
          return CircularProgressIndicator(
            backgroundColor: AppColors.primary,
          );
        }
        return AppPasswordInput(
          resend: false,
          enabled: true,
          controller: codeController,
          onPressed: () {
            send(codeController.text);
          },
        );
      case MobileStep.timeout:
        return AppPasswordInput(
            resend: true,
            enabled: false,
            onPressed: () {
              _submit();
            }
        );
      case MobileStep.wrong:
        return AppPasswordInput(
            resend: true,
            enabled: false,
            onPressed: () {
              _submit();
            }
        );
    }
  }

  _PhonePageState({@required this.step});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backward,
      child: Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.875,
                    margin: EdgeInsets.only(top: 82.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (step == MobileStep.number) ? Text('') : IconButton(
                            icon: FaIcon(FontAwesomeIcons.arrowAltCircleLeft),
                            color: AppColors.black,
                            iconSize: 32.0,
                            onPressed: backward
                        ),
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
                  SingleChildScrollView(
                    child: Container(
                        height: MediaQuery.of(context).size.height - offset,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/images/registration_logo.svg'),
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: chooseWords()
                            ),
                            Container(
                              child: chooseInput(controller),
                            )
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}

enum MobileStep {
  number, code, timeout, wrong
}
