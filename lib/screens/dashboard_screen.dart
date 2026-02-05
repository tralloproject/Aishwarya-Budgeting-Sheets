import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'budgets_screen.dart';
import '../widgets/expense_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final totalSpent = provider.getTotalSpentHKD();

    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ My Budget ✨'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthPicker(context, provider),
            const SizedBox(height: 16),
            _buildBalanceCard(totalSpent, provider.getRemainingBalanceHKD(), provider.exchangeRate),
            const SizedBox(height: 24),
            Text('Spendings by Category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildCategoryChart(provider),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecentExpenses(provider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context, ExpenseProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => provider.setSelectedMonth(DateTime(provider.selectedMonth.year, provider.selectedMonth.month - 1)),
        ),
        Text(
          DateFormat('MMMM yyyy').format(provider.selectedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => provider.setSelectedMonth(DateTime(provider.selectedMonth.year, provider.selectedMonth.month + 1)),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double spentHKD, double remainingHKD, double rate) {
    final spentUSD = spentHKD / rate;
    final remainingUSD = remainingHKD / rate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF8BBD0), const Color(0xFFFCE4EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8BBD0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remaining Balance', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            'HKD ${remainingHKD.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent HKD', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(spentHKD.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent USD', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(spentUSD.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rem. USD', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(remainingUSD.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No data yet! Time to go shopping? 🛍️')),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: provider.categories.map((cat) {
                final spent = provider.getSpentByCategoryHKD(cat.id);
                final total = provider.getTotalSpentHKD();
                final percentage = total > 0 ? (spent / total) * 100 : 0.0;

                return PieChartSectionData(
                  color: Color(cat.colorValue),
                  value: spent,
                  title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseProvider provider) {
    final recent = provider.expenses.take(5).toList();
    if (recent.isEmpty) {
      return const Center(child: Text('Click + to add your first expense!'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final expense = recent[index];
        final category = provider.categories.firstWhere((c) => c.id == expense.categoryId);
        return ExpenseListItem(expense: expense, category: category);
      },
    );
  }
}
