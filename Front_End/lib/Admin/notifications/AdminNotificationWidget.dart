import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminNotificationWidget extends StatefulWidget {
  const AdminNotificationWidget({Key? key}) : super(key: key);

  @override
  State<AdminNotificationWidget> createState() => _AdminNotificationWidgetState();
}

class _AdminNotificationWidgetState extends State<AdminNotificationWidget> {
  final TextEditingController _messageController = TextEditingController();
  String _target = 'all'; // 'all' or 'owners'
  bool _isLoading = false;

  Future<void> sendNotification() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uri = Uri.parse('http://192.168.1.127:5000/api/notifications/send');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': message,
          'target': _target,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Notification sent!')),
        );
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notifications'),
        backgroundColor: const Color(0xFF998BCF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose recipient',
              style: textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _target,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Users')),
                DropdownMenuItem(value: 'owners', child: Text('Owners Only')),
              ],
              onChanged: (val) => setState(() => _target = val!),
            ),
            const SizedBox(height: 20),
            Text(
              'Message content',
              style: textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'Outfit'),
              decoration: const InputDecoration(
                hintText: 'Write your announcement here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : sendNotification,
                icon: const Icon(Icons.send),
                label: Text(
                  _isLoading ? 'Sending...' : 'Send Notification',
                  style: const TextStyle(fontFamily: 'Outfit'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF998BCF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
