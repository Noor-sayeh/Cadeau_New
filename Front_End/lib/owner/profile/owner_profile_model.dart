// ignore_for_file: unused_import, must_call_super

import '/custom/animations.dart';

import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'owner_profile_widget.dart' show OwnerProfileWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OwnerProfileModel extends FlutterFlowModel<OwnerProfileWidget> with ChangeNotifier {
  ///  State fields for stateful widgets in this page.
 List<dynamic> ownerProducts = [];

  Future<void> fetchOwnerProducts(String ownerId) async {
  try {
    final url = Uri.parse('http://192.168.1.127:5000/api/owner/$ownerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      ownerProducts = data['data'];
      notifyListeners();  // Notify listeners after the state change
    } else {
      print('❗ Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    print('🔥 Error fetching products: $e');
  }
}
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
