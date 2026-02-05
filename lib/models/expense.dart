import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String paymentMethodId;

  @HiveField(5)
  final double amountHKD;

  @HiveField(6)
  final double amountUSD;

  @HiveField(7)
  final String? notes;

  Expense({
    required this.id,
    required this.date,
    required this.categoryId,
    required this.description,
    required this.paymentMethodId,
    required this.amountHKD,
    required this.amountUSD,
    this.notes,
  });
}
