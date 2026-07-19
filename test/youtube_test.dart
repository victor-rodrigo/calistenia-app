import 'package:flutter_test/flutter_test.dart';

import 'package:treino/core/youtube.dart';

void main() {
  test('gera busca no YouTube pelo nome do exercício', () {
    final url = youtubeSearchUrl('Flexão');

    expect(url.host, 'www.youtube.com');
    expect(url.path, '/results');
    expect(url.queryParameters['search_query'], 'Flexão como fazer');
    expect(url.toString(), contains('search_query='));
  });
}
