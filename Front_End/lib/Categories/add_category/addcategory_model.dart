// ignore_for_file: unused_import, must_call_super

import '/custom/choice_chips.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import '/custom/upload_data.dart';
import 'dart:ui';
import 'addcategory_widget.dart' show AddcategoryWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddcategoryModel extends FlutterFlowModel<AddcategoryWidget> with ChangeNotifier {
  ///  State fields for stateful widgets in this page.

  // State field(s) for key widget.
  FocusNode? keyFocusNode;
  TextEditingController? keyTextController;
  String? Function(BuildContext, String?)? keyTextControllerValidator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  
      String? _choiceChipsValue;
  
  // Update getter and setter
  String? get choiceChipsValue => _choiceChipsValue;
  
  set choiceChipsValue(String? value) {
    _choiceChipsValue = value;
    notifyListeners(); // This will trigger UI update
  }
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    keyFocusNode?.dispose();
    keyTextController?.dispose();
  }
}
