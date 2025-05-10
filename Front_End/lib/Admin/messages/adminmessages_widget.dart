// ignore_for_file: unused_import

import 'dart:convert';

import 'package:cadeau_project/Admin/messages/ChatWithOwnerWidget.dart';
import 'package:http/http.dart' as http show get;

import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'adminmessages_model.dart';
export 'adminmessages_model.dart';

class AdminmessagesWidget extends StatefulWidget {
  const AdminmessagesWidget({super.key});

  static String routeName = 'Adminmessages';
  static String routePath = '/adminmessages';

  @override
  State<AdminmessagesWidget> createState() => _AdminmessagesWidgetState();
}

class _AdminmessagesWidgetState extends State<AdminmessagesWidget> {
  late AdminmessagesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminmessagesModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }
  Future<List<dynamic>> fetchMessages(String ownerId) async {
  final response = await http.get(Uri.parse('http://192.168.1.114:5000/messages/admin/$ownerId'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load messages');
  }
}

Future<List<dynamic>> fetchOwners() async {
  final response = await http.get(Uri.parse('http://192.168.1.114:5000/api/users'));

  if (response.statusCode == 200) {
    final List<dynamic> users = json.decode(response.body);
    // Filter users with role "Owner"
    return users.where((user) => user['role'] == 'Owner').toList();
  } else {
    throw Exception('Failed to load users');
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF998BCF),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 50,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 25,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'My messages',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  fontSize: 20,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 15, 0, 0),
                  child: Text(
                    'Below are messages with your owners.',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: 'Outfit',
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                 
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8, 0, 0, 0),
                                     

child: FutureBuilder<List<dynamic>>(
  future: fetchOwners(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Text('Error loading owners');
    } else {
      final owners = snapshot.data!;
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Important when inside scroll view
        itemCount: owners.length,
        itemBuilder: (context, index) {
          final owner = owners[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text(owner['name'][0]), // First letter fallback
            ),
            title: Text(owner['name']),
            subtitle: Text(owner['email']),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatWithOwnerWidget(ownerId: owner['_id']),
                ),
              );
            },
          );
        },
      );
    }
  },
),


                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                     
                     
                      
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ].divide(SizedBox(height: 6)),
            ),
          ),
        ),
      ),
    );
  }
}

extension on BuildContext {
  void pop() {}
}
