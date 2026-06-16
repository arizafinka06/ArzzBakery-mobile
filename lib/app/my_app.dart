part of '../main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arzz Bakery',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: currentUser != null ? const MainMenuScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

