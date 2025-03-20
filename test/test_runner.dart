import 'package:test/test.dart';

import 'routes/book_routes_test.dart' as book_tests;
import 'routes/category_routes_test.dart' as category_tests;
import 'routes/user_routes_test.dart' as user_tests;

void main() {
  group('API Routes Tests', () {
    user_tests.main();
    book_tests.main();
    category_tests.main();
  });
}
