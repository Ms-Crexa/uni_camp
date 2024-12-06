import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OpenHours extends StatelessWidget {
  const OpenHours({super.key, required this.openHours});

  final List<Map<String, dynamic>> openHours;

  @override
  Widget build(BuildContext context) {
    const daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    // Create a map of day indices (0-6) to their schedules
    final Map<int, Map<String, dynamic>> daySchedules = {};

    for (var schedule in openHours) {
      final days = (schedule['days'] as List<dynamic>)
          .map((day) => day as bool)
          .toList();
      for (int i = 0; i < days.length; i++) {
        if (days[i]) {
          daySchedules[i] = schedule;
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          FontAwesomeIcons.clock,
          size: 20,
          color: Color.fromARGB(255, 8, 118, 207),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (int i = 0; i < daysOfWeek.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(daysOfWeek[i]), // Day name
                        Text(daySchedules.containsKey(i)
                            ? '${daySchedules[i]!['start']} - ${daySchedules[i]!['end'] ?? 'N/A'}'
                            : 'Closed'), // Display "Closed" if no schedule
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}