import 'package:flutter/material.dart';

class MapLegend extends StatelessWidget {
  final List<Map<String, dynamic>> legendItems = [
    {
      'name': 'Martin Hall',
      'color': const Color(0xFFFF6F00),
    },
    {
      'name': 'Community Center of the First Companions',
      'color': Colors.blue,
    },
    {
      'name': 'Jubilee Hall',
      'color': const Color(0xFF39FF14),
    },
    {
      'name': 'Bellarmine Hall',
      'color': const Color(0xFF1F8A70),
    },
    {
      'name': 'Wieman Hall',
      'color': const Color(0xFFF39C12),
    },
    {
      'name': 'Dotterweich Hall',
      'color': const Color(0xFFFC4C4C),
    },
    {
      'name': 'Gisbert Hall',
      'color': const Color(0xFF1ABC9C),
    },
    {
      'name': 'Canasius Hall',
      'color': const Color(0xFF9B59B6),
    },
    {
      'name': 'Thalibut Hall',
      'color': const Color(0xFFDC3545),
    },
    {
      'name': 'Del Rosario Hall',
      'color': const Color(0xFFEC8D0A),
    },
    {
      'name': 'Chapel of Our Lady of the Assumption',
      'color': const Color(0xFF2ECC71),
    },
  ];

  MapLegend({super.key});

  @override
Widget build(BuildContext context) {
  return Positioned(
    right: 10, 
    top: 70,
    child: Container(
      width: 130, // Reduced width // Reduced height
      padding: const EdgeInsets.all(8), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: legendItems.map((item) {
          return ListTile(
            horizontalTitleGap: -10,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: item['color'],
              radius: 8, // Reduced circle size
            ),
            
            title: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 0), // Max width for text
              child: Transform.translate(
                offset: const Offset(0, 0), // Adjust text position
                child: Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 10, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
}