// ignore_for_file: unused_import, duplicate_import, unused_field

import 'package:cadeau_project/owner/profile/owner_display_products/product_display_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/custom/animations.dart';

import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'owner_profile_model.dart';
export 'owner_profile_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class OwnerProfileWidget extends StatefulWidget {
  const OwnerProfileWidget({
    super.key,
    required this.ownerId  // Add this parameter
  });
  final String ownerId;
  static String routeName = 'OwnerProfile';
  static String routePath = '/ownerProfile';

  @override
  State<OwnerProfileWidget> createState() => _OwnerProfileWidgetState();
}

class _OwnerProfileWidgetState extends State<OwnerProfileWidget>
    with TickerProviderStateMixin {
  late OwnerProfileModel _model;
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
 
Map<String, dynamic>? ownerData;
bool isLoadingOwner = true;
  final animationsMap = <String, AnimationInfo>{};
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

String fixImageUrl(String url) {
  if (url.startsWith('http://localhost')) {
    return url.replaceFirst('http://localhost', 'http://192.168.1.104');
  }
  if (url.contains('example.com')) {
    return 'https://via.placeholder.com/120'; // صورة افتراضية بدل example.com
  }
  return url;
}

  @override
  void initState() {
    super.initState();
     
     _tabController = TabController(vsync: this, length: 2);

  // 2. أنشئ الموديل وربطه بالتاب كنترولر
  _model = createModel(context, () => OwnerProfileModel());
  _model.tabBarController = _tabController;

  // 3. نادِ تحميل المنتجات
  _model.fetchOwnerProducts(widget.ownerId);

  // 4. نادِ تحميل بيانات الأونر
  fetchOwnerDetails();

    animationsMap.addAll({
      'rowOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 175.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 175.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 175.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 50.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
   _tabController.dispose();
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
        backgroundColor: Color(0xFFCACAD7),
        appBar: AppBar(
          backgroundColor: Color(0xFF998BCF),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Profile',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 12, 8, 32),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 1170,
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(
                              0,
                              2,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
                             child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent1,
        shape: BoxShape.circle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
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
    SizedBox(height: 12),
    Text(
      ownerData?['name'] ?? 'اسم غير متوفر',
      style: FlutterFlowTheme.of(context).headlineMedium.override(
        fontFamily: 'Outfit',
        color: Colors.black,
        letterSpacing: 0.0,
      ),
    ),
    SizedBox(height: 4),
    Text(
  ownerData?['description'] ?? 'No description available.',
  style: FlutterFlowTheme.of(context).labelMedium.override(
    fontFamily: 'Outfit',
    color: Colors.black54,
    letterSpacing: 0.0,
  ),
  textAlign: TextAlign.center,
),

  ],
),

                            ),
                            if (responsiveVisibility(
                              context: context,
                              tablet: false,
                              tabletLandscape: false,
                              desktop: false,
                            ))
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  
                                ],
                              ),
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                child: Column(
                                  children: [
                                    Align(
  alignment: Alignment.centerLeft, // Equivalent to (-1, 0)
  child: Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.purple, // Your border color
          width: 2,
        ),
      ),
    ),
    child: TabBar(
      isScrollable: true,
      controller: _tabController,
      labelColor: Colors.purple, // Active tab color
      unselectedLabelColor: Colors.grey, // Inactive tab color
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: Colors.purple
        ),
        insets: EdgeInsets.symmetric(horizontal: 16),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: 20),
      tabs: const [
        Tab(text: 'My Items'),
        Tab(text: 'Reviews'),
      ],
    ),
  ),
),
                                    Expanded(
                                      child: TabBarView(
                                        controller: _model.tabBarController,
                                        children: [
                                          ListView.builder(
  padding: EdgeInsets.zero,
  itemCount: _model.ownerProducts.length,
  itemBuilder: (context, index) {
  final product = _model.ownerProducts[index];

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDisplayWidget(productData: product),
        ),
      );
    },
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(4, 12, 4, 0),
      child: Container(
        decoration: BoxDecoration(
  color: FlutterFlowTheme.of(context).secondaryBackground,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      spreadRadius: 2,
      offset: Offset(0, 4),
    ),
  ],
),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fixImageUrl(
                    product['imageUrls'] != null && product['imageUrls'].isNotEmpty
                        ? product['imageUrls'][0]
                        : 'https://via.placeholder.com/120',
                  ),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://via.placeholder.com/120',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'No Name',
                      style: FlutterFlowTheme.of(context).titleLarge,
                      
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$${product['price']?.toString() ?? '0.00'}",
                      style: FlutterFlowTheme.of(context).bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
},

),

                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 12, 0, 0),
                                            child: ListView(
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.vertical,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 0, 12),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12,
                                                                        8,
                                                                        12,
                                                                        8),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            44,
                                                                        height:
                                                                            44,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).accent1,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          shape:
                                                                              BoxShape.rectangle,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .person,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              24,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              12,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'UserName',
                                                                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                  fontFamily: 'Outfit',
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0,
                                                                                4,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              'user@domainname.com',
                                                                              style: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                    fontFamily: 'Outfit',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0,
                                                                              0,
                                                                              4,
                                                                              0),
                                                                          child:
                                                                              Text(
                                                                            '5',
                                                                            style: FlutterFlowTheme.of(context).headlineMedium.override(
                                                                                  fontFamily: 'Outfit',
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .star_rounded,
                                                                          color:
                                                                              Color(0xFF4B39EF),
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12,
                                                                        0,
                                                                        12,
                                                                        8),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      AutoSizeText(
                                                                    '\"These sports shoes are incredibly comfortable, lightweight, and provide excellent support for my feet during workouts and runs. I\'ve noticed a significant improvement in my performance since wearing them!\"',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Outfit',
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
