import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditCategoryWidget extends StatefulWidget {
  final String categoryId;
  final String currentName;
  final String? currentImage;

  const EditCategoryWidget({
    Key? key,
    required this.categoryId,
    required this.currentName,
    this.currentImage,
  }) : super(key: key);

  @override
  _EditCategoryWidgetState createState() => _EditCategoryWidgetState();
}

class _EditCategoryWidgetState extends State<EditCategoryWidget> {
  late TextEditingController _nameController;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  Future<void> _pickNewImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
      });
    }
  }

  Future<void> _submitEdit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Name can't be empty.")));
      return;
    }

    final uri = Uri.parse('${dotenv.env['BASE_URL']}/api/categories/${widget.categoryId}');
    var request = http.MultipartRequest('PUT', uri);
    request.fields['name'] = _nameController.text;

    if (_newImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _newImageFile!.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Category updated successfully.")));
        Navigator.pop(context, true);
      } else {
        final error = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('/uploads/')) {
      return '${dotenv.env['BASE_URL']}$imagePath';
    }
    return '${dotenv.env['BASE_URL']}/uploads/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Custom Top Bar
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Edit Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Image Picker
                GestureDetector(
                  onTap: _pickNewImage,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF998BCF), width: 3),
                      image: _newImageFile != null
                          ? DecorationImage(image: FileImage(_newImageFile!), fit: BoxFit.cover)
                          : (widget.currentImage != null
                              ? DecorationImage(
                                  image: NetworkImage(_getFullImageUrl(widget.currentImage!)),
                                  fit: BoxFit.cover,
                                )
                              : null),
                      color: Colors.grey[200],
                    ),
                    child: _newImageFile == null && widget.currentImage == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey[600]),
                                SizedBox(height: 6),
                                Text('Change Image', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),

                SizedBox(height: 32),

                // Form card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF998BCF), width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _submitEdit,
                        icon: Icon(Icons.save),
                        label: Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF998BCF),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }
}
