import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logFood(String name, double calories, double amount) async {
    try {
      double totalCalories = (calories * amount) / 100;

      // 'daily_logs' isminin doğruluğundan emin ol
      await _firestore.collection('daily_logs').add({
        'food_name': name,
        'calories': totalCalories,
        'amount': amount,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("DATABASE SERVICE HATASI: $e");
      rethrow; 
    }
  }
}