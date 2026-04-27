import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logFood(String name, double calories, double amount) async {
    try {
      double totalCalories = (calories * amount) / 100;

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
  // Bugün eklenen verileri anlık olarak dinleyen fonksiyon
  Stream<QuerySnapshot> getDailyLogs() {
    DateTime now = DateTime.now();
    // Bugünün başlangıç saati (00:00:00)
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('daily_logs')
        .where('date', isGreaterThanOrEqualTo: startOfDay) // Sadece bugünküleri al
        .orderBy('date', descending: true) // En yeniyi en üstte göster
        .snapshots(); // Veritabanında değişim oldukça bize haber ver
  }
}