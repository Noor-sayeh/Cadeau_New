// ignore_for_file: unused_import

import 'dart:convert';

import 'package:cadeau_project/Admin/Categories/CategoryProductsPage.dart';
import 'package:cadeau_project/Admin/SalesChartPage.dart';
import 'package:cadeau_project/Admin/cup_webview.dart';
import 'package:cadeau_project/Admin/giftbox_webview.dart';
import 'package:cadeau_project/Admin/memberlist/member_list_screen.dart';
import 'package:cadeau_project/Admin/messages/adminmessages_widget.dart';
import 'package:cadeau_project/Admin/notifications/announcement.dart';
import 'package:cadeau_project/Admin/notifications/n.dart';
import 'package:cadeau_project/Admin/profile/announcment/JordanHolidaysWidget.dart';
import 'package:cadeau_project/Admin/profile/settings/settingseditadmin_widget.dart';
import 'package:cadeau_project/Admin/reviews.dart';
import 'package:cadeau_project/Sign_login/Authentication.dart';
import 'package:cadeau_project/Admin/products/AdminAllProductsWidget.dart';
import 'package:cadeau_project/test_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'admin_profile_model.dart';
export 'admin_profile_model.dart';

class AdminProfileWidget extends StatefulWidget {
  const AdminProfileWidget({super.key});

  static String routeName = 'Admin_Profile';
  static String routePath = '/adminProfile';

  @override
  State<AdminProfileWidget> createState() => _AdminProfileWidgetState();
}

class _AdminProfileWidgetState extends State<AdminProfileWidget> {
  late AdminProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminProfileModel());
     WidgetsBinding.instance.addPostFrameCallback((_) {
    checkForNewNotifications(context);
  });
  }
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  setState(() {}); // This will refetch the unread count each time
}
Future<bool> hasUnseenOrPendingNotifications() async {
  final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/api/notifications'));
  if (response.statusCode != 200) return false;

  final List data = jsonDecode(response.body);
  return data.any((n) =>
    n['isSeen'] == false ||
    ((n['content'] ?? '').contains('pending') && (n['orderStatus'] == null || n['orderStatus'] == 'pending')));
}

Future<void> checkForNewNotifications(BuildContext context) async {
  // 1. Ask server to ensure pending orders have notifications
  await http.get(Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/scan-pending-orders'));

  // 2. Fetch notifications
  final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/api/notifications'));
  if (response.statusCode != 200) return;

  final data = jsonDecode(response.body) as List;

  // 3. Check if any notification is unseen
  final hasUnseen = data.any((n) => n['isSeen'] == false);

  // ✅ 4. Also check if there's any notification about a *still pending* order
  final hasPendingOrderNotification = data.any((n) =>
      (n['content'] ?? '').contains('pending') &&
      (n['orderStatus'] == null || n['orderStatus'] == 'pending'));

  if (hasUnseen || hasPendingOrderNotification) {
    // Show the top-aligned dialog
    showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'New Notifications',
  transitionDuration: const Duration(milliseconds: 300),
  transitionBuilder: (context, animation, secondaryAnimation, child) {
    final curvedValue = Curves.easeInOut.transform(animation.value);
    return Transform.translate(
      offset: Offset(0, -50 * (1 - curvedValue)),
      child: Opacity(opacity: animation.value, child: child),
    );
  },
  pageBuilder: (context, animation, secondaryAnimation) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding from sides
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 370, // ⬅️ limits width to avoid overflow on small devices
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Expanded( // ✅ Prevents overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          '🔔 New Notifications',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You have unseen updates or pending orders.',
                          style: TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);

  }
}


  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }
  Future<int> fetchUnreadCount() async {
  final response = await http.get(
    Uri.parse('${dotenv.env['BASE_URL']}/messages/unread/admin'),
  );

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.length; // or sum counts if needed
  } else {
    return 0;
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
        backgroundColor: const Color.fromARGB(255, 124, 107, 146),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 124, 107, 146),
          automaticallyImplyLeading: false,
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        body: Align(
          alignment: AlignmentDirectional(0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 140,
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: FaIcon(
                              FontAwesomeIcons.userTie,
                              color: Colors.black,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 12),
                child: Text(
                  'Admin',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).info,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Padding( ///AdminmessagesWidget
                padding: EdgeInsetsDirectional.fromSTEB(16, 24, 16, 32),
                child: InkWell(
   onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AdminmessagesWidget()),
  );
  setState(() {}); // 🔁 Triggers UI rebuild, fetches unread count again
},

                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              alignment: AlignmentDirectional(0, 0),
                              child: FutureBuilder<int>(
  future: fetchUnreadCount(),
  builder: (context, snapshot) {
    final hasUnread = snapshot.hasData && snapshot.data! > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.message_rounded,
          color: Colors.black,
          size: 24,
        ),
        if (hasUnread)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  },
),

                            ),
                          ),
                          Text(
                            'messages',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Outfit',
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
                 child: InkWell(
   onTap: () async {
 Navigator.push(
  context,
  MaterialPageRoute(builder: (_) =>  AdminNotificationsWidget()),
);
},
        
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                alignment: AlignmentDirectional(0, 0),
                                child:  FutureBuilder<bool>(
  future: hasUnseenOrPendingNotifications(),
  builder: (context, snapshot) {
    final hasAlert = snapshot.data == true;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined, color: Colors.black, size: 24),
        if (hasAlert)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  },
),
                              ),
                            ),
                            Text(
                              'Notifications',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Outfit',
                                    fontSize: 18,
                                    letterSpacing: 0.0,
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
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(
                          0,
                          -1,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                                child: Text(
                                  'Settings',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                               Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                    ///AdminAnnouncementWidget
                         child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminNotificationWidget()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons.campaign,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Announcements',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
                         ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                    ///AdminAnnouncementWidget
                         child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const JordanHolidaysWidget()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons.event,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Occasions',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
                         ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                    child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MemberListPage()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons.person_search,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Members',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),

                                    ///AdminAllProductsWidget
child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminAllProductsWidget()),
      );
    },
                                             ///
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons
                                            .production_quantity_limits_outlined,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Products',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
),
                              ),
                                 Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                    ///AdminAllReviewsWidget
                                    ///
              child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminCategoryListPage()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: FaIcon(
                                        Icons.category,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Categories',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
              ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                    child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardWidget()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons.query_stats,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Analytics Dashboard',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                    ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                    ///AdminAllReviewsWidget
                                    ///
              child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminAllReviewsWidget()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: FaIcon(
                                        FontAwesomeIcons.award,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'User Feedback',
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
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
              ),
                              ),
                          
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                     child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingseditadminWidget()),
      );
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons.edit,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Profile Settings',
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
                                    Text(
                                      'Edit Profile',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Outfit',
                                            color: const Color.fromARGB(255, 36, 27, 106),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                                     ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                                     child: InkWell(
     onTap: () async {
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF998BCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Yes, Log Out'),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Perform actual logout here, e.g., clear tokens
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageWidget()),
        );
      }
    },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 16, 8),
                                      child: Icon(
                                        Icons.login_rounded,
                                        color: const Color(0xFF998BCF),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 12, 0),
                                        child: Text(
                                          'Log out of account',
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
                                    Text(
                                      'Log Out?',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Outfit',
                                            color: const Color.fromARGB(255, 36, 27, 106),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
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
      ),
    );
  }
}
