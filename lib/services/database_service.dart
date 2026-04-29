import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yemek kaydetme fonksiyonu
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
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('daily_logs')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Su miktarını güncelle
  Future<void> updateWater(int amount) async {
    String today = DateTime.now().toString().substring(0, 10);
    var doc = await _firestore.collection('water_logs').doc(today).get();

    if (doc.exists) {
      await _firestore.collection('water_logs').doc(today).update({
        'amount': FieldValue.increment(amount),
      });
    } else {
      await _firestore.collection('water_logs').doc(today).set({
        'amount': amount < 0 ? 0 : amount,
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  // Bugünün su miktarını canlı izleyen fonksiyon
  Stream<DocumentSnapshot> getDailyWater() {
    String today = DateTime.now().toString().substring(0, 10);
    return _firestore.collection('water_logs').doc(today).snapshots();
  }

  // Son 7 günün toplam kalorilerini getiren fonksiyon
  Future<Map<String, double>> getWeeklyCalories() async {
    Map<String, double> weeklyData = {};
    DateTime now = DateTime.now();

    // Son 7 günü hazırla (Sıralamayı korumak için önce anahtarları oluşturuyoruz)
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dayName = _getDayName(date.weekday);
      weeklyData[dayName] = 0.0;
    }

    // Firestore'dan son 7 günün tüm kayıtlarını çek
    DateTime sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    
    try {
      var snapshot = await _firestore
          .collection('daily_logs')
          .where('date', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      for (var doc in snapshot.docs) {
        // KRİTİK KONTROL: Veri henüz Firestore'da tam oluşmamışsa (null ise) atla
        if (doc.data().containsKey('date') && doc['date'] != null) {
          Timestamp timestamp = doc['date'];
          DateTime date = timestamp.toDate();
          String dayName = _getDayName(date.weekday);
          
          if (weeklyData.containsKey(dayName)) {
            weeklyData[dayName] = weeklyData[dayName]! + (doc['calories'] as num).toDouble();
          }
        }
      }
    } catch (e) {
      print("Haftalık veri çekme hatası: $e");
    }
    
    return weeklyData;
  }

  // Gün numarasını isme çeviren yardımcı fonksiyon
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