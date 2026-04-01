import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_nexgen/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NexGenApp());
    expect(find.byType(CircularProgressIndicator), findsAny);
  });
}
