import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yemek kaydetme
  Future<void> logFood(String name, double calories, double amount) async {
    double totalCalories = (calories * amount) / 100;
    await _firestore.collection('daily_logs').add({
      'food_name': name,
      'calories': totalCalories,
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
    });
  }

  // Bugünün yemekleri
  Stream<QuerySnapshot> getDailyLogs() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    return _firestore
        .collection('daily_logs')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Su güncelleme
  Future<void> updateWater(int amount) async {
    String today = DateTime.now().toString().substring(0, 10);
    var doc = await _firestore.collection('water_logs').doc(today).get();
    if (doc.exists) {
      await _firestore.collection('water_logs').doc(today).update({'amount': FieldValue.increment(amount)});
    } else {
      await _firestore.collection('water_logs').doc(today).set({'amount': amount < 0 ? 0 : amount, 'date': FieldValue.serverTimestamp()});
    }
  }

  // Su dinleme
  Stream<DocumentSnapshot> getDailyWater() {
    String today = DateTime.now().toString().substring(0, 10);
    return _firestore.collection('water_logs').doc(today).snapshots();
  }

  // Haftalık veri
  Future<Map<String, double>> getWeeklyCalories() async {
    Map<String, double> weeklyData = {};
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      weeklyData[_getDayName(date.weekday)] = 0.0;
    }
    DateTime sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    var snapshot = await _firestore.collection('daily_logs').where('date', isGreaterThanOrEqualTo: sevenDaysAgo).get();
    for (var doc in snapshot.docs) {
      if (doc.data().containsKey('date') && doc['date'] != null) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        String dayName = _getDayName(date.weekday);
        if (weeklyData.containsKey(dayName)) {
          weeklyData[dayName] = weeklyData[dayName]! + (doc['calories'] as num).toDouble();
        }
      }
    }
    return weeklyData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Pzt";
      case 2: return "Sal";
      case 3: return "Çar";
      case 4: return "Per";
      case 5: return "Cum";
      case 6: return "Cmt";
      case 7: return "Paz";
      default: return "";
    }
  }
}