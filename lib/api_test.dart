import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const query = 'harry potter'; // 테스트용 검색어
  final encodedQuery = Uri.encodeComponent(query);
  final url = 'https://openlibrary.org/search.json?q=$encodedQuery';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> docs = data['docs'] ?? [];
      print('Fetched Books: ${docs.length} results'); // 결과 개수 출력
      print(docs.map((book) => book['title']).toList()); // 책 제목만 출력
    } else {
      print('Failed to fetch books. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching books: $e');
  }
}
