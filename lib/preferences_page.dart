import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _musicController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  String _errorMessage = '';
  final Map<String, bool> _selectedItems = {}; // 선택된 항목 저장

  Future<void> _savePreferences() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() {
        _errorMessage = 'User is not logged in.';
      });
      return;
    }

    if (_bookController.text.isEmpty ||
        _musicController.text.isEmpty ||
        _placeController.text.isEmpty) {
      setState(() {
        _errorMessage = '모든 항목을 입력해주세요.';
      });
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('입력 확인'),
          content: Text(
              '책: ${_bookController.text}\n음악: ${_musicController.text}\n장소: ${_placeController.text}\n저장하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('네'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('preferences')
          .doc(currentUser.uid)
          .collection('entries')
          .add({
        'book': _bookController.text.trim(),
        'music': _musicController.text.trim(),
        'place': _placeController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully!')),
      );

      _bookController.clear();
      _musicController.clear();
      _placeController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save preferences: $e';
      });
    }
  }

  Future<void> _deleteSelectedPreferences() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final selectedIds = _selectedItems.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      for (final id in selectedIds) {
        await FirebaseFirestore.instance
            .collection('preferences')
            .doc(currentUser.uid)
            .collection('entries')
            .doc(id)
            .delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selected preferences deleted successfully!')),
      );

      setState(() {
        _selectedItems.clear(); // 선택 초기화
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete preferences: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '취향 설정하기',
          style: TextStyle(color: Color(0xFFE9F2EE)), // 글자색 변경
        ),
        backgroundColor: const Color(0xFF4B443F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _bookController,
              decoration: const InputDecoration(labelText: '책'),
            ),
            TextField(
              controller: _musicController,
              decoration: const InputDecoration(labelText: '음악'),
            ),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(labelText: '장소'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B443F),
              ),
              child: const Text(
                'Save Preferences',
                style: TextStyle(color: Color(0xFFE9F2EE)), // 글자색 변경
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: currentUser == null
                  ? const Center(child: Text('로그인 해주세요.'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('preferences')
                          .doc(currentUser.uid)
                          .collection('entries')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('저장된 데이터가 없습니다.'),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        return Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('선택')),
                                  DataColumn(label: Text('책')),
                                  DataColumn(label: Text('음악')),
                                  DataColumn(label: Text('장소')),
                                ],
                                rows: docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>? ?? {};
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Checkbox(
                                          value:
                                              _selectedItems[doc.id] ?? false,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedItems[doc.id] =
                                                  value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      DataCell(Text(data['book'] ?? '')),
                                      DataCell(Text(data['music'] ?? '')),
                                      DataCell(Text(data['place'] ?? '')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _deleteSelectedPreferences,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B443F),
                              ),
                              child: const Text(
                                'Delete Selected',
                                style: TextStyle(color: Color(0xFFE9F2EE)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
