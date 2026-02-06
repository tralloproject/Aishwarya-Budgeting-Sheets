import 'package:hive/hive.dart';

part 'payment_method.g.dart';

@HiveType(typeId: 1)
class PaymentMethod extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.iconCodePoint,
  });
}
