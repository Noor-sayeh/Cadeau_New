import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String? userName;

  OrderDetailsPage({
    Key? key,
    required this.order,
    this.userName,
  }) : super(key: key);

  Future<void> markAsDelivered(BuildContext context) async {
    final notificationId = order['_id'];
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/mark-delivered');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notificationId': notificationId}),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Marked as delivered!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to mark as delivered: $e')),
      );
    }
  }

  String fixImageUrl(String url) {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (url.contains('/uploads/')) {
      final parts = url.split('/uploads/');
      return '$baseUrl/uploads/${parts.last}';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final items = order['items'] ?? [];
    final products = items.where((item) => item['name'] != null).toList();
    final giftBox = order['giftBox'];
    final giftCard = order['giftCard'];
    final delivery = order['deliveryDetails'];

    return Scaffold(
    appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 1,
  centerTitle: true,
  title: const Text(
    'Order Details',
    style: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  iconTheme: IconThemeData(color: Colors.black87),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("🛒 Products"),
            for (var product in products) buildProductCard(product),
            const SizedBox(height: 16),

            if (giftBox != null) ...[
              sectionTitle("🎁 Gift Box"),
              buildField("Box", giftBox["box"]),
              buildField("Box Color", giftBox["boxColor"]),
              buildField("Lid Color", giftBox["lidColor"]),
              buildField("Ribbon Color", giftBox["ribbonColor"]),
              const SizedBox(height: 16),
            ],

            if (giftCard != null) ...[
              sectionTitle("💌 Gift Card"),
              buildField("Sender", giftCard["senderName"]),
              buildField("Recipient", giftCard["recipientName"]),
              buildField("Message", giftCard["message"]),
              const SizedBox(height: 16),
            ],

            if (delivery != null) ...[
              sectionTitle("🚚 Delivery"),
              buildField("Address", delivery["address"]),
              buildField("Payment Method", order["paymentMethod"]),
              buildField("Total", "\$${order["totalAmount"]}"),
              buildField("Status", order["status"]),
              const SizedBox(height: 20),

              if (order["status"] == "pending")
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => markAsDelivered(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Mark as Delivered"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3A3A3A),
        ),
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final imageUrl = fixImageUrl(product['imageUrl']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(
          product['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Qty: ${product['quantity']} • \$${product['price']}'),
      ),
    );
  }

  Widget buildField(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
