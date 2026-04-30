---

## Kurulum ve Çalıştırma

### Gereksinimler
*   Flutter SDK yüklü olmalıdır.
*   [Firebase Console](https://console.firebase.google.com/) üzerinde yapılandırılmış bir proje.

### Adımlar
1.  **Projeyi Klonlayın**
    ```bash
    git clone [https://github.com/tuwennie/calorie_tracker_app.git](https://github.com/tuwennie/calorie_tracker_app.git)
    ```
2.  **Bağımlılıkları Yükleyin**
    ```bash
    flutter pub get
    ```
3.  **Firebase Yapılandırması**
    *   `google-services.json` (Android) veya `GoogleService-Info.plist` (iOS) dosyalarınızı indirin.
    *   Dosyaları ilgili `android/app/` veya `ios/Runner/` klasörlerine yerleştirin.
4.  **Uygulamayı Başlatın**
    ```bash
    flutter run
    ```

---

## Gelecek Planlaması

- [ ] **Makro Takibi**: Karbonhidrat, protein ve yağ değerlerinin detaylı kırılımı.
- [ ] **Kişisel Hedefler**: Vücut kitle endeksine göre günlük kalori hedefi belirleme.
- [ ] **Kimlik Doğrulama**: Firebase Auth ile güvenli kullanıcı girişi.
- [ ] **Karanlık Mod**: Gece kullanımı için adaptif tema desteği.

---

# Kalori Takip & Sağlıklı Yaşam Asistanı

**Flutter** ve **Firebase** teknolojileri kullanılarak geliştirilmiş, modern ve yüksek performanslı bir mobil sağlık asistanı. Bu uygulama, kullanıcıların günlük beslenme verilerini gerçek zamanlı olarak takip etmelerine, su tüketimlerini izlemelerine ve haftalık gelişimlerini interaktif grafiklerle analiz etmelerine olanak tanır.

---

## Öne Çıkan Özellikler

*   **Anlık Veri Senkronizasyonu**: **Cloud Firestore** entegrasyonu sayesinde besin kayıtları ve su tüketimi cihazlar arasında anında senkronize edilir.
*   **Canlı Besin Veritabanı**: **OpenFoodFacts REST API** entegrasyonu ile binlerce ürünün kalori ve besin değerlerine anında erişim sağlanır.
*   **Veri Görselleştirme**: **fl_chart** kütüphanesi kullanılarak, kullanıcının son 7 günlük beslenme trendleri dinamik sütun grafiklerine dönüştürülür.
*   **Akıllı Su Takibi**: Günlük hidrasyon seviyesini izleyen ve verileri bulut üzerinde güvenle saklayan etkileşimli su sayacı.
*   **Modern UI/UX**: Kullanıcı deneyimine odaklanan, estetik lila/pembe temalı, akıcı arayüz tasarımı.

---

## Uygulama Önizlemesi

| Dashboard & Su Takibi | Haftalık Analiz | Besin Arama |
| :---: | :---: | :---: |
| <!-- EKRAN_GORUNTUSU_1: Ana panel görüntüsünü buraya ekleyin --> | <!-- EKRAN_GORUNTUSU_2: Grafik ekranı görüntüsünü buraya ekleyin --> | <!-- EKRAN_GORUNTUSU_3: Arama sonuçları görüntüsünü buraya ekleyin --> |
| _Günlük Özet_ | _7 Günlük İlerleme_ | _API Entegrasyonu_ |

---

## Teknik Altyapı

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **Veritabanı**: [Google Firebase](https://firebase.google.com/) (Cloud Firestore)
*   **Harici API**: [OpenFoodFacts API](https://world.openfoodfacts.org/data)
*   **Durum Yönetimi (State Management)**: **StreamBuilder** ve **FutureBuilder** ile reaktif UI güncellemeleri.
*   **Grafik Motoru**: [fl_chart](https://pub.dev/packages/fl_chart)

---

## Proje Mimarisi

Proje, sürdürülebilirlik ve temiz kod prensiplerine uygun olarak modüler bir **Servis Odaklı Mimari** ile yapılandırılmıştır:
```text
lib/
 ├── models/          # Veri modelleri (Örn: FoodModel)
 ├── services/        # İş mantığı: API iletişimi ve Firebase işlemleri
 ├── views/           # UI bileşenleri, özel lila temalı widgetlar ve ekranlar
 └── main.dart        # Uygulama başlangıç noktası ve Firebase kurulumu