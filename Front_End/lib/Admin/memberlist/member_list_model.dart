import 'package:cadeau_project/custom/form_field_controller.dart';
import 'package:flutter/material.dart';

class MemberListModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';
  final List<Map<String, dynamic>> members = [
    {
      'name': 'Admin User',
      'email': 'admin@domainname.com',
      'isOwner': true,
    },
    {
      'name': 'Regular User',
      'email': 'user@domainname.com',
      'isOwner': false,
    },
    {
      'name': 'Business Owner',
      'email': 'owner@domainname.com',
      'isOwner': true,
    },
  ];

  late FormFieldController<List<String>> choiceChipsValueController;

  var choiceChipsValue;

  var textControllerValidator;

  var textController;

  List<Map<String, dynamic>> get filteredMembers {
    final searchQuery = searchController.text.toLowerCase();
    return members.where((member) {
      final matchesSearch = member['name'].toLowerCase().contains(searchQuery) ||
          member['email'].toLowerCase().contains(searchQuery);
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Owners' && member['isOwner']) ||
          (selectedFilter == 'Users' && !member['isOwner']);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  get textFieldFocusNode => null;

  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void deleteMember(int index) {
    members.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}