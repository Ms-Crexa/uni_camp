// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class OpenHoursForm extends StatefulWidget {
  const OpenHoursForm(
      {super.key, required this.openHours, required this.onSave});

  final List<Map<String, dynamic>> openHours;
  final void Function(List<Map<String, dynamic>>) onSave;

  @override
  _OpenHoursForm createState() => _OpenHoursForm();
}

class _OpenHoursForm extends State<OpenHoursForm> {
  List<bool> selectedDays = List.filled(7, false); // For Su, M, T, W, Th, F, Sa
  TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 0);
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    schedules = List.from(widget.openHours);
  }

  void _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  void _addHours() {
    // Save current selection as a finalized schedule
    setState(() {
      schedules.add({
        "days": List.from(selectedDays), // Copy the current state
        "start": startTime.format(context),
        "end": endTime.format(context),
      });

      // Save the finalized schedules to the parent widget
      widget.onSave(schedules);

      // Reset inputs for a new schedule
      selectedDays = List.filled(7, false);
      startTime = const TimeOfDay(hour: 7, minute: 0);
      endTime = const TimeOfDay(hour: 23, minute: 0);
    });
  }

  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: Column(
        children: [
          // Day Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["Su", "M", "T", "W", "Th", "F", "Sa"]
                .asMap()
                .entries
                .map(
                  (entry) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDays[entry.key] = !selectedDays[entry.key];
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: selectedDays[entry.key]
                          ? Colors.blue
                          : Colors.grey[300],
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: selectedDays[entry.key]
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Time Pickers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text("Start Time"),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(startTime.format(context)),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text("End Time"),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(endTime.format(context)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add Hours Button
          ElevatedButton(
            onPressed: _addHours,
            child: const Text("ADD HOURS"),
          ),
          const SizedBox(height: 16),

          // Display Finalized Schedules with Delete Button
          Expanded(
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final selectedDaysStr = ["Su", "M", "T", "W", "Th", "F", "Sa"]
                    .asMap()
                    .entries
                    .where((entry) => schedule["days"][entry.key])
                    .map((entry) => entry.value)
                    .join(", ");
                return ListTile(
                  title: Text(
                    "$selectedDaysStr: ${schedule["start"]} - ${schedule["end"]}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSchedule(index),
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
