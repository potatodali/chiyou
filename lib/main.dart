import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase 옵션 가져오기
import 'login_page.dart'; // 로그인 페이지

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHiYOU',
      theme: ThemeData(
        primaryColor: const Color(0xFF4B443F),
        scaffoldBackgroundColor: const Color(0xFFE9F2EE),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            // 로그인 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: Image.asset(
            'assets/images/logo_me.png', // 원하는 이미지 경로
            width: 900, // 이미지 너비
            height: 900, // 이미지 높이
          ),
        ),
      ),
    );
  }
}
