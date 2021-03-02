import 'package:faol_fuqarolar/Models/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:photo_view/photo_view.dart';
import '../globals.dart' as globals;

import '../main.dart';
import 'mainPage.dart';

class ViewProblemPage extends StatefulWidget {
  final problem;

  @override
  _ViewProblemPageState createState() => _ViewProblemPageState(problem: problem);

  ViewProblemPage({this.problem});
}

class _ViewProblemPageState extends State<ViewProblemPage> {
  final problem;
  _ViewProblemPageState({this.problem});

  FaIcon getIcon() {
    IconData icon;
    switch (problem.status) {
      case Status.sent:
        icon = FontAwesomeIcons.paperPlane;
        break;
      case Status.process:
        icon = FontAwesomeIcons.spinner;
        break;
      case Status.success:
        icon = FontAwesomeIcons.checkCircle;
        break;
      case Status.reject:
        icon = FontAwesomeIcons.timesCircle;
        break;
    }
    return FaIcon(icon, color: AppColors.white, size: 32.0);
  }

  String getText() {
    String text;
    switch (problem.status) {
      case Status.sent:
        text = globals.currentLang['ViewStatusSent'];
        break;
      case Status.process:
        text = globals.currentLang['ViewStatusProcess'];
        break;
      case Status.success:
        text = globals.currentLang['ViewStatusSuccess'];
        break;
      case Status.reject:
        text = globals.currentLang['ViewStatusReject'];
        break;
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 325.0,
            child: FullScreenWidget(
              child: Hero(
                tag: 'smallImage',
                child: ClipRRect(
                  child: Container(
                    child: PhotoView(
                      imageProvider: problem.image,
                      customSize: MediaQuery.of(context).size,
                      backgroundDecoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 82.0,
            left: MediaQuery.of(context).size.width * 0.0625,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.875,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: FaIcon(FontAwesomeIcons.arrowAltCircleLeft),
                      color: AppColors.white,
                      iconSize: 32.0,
                      onPressed: () {
                        Navigator.pop(context);
                      }
                  ),
                  IconButton(
                    color: AppColors.white,
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
          ),
          Positioned(
              child: Container(
                margin: EdgeInsets.only(top: 310.0),
                height: 16.0,
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
                ),
              )
          ),
          Container(
            margin: EdgeInsets.only(top: 325.0),
            color: AppColors.background,
            height: MediaQuery.of(context).size.height - 325.0,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.0625,
                      top: 16.0,
                      right: MediaQuery.of(context).size.width * 0.0625,
                    ),
                    child: Row(
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
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 36.0, horizontal: (MediaQuery.of(context).size.width * 0.0625)),
                          child: Text(
                            problem.text,
                            style: TextStyle(
                                color: AppColors.black,
                                fontSize: 16.0
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: Center(
                        child: SvgPicture.asset('assets/images/logo_semitransparent.svg')
                    ),
                  ),
                  Container(
                    height: 80.0,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0625),
                    color: MainPage.getColor(problem.status),
                    child: Row(
                      children: [
                        Container(
                          child: getIcon(),
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.025),
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Text(getText(), style: TextStyle(
                                color: AppColors.white
                            ),)
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.mapMarkerAlt, color: AppColors.reject),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(problem.location),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}