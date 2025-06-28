import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GiftBoxWebView extends StatefulWidget {
  @override
  _GiftBoxWebViewState createState() => _GiftBoxWebViewState();
}

class _GiftBoxWebViewState extends State<GiftBoxWebView> {
  late final WebViewController _controller;

  Future<void> saveBoxSelection(WebViewController controller) async {
    try {
      final jsResult = await controller.runJavaScriptReturningResult('getSelectedBoxData()');

      String cleanedResult = jsResult.toString();
      if (cleanedResult.startsWith('"') && cleanedResult.endsWith('"')) {
        cleanedResult = cleanedResult.substring(1, cleanedResult.length - 1).replaceAll(r'\"', '"');
      }

      final data = jsonDecode(cleanedResult);
      print("✅ Data saved:  $data");

      // 🔗 أرسل إلى السيرفر
      final response = await http.post(
        Uri.parse("http://192.168.1.106:5000/api/box/saveBoxChoice"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": "noor123", // غيّريه لاحقاً بالتوكن الحقيقي
          ...data,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم الحفظ في MongoDB!")),
        );
      } else {
        print("❌ problem: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse("https://giftboxes3d.vercel.app/"))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' 3D giftbox'),
        centerTitle: true,
       
      ),
      body: Column(
        children: [
          // WebView يأخذ كل المساحة المتبقية
          Expanded(child: WebViewWidget(controller: _controller)),

          // زر الحفظ أسفل الشاشة
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => saveBoxSelection(_controller),
                icon: Icon(Icons.save),
                label: Text("Save " ,style: const TextStyle(color : Colors.white,)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 124, 177, 255),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
