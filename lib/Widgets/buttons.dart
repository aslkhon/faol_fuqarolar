import 'package:flutter/material.dart';

import '../main.dart';

class ApplicationButton extends StatelessWidget {
  ApplicationButton({@required this.onPressed, this.text, this.buttonStyle});

  final GestureTapCallback onPressed;
  final AppButtonStyle buttonStyle;
  final text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.875,
      height: 56.0,
      margin: EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
          color: (buttonStyle == AppButtonStyle.ButtonBlue) ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 3)
            )
          ]
      ),
      child: MaterialButton(
        child: Text(text, style: TextStyle(
            color: (buttonStyle == AppButtonStyle.ButtonBlue) ? AppColors.white : AppColors.primary,
            fontSize: 18.0,
            fontWeight: FontWeight.bold
        )),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        onPressed: onPressed,
      ),
    );
  }
}

enum AppButtonStyle {
  ButtonWhite, ButtonBlue
}