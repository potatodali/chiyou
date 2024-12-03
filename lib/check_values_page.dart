import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckValuesPage extends StatefulWidget {
  const CheckValuesPage({super.key});

  @override
  State<CheckValuesPage> createState() => _CheckValuesPageState();
}

class _CheckValuesPageState extends State<CheckValuesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<DateTime, List<String>> _events = {}; // 날짜별 데이터를 저장할 맵
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Firestore 데이터 로드
  Future<void> _loadData() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('preferences')
        .doc(currentUser.uid)
        .collection('entries')
        .get();

    final Map<DateTime, List<String>> tempEvents = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;
      if (timestamp != null) {
        // 날짜를 시간 없이 저장
        final date = DateTime(
          timestamp.toDate().year,
          timestamp.toDate().month,
          timestamp.toDate().day,
        );

        final entry = '책: ${data['book'] ?? 'N/A'}, '
            '음악: ${data['music'] ?? 'N/A'}, '
            '장소: ${data['place'] ?? 'N/A'}';

        if (tempEvents.containsKey(date)) {
          tempEvents[date]!.add(entry);
        } else {
          tempEvents[date] = [entry];
        }
      }
    }

    setState(() {
      _events = tempEvents;
    });
  }

  // 선택된 날짜의 이벤트 가져오기
  List<String> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day); // 시간 제거
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '이번 달에 좋아한 것',
          style: TextStyle(color: Color(0xFFE9F2EE)), // 글자색 변경),),
        ),
        backgroundColor: const Color(0xFF4B443F),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF4B443F),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFFE9F2EE),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFF4B443F),
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map((event) => Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(event),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
