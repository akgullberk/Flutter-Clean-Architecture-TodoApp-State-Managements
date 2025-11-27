// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskly/core/di/injection_container.dart' as di;
import 'package:taskly/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('taskly_test');
    await di.init(hiveSubDir: tempDir.path);
  });

  testWidgets('TodoListPage renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Taskly'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
