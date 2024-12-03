import 'package:flutter/material.dart';
import 'api_services.dart';

class RecommendationPage extends StatefulWidget {
  final String userQuery; // userQuery 추가

  const RecommendationPage(
      {super.key, required this.userQuery}); // 생성자에 required 추가

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final TextEditingController _userInputController = TextEditingController();
  List<Map<String, String>> recommendations = [];
  List<String> searchHistory = []; // 검색 기록 저장
  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    _userInputController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  Future<void> _fetchRecommendations(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final books = await fetchBooks(query);
      setState(() {
        recommendations = books;
        if (!searchHistory.contains(query)) {
          searchHistory.add(query); // 검색 기록에 추가
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '추천 결과를 가져오는 중 오류가 발생했습니다.\n\n오류 내용: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '나만을 위한 추천 받기',
          style: TextStyle(color: Color(0xFFE9F2EE)), // 글자색 변경),
        ),
        backgroundColor: const Color(0xFF4B443F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색어 입력 필드
            TextField(
              controller: _userInputController,
              decoration: const InputDecoration(
                labelText: '추천받을 키워드를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 추천받기 버튼
            ElevatedButton(
              onPressed: () {
                final query = _userInputController.text.trim();
                if (query.isNotEmpty) {
                  _fetchRecommendations(query);
                } else {
                  setState(() {
                    errorMessage = '키워드를 입력해주세요.';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B443F),
              ),
              child: const Text('추천받기',
                  style: TextStyle(color: Color(0xFFE9F2EE))),
            ),
            const SizedBox(height: 16),
            // 검색 기록 테이블
            if (searchHistory.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '검색 기록:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: searchHistory.length,
                      itemBuilder: (context, index) {
                        final history = searchHistory[index];
                        return ListTile(
                          title: Text(history),
                          trailing: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              _fetchRecommendations(history); // 선택한 검색어로 다시 추천
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // 로딩 상태
            if (isLoading)
              const CircularProgressIndicator()
            // 에러 메시지
            else if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              )
            // 추천 결과가 없을 때
            else if (recommendations.isEmpty)
              const Text(
                '추천 결과가 없습니다.\n다른 키워드로 검색해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              )
            // 추천 결과 리스트
            else
              Expanded(
                child: ListView.builder(
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final book = recommendations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          book['title'] ?? 'Unknown Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Author: ${book['author'] ?? 'Unknown Author'}',
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(book['title'] ?? 'Unknown Title'),
                              content: Text(
                                'Author: ${book['author'] ?? 'Unknown Author'}\n\n'
                                '이 책을 관심 목록에 추가하거나 더 알아보시겠습니까?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('닫기'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // 관심 목록 추가 로직 구현
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4B443F),
                                  ),
                                  child: const Text('추가'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
