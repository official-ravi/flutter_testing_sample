import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing/article.dart';
import 'package:flutter_testing/article_page.dart';
import 'package:flutter_testing/news_change_notifier.dart';
import 'package:flutter_testing/news_page.dart';
import 'package:flutter_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: "Test 1", content: "Test 1 Content"),
    Article(title: "Test 2", content: "Test 2 Content"),
    Article(title: "Test 3", content: "Test 3 Content"),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => articlesFromService);
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets(
    """Tapping on the first article excerpts open,
   the article page where the full article deatails are available""",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();

      await tester.tap(find.text("Test 1 Content"));

      await tester.pumpAndSettle();

      expect(find.byType(NewsPage), findsNothing);
      expect(find.byType(ArticlePage), findsOneWidget);

      expect(find.text("Test 1"), findsOneWidget);
      expect(find.text("Test 1 Content"), findsOneWidget);
    },
  );
}
