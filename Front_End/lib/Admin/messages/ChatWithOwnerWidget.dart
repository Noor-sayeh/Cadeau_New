// ignore_for_file: unused_import

import 'dart:convert';

import 'package:http/http.dart' as http show get, post;

import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatWithOwnerWidget extends StatefulWidget {
  final String ownerId;

  const ChatWithOwnerWidget({super.key, required this.ownerId});

  @override
  State<ChatWithOwnerWidget> createState() => _ChatWithOwnerWidgetState();
}

class _ChatWithOwnerWidgetState extends State<ChatWithOwnerWidget> {
  List<dynamic> messages = [];
  TextEditingController messageController = TextEditingController();
 
Map<String, dynamic>? ownerData;
bool isLoadingOwner = true;
  Future<void> fetchMessages() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.127:5000/messages/admin/${widget.ownerId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        messages = json.decode(response.body);
      });
    } else {
      print('Failed to load messages');
    }
    await http.post(
  Uri.parse('http://192.168.1.127:5000/messages/mark-seen'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'senderId': widget.ownerId,
    'receiverId': '68037c897aea2125f35f30a0',
  }),
);

  }



Future<void> fetchOwnerDetails() async {
  try {
    // 1. جهزي الرابط اللي بتطلبي منه بيانات الأونر
    final url = Uri.parse('http://192.168.1.127:5000/api/owners/get/${widget.ownerId}');
    
    // 2. أرسلي طلب GET على الرابط
    final response = await http.get(url);

    // 3. إذا السيرفر رجعلك رد ناجح (كود 200)
    if (response.statusCode == 200) {
      // فككي بيانات الجيسون
      final data = jsonDecode(response.body);

      // 4. خزي البيانات في متغير ownerData وعلمي ان التحميل خلص
      setState(() {
        ownerData = data;
        isLoadingOwner = false;
      });

    } else {
      // 5. لو الرد مش 200، اعرضي رسالة خطأ
      print('❗ فشل تحميل بيانات الأونر: ${response.statusCode}');
    }

  } catch (e) {
    // 6. لو صار خطأ أثناء الاتصال بالإنترنت أو بالسيرفر
    print('🔥 خطأ أثناء جلب بيانات الأونر: $e');
  }
}
  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://192.168.1.127:5000/messages/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderId': '68037c897aea2125f35f30a0', // Replace with real admin ID
        'receiverId': widget.ownerId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      messageController.clear();
      fetchMessages(); // Refresh
    } else {
      print('Message send failed');
    }
  }
Future<void> markMessagesAsSeen(String senderId) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.127:5000/messages/mark-seen'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'senderId': senderId, // owner's ID
      'receiverId': '68037c897aea2125f35f30a0', // static admin ID
    }),
  );

  if (response.statusCode != 200) {
    print('❌ Failed to mark messages as seen');
  } else {
    print('✅ Messages marked as seen');
  }
}
  @override
  void initState() {
    super.initState();
    
     fetchOwnerDetails(); 
     
       markMessagesAsSeen(widget.ownerId).then((_) {
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
        child: Icon(Icons.person, color: Color(0xFF6F61EF)),
      ),
      SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ownerData?['name'] ?? 'اسم غير متوفر', // optionally dynamic
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ],
  ),
  backgroundColor: Color(0xFF6F61EF),
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pop(context),
  ),
),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isAdmin = msg['senderId'] == '68037c897aea2125f35f30a0';
                return Align(
  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
  child: Container(
    margin: EdgeInsets.symmetric(vertical: 4),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: isAdmin ? Color(0xFF6F61EF) : Colors.grey[100],
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isAdmin ? 16 : 0),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(isAdmin ? 0 : 16),
      ),
    ),
    child: Text(
      msg['content'],
      style: TextStyle(
        color: isAdmin ? Colors.white : Colors.black87,
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
          ),
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ),
      SizedBox(width: 8),
      CircleAvatar(
        backgroundColor: Color(0xFF6F61EF),
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
    );
  }
}
