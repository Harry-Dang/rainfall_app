String getDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[date.month - 1] + ' ' + date.day.toString();
}

String getWeekday(DateTime date) {
  const days = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

String getTime(DateTime date) {
  String minute =
      date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString();
  String hour;
  String period;
  if (date.hour == 0) {
    hour = '12';
    period = 'AM';
  } else if (date.hour < 12) {
    hour = date.hour.toString();
    period = 'AM';
  } else if (date.hour == 12) {
    hour = date.hour.toString();
    period = 'PM';
  } else {
    hour = (date.hour - 12).toString();
    period = 'PM';
  }
  return hour + ':' + minute + ' ' + period;
}

String getHour(DateTime date) {
  if (date.hour == 0) {
    return '12 AM';
  } else if (date.hour < 12) {
    return date.hour.toString() + ' AM';
  } else {
    return (date.hour - 12).toString() + ' PM';
  }
}
