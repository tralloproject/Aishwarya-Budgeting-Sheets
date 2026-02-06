import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  final String categoryId;

  @HiveField(1)
  final double limitHKD;

  @HiveField(2)
  final double limitUSD;

  Budget({
    required this.categoryId,
    required this.limitHKD,
    required this.limitUSD,
  });
}
