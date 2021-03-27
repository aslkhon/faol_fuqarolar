import 'dart:convert';

import 'package:faol_fuqarolar/Models/message.dart';
import 'package:faol_fuqarolar/Notifications/serverSocket.dart';
import 'package:faol_fuqarolar/Pages/introPage.dart';
import 'package:faol_fuqarolar/Pages/viewProblemPage.dart';
import 'package:faol_fuqarolar/Providers/auth.dart';
import 'package:faol_fuqarolar/Providers/request.dart';
import 'package:faol_fuqarolar/languages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart' as globals;
import '../main.dart';
import 'accountPage.dart';
import 'addProblemPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();

  static Color getColor(int statusId) {
    Color color;
    switch (statusId) {
      case 1:
        color = AppColors.sent;
        break;
      case 2:
        color = AppColors.process;
        break;
      case 3:
        color = AppColors.success;
        break;
      case 4:
        color = AppColors.reject;
        break;
    }
    return color;
  }

  static getCategory(RequestItem problem) {
    if (globals.currentLang == Languages.russian)
      return problem.category.nameRu;
    else
      return problem.category.nameUz;
  }

  static getMahalla(RequestItem problem) {
    if (globals.currentLang == Languages.russian)
      return problem.mahalla.nameRu;
    else
      return problem.mahalla.nameUz;
  }

  MainPage();
}

class _MainPageState extends State<MainPage> {
  ListStatus status = ListStatus.all;
  List<RequestItem> problems = [];

  @override
  void initState() {
    _versionCheck();
    _getMessage();
    getProblems();
    super.initState();
  }

  final picker = ImagePicker();
  bool isLoading = false;

  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera,
       maxHeight: 1080,
      maxWidth: 1080,
      imageQuality: 80
    );

    if (pickedFile != null)
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddProblemPage(imagePath: pickedFile.path))).then((value) => setState(() {}));
    else
      print('No image');
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];

  void _getMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        final notification = message['notification'];
        print(notification);
        setState(() {
          messages.add(
            Message(
              title: notification['title'],
              body: notification['body'],
            ),
          );
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print(message);
        final notification = message['notification'];
        print(notification);
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {},
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    final SocketService socketService = injector.get<SocketService>();
    socketService.socket.on("assignedRequest", (data) {
      getProblems();
    });
    socketService.socket.on("closedRequest", (data) {
      getProblems();
    });
    socketService.socket.on("rejectedRequest", (data) {
      getProblems();
    });
  }

  Future<void> _fetchData(int status) async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final phoneNumber = preferences.getString('phone');
    final token = preferences.getString('token');
    print(token);
    if (phoneNumber == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
    }
    var url;
    if (status == 0) {
      url = 'https://api.faol-fuqarolar.uz/api/requests?phone=$phoneNumber';
    } else {
      url = 'https://api.faol-fuqarolar.uz/api/requests?phone=$phoneNumber&statusId=$status';
    }
    print(token);
    try {
      await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).then((value) {
        if (value.statusCode == 401) {
          Auth().logOut().then((_) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
          });
        } else {
          final extractedData = json.decode(value.body);
          if (extractedData == null) {
            print('null');
            return null;
          }
          problems = List<RequestItem>.from(
              extractedData.map((i) => RequestItem.fromJson(i))
          );
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
      );
    } catch (error) {
      print(error);
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
  Future<void> getProblems() async {
    switch (_value) {
      case ListStatus.all:
        await _fetchData(0);
        break;
      case ListStatus.sent:
        await _fetchData(1);
        break;
      case ListStatus.process:
        await _fetchData(2);
        break;
      case ListStatus.success:
        await _fetchData(3);
        break;
      case ListStatus.reject:
        await _fetchData(4);
        break;
    }
  }

  DateTime currentBackPressTime;

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

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    FocusManager.instance.primaryFocus.unfocus();
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
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.875,
                margin: EdgeInsets.only(top: 82.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child: SvgPicture.asset('assets/images/logo_primary.svg'),
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
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
                          getProblems();
                          hideKeyboard(context);
                        });
                      }),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 250.0,
                child: (isLoading) ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: AppColors.primary,
                  ),
                ) : Container(
                  child:
                  problems.isEmpty ? Center(child: Text(globals.currentLang['NoMuammo'], style: TextStyle(
                    color: AppColors.grey, fontSize: 18.0
                  ),)) :
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: 64.0),
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: problems.length,
                    itemBuilder: (context, index) {
                      final problem = problems[index];
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
                                      color: MainPage.getColor(problem.statusId)
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        child: Text(
                                          problem.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        child: Text(
                                          MainPage.getMahalla(problem),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12.0
                                          ),
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
                                                Text(DateFormat("d MMMM HH:mm").format(DateTime.parse(problem.createdAt).toLocal()),
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0))
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
                                            child: Text(MainPage.getCategory(problem), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
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
              child: MaterialButton(
                color: AppColors.primary,
                child: _checkVersion ? Center(child: CircularProgressIndicator(backgroundColor: AppColors.primary,),) : FaIcon(
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
      ),
    );
  }
}

enum ListStatus {
  all, sent, process, success, reject
}