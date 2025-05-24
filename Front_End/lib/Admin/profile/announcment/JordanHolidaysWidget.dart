import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';



class JordanHolidaysWidget extends StatefulWidget {
  const JordanHolidaysWidget({super.key});

  @override
  State<JordanHolidaysWidget> createState() => _JordanHolidaysWidgetState();
}

class _JordanHolidaysWidgetState extends State<JordanHolidaysWidget> {
  final String apiKey = 'uubepAFbhk28YpAuLgDYogxLzLNRewHc'; // Replace with your real Calendarific key
   int selectedYear = 2025;
  int selectedMonth = 0; // 0 = All months

  List<dynamic> allHolidays = [];
  
bool isLoading = false;





@override
void initState() {
  super.initState();
  fetchJordanHolidays();
}


 Future<void> fetchJordanHolidays() async {
  setState(() => isLoading = true);
  final url = Uri.parse(
    'https://calendarific.com/api/v2/holidays?api_key=$apiKey&country=JO&year=$selectedYear',
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      allHolidays = data['response']['holidays'];
      isLoading = false;
    });
  } else {
    setState(() => isLoading = false);
    throw Exception('Failed to load holidays');
  }
}


  List<dynamic> get filteredHolidays {
    if (selectedMonth == 0) return allHolidays;
    return allHolidays.where((holiday) {
      return holiday['date']['datetime']['month'] == selectedMonth;
    }).toList();
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    '🇯🇴 2025 Jordan Occasions',
    style: TextStyle(
      color: Color.fromARGB(255, 124, 107, 146),
      fontFamily: 'Outfit', // Set title font
      fontWeight: FontWeight.bold, // Make the text bold for emphasis
      fontSize: 20, // Adjust font size if needed
      shadows: [
        Shadow(
          blurRadius: 10.0, // Adjust the blur radius for the shadow
          color: Colors.grey, // Semi-transparent black shadow
          offset: Offset(2.0, 2.0), // Set shadow offset for depth
        ),
      ],
    ),
  ),
  backgroundColor: const Color.fromARGB(255, 255, 246, 246), // Match the page background color
  elevation: 0, // Remove the shadow for a seamless look
),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Month Dropdown
                DropdownButton<int>(
                  value: selectedMonth,
                  onChanged: (value) {
                    setState(() => selectedMonth = value!);
                  },
                  items: [
                    DropdownMenuItem(value: 0, child: Text('All Months')),
                    for (int i = 1; i <= 12; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(monthName(i)),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Year Dropdown
                DropdownButton<int>(
                  value: selectedYear,
                  onChanged: (value) async {
                    setState(() => selectedYear = value!);
                    await fetchJordanHolidays(); // refetch holidays for new year
                  },
                  items: List.generate(10, (index) {
                    final year = 2023 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year'),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredHolidays.isEmpty
                      ? const Center(child: Text('No holidays found for this month'))
                      : ListView.builder(
                          itemCount: filteredHolidays.length,
                          itemBuilder: (context, index) {
                            final holiday = filteredHolidays[index];
                            final date = holiday['date']['iso'];
                            final name = holiday['name'];
                            final type = holiday['type']?.join(', ') ?? '';

                            return Card(
  elevation: 5, // Add subtle shadow for card effect
  margin: const EdgeInsets.symmetric(vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // Rounded corners
    side: BorderSide(
      color: Color.fromARGB(255, 124, 107, 146), // Border color
      width: 1.5, // Border width
    ),
  ),
  child: ListTile(
    title: Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    subtitle: Text(
      '$date — $type',
      style: TextStyle(
        color: Colors.grey[600], // Subtle color for subtitle
      ),
    ),
    leading: Icon(
      Icons.event_note,
      color: Color.fromARGB(255, 124, 107, 146),
    ),
  ),
);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}
