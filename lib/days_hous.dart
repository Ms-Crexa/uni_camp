import 'package:flutter/material.dart';

class ScheduleWidget extends StatefulWidget {
  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  List<bool> selectedDays = List.filled(7, false); // For Su, M, T, W, Th, F, Sa
  TimeOfDay startTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 23, minute: 0);
  List<Map<String, dynamic>> schedules = [];

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

      // Reset inputs for a new schedule
      selectedDays = List.filled(7, false);
      startTime = TimeOfDay(hour: 7, minute: 0);
      endTime = TimeOfDay(hour: 23, minute: 0);
    });
  }

  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule Picker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 16),

            // Time Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Start Time"),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(startTime.format(context)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("End Time"),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(endTime.format(context)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Add Hours Button
            ElevatedButton(
              onPressed: _addHours,
              child: Text("ADD HOURS"),
            ),
            SizedBox(height: 16),

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
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSchedule(index),
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
}
