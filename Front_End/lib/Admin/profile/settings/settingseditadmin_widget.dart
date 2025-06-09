// ignore_for_file: unused_import

import 'package:cadeau_project/Admin/profile/settings/resetpass/resetpass_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settingseditadmin_model.dart';
export 'settingseditadmin_model.dart';
class SettingseditadminWidget extends StatefulWidget {
  const SettingseditadminWidget({super.key});

  @override
  State<SettingseditadminWidget> createState() => _SettingseditadminWidgetState();
}

class _SettingseditadminWidgetState extends State<SettingseditadminWidget> {
  late SettingseditadminModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingseditadminModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    fetchAdminName().then((name) {
      if (name != null) {
        setState(() {
          _model.textController1.text = name;
        });
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> updateAdminName(String adminId, String name) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/admin/$adminId/update');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 200) {
      print('✅ Admin name updated successfully.');
    } else {
      print('❌ Failed to update name: ${response.body}');
    }
  }

  Future<String?> fetchAdminName() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/admin/admin-info');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'];
    } else {
      print('Failed to fetch admin info: ${response.body}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Profile Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 32),

              Text(
                'Your Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              SizedBox(height: 16),

              // Name field
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _model.textController1,
                  focusNode: _model.textFieldFocusNode1,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    hintText: 'Admin',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 124, 177, 255), width: 2),
                    ),
                  ),
                  validator: _model.textController1Validator.asValidator(context),
                ),
              ),

              SizedBox(height: 32),

              // Reset Password Card
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetpassWidget()));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Color.fromARGB(255, 124, 177, 255)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Save Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final adminId = '68037c897aea2125f35f30a0';
                    final name = _model.textController1.text.trim();

                    if (name.isNotEmpty) {
                      await updateAdminName(adminId, name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name cannot be empty')),
                      );
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 124, 177, 255),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
