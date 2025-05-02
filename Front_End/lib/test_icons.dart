import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: TestIconsPage(),
  ));
}

class TestIconsPage extends StatefulWidget {
  @override
  _TestIconsPageState createState() => _TestIconsPageState();
}

class _TestIconsPageState extends State<TestIconsPage> {
  String? selected;

  final List<Map<String, dynamic>> icons = [
    {'label': 'Clothing', 'icon': Icons.dry_cleaning_sharp},
    {'label': 'Luxury gift', 'icon': Icons.monetization_on_rounded},
    {'label': 'Pet Accessories', 'icon': Icons.pets_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Icons')),
      body: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: List.generate(icons.length, (index) {
          final item = icons[index];
          final isSelected = selected == item['label'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selected = item['label'];
                print('Selected: $selected');
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
                        ? Border.all(color: Colors.purple, width: 4)
                        : null,
                  ),
                  child: Icon(
                    item['icon'],
                    size: 30,
                    color: isSelected ? Colors.purple : Colors.black54,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  item['label'],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.purple : Colors.black,
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
