import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OwnerAllNotificationsWidget extends StatefulWidget {
  final String ownerId;
  const OwnerAllNotificationsWidget({super.key, required this.ownerId});

  @override
  State<OwnerAllNotificationsWidget> createState() => _OwnerAllNotificationsWidgetState();
}

class _OwnerAllNotificationsWidgetState extends State<OwnerAllNotificationsWidget> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllOwnerNotifications();
  }

  Future<void> fetchAllOwnerNotifications() async {
    final uri = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/${widget.ownerId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final allNotifs = jsonDecode(response.body);

        allNotifs.sort((a, b) =>
            DateTime.parse(b['sentAt']).compareTo(DateTime.parse(a['sentAt'])));

        setState(() {
          notifications = allNotifs;
          isLoading = false;
        });
      } else {
        print('❌ Failed to fetch owner notifications: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📩 Owner Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No notifications yet"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final content = notif['content'] ?? '';
                    final sentAt = notif['sentAt'] ?? '';
                    final isDelivery = (content.toLowerCase().contains('out for delivery') ||
                        notif['status'] == 'delivery');

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isDelivery ? Colors.green[50] : Colors.white,
                      child: ListTile(
                        leading: Icon(
                          isDelivery ? Icons.local_shipping : Icons.campaign,
                          color: isDelivery ? Colors.green : Color.fromARGB(255, 124, 177, 255),
                        ),
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
