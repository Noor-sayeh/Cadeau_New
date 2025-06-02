// admin_all_products_widget.dart
// This page displays all products for the admin with owner name displayed on each card

// ignore_for_file: unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '/custom/theme.dart';
import 'package:cadeau_project/owner/profile/owner_display_products/product_display_widget.dart';

class AdminAllProductsWidget extends StatefulWidget {
  const AdminAllProductsWidget({super.key});

  @override
  State<AdminAllProductsWidget> createState() => _AdminAllProductsWidgetState();
}

class _AdminAllProductsWidgetState extends State<AdminAllProductsWidget> {
  List<dynamic> allProducts = [];
  bool isLoading = true;
  Map<String, String> ownerNamesCache = {}; // ownerId -> name

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }
Widget _buildSummarySection() {
  final productCount = allProducts.length;
  final ownerCount = ownerNamesCache.keys.length;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _dashboardCard(Icons.inventory_2, 'Products', productCount.toString()),
      _dashboardCard(Icons.person, 'Owners', ownerCount.toString()),
    ],
  );
}

Widget _dashboardCard(IconData icon, String title, String value) {
  return Container(
    width: 150,
    height: 90,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF6F61EF)),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    ),
  );
}

  Future<void> fetchAllProducts() async {
    try {
      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/all');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        allProducts = data['data'];
        await fetchAllOwnerNames();
        setState(() => isLoading = false);
      } else {
        print('❗ Failed to load products: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('🔥 Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAllOwnerNames() async {
    for (var product in allProducts) {
      final ownerId = product['owner_id'];
      if (!ownerNamesCache.containsKey(ownerId)) {
        try {
          final ownerUrl = Uri.parse('${dotenv.env['BASE_URL']}/api/owners/get/$ownerId');
          final ownerResponse = await http.get(ownerUrl);

          if (ownerResponse.statusCode == 200) {
            final ownerData = json.decode(ownerResponse.body);
            ownerNamesCache[ownerId] = ownerData['name'] ?? 'Unknown';
          } else {
            ownerNamesCache[ownerId] = 'Unknown';
          }
        } catch (e) {
          ownerNamesCache[ownerId] = 'Unknown';
        }
      }
    }
  }

  String fixImageUrl(String url) {
  final baseUrl = dotenv.env['BASE_URL'] ?? '';

  // استخراج /uploads/filename فقط من أي URL فيه IP
  if (url.contains('/uploads/')) {
    final parts = url.split('/uploads/');
    return '$baseUrl/uploads/${parts.last}';
  }

  // إذا ما فيه uploads (رابط غريب)، رجعيه زي ما هو
  return url;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        
        title: Text('All Products',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Outfit',
                  color: const Color.fromARGB(255, 0, 0, 0),
                  letterSpacing: 0.0,
                )),
        centerTitle: true,
      ),
      
      backgroundColor: Colors.white,

      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allProducts.length + 1, // +1 for the counter on top
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '🧺 Total Products: ${allProducts.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          }

          final product = allProducts[index - 1]; // -1 to skip header
          final ownerName = ownerNamesCache[product['owner_id']] ?? 'Loading...';

            

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDisplayWidget(productData: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                fixImageUrl(product['imageUrls'] != null && product['imageUrls'].isNotEmpty
                                    ? product['imageUrls'][0]
                                    : 'https://via.placeholder.com/120'),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    'https://via.placeholder.com/120',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'No Name',
                                    style: FlutterFlowTheme.of(context).titleMedium,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'By $ownerName',
                                    style: FlutterFlowTheme.of(context).labelMedium.override(
                                          fontFamily: 'Outfit',
                                          color: Colors.black54,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "\$${product['price']?.toString() ?? '0.00'}",
                                    style: FlutterFlowTheme.of(context).labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}