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
        title: const Text("Besin Ara"),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Besin Ara (Örn: Çikolata)",
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: _search,
            ),
          ),
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
                            ? Image.network(product['image_small_url'], 
                                width: 50, 
                                errorBuilder: (c, e, s) => const Icon(Icons.fastfood))
                            : const Icon(Icons.fastfood),
                        title: Text(product['product_name'] ?? "Bilinmeyen Ürün"),
                        subtitle: Text("100g için: $calories kcal"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () {
                            _showAddDialog(
                              product['product_name'] ?? "Bilinmeyen Ürün",
                              double.tryParse(calories.toString()) ?? 0,
                            );
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

  void _showAddDialog(String name, double kcalPer100) {
    final TextEditingController amountController = TextEditingController(text: "100");

    showDialog(
      context: context,
      builder: (context) {
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
                double amount = double.tryParse(amountController.text) ?? 100;
                await DatabaseService().logFood(name, kcalPer100, amount);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Başarıyla kaydedildi!"),
                      backgroundColor: Colors.green,
                    ),
                  );
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