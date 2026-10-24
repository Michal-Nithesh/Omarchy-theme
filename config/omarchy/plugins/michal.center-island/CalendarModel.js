.pragma library

var MONTH_NAMES = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
];

var DAY_NAMES = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

function monthName(monthIndex) {
  return MONTH_NAMES[monthIndex] || "";
}

function generateMonthDays(year, month) {
  var firstDay = new Date(year, month, 1);
  var lastDay = new Date(year, month + 1, 0);
  // Monday is 0, Sunday is 6
  var startDayOfWeek = (firstDay.getDay() + 6) % 7;
  var daysInMonth = lastDay.getDate();
  var daysInPrevMonth = new Date(year, month, 0).getDate();

  var today = new Date();
  var todayY = today.getFullYear();
  var todayM = today.getMonth();
  var todayD = today.getDate();

  var days = [];

  // Previous month filler
  for (var i = startDayOfWeek - 1; i >= 0; i--) {
    days.push({
      day: daysInPrevMonth - i,
      currentMonth: false,
      isToday: false
    });
  }

  // Current month
  for (var d = 1; d <= daysInMonth; d++) {
    var isToday = (todayY === year && todayM === month && todayD === d);
    days.push({
      day: d,
      currentMonth: true,
      isToday: isToday
    });
  }

  // Next month filler to complete rows of 7
  var remaining = 7 - (days.length % 7);
  if (remaining < 7) {
    for (var n = 1; n <= remaining; n++) {
      days.push({
        day: n,
        currentMonth: false,
        isToday: false
      });
    }
  }

  return days;
}

function dayOfYear(date) {
  var start = new Date(date.getFullYear(), 0, 0);
  var diff = date - start;
  var oneDay = 1000 * 60 * 60 * 24;
  return Math.floor(diff / oneDay);
}

function yearPercent(date) {
  var y = date.getFullYear();
  var isLeap = (y % 4 === 0 && y % 100 !== 0) || (y % 400 === 0);
  var totalDays = isLeap ? 366 : 365;
  var doy = dayOfYear(date);
  return Math.round((doy / totalDays) * 100);
}
