// ignore_for_file: unused_import, duplicate_import, unused_field

import 'package:cadeau_project/owner/profile/owner_display_products/product_display_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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


  List<Map<String, dynamic>> ownerReviews = [];
bool isLoadingReviews = true;

Future<void> fetchOwnerReviews() async {
  try {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/reviews/owner/${widget.ownerId}');
    print('📡 Fetching reviews from $url');

    final response = await http.get(url);
    print('🧾 Status Code: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        ownerReviews = List<Map<String, dynamic>>.from(json['data']);
        isLoadingReviews = false;
      });
    } else {
      print('❌ Failed to fetch reviews');
      setState(() {
        isLoadingReviews = false;
      });
    }
  } catch (e) {
    print('🔥 Error fetching reviews: $e');
    setState(() {
      isLoadingReviews = false;
    });
  }
}


Future<void> fetchOwnerDetails() async {
  try {
    // 1. جهزي الرابط اللي بتطلبي منه بيانات الأونر
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/owners/get/${widget.ownerId}');
    
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
Color _getColorFromName(String? name) {
  if (name == null || name.isEmpty) return Colors.grey;

  final int hash = name.codeUnits.fold(0, (prev, char) => prev + char);

  final List<Color> colorPalette = [
    Color.fromARGB(255, 192, 57, 95),
    Color.fromARGB(255, 182, 61, 174),
    Color.fromARGB(255, 147, 129, 226),
    Color.fromARGB(255, 98, 123, 160),
    Color.fromARGB(255, 136, 220, 230),
    Color.fromARGB(255, 247, 117, 149),
    Color.fromARGB(255, 255, 196, 123),
    Color.fromARGB(255, 248, 149, 255),
    Color.fromARGB(255, 141, 98, 166),
    Color.fromARGB(255, 186, 93, 98),
  ];

  return colorPalette[hash % colorPalette.length];
}



 String fixImageUrl(String url) {
  final baseUrl = dotenv.env['BASE_URL'] ?? '';

  // استخراج /uploads/filename فقط من أي URL فيه IP
  if (url.contains('/uploads/')) {
    final parts = url.split('/uploads/');
    return '$baseUrl/uploads/${parts.last}';
  }

  // إذا ما فيه uploads (رابط غريب)، رجعيه زي ما هو
  return url;
}

  @override
  void initState() {
    super.initState();
     
     _tabController = TabController(vsync: this, length: 2);
    fetchOwnerReviews();
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
        backgroundColor: Colors.white,
        
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
                      
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
  children: [
    GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Icon(
        Icons.arrow_back,
        color: Colors.black87,
        size: 26,
      ),
    ),
    SizedBox(width: 12),
    Text(
      'Profile',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
    ),
  ],
),
SizedBox(height: 12),

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
      child: CircleAvatar(
  radius: 60,
  backgroundImage: AssetImage(
    ownerData?['gender']?.toLowerCase() == 'female'
        ? 'assets/images/ownergirl.avif'
        : 'assets/images/ownerboy.avif',
  ),
  backgroundColor: Colors.transparent,
)
    ),
    SizedBox(height: 12),
    Text(
      ownerData?['name'] ?? 'Owner',
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
          color: Color.fromARGB(255, 124, 177, 255), // Your border color
          width: 2,
        ),
      ),
    ),
    child: TabBar(
      isScrollable: true,
      controller: _tabController,
      labelColor: Color.fromARGB(255, 124, 177, 255), // Active tab color
      unselectedLabelColor: Colors.grey, // Inactive tab color
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: Color.fromARGB(255, 124, 177, 255)
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
                                            child: isLoadingReviews
  ? Center(child: CircularProgressIndicator())
  : ListView.builder(
      itemCount: ownerReviews.length,
      itemBuilder: (context, index) {
        final review = ownerReviews[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: ListTile(
              leading: review['userAvatar'] != null && review['userAvatar'].isNotEmpty
    ? CircleAvatar(
        backgroundImage: NetworkImage(review['userAvatar']),
        radius: 24,
      )
    : CircleAvatar(
        backgroundColor: _getColorFromName(review['userName']),
        radius: 24,
        child: Text(
          review['userName'] != null && review['userName'].isNotEmpty
              ? review['userName'][0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),


              title: Text('${review['userName']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('“${review['comment']}”'),
                  Text('⭐ ${review['rating']} – ${review['productName']}', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        );
      },
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
