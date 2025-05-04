// ignore_for_file: unused_import

import '/custom/choice_chips.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import 'dart:ui';
import 'editproduct_widget.dart' show EditproductWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditproductModel extends FlutterFlowModel<EditproductWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for productName widget.
  FocusNode? productNameFocusNode;
  TextEditingController? productNameTextController;
  String? Function(BuildContext, String?)? productNameTextControllerValidator;
  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;
  // State field(s) for minprice widget.
  FocusNode? minpriceFocusNode;
  TextEditingController? minpriceTextController;
  String? Function(BuildContext, String?)? minpriceTextControllerValidator;
  // State field(s) for maxprice widget.
  FocusNode? maxpriceFocusNode;
  TextEditingController? maxpriceTextController;
  String? Function(BuildContext, String?)? maxpriceTextControllerValidator;
  // State field(s) for dicount widget.
  bool? discountValue;
  // State field(s) for diciuntamount widget.
  FocusNode? diciuntamountFocusNode;
  TextEditingController? diciuntamountTextController;
  String? Function(BuildContext, String?)? diciuntamountTextControllerValidator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  List<String>? get choiceChipsValues => choiceChipsValueController?.value;
  set choiceChipsValues(List<String>? val) =>
      choiceChipsValueController?.value = val;
  // State field(s) for stock widget.
  FocusNode? stockFocusNode;
  TextEditingController? stockTextController;
  String? Function(BuildContext, String?)? stockTextControllerValidator;

  var discountValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    productNameFocusNode?.dispose();
    productNameTextController?.dispose();

    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();

    minpriceFocusNode?.dispose();
    minpriceTextController?.dispose();

    maxpriceFocusNode?.dispose();
    maxpriceTextController?.dispose();

    diciuntamountFocusNode?.dispose();
    diciuntamountTextController?.dispose();

    stockFocusNode?.dispose();
    stockTextController?.dispose();
  }
}
