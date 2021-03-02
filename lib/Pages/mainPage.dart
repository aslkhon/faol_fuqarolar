import 'dart:io';

import 'package:faol_fuqarolar/Models/problem.dart';
import 'package:faol_fuqarolar/Pages/viewProblemPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../globals.dart' as globals;
import '../main.dart';
import 'accountPage.dart';
import 'addProblemPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();

  static Color getColor(Status status) {
    Color color;
    switch (status) {
      case Status.sent:
        color = AppColors.sent;
        break;
      case Status.process:
        color = AppColors.process;
        break;
      case Status.success:
        color = AppColors.success;
        break;
      case Status.reject:
        color = AppColors.reject;
        break;
    }
    return color;
  }

  MainPage();
}

class _MainPageState extends State<MainPage> {
  ListStatus status = ListStatus.all;
  final List<Problem> allProblems = [];
  final List<Problem> sent = [];
  final List<Problem> process = [];
  final List<Problem> success = [];
  final List<Problem> reject = [];

  File _image;
  final picker = ImagePicker();
  bool isLoading = false;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddProblemPage(image: _image))).then((value) => setState(() {}));
  }

  _MainPageState() {
    for (int i = 0; i < 5; i++) {
      allProblems.add(
          Problem(
              status: Status.reject,
              text: "Mahallaga kirishda o'rnatilgan ...",
              location: "Sharof Rashidov tumani, Ilgar ko'chasi 27",
              category: "Ichimlik Suvi",
              time: Time(year: 2021, month: Month.February, day: 25, hour: 14, minute: 20),
              image: AssetImage('assets/images/image.jpg')
          )
      );
    }
    for (int i = 0; i < 3; i++) {
      sent.add(
          Problem(
              status: Status.sent,
              text: "Mahallaga kirishda o'rnatilgan ...",
              location: "Sharof Rashidov tumani, Ilgar ko'chasi 27",
              category: "Ichimlik Suvi",
              time: Time(year: 2021, month: Month.February, day: 25, hour: 14, minute: 20),
              image: AssetImage('assets/images/image.jpg')
          )
      );
    }
    for (int i = 0; i < 6; i++) {
      process.add(
          Problem(
              status: Status.process,
              text: "Mahallaga kirishda o'rnatilgan ...",
              location: "Sharof Rashidov tumani, Ilgar ko'chasi 27",
              category: "Ichimlik Suvi",
              time: Time(year: 2021, month: Month.February, day: 25, hour: 14, minute: 20),
              image: AssetImage('assets/images/image.jpg')
          )
      );
    }
    for (int i = 0; i < 3; i++) {
      success.add(
          Problem(
              status: Status.success,
              text: "Mahallaga kirishda o'rnatilgan ...",
              location: "Sharof Rashidov tumani, Ilgar ko'chasi 27",
              category: "Ichimlik Suvi",
              time: Time(year: 2021, month: Month.February, day: 25, hour: 14, minute: 20),
              image: AssetImage('assets/images/image.jpg')
          )
      );
    }
    for (int i = 0; i < 3; i++) {
      reject.add(
          Problem(
              status: Status.reject,
              text: "Mahallaga kirishda o'rnatilgan ...",
              location: "Sharof Rashidov tumani, Ilgar ko'chasi 27",
              category: "Ichimlik Suvi",
              time: Time(year: 2021, month: Month.February, day: 25, hour: 14, minute: 20),
              image: AssetImage('assets/images/image.jpg')
          )
      );
    }
  }

  ListStatus _value = ListStatus.all;

  TextStyle getTextStyle(ListStatus listStatus) {
    Color color;
    switch(listStatus) {
      case ListStatus.all:
        color = AppColors.primary;
        break;
      case ListStatus.sent:
        color = AppColors.sent;
        break;
      case ListStatus.process:
        color = AppColors.process;
        break;
      case ListStatus.success:
        color = AppColors.success;
        break;
      case ListStatus.reject:
        color = AppColors.reject;
        break;
    }
    return TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20.0);
  }

  // ignore: missing_return
  List<Problem> getProblems() {
    switch (_value) {
      case ListStatus.all:
        return allProblems;
      case ListStatus.sent:
        return sent;
      case ListStatus.process:
        return process;
      case ListStatus.success:
        return success;
      case ListStatus.reject:
        return reject;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.875,
              margin: EdgeInsets.only(top: 82.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/images/logo_primary.svg'),
                  Row(
                    children: [
                      IconButton(
                        color: AppColors.black,
                        icon: FaIcon(FontAwesomeIcons.userCircle),
                        iconSize: 32.0,
                        onPressed: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage())).then((value) => setState(() {}))
                        },
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
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.875,
              height: 56.0,
              margin: EdgeInsets.symmetric(vertical: 32.0),
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 3)
                    )
                  ]
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: _value,
                    elevation: 3,
                    dropdownColor: AppColors.white,
                    items: [
                      DropdownMenuItem(
                        child: Text(globals.currentLang['StatusOne'], style: getTextStyle(ListStatus.all)),
                        value: ListStatus.all,
                      ),
                      DropdownMenuItem(
                        child: Text(globals.currentLang['StatusTwo'], style: getTextStyle(ListStatus.sent)),
                        value: ListStatus.sent,
                      ),
                      DropdownMenuItem(
                          child: Text(globals.currentLang['StatusThree'], style: getTextStyle(ListStatus.process)),
                          value: ListStatus.process
                      ),
                      DropdownMenuItem(
                          child: Text(globals.currentLang['StatusFour'], style: getTextStyle(ListStatus.success)),
                          value: ListStatus.success
                      ),
                      DropdownMenuItem(
                          child: Text(globals.currentLang['StatusFive'], style: getTextStyle(ListStatus.reject)),
                          value: ListStatus.reject
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    }),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 250.0,
              child: (isLoading) ? CircularProgressIndicator(
                backgroundColor: AppColors.primary,
              ) : ListView.builder(
                padding: EdgeInsets.only(bottom: 64.0),
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: getProblems().length,
                itemBuilder: (context, index) {
                  final problem = getProblems()[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0625, vertical: 8.0),
                    child: Container(
                      height: 96.0,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6 ,
                              offset: Offset(0, 3)
                          )
                        ],
                      ),
                      child: RawMaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProblemPage(problem: problem))).then((value) => setState(() {}));
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 96.0,
                              width: 8.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                                  color: MainPage.getColor(problem.status)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    problem.text,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0
                                    ),
                                  ),
                                  Text(
                                    problem.location,
                                    style: TextStyle(
                                        fontSize: 12.0
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 6.0),
                                        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                                        decoration: BoxDecoration(
                                            color: AppColors.chips,
                                            borderRadius: BorderRadius.circular(16.0)
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: FaIcon(FontAwesomeIcons.clock, size: 12.0),
                                            ),
                                            Text(problem.time.getString(globals.currentLang), style: TextStyle(fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 6.0, left: 8.0),
                                        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                                        decoration: BoxDecoration(
                                            color: AppColors.chips,
                                            borderRadius: BorderRadius.circular(16.0)
                                        ),
                                        child: Text(problem.category, style: TextStyle(fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 3)
                  )
                ]
            ),
            child: FlatButton(
              color: AppColors.primary,
              child: FaIcon(
                FontAwesomeIcons.camera,
                color: AppColors.white,
              ),
              onPressed: () {
                getImage();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)
              ),
            ),
          ),
        )
    );
  }
}

enum ListStatus {
  all, sent, process, success, reject
}