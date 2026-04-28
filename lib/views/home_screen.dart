import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Arka plan rengini çok açık bir lila yapalım
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Besin Takibi"),
      ),
      body: Column(
        children: [
          // 1. Dashboard Kartı (Lila - Pembe Geçişli)
          StreamBuilder<QuerySnapshot>(
            stream: DatabaseService().getDailyLogs(),
            builder: (context, snapshot) {
              double totalKcal = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  totalKcal += (doc['calories'] as num).toDouble();
                }
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "BUGÜNKÜ TOPLAM",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${totalKcal.toStringAsFixed(1)} kcal",
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Bugün ne yedin? 🍎",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _search,
            ),
          ),

          // 3. Sonuç Listesi
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      final String productName = product['product_name'] ?? "Bilinmeyen Ürün";
                      final calories = product['nutriments']?['energy-kcal_100g'] ?? 0;
                      final String? imageUrl = product['image_front_small_url'];

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null
                                ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                : Container(color: Colors.purple.shade50, width: 50, height: 50, child: const Icon(Icons.fastfood, color: Colors.purple)),
                          ),
                          title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$calories kcal / 100g", style: TextStyle(color: Colors.purple.shade300)),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFFE91E63), size: 30),
                            onPressed: () => _showAddDialog(product),
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

  void _showAddDialog(Map<String, dynamic> product) {
    final TextEditingController amountController = TextEditingController(text: "100");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(product['product_name'] ?? "Miktar Girin"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: "gram"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              double amount = double.tryParse(amountController.text) ?? 100.0;
              double kcal = double.tryParse(product['nutriments']?['energy-kcal_100g']?.toString() ?? "0") ?? 0.0;
              await DatabaseService().logFood(product['product_name'] ?? "Bilinmeyen", kcal, amount);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kaydedildi! ✨"), backgroundColor: Color(0xFF9C27B0)),
                );
              }
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}