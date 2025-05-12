// ignore_for_file: unused_import, unused_local_variable

import 'package:cadeau_project/owner/profile/owner_edit/editproduct_widget.dart';

import '/custom/choice_chips.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;

import 'product_display_model.dart';
export 'product_display_model.dart';

class ProductDisplayWidget extends StatefulWidget {
 
final Map<String, dynamic> productData;

  const ProductDisplayWidget({super.key, required this.productData});
  static String routeName = 'ProductDisplay';
  static String routePath = '/productDisplay';

  @override
  State<ProductDisplayWidget> createState() => _ProductDisplayWidgetState();
}

class _ProductDisplayWidgetState extends State<ProductDisplayWidget> {
  late ProductDisplayModel _model;
  PageController _pageController = PageController();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductDisplayModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final product = widget.productData;

  return Scaffold(
    key: scaffoldKey,
    backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
    appBar: AppBar(
      backgroundColor: Color(0xFF998BCF),
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30,
        borderWidth: 1,
        buttonSize: 60,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Details',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: FlutterFlowTheme.of(context).secondaryBackground,
              letterSpacing: 0.0,
            ),
      ),
      centerTitle: false,
      elevation: 0,
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    children: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF998BCF),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 230,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: product['imageUrls']?.length ?? 1,
              itemBuilder: (context, index) {
                final imageUrl = (product['imageUrls'] != null && product['imageUrls'].isNotEmpty)
                    ? product['imageUrls'][index]
                    : 'https://via.placeholder.com/120';
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 230,
                );
              },
            ),
          ),
        ),
      ),
      SizedBox(height: 8),
      SmoothPageIndicator(
        controller: _pageController,
        count: product['imageUrls']?.length ?? 1,
        effect: ExpandingDotsEffect(
          activeDotColor: Color(0xFF998BCF), // ✨ نفس لون الأب بار
          dotColor: Colors.grey.shade300,
          dotHeight: 8,
          dotWidth: 8,
          expansionFactor: 2,
          spacing: 6,
        ),
      ),
    ],
  ),
),



       Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        product['name'] ?? 'No Name',
        style: FlutterFlowTheme.of(context).headlineLarge.override(
          fontFamily: 'Outfit',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 6),
      Text(
        product['description'] ?? 'No Description',
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    ],
  ),
),



          Divider(height: 24, thickness: 1),

      // --- تفاصيل الأسعار ---
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(2, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Info',
          style: FlutterFlowTheme.of(context).titleMedium.override(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),

        buildPriceRow(Icons.attach_money, 'Starting Price', '\$${product['priceRange'] ?? product['price'] ?? 'N/A'}'),
        buildPriceRow(Icons.local_offer, 'Is On Sale?', product['isOnSale'] == true ? 'Yes' : 'No'),
        if (product['discountAmount'] != null)
          buildPriceRow(Icons.discount, 'Discount', '\$${product['discountAmount']}'),
        buildPriceRow(Icons.price_change, 'Final Price', '\$${product['price']}'),
        buildPriceRow(Icons.inventory_2, 'Stock', '${product['stock'] ?? 'N/A'}'),
      ],
    ),
  ),
),

      Divider(height: 24, thickness: 1),

          // Display Recipients
          if (product['recipientType'] != null)
  buildChipsSection('Recipients', product['recipientType'], Icons.person),
if (product['occasion'] != null)
  buildChipsSection('Occasions', product['occasion'], Icons.event),
if (product['keywords'] != null)
  buildChipsSection('Keywords', product['keywords'], Icons.tag),


      SizedBox(height: 24),

          // Bottons Section (Edit + Delete)
          SizedBox(height: 24),
         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  child: Row(
    children: [
      // زر Edit
      Expanded(
        child: FFButtonWidget(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditproductWidget(
                  productData: widget.productData,
                ),
              ),
            );
          },
          text: 'Edit',
          options: FFButtonOptions(
            height: 48,
            color: Color(0xFF998BCF),
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Outfit',
              color: Colors.white,
            ),
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      SizedBox(width: 12),

      // زر Delete
      Expanded(
        child: FFButtonWidget(
          onPressed: () async {
            final confirmDelete = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Row(
      children: [
        Icon(Icons.delete_forever, color: Color(0xFFD01C42)),
        SizedBox(width: 8),
        Text('Delete Product'),
      ],
    ),
    content: Text('Are you sure you want to delete this product? This action cannot be undone.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD01C42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pop(context, true),
        child: Text('Yes, Delete'),
      ),
    ],
  ),
);


            if (confirmDelete == true) {
              try {
                final response = await http.delete(
                  Uri.parse('http://192.168.1.127:5000/api/${widget.productData['productId']}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
                  },
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product deleted successfully')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete product')),
                  );
                }
              } catch (e) {
                print('Error deleting product: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('An error occurred')),
                );
              }
            }
          },
          text: 'Delete',
          options: FFButtonOptions(
            height: 48,
            color: Color(0xFFD01C42),
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Outfit',
              color: Colors.white,
            ),
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  ),
),

          SizedBox(height: 24),
        ],
      ),
    ),
  );
}

Widget buildChipsSection(String title, List<dynamic> items, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF998BCF), size: 20),
            SizedBox(width: 6),
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Outfit',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF998BCF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}



Widget buildInfoRow(String title, String value) {
  final bool isStock = title.toLowerCase().contains('stock');

  return Padding(
    padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'Outfit',
                fontSize: 16,
                letterSpacing: 0.0,
                color: Colors.black, // ✨ العنوان أسود عادي
              ),
        ),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: isStock ? FontWeight.bold : FontWeight.normal,
                color: isStock
                    ? Colors.black87
                    : FlutterFlowTheme.of(context).primaryText, // ✨ نفس لون السهم
              ),
        ),
      ],
    ),
  );
}

Widget buildPriceRow(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: Color(0xFF998BCF), size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Outfit',
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyLarge.override(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}



}
