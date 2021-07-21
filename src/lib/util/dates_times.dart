String getDate(date) {
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

String getTime(date) {
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
  } else {
    hour = (date.hour - 12).toString();
    period = 'PM';
  }
  return hour + ':' + minute + ' ' + period;
}
