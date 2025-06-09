import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AdminNotificationWidget extends StatefulWidget {
  const AdminNotificationWidget({Key? key}) : super(key: key);

  @override
  State<AdminNotificationWidget> createState() => _AdminNotificationWidgetState();
}

class _AdminNotificationWidgetState extends State<AdminNotificationWidget> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> holidays = [];
bool showAllSuggestions = false;
 String _target = 'users'; // ✅ match with DropdownMenuItem values
 // 'all' or 'owners'
  bool _isLoading = false;
  List<dynamic> owners = [];
List<String> selectedOwnerIds = [];

           final List<String> suggestions = [
  "🎉 New discount offers this weekend!",
  "🚨 Please check your product stock levels.",
  "📦 We are improving our delivery process!",
  "✨ Thank you for being part of our platform.",
  "🎁 Check out our new gift collections just added!",
  "🎉 A special surprise awaits you in the app now!",
  "💡 Don’t forget to customize your gift box for your loved ones.",
  "🧾 Owners: Kindly double-check your product stock status.",
  "📦 We’ve improved our delivery timings for faster service!",
  "🛍️ New categories are now available. Explore and add more items.",
  "🎈 Send joy with our pre-designed gift cards – now live!",
];
  Future<void> sendNotification() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uri = Uri.parse('${dotenv.env['BASE_URL']}/api/notifications/send');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
           'content': message,
  'target': _target,
  'userIds': _target == 'owners' ? selectedOwnerIds : [],
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Notification sent!')),
        );
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }
 Future<void> fetchOwners() async {
  final url = Uri.parse('${dotenv.env['BASE_URL']}/api/owners/all');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        owners = body['owners']; // ✅ حدد المفتاح الصحيح من الـ JSON
      });
    }
  } catch (e) {
    print('❌ Failed to fetch owners: $e');
  }
}

Future<void> fetchJordanHolidays() async {
  final apiKey = 'uubepAFbhk28YpAuLgDYogxLzLNRewHc';
  final currentYear = DateTime.now().year;

  final url = Uri.parse(
    'https://calendarific.com/api/v2/holidays?api_key=$apiKey&country=JO&year=$currentYear',
  );

  try {
    final response = await http.get(url);//const Color.fromARGB(255, 5, 73, 124),
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final all = data['response']['holidays'];

      final today = DateTime.now();
      final upcoming = all.where((holiday) {
        final dateStr = holiday['date']['iso'];
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;

        final diff = date.difference(today).inDays;
        return diff >= 0 && diff <= 7;
      }).toList();

      setState(() {
        holidays = upcoming;
      });
    }
  } catch (e) {
    print('❌ Failed to fetch holidays: $e');
  }
}


@override
void initState() {
  super.initState();
  fetchOwners();
  fetchJordanHolidays();
}

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
 
    final validTargets = ['users', 'owners'];
  if (!validTargets.contains(_target)) {
    _target = 'users';
  }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        title: const Text(
          'Admin Notifications',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Choose recipient',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A3A3A), 
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _target,
                decoration: InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade400),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade400), // Normal border
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Color(0xFF7CB1FF), width: 2), // 👈 Your desired blue focus color
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
),

                
                  dropdownColor: Colors.white, // ✅ خلفية القائمة
  style: const TextStyle(
    fontFamily: 'Outfit',
    fontSize: 15,
    color: Color(0xFF3A3A3A), // ✅ لون النص
  ),
                items: const [
                 
                  DropdownMenuItem(value: 'users', child: Text('Customers Only')),
DropdownMenuItem(value: 'owners', child: Text('Owners Only')),

                ],
                onChanged: (val) => setState(() => _target = val!),
              ),
              if (_target == 'owners') ...[
  const SizedBox(height: 20),
  Text(
    'Select specific owners',
    style: textTheme.titleMedium?.copyWith(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w600,
    ),
  ),
  const SizedBox(height: 8),
  Wrap(
    spacing: 8,
    runSpacing: 8,
    children: owners.map<Widget>((owner) {
      final id = owner['_id'];
      final name = owner['name'];
      final isSelected = selectedOwnerIds.contains(id);

      return FilterChip(
        selected: isSelected,
        label: Text(name, style: TextStyle(fontFamily: 'Outfit',color: isSelected ? Colors.white : Colors.black,)),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              selectedOwnerIds.add(id);
            } else {
              selectedOwnerIds.remove(id);
            }
          });
        },
        selectedColor: Color.fromARGB(255, 124, 177, 255),
        checkmarkColor: const Color.fromARGB(255, 0, 0, 0),
      );
    }).toList(),
  ),
],

              const SizedBox(height: 24),
   const SizedBox(height: 16),
Text(
  '📆 Upcoming Holiday Suggestions',
  style: textTheme.titleMedium?.copyWith(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w600,
  ),
),
const SizedBox(height: 8),
holidays.isEmpty
    ? const Text('No holidays within the next 7 days.')
    : Wrap(
        spacing: 8,
        runSpacing: 8,
        children: holidays.map<Widget>((holiday) {
          final name = holiday['name'];
          final date = holiday['date']['iso'];

          return ActionChip(
            label: Text('🎉 $name', style: const TextStyle(fontFamily: 'Outfit')),
            backgroundColor: const Color.fromARGB(255, 234, 250, 255),
            onPressed: () {
               final formattedDate = DateTime.tryParse(date)?.toLocal().toString().split(' ')[0] ?? date;

  if (_target == 'owners') {
    _messageController.text =
      "🛒 $name is approaching on $formattedDate – make sure your products are up!";
  } else {
    _messageController.text =
      "🎉 Wishing you a joyful $name on $formattedDate – from all of us!";
  }
            },
          );
        }).toList(),
      ),

const SizedBox(height: 16),
Text(
  'Suggestions',
  style: textTheme.titleMedium?.copyWith(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w600,
  ),
),
const SizedBox(height: 8),

Wrap(
  spacing: 8,
  runSpacing: 8,
  children: (showAllSuggestions ? suggestions : suggestions.take(2)).map((s) {
    return ActionChip(
      label: Text(s, style: const TextStyle(fontFamily: 'Outfit')),
      backgroundColor: const Color.fromARGB(255, 234, 250, 255),
      onPressed: () {
        _messageController.text = s;
      },
    );
  }).toList(),
),
if (!showAllSuggestions && suggestions.length > 2)
  TextButton.icon(
    onPressed: () => setState(() => showAllSuggestions = true),
    icon: const Icon(Icons.expand_more),
    label: const Text('Show more suggestions'),
    style: TextButton.styleFrom(
      foregroundColor: Color.fromARGB(255, 255, 180, 68),
    ),
  ),


              Text(
                'Message content',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'Outfit'),
                decoration: InputDecoration(
                  hintText: 'Write your announcement here...',
                  hintStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : sendNotification,
                  icon: const Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Sending...' : 'Send Notification',
                    style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 124, 177, 255),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
