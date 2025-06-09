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
      final ownersResponse = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/api/owners/all'));
      final unreadResponse = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/messages/unread/admin'));

      if (ownersResponse.statusCode == 200 && unreadResponse.statusCode == 200) {
        final decodedOwners = json.decode(ownersResponse.body);
        final List owners = decodedOwners is List ? decodedOwners : decodedOwners['owners'] ?? [];

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
        throw Exception('Failed to load owners or unread');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, int>> fetchUnreadCounts() async {
    final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/messages/unread/admin'));
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF8F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Admin Messages',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View and manage your conversations with all owners:',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchOwnersWithUnread(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Text('Error loading data');
                    } else {
                      final owners = snapshot.data!['owners'] as List;
                      final unreadCounts = snapshot.data!['unreadCounts'] as Map<String, int>;

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: owners.length,
                        itemBuilder: (context, index) {
                          final owner = owners[index];
                          final unread = unreadCounts[owner['_id']];

                          return Material(
                            color: Colors.white,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Color.fromARGB(255, 124, 177, 255),
                                child: Text(
                                  owner['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                owner['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(owner['email']),
                              trailing: unread != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$unread',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatWithOwnerWidget(ownerId: owner['_id']),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
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
