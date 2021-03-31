import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';

// ignore: must_be_immutable
class MobileInput extends StatelessWidget {
  final TextEditingController controller;
  MobileInput({this.onPressed, this.controller, this.isLoading});
  final GestureTapCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.875,
      height: 56.0,
      margin: EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 3)
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('+998', style: TextStyle(
                    color: AppColors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                )),
                Container(
                  width: 150.0,
                  padding: EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                      controller: controller,
                      maxLength: 9,
                      onFieldSubmitted: (value) {
                        onPressed();
                      },
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0
                      ),
                      keyboardType: TextInputType.number,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: ""
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ]),
                ),
              ],
            ),
            (isLoading) ? CircularProgressIndicator(
              backgroundColor: AppColors.primary,
            ) : GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 15.0, right: 5.0),
                    child: FaIcon(FontAwesomeIcons.angleRight, color: AppColors.primary,)
                ),
                onTap: onPressed
            )
          ],
        ),
      ),
    );
  }
}

class AppPasswordInput extends StatelessWidget {
  AppPasswordInput({this.onPressed, this.resend, this.enabled, this.controller});
  final GestureTapCallback onPressed;
  final TextEditingController controller;
  final bool resend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.875,
      height: 56.0,
      margin: EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 3)
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 34,
              width: 34,
            ),
            Container(
              width: 180.0,
              child: TextFormField(
                  enabled: enabled,
                  maxLength: 6,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      letterSpacing: 5.0
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.primary,
                  controller: controller,
                  onChanged: (value) {
                    if (value.length == 6) {
                      onPressed();
                    }
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                      hintText: "******"
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ]),
            ),
            (resend) ? GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
                    child: FaIcon(FontAwesomeIcons.redo, color: AppColors.primary,)
                ),
                onTap: onPressed
            ) : Container(
              height: 34,
              width: 34,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class NameInput extends StatelessWidget {
  TextEditingController controller;
  NameInput({this.hint, this.controller, this.error});
  final hint;
  final bool error;

  @override
  Widget build(BuildContext context) {
    Border border;
    if (error)
      border = Border.all(color: AppColors.reject, width: 1.0);
    else
      border = Border.all(color: Colors.transparent);
    return Container(
      width: MediaQuery.of(context).size.width * 0.875,
      height: 56.0,
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: border,
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 3)
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 250.0,
              padding: EdgeInsets.only(left: 8.0),
              child: TextFormField(
                  maxLength: 20,
                  controller: controller,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.name,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                      hintText: hint,
                      hintStyle: TextStyle(color: AppColors.grey)
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я]+')),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}