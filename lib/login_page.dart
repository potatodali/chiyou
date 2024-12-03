import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_page.dart'; // 나만의 페이지로 이동

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 성공!')),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyPage()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }

  Future<void> _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('회원가입 성공!')));

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyPage()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '로그인',
          style: TextStyle(color: Color(0xFFE9F2EE)), // 글자색 변경
        ),
        backgroundColor: const Color(0xFF4B443F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B443F),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(color: Color(0xFFE9F2EE)), // 글자색 변경
              ),
            ),
            TextButton(
              onPressed: _signUp,
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(const Color(0xFF4B443F)), // 버튼 배경색
                foregroundColor:
                    WidgetStateProperty.all(const Color(0xFFE9F2EE)), // 글자색
              ),
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
