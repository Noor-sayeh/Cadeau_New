import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDeliveryNotificationsWidget extends StatefulWidget {
  final String userId;
  const UserDeliveryNotificationsWidget({super.key, required this.userId});

  @override
  State<UserDeliveryNotificationsWidget> createState() => _UserDeliveryNotificationsWidgetState();
}

class _UserDeliveryNotificationsWidgetState extends State<UserDeliveryNotificationsWidget> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeliveryNotifications();
  }

  Future<void> fetchDeliveryNotifications() async {
    final uri = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/${widget.userId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> allNotifs = jsonDecode(response.body);

        // Filter only delivery-related notifications
        final deliveryNotifs = allNotifs.where((n) {
  final content = (n['content']?.toLowerCase() ?? '');
  return content.contains('out for delivery') || n['triggeredBy'] == 'admin';
}).toList();


        // Sort by date
        deliveryNotifs.sort((a, b) =>
            DateTime.parse(b['sentAt']).compareTo(DateTime.parse(a['sentAt'])));

        setState(() {
          notifications = deliveryNotifs;
          isLoading = false;
        });
      } else {
        print('❌ Failed to fetch user delivery notifications: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  String formatOrderContent(String content) {
    final match = RegExp(r'order (\w+)', caseSensitive: false).firstMatch(content);
    if (match != null && match.group(1) != null) {
      final fullId = match.group(1)!;
      final shortId = fullId.substring(0, 8);
      return content.replaceAll(match.group(0)!, '#$shortId');
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          " Notifications 📩",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No delivery updates yet"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final content = formatOrderContent(notif['content'] ?? '');
                    final sentAt = notif['sentAt'] ?? '';

                     return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping, color: Colors.green),
                        title: Text(content),
                        subtitle: Text(
                          DateTime.parse(sentAt).toLocal().toString().substring(0, 16),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
          
                  },
                ),
    );
  }
}
