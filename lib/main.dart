import 'package:bilheteriapdm/consts/themes_data.dart';
import 'package:bilheteriapdm/providers/theme_provider.dart';
import 'package:bilheteriapdm/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(
        ),
        ),
    ],
      child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child){
            return MaterialApp(
              title: "Venda De Bilhetes",
              theme: Styles.themeData(
                  isDarkTheme: themeProvider.getIsDartTheme, context: context),
              home: const HomePage(),
            );
          }),
    );
  }
}



