import 'package:cadeau_project/Admin/Categories/edit_category_widget.dart';
import 'package:cadeau_project/Categories/add_category/addcategory_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class AdminCategoryListPage extends StatefulWidget {
  const AdminCategoryListPage({Key? key}) : super(key: key);

  @override
  _AdminCategoryListPageState createState() => _AdminCategoryListPageState();
}

class _AdminCategoryListPageState extends State<AdminCategoryListPage> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['categories'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _deleteCategory(String id) async {
    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/api/categories/$id'),
    );
    if (response.statusCode == 200) {
      _fetchCategories(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category')),
      );
    }
  }

  String _getCategoryImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://placehold.co/300x300?text=Category';
    }
    if (imagePath.startsWith('/uploads/')) {
      return '${dotenv.env['BASE_URL']}$imagePath';
    }
    return '${dotenv.env['BASE_URL']}/uploads/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildAdminCard(category);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // navigate to create category screen
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AddcategoryWidget(
      ownerId: '68037c897aea2125f35f30a0',
      caller: 'admin',
    ),
  ),
);

        },
        backgroundColor: Color(0xFF6F61EF),
        shape: const CircleBorder(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAdminCard(dynamic category) {
    final name = category['name'] ?? 'Unnamed';
    final imageUrl = _getCategoryImageUrl(category['image']);
    final id = category['_id'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => Icon(Icons.broken_image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditCategoryWidget(
        categoryId: category['_id'],
        currentName: category['name'],
        currentImage: category['image'], // might be null
      ),
    ),
  );
},

                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, id, name),

                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  
void _showDeleteDialog(BuildContext context, String categoryId, String categoryName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Category'),
      content: Text('Are you sure you want to delete "$categoryName"? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Close the dialog
            await _deleteCategory(categoryId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Delete'),
        ),
      ],
    ),
  );
}
}

