import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing/article.dart';
import 'package:flutter_testing/news_change_notifier.dart';
import 'package:flutter_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut; // system under test(sut)
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test(
    "check if initial values are correct on load",
    () async {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  group('getArticles', () {
    final articlesFromService = [
      Article(title: "Article 1", content: "Article 1 Content"),
      Article(title: "Article 2", content: "Article 2 Content"),
      Article(title: "Article 3", content: "Article 3 Content"),
    ];

    void arrangeNewsServiceReturns3Articles() {
      // Assign
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => articlesFromService);
    }

    test(
      "get articles using network service",
      () async {
        // Assign
        arrangeNewsServiceReturns3Articles();

        // Act
        await sut.getArticles();

        // Assert
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      """indicated loading of data,
      sets articles to show one from the service,
      indicates data is not loaded anymore""",
      () async {
        // Assign
        arrangeNewsServiceReturns3Articles();

        // Act
        final future = sut.getArticles();

        // Assert
        expect(sut.isLoading, true);
        await future;
        expect(sut.articles, [
          Article(title: "Article 1", content: "Article 1 Content"),
          Article(title: "Article 2", content: "Article 2 Content"),
          Article(title: "Article 3", content: "Article 3 Content"),
        ]);
        expect(sut.isLoading, false);
      },
    );
  });
}
