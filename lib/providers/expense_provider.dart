import 'package:flutter/foundation.dart' hide Category;
import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';
import '../models/budget.dart';
import '../services/currency_service.dart';
import '../services/location_service.dart';

class ExpenseProvider with ChangeNotifier {
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final Box<Category> _categoryBox = Hive.box<Category>('categories');
  final Box<PaymentMethod> _pmBox = Hive.box<PaymentMethod>('paymentMethods');
  final Box<Budget> _budgetBox = Hive.box<Budget>('budgets');
  final Box _settingsBox = Hive.box('settings');

  final CurrencyService _currencyService = CurrencyService();
  double _exchangeRate = 7.8;

  DateTime _selectedMonth = DateTime.now();

  String _locationCurrency = 'HKD';
  String get locationCurrency => _locationCurrency;

  ExpenseProvider() {
    _loadExchangeRate();
    _loadBalance();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    final country = await LocationService().getCurrentCountry();
    if (country != null) {
      if (country == 'United States') {
        _locationCurrency = 'USD';
      } else if (country == 'Hong Kong') {
        _locationCurrency = 'HKD';
      }
      notifyListeners();
    }
  }

  double get exchangeRate => _exchangeRate;
  DateTime get selectedMonth => _selectedMonth;

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  Future<void> _loadExchangeRate() async {
    _exchangeRate = await _currencyService.getExchangeRate();
    notifyListeners();
  }

  List<Expense> get allExpenses => _expenseBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<Expense> get expenses => allExpenses.where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month).toList();
  List<Category> get categories => _categoryBox.values.toList();
  List<PaymentMethod> get paymentMethods => _pmBox.values.toList();
  List<Budget> get budgets => _budgetBox.values.toList();

  void addExpense(Expense expense) {
    _expenseBox.put(expense.id, expense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenseBox.delete(id);
    notifyListeners();
  }

  void setBudget(Budget budget) {
    _budgetBox.put(budget.categoryId, budget);
    notifyListeners();
  }

  double getTotalSpentHKD() {
    return expenses.fold(0, (sum, item) => sum + item.amountHKD);
  }

  double _initialBalanceHKD = 10000.0; // Default
  double get initialBalanceHKD => _initialBalanceHKD;

  Future<void> _loadBalance() async {
    _initialBalanceHKD = _settingsBox.get('initialBalance', defaultValue: 10000.0);
    notifyListeners();
  }

  void setInitialBalance(double balance) {
    _initialBalanceHKD = balance;
    _settingsBox.put('initialBalance', balance);
    notifyListeners();
  }

  double getRemainingBalanceHKD() {
    return _initialBalanceHKD - getTotalSpentHKD();
  }

  double getSpentByCategoryHKD(String categoryId) {
    return expenses
        .where((e) => e.categoryId == categoryId)
        .fold(0, (sum, item) => sum + item.amountHKD);
  }

  Budget? getBudgetForCategory(String categoryId) {
    return _budgetBox.get(categoryId);
  }

  // Location-based currency suggestion (Simplified)
  String getSuggestedCurrency() {
    // This could be enhanced with geolocator
    return 'HKD';
  }
}
