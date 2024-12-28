// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  String? title;
  String content;
  String yes;
  String? no;
  Function yesOnPressed;
  Function? noOnPressed;

  MyAlertDialog({this.title, required this.content, required this.yesOnPressed, required this.yes, this.noOnPressed, this.no});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: title != null ? Text(title!) : null,
        titleTextStyle: theme.textTheme.bodyLarge,
        content: Text(content, style: theme.textTheme.bodyMedium),
        // backgroundColor: ,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: <Widget>[
          if (yes.isNotEmpty == true)
            TextButton(
              onPressed: () {
                yesOnPressed();
              },
              child: Text(yes),
            ),
          if (no?.isNotEmpty == true)
            TextButton(
              onPressed: () {
                if (noOnPressed != null) noOnPressed!();
              },
              child: Text(no!),
            ),
        ],
      ),
    );
  }
}
