import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/next/next_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('The first widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NextPage(),
        ),
      ),
    );

    expect(find.text('textStyleLarge'), findsOneWidget);
  });
}
