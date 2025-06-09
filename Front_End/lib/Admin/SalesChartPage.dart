import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  int totalUsers = 0;
  int totalOwners = 0;
  int totalOrders = 0;
  double totalRevenue = 0;
  bool isLoading = true;

  late final WebViewController _webController1;
  late final WebViewController _webController2;
  late final WebViewController _webController3;

  @override
  void initState() {
    super.initState();

    _webController1 = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://charts.mongodb.com/charts-project-0-ulnoobu/embed/charts?id=ee97fd10-2e4a-4aee-bb46-229df1f12ef4&maxDataAge=14400&theme=light&autoRefresh=true'));

    _webController2 = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://charts.mongodb.com/charts-project-0-ulnoobu/embed/charts?id=24cc2f2e-bfb1-49ca-b3a4-471ffb1ad880&maxDataAge=14400&theme=light&autoRefresh=true')); // 🔁 Add your second chart here
   
    _webController3 = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..loadRequest(Uri.parse(
      'https://charts.mongodb.com/charts-project-0-ulnoobu/embed/charts?id=8f6d1827-55b8-4504-8fd0-5bb0412a3fd3&maxDataAge=14400&theme=light&autoRefresh=true'));

    fetchStats();
  }
///https://charts.mongodb.com/charts-project-0-ulnoobu/embed/charts?id=8f6d1827-55b8-4504-8fd0-5bb0412a3fd3&maxDataAge=14400&theme=light&autoRefresh=true
  Future<void> fetchStats() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/admin/stats');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalUsers = data['users'];
        totalOwners = data['owners'];
        totalRevenue = double.tryParse(data['totalRevenue'].toString()) ?? 0;
        totalOrders = data['orders'] ?? 0;
        isLoading = false;
      });
    } else {
      print('❌ Failed to load stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8FC),
      appBar: AppBar(
        title: const Text(
          '📊 Admin Dashboard',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            
            fontSize: 18, // Slightly smaller title font
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard('Users', totalUsers.toString(), Icons.person),
                      _buildStatCard('Owners', totalOwners.toString(), Icons.store),
                      _buildStatCard('Orders', totalOrders.toString(), Icons.list_alt),
                      _buildStatCard('Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.attach_money),
                    ],
                  ),
         
                  const SizedBox(height: 24),
const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    '📈 Data Visualizations',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF3E3E3E),
    ),
  ),
),
const SizedBox(height: 12),

                ExpansionTile(
  initiallyExpanded: false,
  title: Row(
    children: const [
      Icon(Icons.bar_chart, color: Color.fromARGB(255, 124, 177, 255)),
      SizedBox(width: 8),
      Text(
        '🧾 Monthly Sales Chart',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  ),
  children: [
    SizedBox(
      height: 400,
      width: double.infinity,
      child: WebViewWidget(controller: _webController1),
    ),
  ],
),
const SizedBox(height: 16),
ExpansionTile(
  initiallyExpanded: false,
  title: Row(
    children: const [
      Icon(Icons.star, color: Color.fromARGB(255, 124, 177, 255)),
      SizedBox(width: 8),
      Text(
        '🏆 Top Selling Products',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  ),
  children: [
    SizedBox(
      height: 350,
      width: double.infinity,
      child: WebViewWidget(controller: _webController2),
    ),
  ],
),
const SizedBox(height: 16),
ExpansionTile(
  initiallyExpanded: false, // ✅ مخفي بشكل افتراضي
  title: Row(
    children: const [
      Icon(Icons.trending_up, color: Color.fromARGB(255, 124, 177, 255)),
      SizedBox(width: 8),
      Text(
        '👥 User Growth Trend',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  ),
  children: [
    SizedBox(
      height: 350,
      width: double.infinity,
      child: WebViewWidget(controller: _webController3),
    ),
  ],
),

                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Color.fromARGB(255, 124, 177, 255)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
