import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:olympus_meals/main.dart';

void main() {
  testWidgets('App initializes successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Allow some frames to build
    await tester.pump();

    // Verify the app loaded successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
