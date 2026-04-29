import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
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
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(title: const Text("Sağlıklı Yaşam")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _dbService.getDailyLogs(),
                    builder: (context, snapshot) {
                      double totalKcal = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          totalKcal += (doc['calories'] as num).toDouble();
                        }
                      }
                      return _buildEnergyCard(totalKcal);
                    },
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _dbService.getDailyWater(),
                    builder: (context, snapshot) {
                      int water = 0;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        water = (snapshot.data!.data() as Map<String, dynamic>)['amount'] ?? 0;
                      }
                      return _buildWaterCard(water);
                    },
                  ),
                  FutureBuilder<Map<String, double>>(
                    future: _dbService.getWeeklyCalories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                      return _buildChartCard(snapshot.data ?? {});
                    },
                  ),
                  _buildSearchField(),
                  if (_isLoading) const CircularProgressIndicator(),
                  _buildResultList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(double kcal) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25), margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(children: [
        const Text("BUGÜNKÜ ENERJİ", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        Text("${kcal.toStringAsFixed(1)} kcal", style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildWaterCard(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.water_drop, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 10),
          Text("$count Bardak Su", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        Row(children: [
          IconButton(onPressed: () => _dbService.updateWater(-1), icon: const Icon(Icons.remove_circle_outline)),
          IconButton(onPressed: () => _dbService.updateWater(1), icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 35)),
        ]),
      ]),
    );
  }

  Widget _buildChartCard(Map<String, double> data) {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < data.length; i++) {
      groups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: data.values.elementAt(i), color: Colors.purple, width: 14, borderRadius: BorderRadius.circular(4))
      ]));
    }
    return Container(
      height: 240, width: double.infinity, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Haftalık Analiz", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
        const SizedBox(height: 20),
        Expanded(child: BarChart(BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: groups,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= data.length) return const Text("");
                return Text(data.keys.elementAt(val.toInt()), style: const TextStyle(fontSize: 10, color: Colors.grey));
              },
            )),
          ),
        ))),
      ]),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Besin Ara...", prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
        onSubmitted: _search,
      ),
    );
  }

  Widget _buildResultList() {
    return ListView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final p = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: ListTile(
            title: Text(p['product_name'] ?? "Bilinmeyen"),
            subtitle: Text("${p['nutriments']?['energy-kcal_100g'] ?? 0} kcal"),
            trailing: IconButton(icon: const Icon(Icons.add_circle, color: Colors.pink), onPressed: () => _showAddDialog(p)),
          ),
        );
      },
    );
  }

  void _showAddDialog(Map<String, dynamic> product) {
    final controller = TextEditingController(text: "100");
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Miktar Girin"),
      content: TextField(controller: controller, keyboardType: TextInputType.number),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
        ElevatedButton(onPressed: () async {
          double amount = double.tryParse(controller.text) ?? 100.0;
          double kcal = double.tryParse(product['nutriments']?['energy-kcal_100g']?.toString() ?? "0") ?? 0.0;
          await _dbService.logFood(product['product_name'] ?? "Besin", kcal, amount);
          if (mounted) { Navigator.pop(context); setState(() {}); }
        }, child: const Text("Ekle")),
      ],
    ));
  }
}