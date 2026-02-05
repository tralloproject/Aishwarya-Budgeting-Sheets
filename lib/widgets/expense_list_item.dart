import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final Category category;

  const ExpenseListItem({super.key, required this.expense, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(category.colorValue).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
            color: Color(category.colorValue),
          ),
        ),
        title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(expense.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'HKD ${expense.amountHKD.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'USD ${expense.amountUSD.toStringAsFixed(1)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
