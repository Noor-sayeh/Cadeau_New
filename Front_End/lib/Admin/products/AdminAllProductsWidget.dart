// admin_all_products_widget.dart
// This page displays all products for the admin with owner name displayed on each card

import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<void> fetchAllProducts() async {
    try {
      final url = Uri.parse('http://192.168.1.127:5000/api/all');
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
          final ownerUrl = Uri.parse('http://192.168.1.127:5000/api/owners/get/$ownerId');
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
    if (url.startsWith('http://localhost')) {
      return url.replaceFirst('http://localhost', 'http://192.168.1.104');
    }
    if (url.contains('example.com')) {
      return 'https://via.placeholder.com/120';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 216, 216, 227),
        
        title: Text('All Products',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Outfit',
                  color: const Color.fromARGB(255, 124, 107, 146),
                  letterSpacing: 0.0,
                )),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 216, 216, 227),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: allProducts.length,
              itemBuilder: (context, index) {
                final product = allProducts[index];
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