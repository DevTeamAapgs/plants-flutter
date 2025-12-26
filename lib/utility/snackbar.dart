import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
    ),
  );
}

void showToastMessage(String text) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: text.trim(),
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
    backgroundColor: const Color(0xFF166534),
    textColor: const Color(0xFFD1FFE3),
    fontSize: 14.0,
    webBgColor: 'linear-gradient(to right, #166534, #0f3f24)',
    webPosition: 'center',
  );
}
