import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';
import '../models/budget.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(PaymentMethodAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(BudgetAdapter());

    // Open boxes
    await Hive.openBox<Category>('categories');
    await Hive.openBox<PaymentMethod>('paymentMethods');
    await Hive.openBox<Expense>('expenses');
    await Hive.openBox<Budget>('budgets');
    await Hive.openBox('settings'); // For theme, currency preference, etc.

    // Seed initial data if empty
    await _seedInitialData();
  }

  static Future<void> _seedInitialData() async {
    final categoryBox = Hive.box<Category>('categories');
    if (categoryBox.isEmpty) {
      final initialCategories = [
        Category(id: '1', name: 'Food', iconCodePoint: 0xe25a, colorValue: 0xFFFFAB91), // Pastel orange
        Category(id: '2', name: 'Transport', iconCodePoint: 0xe1d1, colorValue: 0xFF81D4FA), // Pastel blue
        Category(id: '3', name: 'Home Essentials', iconCodePoint: 0xe318, colorValue: 0xFFA5D6A7), // Pastel green
        Category(id: '4', name: 'Fun', iconCodePoint: 0xe4b6, colorValue: 0xFFF48FB1), // Pastel pink
        Category(id: '5', name: 'Coffee & Snacks', iconCodePoint: 0xe18a, colorValue: 0xFFFFCC80), // Pastel peach
      ];
      for (var cat in initialCategories) {
        await categoryBox.put(cat.id, cat);
      }
    }

    final pmBox = Hive.box<PaymentMethod>('paymentMethods');
    if (pmBox.isEmpty) {
      final initialPMs = [
        PaymentMethod(id: '1', name: 'Cash', iconCodePoint: 0xef26),
        PaymentMethod(id: '2', name: 'Octopus', iconCodePoint: 0xe1af),
        PaymentMethod(id: '3', name: 'Credit Card', iconCodePoint: 0xe19f),
      ];
      for (var pm in initialPMs) {
        await pmBox.put(pm.id, pm);
      }
    }
  }
}
