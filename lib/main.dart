import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(), //Uygulama açıldığında homescreen ekranı gösterilecek
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Servisimize erişmek için bir nesne oluşturuyoruz
  final ApiService _apiService = ApiService();
  
  // Arama sonuçları bu listede tutulacak
  List<dynamic> _searchResults = [];
  
  // Veri yüklenirken ekranda yükleniyor simgesi göstermek için
  bool _isLoading = false;

  // Arama işlemini başlatan fonksiyon
  void _search(String query) async {
    if (query.isEmpty) return; // Boş arama yapmaması için kontrol

    setState(() {
      _isLoading = true; // Yükleniyor simgesini açar
    });

    // ApiService içindeki searchFood fonksiyonunu çağırıyoruz
    final results = await _apiService.searchFood(query);

    setState(() {
      _searchResults = results; // Gelen sonuçları listeye aktaracak
      _isLoading = false; // Yükleniyor simgesini kapat
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Besin Ara"),
        centerTitle: true,
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ürün adı yazın (Örn: Elma, Çikolata...)",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              // Klavyedeki arama butonuna basınca fonksiyonu çalıştırır
              onSubmitted: (value) => _search(value),
            ),
          ),

          // Sonuç Listesi veya Yükleniyor Simgesi
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: _searchResults.isEmpty
                      ? const Center(child: Text("Aramak için bir şey yazın."))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            
                            // Ürün bilgilerini güvenli bir şekilde alıyoruz
                            final String productName = product['product_name'] ?? "Bilinmeyen Ürün";
                            final String calories = product['nutriments']?['energy-kcal_100g']?.toString() ?? "0";
                            final String? imageUrl = product['image_front_small_url'];

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: imageUrl != null
                                    ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                    : const Icon(Icons.fastfood, size: 40),
                                title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("100g'da $calories kcal"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                    // Buraya daha sonra loglama (veritabanına ekleme) gelecek
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}