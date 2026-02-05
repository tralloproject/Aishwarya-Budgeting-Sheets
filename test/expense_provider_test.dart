import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:aishwarya_budget_app/providers/expense_provider.dart';
import 'package:aishwarya_budget_app/models/expense.dart';
import 'package:aishwarya_budget_app/models/category.dart';
import 'package:aishwarya_budget_app/models/payment_method.dart';
import 'package:aishwarya_budget_app/models/budget.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CategoryAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PaymentMethodAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ExpenseAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BudgetAdapter());

    await Hive.openBox<Expense>('expenses');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<PaymentMethod>('paymentMethods');
    await Hive.openBox<Budget>('budgets');
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('Adding an expense updates the list and total', () async {
    final provider = ExpenseProvider();
    final expense = Expense(
      id: '1',
      date: DateTime.now(),
      categoryId: '1',
      description: 'Test',
      paymentMethodId: '1',
      amountHKD: 100.0,
      amountUSD: 12.8,
    );

    provider.addExpense(expense);

    expect(provider.expenses.length, 1);
    expect(provider.getTotalSpentHKD(), 100.0);
  });

  test('Calculating spent by category works correctly', () async {
    final provider = ExpenseProvider();
    provider.addExpense(Expense(
      id: '1',
      date: DateTime.now(),
      categoryId: 'cat1',
      description: 'Test 1',
      paymentMethodId: '1',
      amountHKD: 50.0,
      amountUSD: 6.4,
    ));
    provider.addExpense(Expense(
      id: '2',
      date: DateTime.now(),
      categoryId: 'cat1',
      description: 'Test 2',
      paymentMethodId: '1',
      amountHKD: 30.0,
      amountUSD: 3.8,
    ));
    provider.addExpense(Expense(
      id: '3',
      date: DateTime.now(),
      categoryId: 'cat2',
      description: 'Test 3',
      paymentMethodId: '1',
      amountHKD: 20.0,
      amountUSD: 2.5,
    ));

    expect(provider.getSpentByCategoryHKD('cat1'), 80.0);
    expect(provider.getSpentByCategoryHKD('cat2'), 20.0);
  });
}
