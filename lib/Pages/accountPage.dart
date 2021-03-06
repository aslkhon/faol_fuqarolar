import 'package:faol_fuqarolar/Providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart' as globals;

import '../Widgets/buttons.dart';
import '../main.dart';
import 'introPage.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();

  AccountPage();
}

class _AccountPageState extends State<AccountPage> {
  var name = "";
  var surname = "";
  var phoneNumber = "";

  _AccountPageState();

  getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    name = preferences.getString('name');
    surname = preferences.getString('surname');
    phoneNumber = '+' + preferences.getString('phone');
    setState(() {});
  }

  @override
  void initState() {
    getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.875,
              margin: EdgeInsets.only(top: 82.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: FaIcon(FontAwesomeIcons.arrowAltCircleLeft),
                      color: AppColors.black,
                      iconSize: 32.0,
                      onPressed: () {
                        Navigator.pop(context);
                      }
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
            Container(
                height: MediaQuery.of(context).size.height - 218,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: SvgPicture.asset('assets/images/logo.svg'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 4.0),
                        child: Text(
                          name + ' ' + surname,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.grey
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 64.0),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              width: MediaQuery.of(context).size.width * 0.875,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    globals.currentLang['AccountContact'],
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14.0
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  GestureDetector(
                                    onTap: () async{
                                      var url = 'mailto://shrashidov@jizzax.uz';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('shrashidov@jizzax.uz')
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async{
                                      var url = 'tel://+998723421018';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text('Telefon: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('+998 72 342-10-18')
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.shadow,
                                          width: 1.0
                                      )
                                  )
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              width: MediaQuery.of(context).size.width * 0.875,
                              child: GestureDetector(
                                onTap: () async{
                                  var url = "https://faol-fuqarolar.uz/privacy.html";
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: Text(
                                        globals.currentLang['AccountPrivacy'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            decoration: TextDecoration.underline,
                                            fontSize: 14.0
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.externalLinkAlt,
                                        color: AppColors.primary,
                                        size: 18.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.shadow,
                                          width: 1.0
                                      )
                                  )
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              width: MediaQuery.of(context).size.width * 0.875,
                              child: GestureDetector(
                                onTap: () async{
                                  var url = "https://faol-fuqarolar.uz/terms.html";
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    child: Text(
                                        globals.currentLang['AccountTerms'],
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            decoration: TextDecoration.underline,
                                            fontSize: 14.0
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.externalLinkAlt,
                                        color: AppColors.primary,
                                        size: 18.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.shadow,
                                          width: 1.0
                                      )
                                  )
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
            ),
            ApplicationButton(
              onPressed: () {
                Auth().logOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
              },
              text: globals.currentLang['AccountButton'],
              buttonStyle: AppButtonStyle.ButtonWhite,
            ),
          ],
        )
    );
  }
}