import 'package:flutter/material.dart';
import 'recommendation_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController queryController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('책 검색'),
        backgroundColor: const Color(0xFF4B443F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: queryController,
              decoration: const InputDecoration(
                labelText: '책 제목 또는 저자 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final query = queryController.text.trim();
                if (query.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecommendationPage(userQuery: query),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B443F),
              ),
              child: const Text('검색'),
            ),
          ],
        ),
      ),
    );
  }
}
