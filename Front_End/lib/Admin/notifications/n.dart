import 'package:cadeau_project/Admin/notifications/OrderDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminNotificationsWidget extends StatefulWidget {
  const AdminNotificationsWidget({super.key});

  @override
  State<AdminNotificationsWidget> createState() => _AdminNotificationsWidgetState();
}

class _AdminNotificationsWidgetState extends State<AdminNotificationsWidget> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    markAllAsSeen();
  }

  Future<void> markAllAsSeen() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/mark-all-seen');
    try {
      await http.post(url);
    } catch (e) {
      print('❌ Failed to mark as seen: $e');
    }
  }

  Future<void> fetchNotifications() async {
    final notifUri = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications');
    final usersUri = Uri.parse('${dotenv.env['BASE_URL']}/api/users');

    try {
      final notifRes = await http.get(notifUri);
      final usersRes = await http.get(usersUri);

      if (notifRes.statusCode == 200 && usersRes.statusCode == 200) {
        final notifData = jsonDecode(notifRes.body);
        final usersData = jsonDecode(usersRes.body);

        final userMap = {
          for (var user in usersData) user['_id']: user['name']
        };

        // Filter only order notifications with valid orderDetails
       final filtered = notifData.where((n) =>
  n['triggeredBy'] != 'admin' && // ✅ exclude admin-generated messages
  (
    (n['orderDetails'] != null && n['content']?.toLowerCase().contains('order') == true)
    || !(n['content']?.toLowerCase().contains('order') ?? false)
  )
).toList();


        // Sort descending (newest first)
        filtered.sort((a, b) =>
            DateTime.parse(b['sentAt']).compareTo(DateTime.parse(a['sentAt'])));

        // Inject userName
        for (var notif in filtered) {
          String? extractedUserId;
          final userId = notif['userId'];
          if (userId is Map && userId['_id'] != null) {
            extractedUserId = userId['_id'];
          } else if (userId is String) {
            extractedUserId = userId;
          } else if (notif['content'] != null) {
            final match = RegExp(r'from user (\w+)').firstMatch(notif['content']);
            if (match != null) {
              extractedUserId = match.group(1);
            }
          }
          notif['userName'] = userMap[extractedUserId] ?? 'Unknown';
        }

        setState(() {
          notifications = filtered;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<bool> markAsDelivered(String notificationId) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/mark-delivered');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notificationId': notificationId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('❌ Error marking as delivered: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF3A3A3A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '📢 Admin Notifications',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3A3A3A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          final order = notif['orderDetails'];
final isOrder = order != null;
final isDelivered = isOrder && order['status'] == 'delivery';

                          final sentAt = notif['sentAt'] ?? '';
                         
                    String shortOrderId = '';
if (order != null && order['_id'] != null && order['_id'].toString().length >= 8) {
  shortOrderId = order['_id'].toString().substring(0, 8);
}

 // 🟢 newest gets #1
                          final userName = notif['userName'] ?? 'Unknown';

                          return InkWell(
                            onTap: () {
  if (isOrder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(
          order: order,
          userName: userName,
        ),
      ),
    );
  }
},

                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 3,
                              color: isOrder && !isDelivered ? const Color(0xFFFFF3E0) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isOrder ? (isDelivered ? Colors.grey : Colors.deepOrange) : Colors.blueAccent,
                                  width: 1.2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isOrder ? Icons.local_shipping : Icons.notifications_active,
                                          color: isOrder ? (isDelivered ? Colors.grey : Colors.deepOrange) : Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 8),
                                       Expanded(
  child: Text(
    isOrder
      ? '#$shortOrderId from $userName - ${isDelivered ? "Delivered" : "Pending"}'
      : '$userName - ${notif['content']}',
    style: TextStyle(
      fontSize: 15,
      fontWeight: !isDelivered ? FontWeight.bold : FontWeight.normal,
      color: const Color(0xFF424242),
    ),
  ),
),

                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateTime.parse(sentAt).toLocal().toString().substring(0, 16),
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        if (isOrder && !isDelivered)
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              final updated = await markAsDelivered(notif['_id']);
                                              if (updated) {
                                                setState(() {
                                                  notifications[index]['orderDetails']['status'] = 'delivery';
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.done, size: 16),
                                            label: const Text('Mark as Delivered'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green[600],
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              textStyle: const TextStyle(fontSize: 13),
                                            ),
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
