// ignore_for_file: unused_import, unused_field, unused_local_variable

import 'dart:io';

import 'package:cadeau_project/custom/util.dart' as _picker;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import '/custom/choice_chips.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'editproduct_model.dart';
export 'editproduct_model.dart';
import 'dart:convert';

class EditproductWidget extends StatefulWidget {
  
final Map<String, dynamic> productData; // ✨ 

  const EditproductWidget({super.key, required this.productData});
  static String routeName = 'editproduct';
  static String routePath = '/editproduct';
  
  @override
  State<EditproductWidget> createState() => _EditproductWidgetState();
}

class _EditproductWidgetState extends State<EditproductWidget> {
  late EditproductModel _model;
  
  final scaffoldKey = GlobalKey<ScaffoldState>();
List<String> existingImageUrls = []; // الصور الموجودة في قاعدة البيانات
Map<int, File?> selectedImages = {};

   // الصور اللي المستخدم رح يختارهم
 List<String> imageUrls = [];
  Map<int, File> updatedImages = {};
  final ImagePicker _picker = ImagePicker();
 @override
void initState() {
  super.initState();
  _model = createModel(context, () => EditproductModel());
  _model.discountValue = widget.productData['isOnSale'] ?? false; 
  existingImageUrls = List<String>.from(widget.productData['imageUrls'] ?? []);
  _model.productNameTextController ??= TextEditingController(text: widget.productData['name'] ?? '');
  _model.productNameFocusNode ??= FocusNode();
imageUrls = List<String>.from(existingImageUrls);

  _model.descriptionTextController ??= TextEditingController(text: widget.productData['description'] ?? '');
  _model.descriptionFocusNode ??= FocusNode();

  final priceRange = widget.productData['priceRange'];
final minPrice = (priceRange is Map && priceRange.containsKey('min'))
    ? priceRange['min'].toString()
    : priceRange?.toString() ?? '';

_model.minpriceTextController ??= TextEditingController(text: minPrice);

  _model.minpriceFocusNode ??= FocusNode();

  _model.maxpriceTextController ??= TextEditingController(
    text: widget.productData['price']?.toString() ?? ''
  );
  _model.maxpriceFocusNode ??= FocusNode();

  _model.diciuntamountTextController ??= TextEditingController(
    text: widget.productData['discountAmount']?.toString() ?? ''
  );
  _model.diciuntamountFocusNode ??= FocusNode();

  _model.stockTextController ??= TextEditingController(
    text: widget.productData['stock']?.toString() ?? ''
  );
  _model.stockFocusNode ??= FocusNode();
}


  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }


Future<void> pickImage(int index) async {
  final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    setState(() {
      updatedImages[index] = File(picked.path);
    });
  }
}

Future<String> uploadImageToStorage(File imageFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${dotenv.env['BASE_URL']}/api/upload-image'),
  );
  request.files.add(
    await http.MultipartFile.fromPath('image', imageFile.path),
  );
  var response = await request.send();

  if (response.statusCode == 200) {
    var resString = await response.stream.bytesToString();
    var data = jsonDecode(resString);
    return data['imageUrl']; // حسب اللي بيرجعه السيرفر
  } else {
    throw Exception('Failed to upload image');
  }
}



  @override
  Widget build(BuildContext context) {
    final int imageCount = 3;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              
              children: [
Padding(
  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
  child: Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back, color: Colors.black, size: 26),
      ),
      const SizedBox(width: 12),
      Text(
        'Edit Product', // or 'Details', 'Edit Product'
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    ],
  ),
),


                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                  
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: TextFormField(
                            controller: _model.productNameTextController,
                            focusNode: _model.productNameFocusNode,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Product name...',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                    color: Colors.black,
                                  ),
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
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 124, 177, 255),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                              .primary,
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
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16, 20, 16, 20),
                            ),
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                      color: Colors.black,
                                    ),
                            cursorColor: FlutterFlowTheme.of(context).primary,
                            validator: _model.productNameTextControllerValidator
                                .asValidator(context),
                          ),
                          
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical:4),
                          child: TextFormField(
                            controller: _model.descriptionTextController,
                            focusNode: _model.descriptionFocusNode,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Description...',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                    color: Colors.black,
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
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 124, 177, 255),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                              .primary,
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
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16, 16, 16, 16),
                            ),
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                      color: Colors.black,
                                    ),
                            maxLines: 9,
                            minLines: 4,
                            cursorColor: FlutterFlowTheme.of(context).primary,
                            validator: _model.descriptionTextControllerValidator
                                .asValidator(context),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(13, 15, 13, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Starting Price',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                    ),
                                    TextFormField(
                                      controller: _model.minpriceTextController,
                                      focusNode: _model.minpriceFocusNode,
                                      autofocus: true,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        
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
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(255, 124, 177, 255),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                              .primary,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                16, 16, 16, 16),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                      minLines: 1,
                                      cursorColor:
                                          FlutterFlowTheme.of(context).primary,
                                      validator: _model
                                          .minpriceTextControllerValidator
                                          .asValidator(context),
                                    ),
                                    Text(
                                      'Highest Price',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                    ),
                                    TextFormField(
                                      controller: _model.maxpriceTextController,
                                      focusNode: _model.maxpriceFocusNode,
                                      autofocus: true,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        
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
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(255, 124, 177, 255),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                              .primary,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                16, 16, 16, 16),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                      minLines: 1,
                                      cursorColor:
                                          FlutterFlowTheme.of(context).primary,
                                      validator: _model
                                          .maxpriceTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ].divide(SizedBox(height: 4)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                                  Text(
                                                    'Cash discount?',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily: 'Outfit',
                                                          letterSpacing: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                                  Switch.adaptive(
                                                  value: _model.discountValue ?? false,
  onChanged: (value) {
    setState(() {
      _model.discountValue = value;
    });
  },
                                                    activeColor: Colors.white, // 🟢 Thumb color when ON
  activeTrackColor: Color.fromARGB(255, 124, 177, 255), // 🟣 Track color when ON (your theme)
  inactiveThumbColor: Colors.white, // ⚪ Thumb color when OFF
  inactiveTrackColor: Color(0xFFD3CCE3),
                                                  ),
                                                  Text(
                                                    'dicount amount',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily: 'Outfit',
                                                          letterSpacing: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                                  TextFormField(
                                                    controller: _model
                                                        .diciuntamountTextController,
                                                    focusNode: _model
                                                        .diciuntamountFocusNode,
                                                    autofocus: true,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                     
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      alignLabelWithHint: true,
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      errorStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:Color.fromARGB(255, 124, 177, 255),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      filled: true,
                                                      fillColor: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      contentPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(16, 16,
                                                                  16, 16),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily: 'Outfit',
                                                          letterSpacing: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .diciuntamountTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ].divide(SizedBox(height: 4)),
                                ),
                              ),
                            ].divide(SizedBox(width: 12)),
                          ),
                        ),
                        Container(
                  height: 100,
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0.0,
                                  color: Colors.black,
                                ),
                          ),
                          
                              Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 13, 0, 0),
                              child: Container(
                                width: 370,
                                child: TextFormField(
                                  controller: _model.stockTextController,
                                  focusNode: _model.stockFocusNode,
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.words,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    
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
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          fontSize: 12,
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(255, 124, 177, 255),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                              .primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            16, 16, 16, 16),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                        color: Colors.black,
                                      ),
                                  minLines: 1,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model.stockTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
                      ].divide(SizedBox(height: 10)),
                    ),
                  ),
                ),
                
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
    ],
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                      child: FFButtonWidget(
  onPressed: () async {
    final Map<String, dynamic> updates = {};

    if (_model.productNameTextController.text.trim() != (widget.productData['name'] ?? '')) {
      updates['name'] = _model.productNameTextController.text.trim();
    }
    if (_model.descriptionTextController.text.trim() != (widget.productData['description'] ?? '')) {
      updates['description'] = _model.descriptionTextController.text.trim();
    }
    if (_model.minpriceTextController.text.isNotEmpty &&
        _model.minpriceTextController.text != widget.productData['priceRange']?.toString()) {
      updates['priceRange'] = double.tryParse(_model.minpriceTextController.text) ?? 0.0;
    }
    if (_model.maxpriceTextController.text.isNotEmpty &&
        _model.maxpriceTextController.text != widget.productData['price']?.toString()) {
      updates['price'] = double.tryParse(_model.maxpriceTextController.text) ?? 0.0;
    }
    if (_model.diciuntamountTextController.text.isNotEmpty &&
        _model.diciuntamountTextController.text != widget.productData['discountAmount']?.toString()) {
      updates['discountAmount'] = double.tryParse(_model.diciuntamountTextController.text) ?? 0.0;
    }
    if (_model.stockTextController.text.isNotEmpty &&
        _model.stockTextController.text != widget.productData['stock']?.toString()) {
      updates['stock'] = int.tryParse(_model.stockTextController.text) ?? 0;
    }
    if (_model.discountValue != null &&
    _model.discountValue != (widget.productData['isOnSale'] ?? false)) {
  updates['isOnSale'] = _model.discountValue!;
}

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No changes made')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${dotenv.env['BASE_URL']}/api/${widget.productData['_id']}'), // ✅ الرابط الصحيح مع الـ ID
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );
      print('Status code: ${response.statusCode}');
print('Response body: ${response.body}');
print('Sent updates: $updates');
print('Product ID: ${widget.productData['productId']}');

      
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
       
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  },
  
  text: 'Save Changes',
  options: FFButtonOptions(
    width: double.infinity,
    height: 48,
    color: Color.fromARGB(255, 124, 177, 255),
    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
      fontFamily: 'Outfit',
      color: Colors.white,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
),

                    ),
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
