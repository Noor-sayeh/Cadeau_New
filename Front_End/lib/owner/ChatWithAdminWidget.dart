import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatWithAdminWidget extends StatefulWidget {
  final String ownerId;

  const ChatWithAdminWidget({super.key, required this.ownerId});

  @override
  State<ChatWithAdminWidget> createState() => _ChatWithAdminWidgetState();
}

class _ChatWithAdminWidgetState extends State<ChatWithAdminWidget> {
  final TextEditingController messageController = TextEditingController();
  final String adminId = '68037c897aea2125f35f30a0';
  List<dynamic> messages = [];

  Future<void> fetchMessages() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/messages/admin/${widget.ownerId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        messages = json.decode(response.body);
      });
    } else {
      print('❌ Failed to fetch messages');
    }
  }

  Future<void> markMessagesAsSeen({required String senderId, required String receiverId}) async {
    await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/messages/mark-seen'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
      }),
    );
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/messages/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderId': widget.ownerId,
        'receiverId': adminId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      messageController.clear();
      fetchMessages();
    } else {
      print('❌ Failed to send message: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    markMessagesAsSeen(senderId: adminId, receiverId: widget.ownerId).then((_) {
      fetchMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Color.fromARGB(255, 124, 107, 146)),
            ),
            SizedBox(width: 12),
            Text(
              'Admin',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 124, 107, 146),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color.fromARGB(255, 124, 107, 146),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isOwner = msg['senderId'] == widget.ownerId;
                  return Align(
                    alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isOwner ? Color.fromARGB(255, 124, 107, 146) : Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isOwner ? 16 : 0),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(isOwner ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['content'],
                        style: TextStyle(
                          color: isOwner ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 124, 107, 146),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
