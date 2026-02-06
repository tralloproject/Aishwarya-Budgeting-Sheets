import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/budget.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Budgets 🎯')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final cat = provider.categories[index];
          final budget = provider.getBudgetForCategory(cat.id);
          final spent = provider.getSpentByCategoryHKD(cat.id);

          return _buildBudgetCard(context, cat, budget, spent, provider);
        },
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, cat, Budget? budget, double spent, ExpenseProvider provider) {
    final limit = budget?.limitHKD ?? 0.0;
    final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver = limit > 0 && spent > limit;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue)),
                    const SizedBox(width: 8),
                    Text(cat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20, color: Colors.grey),
                  onPressed: () => _showEditBudgetDialog(context, cat, budget, provider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey[200],
              color: isOver ? Colors.redAccent : Color(cat.colorValue),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: HKD ${spent.toStringAsFixed(1)}', style: TextStyle(color: isOver ? Colors.red : Colors.black54)),
                Text('Limit: HKD ${limit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            if (isOver)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Oh no! You exceeded your budget! 🙊', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, cat, Budget? budget, ExpenseProvider provider) {
    final controller = TextEditingController(text: budget?.limitHKD.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for ${cat.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Limit (HKD)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final limit = double.tryParse(controller.text) ?? 0.0;
              provider.setBudget(Budget(
                categoryId: cat.id,
                limitHKD: limit,
                limitUSD: limit / provider.exchangeRate,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
