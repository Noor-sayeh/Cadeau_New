// ignore_for_file: unused_import, unused_label

import 'package:cadeau_project/Categories/add_category/addcategory_widget.dart';
import 'package:cadeau_project/Sign_login/Authentication.dart';
import 'package:cadeau_project/owner/ChatWithAdminWidget.dart';
import 'package:cadeau_project/owner/profile/owner_profile_widget.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';

import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cadeau_project/product/create_product_widget.dart';
import 'ownermenu_model.dart';
export 'ownermenu_model.dart';


class OwnermenuWidget extends StatefulWidget {
  final String ownerId;

  const OwnermenuWidget({Key? key, required this.ownerId}) : super(key: key);

  @override
  _OwnermenuWidgetState createState() => _OwnermenuWidgetState();
}

class _OwnermenuWidgetState extends State<OwnermenuWidget> {
  Map<String, dynamic>? ownerData;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  String ownerName = '';
  @override
  void initState() {
    super.initState();
    fetchOwnerData();
  }

   Future<void> fetchOwnerData() async {
    final url = 'http://192.168.1.127:5000/api/owners/get/${widget.ownerId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          ownerData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch owner data: $e");
    }
  }


Future<bool> hasUnreadFromAdmin() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.127:5000/messages/unread/owner/${widget.ownerId}'),
  );

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.any((entry) => entry['_id'] == '68037c897aea2125f35f30a0');
  } else {
    print('Failed to fetch unread from admin');
    return false;
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
           backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,

            automaticallyImplyLeading: false,
            title:  Text(
  'Cadeau',
  style: GoogleFonts.dancingScript(
    color: const Color(0xFF998BCF),
    fontSize: 38,
    letterSpacing: 0.0,
    fontWeight: FontWeight.w700,
    shadows: [
      Shadow(
        blurRadius: 10,
        color: Colors.black.withOpacity(0.3),
        offset: Offset(2, 2),
      ),
    ],
  ),
),
            actions: [],
            centerTitle: false,
            elevation: 0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).accent1,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          FontAwesomeIcons.userShield,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: isLoading || ownerData == null
                         ? CircularProgressIndicator()
                         : Text(
                         ownerData!['name'],
                         style: FlutterFlowTheme.of(context).headlineSmall.override(
                           fontFamily: 'Outfit',
                           letterSpacing: 0.0,
                           color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                        ),
                  ),
                  Divider(
                    height: 44,
                    thickness: 1,
                    indent: 24,
                    endIndent: 24,
                    color: const Color(0xFF998BCF),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(
    color: FlutterFlowTheme.of(context).alternate,
    width: 2,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ],
),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 24,
                            ),
                            FFButtonWidget(
                              onPressed: () {
                                print('Buttonprofile pressed ...');
                                Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerProfileWidget(ownerId: widget.ownerId),
      ),
    );
                              },
                              text: 'Profile',
                              options: FFButtonOptions(
                                width: 300,
                                height: 40,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                iconPadding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: Colors.white,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(
    color: FlutterFlowTheme.of(context).alternate,
    width: 2,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ],
),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 12, 8, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                              child: Icon(
                                Icons.production_quantity_limits,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateProductWidget(ownerId: widget.ownerId),
                                  ),
                                );
                                print('ButtonnewPro pressed ...');
                              },
                              text: 'Add new product',
                              options: FFButtonOptions(
                                width: 300,
                                height: 40,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                iconPadding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: Colors.white,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
  padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
  child: Container(
    width: double.infinity,
    decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(
    color: FlutterFlowTheme.of(context).alternate,
    width: 2,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ],
),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(8, 12, 8, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
            child: Icon(
              Icons.category,
              color: Colors.black,
              size: 24,
            ),
          ),
          FFButtonWidget(
            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddcategoryWidget(ownerId: widget.ownerId),
    ),
  );
},
            text: 'Add new category',
            options: FFButtonOptions(
              width: 300,
              height: 40,
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: Colors.white,
              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Outfit',
                    letterSpacing: 0.0,
                  ),
              elevation: 0,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
    ),
  ),
),
Padding(
  padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
  child: FutureBuilder<bool>(
    future: hasUnreadFromAdmin(),
    builder: (context, snapshot) {
      final hasUnread = snapshot.hasData && snapshot.data!;
     
      return Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasUnread ? Color(0xFFD6D0FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasUnread
                    ? const Color.fromARGB(255, 124, 107, 146)
                    : FlutterFlowTheme.of(context).alternate,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasUnread
                      ? const Color.fromARGB(255, 124, 107, 146).withOpacity(0.6)
                      : Colors.grey.withOpacity(0.2),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Colors.black,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatWithAdminWidget(ownerId: widget.ownerId),
        ),
      );
      setState(() {});
    },
    child: Text(
      'Contact Admin',
      style: FlutterFlowTheme.of(context).titleMedium.override(
        fontFamily: 'Outfit',
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
  ),
),

                ],
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 6,
              right: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF7C6B92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  ),
),






Padding(
  padding: EdgeInsets.symmetric(vertical: 16),
  child: FFButtonWidget(
    onPressed: () async {
      // عرض نافذة تأكيد قبل تسجيل الخروج
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: const Color(0xFF998BCF)),
              SizedBox(width: 8),
              Text('Log Out'),
            ],
          ),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel' ,style: TextStyle(
      fontFamily: 'Outfit',
       // أو استخدم GoogleFonts
    ),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF998BCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Yes, Log Out',style: TextStyle(
      fontFamily: 'Outfit', // أو استخدم GoogleFonts
    ),),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // سجل الخروج فعلاً
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageWidget(),
          ),
        );
      }
    },
    text: 'Log Out',
    options: FFButtonOptions(
      width: 150,
      height: 44,
      color: const Color(0xFF998BCF),
      textStyle: TextStyle(
        color: Colors.white,
        fontFamily: 'Outfit',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
