import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

    final uri = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/send');

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
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF998BCF)),
        title: const Text(
          'Admin Notifications',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Color(0xFF998BCF),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose recipient',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _target,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 15),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(value: 'owners', child: Text('Owners Only')),
                ],
                onChanged: (val) => setState(() => _target = val!),
              ),
              const SizedBox(height: 24),
              Text(
                'Message content',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'Outfit'),
                decoration: InputDecoration(
                  hintText: 'Write your announcement here...',
                  hintStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : sendNotification,
                  icon: const Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Sending...' : 'Send Notification',
                    style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF998BCF),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
