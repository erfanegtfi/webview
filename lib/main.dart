import 'package:flutter/material.dart';

import 'webview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.green.shade700,
          onPrimary: Colors.green.shade700,
          secondary: Colors.green.shade900,
          onSecondary: Colors.green.shade900,
          error: Colors.red,
          onError: Colors.red,
          surface: Colors.white,
          onSurface: Colors.blue,
        ),
        // colorScheme: ColorScheme.fromSeed(
        //   surface: Colors.blue,
        //   seedColor: Colors.green.shade700,
        // ),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: WebviewScreen(),
    );
  }
}
