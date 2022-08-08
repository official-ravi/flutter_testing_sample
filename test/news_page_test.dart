import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing/article.dart';
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
    Article(title: "Article 1", content: "Article 1 Content"),
    Article(title: "Article 2", content: "Article 2 Content"),
    Article(title: "Article 3", content: "Article 3 Content"),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => articlesFromService);
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondsWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    });
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
    "title is displayed",
    (WidgetTester tester) async {
      // Assign
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text("News"), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator us displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2SecondsWait();

      //Renders the UI from the given [widget].
      await tester.pumpWidget(createWidgetUnderTest());

      //Triggers a frame after duration amount of time.
      await tester.pump(const Duration(microseconds: 5000));

      // find widget by type
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // find widget by key
      expect(find.byKey(const Key("ProgressIndicator")), findsOneWidget);

      // This essentially waits for all animations to have completed.
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());

      // no need to pass any timer as in this case the 3 articles are going to be available without any delay
      await tester.pump();

      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
