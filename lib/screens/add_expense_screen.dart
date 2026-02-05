import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedPaymentMethodId;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Expense ✏️')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How much? 💰', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: 'HKD ',
                  hintText: '0.00',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 24),
              Text('What for? 📝', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'e.g. Yummy Boba Tea 🧋'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),
              Text('Category 🌈', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildCategorySelector(provider),
              const SizedBox(height: 24),
              Text('Payment Method 💳', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildPaymentMethodSelector(provider),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _saveExpense(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Save Expense ✨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ExpenseProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: provider.categories.map((cat) {
        final isSelected = _selectedCategoryId == cat.id;
        return FilterChip(
          label: Text(cat.name),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedCategoryId = cat.id),
          selectedColor: Color(cat.colorValue).withOpacity(0.5),
          checkmarkColor: Colors.white,
          avatar: Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), size: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodSelector(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethodId,
      decoration: const InputDecoration(),
      items: provider.paymentMethods.map((pm) {
        return DropdownMenuItem(
          value: pm.id,
          child: Row(
            children: [
              Icon(IconData(pm.iconCodePoint, fontFamily: 'MaterialIcons'), size: 20),
              const SizedBox(width: 8),
              Text(pm.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedPaymentMethodId = val),
      validator: (value) => value == null ? 'Please select a payment method' : null,
    );
  }

  void _saveExpense(ExpenseProvider provider) {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final amountHKD = double.parse(_amountController.text);
      final expense = Expense(
        id: const Uuid().v4(),
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text,
        paymentMethodId: _selectedPaymentMethodId!,
        amountHKD: amountHKD,
        amountUSD: amountHKD / provider.exchangeRate,
      );
      provider.addExpense(expense);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added! Yay! 🥳'), backgroundColor: Colors.green),
      );
    }
  }
}
