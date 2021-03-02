import 'dart:io';

import 'package:faol_fuqarolar/Widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:photo_view/photo_view.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import '../globals.dart' as globals;
import '../languages.dart';
import '../main.dart';
import 'mainPage.dart';

class AddProblemPage extends StatefulWidget {
  final File image;
  @override
  _AddProblemPageState createState() => _AddProblemPageState(image);

  AddProblemPage({this.image});
}

class _AddProblemPageState extends State<AddProblemPage> {
  final keyboardVisibilityController = KeyboardVisibilityController();
  final File image;

  _AddProblemPageState(this.image) {
    getLocation();
  }
  var paddingTop = 325.0;

  String _value = 'Tax';
  final items =  [
    DropdownMenuItem(
      child: Text('Tax'),
      value: 'Tax',
    ),
    DropdownMenuItem(
      child: Text('Building'),
      value: 'Building',
    ),
    DropdownMenuItem(
      child: Text('Building'),
      value: 'Buildib',
    ),
    DropdownMenuItem(
      child: Text('Building'),
      value: 'Buildib',
    ),
    DropdownMenuItem(
      child: Text('Building'),
      value: 'Buildib',
    ),
    DropdownMenuItem(
      child: Text('Buildin'),
      value: 'Buildib',
    )
  ];


  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardVisibilityController.onChange.listen((bool visible) {
      if(visible) paddingTop = 150; else paddingTop = 325;
    });
  }

  var locationString = '';

  getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    Future<List<Address>> _getAddress(double lat, double lang) async {
      final coordinates = new Coordinates(lat, lang);
      List<Address> add =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
      return add;
    }

    _getAddress(_locationData.latitude, _locationData.longitude).then((value) =>
        setState(() {
          locationString = value.first.addressLine;
        })
    );
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
                      imageProvider: AssetImage(image.path),
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
              child: AnimatedContainer(
                duration: Duration(milliseconds: 100),
                margin: EdgeInsets.only(top: paddingTop - 15),
                height: 16.0,
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
                ),
              )
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            margin: EdgeInsets.only(top: paddingTop),
            color: AppColors.background,
            height: MediaQuery.of(context).size.height - 325.0,
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.875,
                  height: 68.0,
                  margin: EdgeInsets.only(bottom: 32.0, top: 16.0),
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
                  child: SearchableDropdown.single(
                    items: items,
                    value: _value,
                    hint: globals.currentLang['AddProblemCategory'],
                    displayClearIcon: false,
                    underline: Container(),
                    searchHint: globals.currentLang['AddProblemCategory'],
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                    isExpanded: true,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.875,
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 6,
                            offset: Offset(0, 3)
                        )
                      ],
                      border: Border.all(color: AppColors.reject)
                  ),
                  child: TextField(
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: globals.currentLang['AddProblemHint'],
                      border: InputBorder.none,
                    ),
                    maxLines: 6,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.875,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: FaIcon(FontAwesomeIcons.mapMarkerAlt, color: AppColors.reject,), flex: 1,),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(locationString),
                          ),
                          flex: 5,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 88.0,
            left: MediaQuery.of(context).size.width * 0.0625,
            child: ApplicationButton(
              onPressed: () => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage())).then((value) => setState(() {}))
              },
              text: globals.currentLang['IntroButton'],
              buttonStyle: AppButtonStyle.ButtonBlue,
            ),
          ),
        ],
      ),
    );
  }
}