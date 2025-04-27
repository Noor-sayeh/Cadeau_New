// ignore_for_file: unused_import

import 'package:cadeau_project/Sign_login/Authentication.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';

import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'owner_authentication_model.dart';
export 'owner_authentication_model.dart';

/// Let the owner wait until the admin accepts him.
class OwnerAuthenticationWidget extends StatefulWidget {
  const OwnerAuthenticationWidget({super.key});

  static String routeName = 'ownerAuthentication';
  static String routePath = '/ownerAuthentication';

  @override
  State<OwnerAuthenticationWidget> createState() =>
      _OwnerAuthenticationWidgetState();
}

class _OwnerAuthenticationWidgetState extends State<OwnerAuthenticationWidget> {
  late OwnerAuthenticationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OwnerAuthenticationModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF998BCF),
          automaticallyImplyLeading: false,
          title: Text(
            'Cadeau',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 30,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 350,
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                ),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '\"Your registration has been received! Please wait for admin approval before logging in. You will be notified via email once your account is activated.\"\n',
                        textAlign: TextAlign.center,
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 20,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => userHomePage(userId: '68037c897aea2125f35f30a0',),
                            ), // Replace with the correct widget
                            );
                            },
                            text: 'Back',
                            options: FFButtonOptions(
                              width: 200,
                              height: 40,
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                              iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: Color(0xFF998BCF),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          Text(
                            'Click back to try to log in',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ].divide(SizedBox(height: 12)),
                      ),
                    ].divide(SizedBox(height: 100)),
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
