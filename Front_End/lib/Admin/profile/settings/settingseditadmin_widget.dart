// ignore_for_file: unused_import

import 'package:cadeau_project/Admin/profile/settings/resetpass/resetpass_widget.dart';

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

  static String routeName = 'Settingseditadmin';
  static String routePath = '/settingseditadmin';

  @override
  State<SettingseditadminWidget> createState() =>
      _SettingseditadminWidgetState();
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
  final url = Uri.parse('http://192.168.1.127:5000/api/admin/$adminId/update');

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
  final url = Uri.parse('http://192.168.1.127:5000/api/admin/admin-info');

  final response = await http.get(url, headers: {
    'Content-Type': 'application/json',
    // Add auth headers if needed
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['name']; // "Admin"
  } else {
    print('Failed to fetch admin info: ${response.body}');
    return null;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF998BCF),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          buttonSize: 48,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).info,
            size: 25,
          ),
            onPressed: () {
    Navigator.pop(context); // This pops the current route
  },
        ),
        title: Text(
          'Profile Settings',
          style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).secondaryBackground,
                letterSpacing: 0.0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Your information',
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Outfit',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                            child: TextFormField(
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Admin',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                  ),
                              validator: _model.textController1Validator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(width: 5)),
                    ),
                   
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 8),
                      //ResetpassWidget
                        child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetpassWidget()),
      );
    },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 8, 16, 8),
                            child: Icon(
                              Icons.lock,
                              color: Color(0xFF998BCF),
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                              child: Text(
                                'Reset Password',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 16,
                                      letterSpacing: 0.0,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24,
                          ),
                        ],
                      ),
                        ),
                    ),
                  ],
                ),
              ),
              FFButtonWidget(
                onPressed: () async {
  final adminId = '68037c897aea2125f35f30a0'; // Replace with actual logged-in admin ID
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

                text: 'Save Changes',
                options: FFButtonOptions(
                  width: 270,
                  height: 50,
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: Color(0xFF998BCF),
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                  elevation: 3,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ].divide(SizedBox(height: 5)),
          ),
        ),
      ),
    );
  }
}
