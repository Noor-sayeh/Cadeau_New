import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CupWebView extends StatefulWidget {
  @override
  _CupWebViewState createState() => _CupWebViewState();
}

class _CupWebViewState extends State<CupWebView> {
  late final WebViewController _controller;
  int quantity = 1;
  Future<void> saveCupSelection(WebViewController controller) async {
    try {
      final jsResult = await controller.runJavaScriptReturningResult('getSelectedCupData()');

      String cleanedResult = jsResult.toString();
      if (cleanedResult.startsWith('"') && cleanedResult.endsWith('"')) {
        cleanedResult = cleanedResult.substring(1, cleanedResult.length - 1).replaceAll(r'\"', '"');
      }

      final data = jsonDecode(cleanedResult);
      print("✅ بيانات الكوب: $data");

      final response = await http.post(
        Uri.parse("http://192.168.1.107:5000/api/cups/saveCupChoice"), // تأكدي من المسار
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
  "userId": "noor123",
  "name": data["cup"],
  "cupColor": data["cupColor"],
  "sticker": data["sticker"],
  "description": "Customized cup",
  "price": 100,
  "quantity": quantity,
}),

      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم حفظ تصميم الكوب!")),
        );
      } else {
        print("❌ خطأ في الحفظ: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse("https://3-d-lvs8.vercel.app/")) // غيري بالرابط
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize your own cup '),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "احفظ اختياراتي",
            onPressed: () => saveCupSelection(_controller),
          )
        ],
      ),
     body: Column(
  children: [
    Expanded(child: WebViewWidget(controller: _controller)),

    // 🟣 مدخل الكمية
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text("quantity:", style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {
                  quantity = int.tryParse(val) ?? 1;
                });
              },
            ),
          ),
        ],
      ),
    ),

    // 🟣 زر الحفظ
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => saveCupSelection(_controller),
        icon: Icon(Icons.save),
        label: Text(" Save "),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    ),
  ],
),

    );
  }
}
