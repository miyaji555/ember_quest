import 'package:flutter/material.dart';
import 'package:flutter_template/constants/route_path.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('The first widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MyApp(),
        ),
      ),
    );

    expect(find.text(kPageNameTop), findsOneWidget);
    expect(find.text(kPageNameNext), findsOneWidget);
    await tester.tap(find.text(kPageNameNext));
    await tester.pump();
    expect(find.text('test'), findsOneWidget);
    await tester.pump();
    expect(find.text('textStyleLarge'), findsOneWidget);
  });
}
