// ignore_for_file: unused_field, unused_import, unused_element, unused_local_variable

import 'package:cadeau_project/custom/icon_button.dart';
import 'package:cadeau_project/owner/menu/ownermenu_widget.dart';

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
import 'addcategory_model.dart';
export 'addcategory_model.dart';

class AddcategoryWidget extends StatefulWidget {
  
final String ownerId; // 

  const AddcategoryWidget({Key? key, required this.ownerId}) : super(key: key); 
  static String routeName = 'addcategory';
  static String routePath = '/addcategory';

  @override
  State<AddcategoryWidget> createState() => _AddcategoryWidgetState();
}

class _AddcategoryWidgetState extends State<AddcategoryWidget> {
  
  late AddcategoryModel _model;
File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddcategoryModel());
     String? choiceChipsValue;
    _model.keyTextController ??= TextEditingController();
    _model.keyFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }
 Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Update button press handler
  Future<void> _createCategory() async {
    if (_model.keyTextController.text.isEmpty ||
        _model.choiceChipsValue == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.127:5000/api/categories'),
    );

    request.fields['name'] = _model.keyTextController.text;
    request.fields['icon'] = _model.choiceChipsValue!;

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _selectedImage!.path,
    ));

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Category created successfully!')),
      );

      setState(() {
        _model.keyTextController?.clear();
        _model.choiceChipsValue = null;
        _selectedImage = null;
      });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${await response.stream.bytesToString()}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  Widget _buildImageWidget() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
  width: 160,
  height: 160,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: const Color.fromARGB(255, 177, 158, 203),
    border: Border.all(color: const Color.fromARGB(255, 129, 7, 194), width: 3),
    image: _selectedImage != null
        ? DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: _selectedImage == null
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 40, color: Colors.grey[700]),
            SizedBox(height: 8),
            Text('Upload Image', style: TextStyle(fontSize: 12)),
          ],
        )
      : null,
),

    );
  }
  final List<Map<String, dynamic>> _iconDataList = [
  {'label': 'Clothing', 'icon': Icons.dry_cleaning_sharp},
  {'label': 'Luxury gift', 'icon': Icons.monetization_on_rounded},
  {'label': 'Pet Accessories', 'icon': Icons.pets_outlined},
  {'label': 'Gardening Kits', 'icon': Icons.forest},
  {'label': 'Makeup', 'icon': Icons.face_3},
  {'label': 'Handmade', 'icon': Icons.handshake_rounded},
  {'label': 'Whatches', 'icon': Icons.watch_sharp},
  {'label': 'Flowers', 'icon': Icons.spa},
  {'label': 'Perfumes & Fragrances', 'icon': FontAwesomeIcons.airFreshener},
  {'label': 'BabyCare', 'icon': FontAwesomeIcons.babyCarriage},
  {'label': 'Surprise Boxes', 'icon': Icons.card_giftcard},
  {'label': 'Bags & Wallets', 'icon': FontAwesomeIcons.shoppingBag},
  {'label': 'Sunglasses', 'icon': FontAwesomeIcons.glasses},
  {'label': 'Personalized Mugs', 'icon': FontAwesomeIcons.mugHot},
  {'label': 'Art Supplies', 'icon': Icons.brush},
  {'label': 'Sports & Fitness', 'icon': FontAwesomeIcons.dumbbell},
  {'label': 'Board Games', 'icon': FontAwesomeIcons.chess},
  {'label': 'Jewlery', 'icon': FontAwesomeIcons.sketch},
  {'label': 'Instruments', 'icon': FontAwesomeIcons.guitar},
  {'label': 'Chocolate Boxes', 'icon': FontAwesomeIcons.boxOpen},
  {'label': 'Travel Accessories', 'icon': Icons.airplanemode_active},
  {'label': 'Phone Accessories', 'icon': Icons.phone_iphone},
  {'label': 'Car Accessories', 'icon': Icons.directions_car},
  {'label': 'Other', 'icon': FontAwesomeIcons.modx},
];

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
    'Create Category',
    style: FlutterFlowTheme.of(context).headlineMedium.override(
          fontFamily: 'Outfit',
          color: Colors.white,
          fontSize: 20,
          letterSpacing: 0.0,
        ),
  ),
  actions: [
    Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 12, 8),
      child: FlutterFlowIconButton(
        borderColor: FlutterFlowTheme.of(context).alternate,
        borderRadius: 12,
        borderWidth: 1,
        buttonSize: 40,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
        icon: Icon(
          Icons.close_rounded,
          color: FlutterFlowTheme.of(context).primaryText,
          size: 24,
        ),
        onPressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OwnermenuWidget(ownerId: widget.ownerId),
            ),
          );
        },
      ),
    ),
  ],
  centerTitle: false,
  elevation: 0,
),

        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                        child: Text(
                          'Enter details to create a category',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                      Padding(
  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
  child: _buildImageWidget(),
),
                      Container(
                        width: 370,
                        child: TextFormField(
                          controller: _model.keyTextController,
                          focusNode: _model.keyFocusNode,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'category name...',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0.0,
                                ),
                            alignLabelWithHint: true,
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0.0,
                                ),
                            errorStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Outfit',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 129, 7, 194),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 129, 7, 194),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            contentPadding:
                                EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                  ),
                          minLines: 1,
                          cursorColor: FlutterFlowTheme.of(context).primary,
                          validator: _model.keyTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),

                                child: Text(
                                  'Category icon',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Outfit',
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                             GridView.count(
  crossAxisCount: 3,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  padding: const EdgeInsets.all(8),
  children: List.generate(_iconDataList.length, (index) {
    final item = _iconDataList[index];
    final label = item['label'];
    final icon = item['icon'];
    final isSelected = _model.choiceChipsValue == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _model.choiceChipsValue = label;
          print("Selected: $label");
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: isSelected
                  ? Border.all(color: Color(0xFF998BCF), width: 3)
                  : null,
            ),
            child: Icon(
              icon,
              size: 30,
              color: isSelected ? Color(0xFF998BCF) : Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Color(0xFF998BCF) : Colors.black,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }),
),



                            ],
                          ),
                        ),
                      ),
                     
                    ].divide(SizedBox(height: 23)),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                        child: FFButtonWidget(
                          onPressed: _createCategory,
                          text: 'Create Category',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 48,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            iconPadding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: Color(0xFF998BCF),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Outfit',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 3,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  

Widget _buildGridIcon(String label, IconData icon) {
  bool isSelected = _model.choiceChipsValue == label;

  return GestureDetector(
    onTap: () {
      setState(() {
        print("Selected: $label");
        _model.choiceChipsValue = label;
      });
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
  shape: BoxShape.circle,
color: isSelected ? Colors.red : Colors.grey[200],

  border: isSelected
      ? Border.all(
          color: Color(0xFF998BCF),
          width: 3,
        )
      : null,
  boxShadow: isSelected
      ? [
          BoxShadow(
            color: Color(0xFF998BCF).withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ]
      : [],
),
          padding: EdgeInsets.all(16),
          child: Icon(
            icon,
            size: 28,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Color(0xFF998BCF) : Colors.black87,
          ),
        )
      ],
    ),
  );
}


}
