import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Arama fonksiyonu
  void _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await _apiService.searchFood(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalori Takip"),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          // Arama Giriş Alanı
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Besin Ara (Örn: Ekmek, Elma...)",
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: _search,
            ),
          ),

          // Yükleniyor simgesi veya Liste
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      final calories = product['nutriments']?['energy-kcal_100g'] ?? 0;

                      return ListTile(
                        leading: product['image_small_url'] != null
                            ? Image.network(
                                product['image_small_url'],
                                width: 50,
                                errorBuilder: (c, e, s) => const Icon(Icons.fastfood),
                              )
                            : const Icon(Icons.fastfood),
                        title: Text(product['product_name'] ?? "Bilinmeyen Ürün"),
                        subtitle: Text("100g için: $calories kcal"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () {
                            // Dialog penceresini açan fonksiyonu çağırıyoruz
                            _showAddDialog(product);
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Miktar Soran Dialog Penceresi
  void _showAddDialog(Map<String, dynamic> product) {
    final TextEditingController amountController = TextEditingController(text: "100");
    final String name = product['product_name'] ?? "Bilinmeyen Ürün";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Kaç gram yediğinizi girin:"),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(suffixText: "gram"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                // DEBUG MESAJI
                print("DEBUG: Ekle butonuna basıldı");

                try {
                  // 1. Değerleri hazırla
                  double amount = double.tryParse(amountController.text) ?? 100.0;
                  
                  // Kaloriyi güvenli bir şekilde al ve double'a çevir
                  var kcalRaw = product['nutriments']?['energy-kcal_100g'];
                  double kcalPer100 = double.tryParse(kcalRaw.toString()) ?? 0.0;

                  print("DEBUG: Gönderilen veriler -> Ad: $name, Kcal: $kcalPer100, Miktar: $amount");

                  // 2. Firebase servisini çağır
                  await DatabaseService().logFood(name, kcalPer100, amount);

                  print("DEBUG: Firestore kaydı başarılı bitti");

                  // 3. UI Güncelle (Dialog'u kapat ve SnackBar göster)
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Başarıyla kaydedildi!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print("DEBUG HATA: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Bir hata oluştu: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Ekle"),
            ),
          ],
        );
      },
    );
  }
}