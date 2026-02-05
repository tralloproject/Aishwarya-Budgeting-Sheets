import 'package:flutter_test/flutter_test.dart';
import 'package:aishwarya_budget_app/main.dart';
import 'package:aishwarya_budget_app/services/storage_service.dart';
import 'package:hive_test/hive_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await setUpTestHive();
    // We can't easily run the full main() because it initializes Hive with real path
    // But we can test the widget structure
    await tester.pumpWidget(const BudgetBuddyApp());

    expect(find.text('✨ My Budget ✨'), findsOneWidget);
  });
}
