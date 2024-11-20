import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OpenHours extends StatelessWidget {
  const OpenHours({super.key, required this.openHours});

  final Map<String, dynamic> openHours;

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
                for (var day in daysOfWeek)
                  if (openHours.containsKey(day.toLowerCase()))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day),
                          Text(openHours[day.toLowerCase()] ?? ''),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        )
      ],
    );
  }
}