import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class Constants {
  /// Единичный отступ, на основании которого считаются все остальные отступы.
  final double paddingUnit;

  /// Отступ сверху, подгоняющий экран под размеры [screenHeight] * [paddingUnit]
  final double topPadding;

  /// Отступ между нижней системной панелью и панелью навигации
  final double bottomPadding;

  const Constants({
    required this.paddingUnit,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// Фактически используемая высота экрана (в единицах [paddingUnit]).
  static const screenHeight = 92;

  /// Высота заголовка приложения (Профиль, ...).
  static const headerHeight = 9;

  /// Высота верхней панели навигации приложения (в единицах [paddingUnit]).
  static const topNavigationBarHeight = 6;

  /// Высота нижней панели навигации приложения (в единицах [paddingUnit]).
  static const bottomNavigationBarHeight = 7;

  /// Продолжительность анимаций (миллисекунды).
  static const dAnimationDuration = Duration(milliseconds: 250);

  /// Полные названия месяцев.
  static const months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  /// Короткие двухбуквенные названия дней недели.
  static const weekDaysShort = [
    'пн',
    'вт',
    'ср',
    'чт',
    'пт',
    'сб',
    'вс',
  ];

  /// Полные названия дней недели.
  static const weekDays = [
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье',
  ];

  /// IP-адрес сервера (включает в себя порт).
  static const serverAddress = 'localhost:8000';

  /// Таймаут для запросов на сервер.
  static const networkTimeout = Duration(seconds: 5);

  /// Отступ заголовка приложения (Профиль, ...).
  EdgeInsets get dAppHeadlinePadding =>
      EdgeInsets.fromLTRB(paddingUnit * 4, 0, 0, paddingUnit);

  /// Отступ блоков — элементов интерфейса, которые делят экран между собой.
  EdgeInsets get dBlockPadding =>
      EdgeInsets.fromLTRB(paddingUnit * 2, 0, paddingUnit * 2, paddingUnit * 2);

  /// Отступ карточек — элементов, перечисляемых на экране.
  EdgeInsets get dCardPadding => EdgeInsets.symmetric(horizontal: paddingUnit);

  /// Отступ карточек, уменьшенный в два раза.
  EdgeInsets get dCardPaddingHalf =>
      EdgeInsets.symmetric(horizontal: paddingUnit / 2);

  /// Отступ заголовка элемента.
  EdgeInsets get dHeadingPadding => EdgeInsets.fromLTRB(
      paddingUnit * 2, paddingUnit * 2, paddingUnit * 2, paddingUnit);

  /// Отступ основного текста.
  EdgeInsets get dTextPadding =>
      EdgeInsets.symmetric(vertical: paddingUnit / 2, horizontal: paddingUnit);

  /// Отступ короткого текста — пометки для другого элемента.
  EdgeInsets get dLabelPadding => EdgeInsets.symmetric(horizontal: paddingUnit);

  /// Радиус скругления углов у внешних (объемлющих) элементов интерфейса.
  double get dOuterRadius => paddingUnit * 4 / 2;

  /// Радиус скругления углов у внутренних элементов интерфейса.
  double get dInnerRadius => dOuterRadius / 2;

  /// Толщина рамок и границ.
  double get borderWidth => paddingUnit / 3;

  /// Размер и интенсивность теней.
  double get dElevation => paddingUnit / 2;

  /// Высота разделителей (используется в списках, под заголовками).
  double get dDividerHeight => paddingUnit / 2;
}

final constantsProvider =
    Provider<Constants>((ref) => throw UnimplementedError());
