import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JordanHolidaysWidget extends StatefulWidget {
  const JordanHolidaysWidget({super.key});

  @override
  State<JordanHolidaysWidget> createState() => _JordanHolidaysWidgetState();
}

class _JordanHolidaysWidgetState extends State<JordanHolidaysWidget> {
  final String apiKey = 'uubepAFbhk28YpAuLgDYogxLzLNRewHc';
  int selectedYear = 2025;
  int selectedMonth = 0;

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
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          '🇯🇴 Jordan Holidays 2025',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    onChanged: (value) => setState(() => selectedMonth = value!),
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('All Months')),
                      for (int i = 1; i <= 12; i++)
                        DropdownMenuItem(value: i, child: Text(monthName(i))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (value) async {
                      setState(() => selectedYear = value!);
                      await fetchJordanHolidays();
                    },
                    items: List.generate(10, (index) {
                      final year = 2023 + index;
                      return DropdownMenuItem(value: year, child: Text('$year'));
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📅 Holidays List',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredHolidays.isEmpty
                      ? const Center(child: Text('No holidays found.'))
                      : ListView.builder(
                          itemCount: filteredHolidays.length,
                          itemBuilder: (context, index) {
                            final holiday = filteredHolidays[index];
                            final name = holiday['name'];
                            final date = holiday['date']['iso'];
                            final type = holiday['type']?.join(', ') ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color.fromARGB(255, 124, 177, 255), width: 0.7),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.event, color: Color.fromARGB(255, 124, 177, 255)),
                                title: Text(
                                  name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  '$date – $type',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
