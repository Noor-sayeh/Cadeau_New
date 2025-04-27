// ignore_for_file: unused_import, unused_element

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
      Uri.parse('http://192.168.1.104:5000/api/categories'),
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
        width: 358.5,
        height: 259.1,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _selectedImage != null
            ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40),
                  Text('Upload Category Image'),
                ],
              ),
      ),
    );
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
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                        ),
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
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                            alignLabelWithHint: true,
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                            errorStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
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
                                    fontFamily: 'Inter',
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 12, 0, 20),
                                child: Text(
                                  'Category icon',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              FlutterFlowChoiceChips(
                                options: [
                                  ChipData(
                                      'Clothing', Icons.dry_cleaning_sharp),
                                  ChipData('Luxury gift',
                                      Icons.monetization_on_rounded),
                                  ChipData(
                                      'Pet Accessories', Icons.pets_outlined),
                                  ChipData('Gardening Kits', Icons.forest),
                                  ChipData('Makeup', Icons.face_3),
                                  ChipData('Handmade', Icons.handshake_rounded),
                                  ChipData('Whatches', Icons.watch_sharp),
                                  ChipData('Flowers', Icons.spa),
                                  ChipData('Perfumes & Fragrances',
                                      FontAwesomeIcons.airFreshener),
                                  ChipData('BabyCare',
                                      FontAwesomeIcons.babyCarriage),
                                  ChipData(
                                      'Surprise Boxes', Icons.card_giftcard),
                                  ChipData('Bags & Wallets',
                                      FontAwesomeIcons.shoppingBag),
                                  ChipData(
                                      'Sunglasses', FontAwesomeIcons.glasses),
                                  ChipData('Personalized Mugs',
                                      FontAwesomeIcons.mugHot),
                                  ChipData('Art Supplies', Icons.brush),
                                  ChipData('Sports & Fitness',
                                      FontAwesomeIcons.dumbbell),
                                  ChipData(
                                      'Board Games', FontAwesomeIcons.chess),
                                  ChipData('Jewlery', FontAwesomeIcons.sketch),
                                  ChipData(
                                      'instruments', FontAwesomeIcons.guitar),
                                  ChipData('Chocolate Boxes',
                                      FontAwesomeIcons.boxOpen),
                                  ChipData('Travel Accessories',
                                      Icons.airplanemode_active),
                                  ChipData(
                                      'Phone Accessories', Icons.phone_iphone),
                                  ChipData(
                                      'Car Accessories', Icons.directions_car),
                                  ChipData('Other', FontAwesomeIcons.modx)
                                ],
                                onChanged: (val) => safeSetState(() =>
                                    _model.choiceChipsValue = val?.firstOrNull),
                                selectedChipStyle: ChipStyle(
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).accent2,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                      ),
                                  iconColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  iconSize: 18,
                                  elevation: 0,
                                  borderColor:
                                      FlutterFlowTheme.of(context).secondary,
                                  borderWidth: 2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                unselectedChipStyle: ChipStyle(
                                  backgroundColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                  iconColor: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  iconSize: 18,
                                  elevation: 0,
                                  borderColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  borderWidth: 2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                chipSpacing: 8,
                                rowSpacing: 8,
                                multiselect: false,
                                initialized: _model.choiceChipsValue != null,
                                alignment: WrapAlignment.start,
                                controller:
                                    _model.choiceChipsValueController ??=
                                        FormFieldController<List<String>>(
                                  ['Tops'],
                                ),
                                wrapped: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                     Padding(
  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
  child: _buildImageWidget(),
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
                          text: 'Create Product',
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
                                  fontFamily: 'Inter Tight',
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
}
