import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class AdminAllReviewsWidget extends StatefulWidget {
  const AdminAllReviewsWidget({super.key});

  @override
  State<AdminAllReviewsWidget> createState() => _AdminAllReviewsWidgetState();
}

class _AdminAllReviewsWidgetState extends State<AdminAllReviewsWidget> {
  List<dynamic> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllReviews();
  }

  // Fetch all reviews from the backend
  Future<void> fetchAllReviews() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/admin/all-reviews');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reviews = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() => isLoading = false);
    }
  }

  // Generate consistent background color from a string
  Color _getColorFromName(String name) {
    final hash = name.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB), // Light neutral background
      appBar: AppBar(
        title: const Text(
          '⭐ User feedback',
          style: TextStyle(
            fontSize: 18, // Slightly smaller title font
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color.fromARGB(255, 3, 1, 18),
        elevation: 1,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? const Center(child: Text('No reviews found.'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${reviews.length} reviews found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  )
                                ],
                              ),
                              child: ListTile(
                                leading: review['userAvatar'] != null &&
                                        review['userAvatar'].isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(review['userAvatar']),
                                        radius: 24,
                                      )
                                    : CircleAvatar(
                                        backgroundColor: _getColorFromName(
                                            review['userName'] ?? ''),
                                        radius: 24,
                                        child: Text(
                                          review['userName']?[0]
                                                  ?.toUpperCase() ??
                                              '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                title: Text('${review['userName']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('“${review['comment']}”'),
                                    const SizedBox(height: 4),
                                    Text(
                                      '⭐ ${review['rating']} – ${review['productName']} • ${DateFormat.yMMMd().format(DateTime.parse(review['createdAt']))}',
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13),
                                    ),
                                    if (review['productOwnerName'] != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Owner: ${review['productOwnerName']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
