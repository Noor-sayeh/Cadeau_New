// ignore_for_file: duplicate_import, unused_import

import 'dart:convert';

import 'package:cadeau_project/owner/details/owner_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cadeau_project/custom/icon_button.dart';
import 'package:cadeau_project/owner/menu/ownermenu_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/custom/choice_chips.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import '/custom/upload_data.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
class MemberListModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';

  List<User> _allUsers = [];
  bool isLoading = true;
  String? error;

  final Set<String> selectedUserIds = {};

  List<User> get filteredUsers {
    final searchQuery = searchController.text.toLowerCase();
  return _allUsers.where((user) {
    final isNotAdmin = user.role.toLowerCase() != 'admin';
    final matchesSearch = user.name.toLowerCase().contains(searchQuery) ||
        user.email.toLowerCase().contains(searchQuery);
    final matchesFilter = selectedFilter == 'All' ||
        (selectedFilter == 'Owners' && user.role.toLowerCase() == 'owner') ||
        (selectedFilter == 'Users' && user.role.toLowerCase() != 'owner');
    return isNotAdmin && matchesSearch && matchesFilter;
  }).toList();
  }

  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  void deleteSelectedUsers() async {
  final idsToDelete = selectedUserIds.toList();
  try {
    await Future.wait(idsToDelete.map((id) async {
      await deleteUser(id);
      _allUsers.removeWhere((user) => user.id == id);
    }));
  } catch (e) {
    error = 'Failed to delete one or more users';
  }

  selectedUserIds.clear();
  notifyListeners();
}


  Future<void> fetchUsers() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await http.get(Uri.parse('http://192.168.1.127:5000/api/users'));
      if (response.statusCode == 200) {
        final List usersJson = json.decode(response.body);
        _allUsers = usersJson.map((json) => User.fromJson(json)).toList();
        error = null;
      } else {
        error = 'Failed to load users';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}


class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatar;

  User({required this.id, required this.name, required this.email, required this.role, required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      avatar: json['avatar'] ?? '',
    );
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('http://192.168.1.127:5000/api/users'));
  if (response.statusCode == 200) {
    final List usersJson = json.decode(response.body);
    return usersJson.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}
Future<void> deleteUser(String id) async {
  final url = Uri.parse('http://192.168.1.127:5000/api/users/$id');

  final response = await http.delete(url);
  if (response.statusCode != 200) {
    throw Exception('Failed to delete user');
  }
}

class MemberListPage extends StatelessWidget {
  const MemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemberListModel()..fetchUsers(),
      child: Scaffold(
        appBar: AppBar(
  title:  Text(
  'Members',
  style: FlutterFlowTheme.of(context).titleLarge.override(
    fontFamily: 'Outfit',
    color: Color.fromARGB(255, 124, 107, 146),
    fontSize: 23, // Your custom size
    letterSpacing: 0,
  ),
),

  iconTheme: IconThemeData(color: Colors.white),
  leading: IconButton(
  icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 88, 84, 84)),
  onPressed: () {
    Navigator.pop(context); // This pops the current route
  },
),
 // Back icon
  backgroundColor: const Color.fromARGB(255, 251, 244, 255), ///const Color.fromARGB(255, 251, 244, 255),
  elevation: 0,
  actionsIconTheme: IconThemeData(color: const Color.fromARGB(255, 88, 84, 84)), // Add + Trash icons
  actions: [
    Consumer<MemberListModel>(
      builder: (context, model, _) {
        return Row(
          children: [
            if (model.selectedFilter == 'Owners')
              IconButton(
                icon: Icon(Icons.add),
                tooltip: 'Add Owner',
                onPressed: () {
                 Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => OwnerDetailsWidget()),
);

                  // Show dialog or route
                },
              ),
            if (model.selectedUserIds.isNotEmpty)
  IconButton(
    icon: Icon(Icons.delete),
    tooltip: 'Delete Selected',
    onPressed: () async {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the selected users? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 124, 107, 146),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        model.deleteSelectedUsers();
      }
    },
  ),

          ],
        );
      },
    ),
  ],
),

        body: Consumer<MemberListModel>(
          builder: (context, model, _) {
            
            if (model.isLoading) {
              return Center(child: CircularProgressIndicator(color: mainPurple));
            }

            if (model.error != null) {
              return Center(child: Text('Error: ${model.error}'));
            }

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: model.searchController,
                   decoration: InputDecoration(
  hintText: 'Search by name or email...',
  prefixIcon: Icon(Icons.search, color: mainPurple),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: mainPurple, width: 2),
    borderRadius: BorderRadius.circular(12),
  ),
),

                    onChanged: (_) => model.notifyListeners(),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Owners', 'Users'].map((filter) {
                    final isSelected = model.selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(
    filter,
    style: TextStyle(color: isSelected ? Colors.white : mainPurple),
  ),
  selected: isSelected,
  selectedColor: mainPurple,
  backgroundColor: Colors.grey[200],
  onSelected: (_) => model.updateFilter(filter),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                Expanded(
                  
                  child: ListView.builder(
                    itemCount: model.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = model.filteredUsers[index];
                      final isSelected = model.selectedUserIds.contains(user.id);
                      return GestureDetector(
                        onLongPress: () => model.toggleUserSelection(user.id),
                        child: Container(
                          color: isSelected ? Colors.purple.withOpacity(0.1) : null,
                          child: buildUserTile(user, isSelected),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Color mainPurple = Color(0xFF998BCF);
Widget buildUserTile(User user, bool isSelected) {
  return Card(
    color: isSelected ? mainPurple.withOpacity(0.1) : Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
  side: BorderSide(color: mainPurple.withOpacity(0.3), width: 1),
),

    child: ListTile(
      leading: Container(
  padding: EdgeInsets.all(6),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: user.role.toLowerCase() == 'owner'
        ? [const Color.fromARGB(255, 224, 84, 246), const Color.fromARGB(255, 205, 40, 211)]
        : [Colors.blue, Colors.purple],
    ),
    border: Border.all(color: Colors.white, width: 2),
  ),
  child: Icon(
    user.role.toLowerCase() == 'owner'
      ? FontAwesomeIcons.userShield
      : FontAwesomeIcons.user,
    color: Colors.white,
    size: 18,
  ),
),


      title: Text(
        user.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: mainPurple,
        ),
      ),
      subtitle: Text(user.email),
      trailing: user.role.toLowerCase() == 'owner'
          ? Icon(Icons.shield_outlined, color: mainPurple)
          : null,
    ),
  );
}

