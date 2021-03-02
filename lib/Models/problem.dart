import 'package:flutter/material.dart';

import '../languages.dart';

class Problem {
  final String text;
  final String location;
  final String category;
  final Time time;
  final Status status;
  final AssetImage image;

  Problem({this.image, this.status, this.text, this.location, this.category, this.time});
}

class Time {
  final int year;
  final Month month;
  final int day;
  final int hour;
  final int minute;

  getMonthRus() {
    switch(month) {
      case Month.January:
        return 'Январь';
      case Month.February:
        return 'Февраль';
      case Month.March:
        return 'Март';
      case Month.April:
        return 'Апрель';
      case Month.May:
        return 'Май';
      case Month.June:
        return 'Июнь';
      case Month.July:
        return 'Июль';
      case Month.August:
        return 'Август';
      case Month.September:
        return 'Сентябрь';
      case Month.October:
        return 'Октябрь';
      case Month.November:
        return 'Ноябрь';
      case Month.December:
        return 'Декабрь';
    }
  }

  getMonthUzb() {
    switch(month) {
      case Month.January:
        return 'Yanvar';
      case Month.February:
        return 'Fevral';
      case Month.March:
        return 'Mart';
      case Month.April:
        return 'Аprel';
      case Month.May:
        return 'Мay';
      case Month.June:
        return 'Iyun';
      case Month.July:
        return 'Iyul';
      case Month.August:
        return 'Аvgust';
      case Month.September:
        return 'Sentabr';
      case Month.October:
        return 'Оktabr';
      case Month.November:
        return 'Noyabr';
      case Month.December:
        return 'Dekabr';
    }
  }

  getString(currentLang) {
    String currentMonth = (currentLang == Languages.russian) ? getMonthRus() : getMonthUzb();
    return day.toString() + ' ' + currentMonth + ', ' + hour.toString() + ':' + minute.toString();
  }

  Time({this.year, this.month, this.day, this.hour, this.minute});
}

enum Month {
  January, February, March, April, May, June, July, August, September, October, November, December
}

enum Status {
  sent, process, success, reject
}