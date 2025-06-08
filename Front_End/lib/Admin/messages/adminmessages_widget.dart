// ignore_for_file: unused_import

import 'dart:convert';

import 'package:cadeau_project/Admin/messages/ChatWithOwnerWidget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/messages/admin/$ownerId'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load messages');
  }
}
Future<Map<String, dynamic>> fetchOwnersWithUnread() async {
  try {
    final ownersResponse = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/api/owners/all'),
    );
    final unreadResponse = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/messages/unread/admin'),
    );

    print('📦 Owners status: ${ownersResponse.statusCode}');
    print('📦 Unread status: ${unreadResponse.statusCode}');
    print('📦 Unread body: ${unreadResponse.body}');

    if (ownersResponse.statusCode == 200 && unreadResponse.statusCode == 200) {
      final decodedOwners = json.decode(ownersResponse.body);
      final List owners = decodedOwners is List
          ? decodedOwners
          : decodedOwners['owners'] ?? [];

      final List<Map<String, dynamic>> unread =
          List<Map<String, dynamic>>.from(json.decode(unreadResponse.body));

      final Map<String, int> unreadCounts = {
        for (var item in unread) item['_id']: item['count']
      };

      return {
        'owners': owners,
        'unreadCounts': unreadCounts,
      };
    } else {
      throw Exception('❌ Failed to load owners or unread');
    }
  } catch (e) {
    print('❗ Exception in fetchOwnersWithUnread: $e');
    rethrow;
  }
}




Future<Map<String, int>> fetchUnreadCounts() async {
  final response = await http.get(
    Uri.parse('${dotenv.env['BASE_URL']}/messages/unread/admin'),
  );
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return {
      for (var entry in data) entry['_id']: entry['count'] as int,
    };
  } else {
    return {};
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
  backgroundColor: Colors.white,
  automaticallyImplyLeading: false,
  leading: IconButton(
    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
    onPressed: () => Navigator.pop(context),
  ),
  title: Text(
    'Admin Messages',
    style: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  ),
  elevation: 0,
  centerTitle: true,
),

        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
               Padding(
  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
  child: Text(
    'View and manage your conversations with all owners:',
    style: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
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
                                     

child: FutureBuilder<Map<String, dynamic>>(
  future: fetchOwnersWithUnread(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Text('Error loading data');
    } else {
      final owners = snapshot.data!['owners'] as List;
      final unreadCounts = snapshot.data!['unreadCounts'] as Map<String, int>;

      return ListView.builder(
        shrinkWrap: true,
physics: NeverScrollableScrollPhysics(),

        itemCount: owners.length,
        itemBuilder: (context, index) {
          final owner = owners[index];
          final unread = unreadCounts[owner['_id']];

          return ListTile(
  leading: CircleAvatar(
    backgroundColor: const Color(0xFF998BCF),
    child: Text(
      owner['name'][0].toUpperCase(),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ),
  title: Text(
    owner['name'],
    style: const TextStyle(fontWeight: FontWeight.w600),
  ),
  subtitle: Text(owner['email']),
  trailing: unread != null
      ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$unread',
            style: const TextStyle(color: Colors.white),
          ),
        )
      : const Icon(Icons.chevron_right),
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatWithOwnerWidget(ownerId: owner['_id']),
      ),
    );
    setState(() {}); // Refresh unread count
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
