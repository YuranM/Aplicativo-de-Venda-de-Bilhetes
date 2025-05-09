import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {

  static const themeStatus = "THEME STATUS";
  bool _darkTheme = false;
  bool get getIsDartTheme => _darkTheme;

  ThemeProvider(){
    getTheme();
  }

  Future<void> setDarkTheme({required bool themevalue}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(themeStatus, themevalue);
    _darkTheme = themevalue;
    notifyListeners();
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkTheme = prefs.getBool(themeStatus) ?? false;
    notifyListeners();
    return _darkTheme;
  }

}
