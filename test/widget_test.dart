import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:regex_builder/main.dart';
import 'package:regex_builder/providers/regex_provider.dart';
import 'package:regex_builder/providers/theme_provider.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => RegexProvider()),
        ],
        child: const DevToolsApp(),
      ),
    );

    expect(find.text('DevTools'), findsOneWidget);
  });
}
