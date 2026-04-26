import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logFood(String name, double calories, double amount) async {
    // 100 gramdaki kalorisini, girilen miktara göre oranlıyoruz
    double totalCalories = (calories * amount) / 100;

    await _firestore.collection('daily_logs').add({
      'food_name': name,
      'calories': totalCalories,
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
    });
  }
}