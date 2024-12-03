import 'dart:convert';
import 'package:http/http.dart' as http;

/// Open Library API에서 책 데이터를 가져오는 함수
/// [query]: 검색어
/// Returns: 책의 제목과 저자 정보를 담은 Map 리스트
Future<List<Map<String, String>>> fetchBooks(String query) async {
  // query 변수를 URI에 안전한 형식으로 인코딩
  final encodedQuery = Uri.encodeComponent(query);
  final url = 'https://openlibrary.org/search.json?q=$encodedQuery';

  try {
    // API 호출
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // 응답 데이터 처리
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> docs = data['docs'] ?? [];

      // 검색 결과 매핑
      return docs.map<Map<String, String>>((dynamic book) {
        final title = book['title'] as String? ?? 'Unknown Title';
        final authors = (book['author_name'] as List<dynamic>?)?.join(', ') ??
            'Unknown Author';
        return {'title': title, 'author': authors};
      }).toList();
    } else {
      // 상태 코드가 200이 아닌 경우
      throw Exception(
          'Failed to fetch books. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    // 예외 처리
    throw Exception('Error fetching books: $e');
  }
}
