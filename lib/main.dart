import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/history_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(EnergyManagerApp());
}

class EnergyManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAWAKINI',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF00E6FF),
          secondary: Color(0xFFFFD54F),
          surface: Color(0xFF0D0D0D),
          background: Color(0xFF000000),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFFFFD54F)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00E6FF),
            foregroundColor: Colors.black,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
        ),
      ),
      home: LoginScreen(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/history': (context) => HistoryScreen(),
        '/reports': (context) => ReportsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}