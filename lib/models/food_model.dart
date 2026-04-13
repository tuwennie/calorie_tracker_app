class FoodModel {
  final String id;
  final String name;
  final double calories;
  final double amount;
  final DateTime date;

  FoodModel ({
    required this.id,
    required this.name,
    required this.calories,
    required this.amount,
    required this.date,
  });


Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'calories': calories,
    'amount': amount,
    'date': date.toIso8601String(),
  };
}
}