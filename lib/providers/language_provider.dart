import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class LanguageProvider with ChangeNotifier {
  Map<String, String> _localizedStrings = {};
  String _currentLang = 'en';

  String get currentLang => _currentLang;

  Future<void> loadLanguage(String langCode) async {
    _currentLang = langCode;
    String jsonString = await rootBundle.loadString('assets/language/$langCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));

    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
