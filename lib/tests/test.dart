import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('Get country sign of String locale name', () {
    final countryLang = 'pt_BR';

    expect(countryLang.substring(0, 2), equals('pt'));
  });
}
