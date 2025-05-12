import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatWithAdminWidget extends StatefulWidget {
  final String ownerId; // logged-in owner's ID
  const ChatWithAdminWidget({super.key, required this.ownerId});

  @override
  State<ChatWithAdminWidget> createState() => _ChatWithAdminWidgetState();
}

class _ChatWithAdminWidgetState extends State<ChatWithAdminWidget> {
  final TextEditingController messageController = TextEditingController();
  final String adminId = '68037c897aea2125f35f30a0'; // static admin ObjectId
  List<dynamic> messages = [];

  Future<void> fetchMessages() async {
    final url = Uri.parse('http://192.168.1.127:5000/messages/admin/${widget.ownerId}');
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
    Uri.parse('http://192.168.1.127:5000/messages/mark-seen'),
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
      Uri.parse('http://192.168.1.127:5000/messages/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderId': widget.ownerId,   // owner is the sender
        'receiverId': adminId,        // admin is the receiver
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
    
      markMessagesAsSeen(
    senderId: '68037c897aea2125f35f30a0', // admin ID
    receiverId: widget.ownerId,
  ).then((_) {
    fetchMessages(); // Load messages only after they're marked seen
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Admin"),
        backgroundColor: const Color(0xFF6F61EF),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isOwner = msg['senderId'] == widget.ownerId;

                return Align(
                  alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isOwner ? const Color(0xFF6F61EF) : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isOwner ? 16 : 0),
                        topRight: const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: Radius.circular(isOwner ? 0 : 16),
                      ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6F61EF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
