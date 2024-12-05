String formatOpenHours(dynamic openHours) {
  if (openHours is Map<String, dynamic>) {
    const daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    List<String> formattedHours = [];
    for (var day in daysOfWeek) {
      if (openHours.containsKey(day)) {
        formattedHours.add(
          '${day[0].toUpperCase() + day.substring(1)}: ${openHours[day]}',
        );
      }
    }

    return formattedHours.isNotEmpty
        ? formattedHours.join('\n')
        : 'No open hours available.';
  } else if (openHours is List<dynamic>) {
    const List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    List<String> formattedHours = [];
    for (var schedule in openHours) {
      if (schedule is Map<String, dynamic> &&
          schedule.containsKey('days') &&
          schedule.containsKey('start') &&
          schedule.containsKey('end')) {
        final days =
            (schedule['days'] as List<dynamic>).map((e) => e as bool).toList();
        final start = schedule['start'] ?? 'N/A';
        final end = schedule['end'] ?? 'N/A';

        List<int> openDays = [];
        for (int i = 0; i < days.length; i++) {
          if (days[i]) {
            openDays.add(i);
          }
        }

        if (openDays.isNotEmpty) {
          String dayRange;
          if (openDays.length == 1) {
            dayRange = daysOfWeek[openDays.first];
          } else {
            dayRange =
                '${daysOfWeek[openDays.first]} - ${daysOfWeek[openDays.last]}';
          }

          formattedHours.add('$dayRange: $start - $end');
        }
      }
    }

    return formattedHours.isNotEmpty
        ? formattedHours.join('\n')
        : 'No open hours available.';
  } else {
    return 'Invalid open hours format.';
  }
}
