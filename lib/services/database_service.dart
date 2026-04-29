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

  // Su miktarını güncelle (Artır veya Azalt)
  Future<void> updateWater(int amount) async {
    // Bugünün tarihini '2026-04-28' formatında alıyoruz
    String today = DateTime.now().toString().substring(0, 10);
    var doc = await _firestore.collection('water_logs').doc(today).get();

    if (doc.exists) {
      // Eğer bugün için bir kayıt varsa, üzerine ekle (+1 veya -1)
      await _firestore.collection('water_logs').doc(today).update({
        'amount': FieldValue.increment(amount),
      });
    } else {
      // Eğer bugün hiç su içilmediyse yeni bir doküman oluştur
      await _firestore.collection('water_logs').doc(today).set({
        'amount': amount < 0 ? 0 : amount, // Eksi değerle başlamasın
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  // Bugünün su miktarını canlı olarak izleyen fonksiyon
  Stream<DocumentSnapshot> getDailyWater() {
    String today = DateTime.now().toString().substring(0, 10);
    return _firestore.collection('water_logs').doc(today).snapshots();
  }
}