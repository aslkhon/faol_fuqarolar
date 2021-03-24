import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:faol_fuqarolar/Providers/auth.dart';
import 'package:faol_fuqarolar/Widgets/buttons.dart';
import 'package:faol_fuqarolar/languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../main.dart';
import 'mainPage.dart';

class AddProblemPage extends StatefulWidget {
  final String imagePath;
  @override
  _AddProblemPageState createState() => _AddProblemPageState(imagePath);

  AddProblemPage({this.imagePath});
}

class _AddProblemPageState extends State<AddProblemPage> {
  final String imagePath;
  List data;
  List mahalla_id;
  TextEditingController controller = TextEditingController();

  _AddProblemPageState(this.imagePath);
  var paddingTop = 325.0;

  String _value;
  String _mahalla;

  List<DropdownMenuItem> items = [];
  List<DropdownMenuItem> mahallas = [];

  Future<void> _send() async {
    setState(() {
      isLoading = true;
    });
    int _id;
    data.forEach((element) {
      if (element[_getLang()] == _value) {
        _id = element['id'];
      }
    });
    int _mahallaId;
    mahalla_id.forEach((element) {
      if (element[_getLang()] == _mahalla) {
        _mahallaId = element['id'];
      }
    });
    print(mahalla_id);
    print(' ${_mahallaId}');
    try {
      await Auth().sentMessage(
        description: controller.text,
        lat: latX,
        lng: longX,
        categoryId: _id,
        mahallaId: _mahallaId,
        imagePath: imagePath
      ).then((value) {
        print(value);
        if (value == 200) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
          showDialog(
            context: this.context,
            builder: (ctx) {
              return AlertDialog(
                content: Container(
                  height: 180.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 64.0,
                        width: 64.0,
                        child: FittedBox(
                            fit: BoxFit.contain,
                            child: FaIcon(FontAwesomeIcons.checkCircle, size: 24.0, color: AppColors.success),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(globals.currentLang['Confirm'], textAlign: TextAlign.center,),
                        ),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Ok'),
                  )
                ],
              );
            },
          );
        }
      });
    } catch (error) {
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getData() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    var url = 'https://api.faol-fuqarolar.uz/api/categories';
    var response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    data = json.decode(response.body);

    items.clear();
    data.forEach((element) {
      items.add(
        DropdownMenuItem(
            child: Text(element[_getLang()]),
          value: element[_getLang()],
        )
      );
    });

    url = 'https://api.faol-fuqarolar.uz/api/mahallas';
    response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    mahalla_id = json.decode(response.body);

    mahallas.clear();
    mahalla_id.forEach((element) {
      mahallas.add(
          DropdownMenuItem(
            child: Text(element[_getLang()]),
            value: element[_getLang()],
          )
      );
    });
    setState(() {
      isLoading = false;
    });
  }

  String _getLang() {
    if (globals.currentLang == Languages.russian) return 'name_ru';
    else return 'name_uz';
  }

  bool isLoading = false;
  bool isRejected = false;
  bool isEmptyLine = false;
  bool isLoadingData = false;

  double latX, longX;

  @override
  void initState() {
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Subscribe
    keyboardVisibilityController.onChange.listen((bool visible) {
      if(visible) paddingTop = 150; else paddingTop = 325;
    });

    _getData();
    getLocation();

    super.initState();
  }

  var locationString = '';

  void getLocation() async {
    setState(() {
      isLoading = true;
    });
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

    try {
      _locationData = await location.getLocation();
    } catch (error) {
      print(error);
    }

    Future<List<Address>> _getAddress(double lat, double lang) async {
      final coordinates = new Coordinates(lat, lang);
      List<Address> add =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
      return add;
    }

    _getAddress(_locationData.latitude, _locationData.longitude).then((value) =>
        setState(() {
          latX = _locationData.latitude; longX = _locationData.longitude;
          locationString = value.first.addressLine;
        })
    );
    setState(() {
      isLoading = false;
    });
  }

  bool isScaled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    child: imagePath == null
                        ? Center(child: Text('Ilovani o\'chirib qaytadan kiring'),)
                        : Image.file(
                      File(imagePath),
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
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
                        _getData();
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
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.875,
                    height: 138.0,
                    margin: EdgeInsets.only(bottom: 32.0, top: 16.0),
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: isEmptyLine ? Border.all(color: AppColors.reject) : Border.all(color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: Offset(0, 3)
                          )
                        ]
                    ),
                    child: isLoadingData ? CircularProgressIndicator(
                      backgroundColor: AppColors.primary,
                    ) : Column(
                      children: [
                        SearchableDropdown.single(
                          items: items,
                          value: _value,
                          isCaseSensitiveSearch: false,
                          hint: globals.currentLang['AddProblemCategory'],
                          displayClearIcon: false,
                          underline: Container(),
                          searchHint: globals.currentLang['AddProblemCategory'],
                          onChanged: (value) {
                            setState(() {
                              isEmptyLine = false;
                              _value = value;
                            });
                          },
                          isExpanded: true,
                        ),
                        SearchableDropdown.single(
                          items: mahallas,
                          value: _mahalla,
                          isCaseSensitiveSearch: false,
                          hint: globals.currentLang['AddProblemMahalla'],
                          displayClearIcon: false,
                          underline: Container(),
                          searchHint: globals.currentLang['AddProblemMahalla'],
                          onChanged: (value) {
                            setState(() {
                              _mahalla = value;
                            });
                          },
                          isExpanded: true,
                        )
                      ],
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
                        border: isRejected ?  Border.all(color: AppColors.reject) : Border.all(color: Colors.transparent)
                    ),
                    child: TextField(
                      cursorColor: AppColors.primary,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: globals.currentLang['AddProblemHint'],
                        border: InputBorder.none,
                      ),
                      onChanged: (_value) {
                        setState(() {
                          isRejected = false;
                        });
                      },
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 108.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.875,
                      child: GestureDetector(
                        onTap: getLocation,
                        child: isLoading ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: AppColors.primary,
                          ),
                        ) : Row(
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
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 88.0,
            left: MediaQuery.of(context).size.width * 0.0625,
            child: ApplicationButton(
              onPressed: () {
                if (controller.text.isEmpty) {
                  setState(() {
                    isRejected = true;
                  });
                }
                if (_value == null) {
                  setState(() {
                    isEmptyLine = true;
                  });
                }
                if (controller.text.isNotEmpty && _value != null && locationString.isNotEmpty)
                  _send();
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