// Basic Flutter widget test for Collections App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:collection_app/main.dart';
import 'package:collection_app/providers/collections_provider.dart';

void main() {
  testWidgets('Collections app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ],
        child: const MyApp(),
      ),
    );
    
    // Just pump once to ensure the app starts without crashing
    await tester.pump();
    
    // Basic smoke test - verify the app doesn't crash on startup
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}