import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:faol_fuqarolar/Providers/request.dart';
import 'package:faol_fuqarolar/languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;

import '../main.dart';
import 'mainPage.dart';

class ViewProblemPage extends StatefulWidget {
  final problem;

  @override
  _ViewProblemPageState createState() => _ViewProblemPageState(problem: problem);

  ViewProblemPage({this.problem});
}

class _ViewProblemPageState extends State<ViewProblemPage> {
  RequestItem problem;
  _ViewProblemPageState({this.problem});

  FaIcon getIcon() {
    IconData icon;
    switch (problem.statusId) {
      case 1:
        icon = FontAwesomeIcons.paperPlane;
        break;
      case 2:
        icon = FontAwesomeIcons.spinner;
        break;
      case 3:
        icon = FontAwesomeIcons.checkCircle;
        break;
      case 4:
        icon = FontAwesomeIcons.timesCircle;
        break;
    }
    return FaIcon(icon, color: AppColors.white, size: 32.0);
  }

  String getText() {
    String text;
    switch (problem.statusId) {
      case 1:
        text = globals.currentLang['ViewStatusSent'];
        break;
      case 2:
        text = globals.currentLang['ViewStatusProcess'] + ' ' + organization;
        break;
      case 3:
        text = globals.currentLang['ViewStatusSuccess'];
        break;
      case 4:
        text = globals.currentLang['ViewStatusReject'];
        break;
    }
    return text;
  }

  bool isLoading = false;
  String organization = 'default';
  String solvedImage;
  bool solvedLoading = false;

  Future<void> _getSolvedImage(int id, int statusId) async {
    setState(() {
      if (statusId == 2)
        isLoading = true;
      else
        solvedLoading = true;
    });
    final _prefs = await SharedPreferences.getInstance();
    final phoneNumber = _prefs.getString("phone");
    final _token = _prefs.getString("token");
    var url =
        'http://api.faol-fuqarolar.uz/api/requests/$id?lang=uz&phone=$phoneNumber';
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });
      String lang = "name";
      if (globals.currentLang == Languages.uzbek) {
        lang = "name";
      } else {
        lang = "name_ru";
      }
      final extractedData = json.decode(response.body);
      print(extractedData['organization'][lang]);
      setState(() {
        if (statusId == 2) {
          organization = extractedData['organization'][lang];
          isLoading = false;
        } else {
          solvedImage = extractedData['comments'][extractedData['comments'].length - 1]['image']['imageUrl'];
          solvedLoading = false;
        }
      });
    } catch (error) {
      throw (error);
    }
  }

  @override
  void initState() {
    if (problem.statusId == 2 || problem.statusId == 3) {
      _getSolvedImage(problem.id, problem.statusId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 325.0,
            child: problem.statusId == 3 ? FullScreenWidget(
              child: Hero(
                tag: 'customTag',
                child: ClipRRect(
                  child: Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 325.0,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                      ),
                      items: [
                        PhotoView(
                          imageProvider: NetworkImage(
                            problem.image.imageUrl,
                          ),
                          customSize: MediaQuery.of(context).size,
                          backgroundDecoration: BoxDecoration(color: Colors.transparent),
                        ),
                         solvedLoading ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: AppColors.primary,
                          ),
                        ) : Stack(
                          children: [
                            PhotoView(
                              imageProvider: NetworkImage(
                                solvedImage,
                              ),
                              customSize: MediaQuery.of(context).size,
                              backgroundDecoration: BoxDecoration(color: Colors.transparent),
                            ),
                            Positioned(
                              top: 270.0,
                              child: Container(
                                padding: const EdgeInsets.only(left: 24.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    globals.currentLang['Result'],
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16.0)
                                ),
                                ),
                              ),
                            )
                          ],
                        )
                      ]
                    ),
                  ),
                ),
              ),
            ) : FullScreenWidget(
              child: Hero(
                tag: 'newImage',
                child: ClipRRect(
                  child: Container(
                    child: PhotoView(
                      imageProvider: NetworkImage(
                        problem.image.imageUrl,
                      ),
                      customSize: MediaQuery.of(context).size,
                      backgroundDecoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            )
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
                              Text(DateFormat("d MMMM HH:mm").format(DateTime.parse(problem.createdAt)),
                                  style: TextStyle(fontWeight: FontWeight.bold))
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
                          child: Text(MainPage.getCategory(problem), style: TextStyle(fontWeight: FontWeight.bold)),
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
                            problem.description,
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
                    color: MainPage.getColor(problem.statusId),
                    child: Row(
                      children: [
                        Container(
                          child: getIcon(),
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.025),
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: isLoading ? Center(child: CircularProgressIndicator(backgroundColor: AppColors.white,)) : Text(getText(), style: TextStyle(
                                color: AppColors.white),),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: FaIcon(FontAwesomeIcons.mapMarkerAlt, color: AppColors.reject,), flex: 1,),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(problem.addressMap),
                          ),
                          flex: 5,
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