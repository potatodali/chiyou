import 'package:flutter/material.dart';
import 'recommendation_page.dart';
import 'preferences_page.dart'; // 취향 입력 페이지
import 'check_values_page.dart'; // 입력한 값 확인 페이지
import 'discussion_page.dart'; // 의견 나누기 페이지
import 'dart:async';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = _getTimeString(); // 초기 시간 설정
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getTimeString();
      });
    });
  }

  // 현재 시간을 가져오는 함수
  String _getTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
        backgroundColor: const Color(0xFF4B443F),
      ),
      body: Column(
        children: [
          // 상단 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PreferencesPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B443F),
                  ),
                  child: const Text(
                    '내 취향 입력하기',
                    style: TextStyle(color: Color(0xFFE9F2EE)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CheckValuesPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B443F),
                  ),
                  child: const Text(
                    '입력한 값 확인하기',
                    style: TextStyle(color: Color(0xFFE9F2EE)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // RecommendationPage로 이동 시 userQuery 값 전달
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendationPage(
                          userQuery: 'defaultQuery', // 예제 값 전달
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B443F),
                  ),
                  child: const Text(
                    '나만을 위한 추천 받기',
                    style: TextStyle(color: Color(0xFFE9F2EE)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DiscussionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B443F),
                  ),
                  child: const Text(
                    '다른 사람과 의견 나누기',
                    style: TextStyle(color: Color(0xFFE9F2EE)),
                  ),
                ),
              ],
            ),
          ),
          // 중앙 이미지 및 시간
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_me.png', // 이미지 경로
                    width: 300, // 이미지 크기 확대
                    height: 300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentTime, // 현재 시간 출력
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
