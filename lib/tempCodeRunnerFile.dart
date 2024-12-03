import 'api_services.dart'; // fetchBooks 함수를 가져옴

void main() async {
  const testQuery = 'harry potter'; // 테스트할 검색어
  try {
    final books = await fetchBooks(testQuery); // fetchBooks 호출
    print(books); // 결과 출력
  } catch (e) {
    print('Error: $e'); // 에러 발생 시 출력
  }
}
