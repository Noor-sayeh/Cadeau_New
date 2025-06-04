// ignore_for_file: unused_import

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
import 'resetpass_model.dart';
export 'resetpass_model.dart';

class ResetpassWidget extends StatefulWidget {
  const ResetpassWidget({super.key});

  static String routeName = 'resetpass';
  static String routePath = '/resetpass';

  @override
  State<ResetpassWidget> createState() => _ResetpassWidgetState();
}

class _ResetpassWidgetState extends State<ResetpassWidget> {
  late ResetpassModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResetpassModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<String?> resetAdminPassword({
    required String adminId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/admin/$adminId/reset-password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Something went wrong';
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, FocusNode focusNode) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: '$label...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF4F4FA),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reset Password',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildInputField('Old Password', _model.textController1!, _model.textFieldFocusNode1!),
              const SizedBox(height: 24),
              _buildInputField('New Password', _model.textController2!, _model.textFieldFocusNode2!),
              const SizedBox(height: 16),
              _buildInputField('Confirm Password', _model.textController3!, _model.textFieldFocusNode3!),
              const SizedBox(height: 32),
              Center(
                child: FFButtonWidget(
                  onPressed: () async {
                    final adminId = '68037c897aea2125f35f30a0';
                    final oldPassword = _model.textController1!.text.trim();
                    final newPassword = _model.textController2!.text.trim();
                    final confirmPassword = _model.textController3!.text.trim();

                    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    final error = await resetAdminPassword(
                      adminId: adminId,
                      oldPassword: oldPassword,
                      newPassword: newPassword,
                      confirmPassword: confirmPassword,
                    );

                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Password updated successfully')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ $error')),
                      );
                    }
                  },
                  text: 'Save Changes',
                  options: FFButtonOptions(
                    width: 270,
                    height: 50,
                    color: const Color(0xFF998BCF),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3,
                    borderSide: const BorderSide(color: Colors.transparent, width: 1),
                    borderRadius: BorderRadius.circular(12),
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
