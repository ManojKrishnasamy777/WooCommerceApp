import 'package:collection/collection.dart';
import 'package:e_com/core/core.dart';
import 'package:e_com/models/settings/region_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

int intFromAny(dynamic value) {
  if (value is int) return value;
  if (value is String) return value.asInt;
  if (value is double) return value.toInt();
  return 0;
}

double doubleFromAny(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return value.asDouble;
  return 0;
}

num numFromAny(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;

  return 0;
}

extension StringEx on String {
  int get asInt => isEmpty ? 0 : int.tryParse(this) ?? 0;

  double get asDouble => double.tryParse(this) ?? 0.0;

  String showUntil(int end, [int start = 0]) {
    return length >= end ? '${substring(start, end)}...' : this;
  }

  String ifEmpty([String onEmpty = 'EMPTY']) {
    return isEmpty ? onEmpty : this;
  }

  bool get isValidEmail {
    final reg = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return reg.hasMatch(this);
  }

  bool get isValidPhone {
    final reg = RegExp(r"^[\+]?([0-9]{2})?[0-9]{11}$");
    return reg.hasMatch(this);
  }

  String get titleCaseSingle => '${this[0].toUpperCase()}${substring(1)}';
  String get toTitleCase => split(' ').map((e) => e.titleCaseSingle).join(' ');

  Color? toColorK([Color? fallbackColor]) {
    String hexColor = replaceAll("#", "");
    final color = int.tryParse("0xFF$hexColor");
    if (color == null) return fallbackColor;
    return Color(color);
  }
}

extension ConvertInt on num {
String fromLocal(LocalCurrency local, [bool calculateRate = false]) {
  final cur = local.currency;
  var value = this;

  if (cur != null && calculateRate) value = value * cur.rate;

  // Construct the custom pattern with the Indian Rupee symbol and comma separators
  final customPattern = '##,##,##,##0${cur?.symbol ?? '₹'}';

  // Use the custom pattern to format the currency value
  return NumberFormat.currency(
    decimalDigits: this is int ? 0 : 2,
    customPattern: customPattern,
  ).format(value);
}


  String currency(CurrencyData currency) {
    return NumberFormat.currency(
      decimalDigits: this is int ? 0 : 2,
      customPattern: '${currency.symbol}##,##,##,##,##0',
    ).format(this);
  }
}

extension DateTimeFormat on DateTime {
  String formatDate(BuildContext context, [String pattern = 'dd-MM-yyyy']) {
    final locale = Localizations.localeOf(context);
    return DateFormat(pattern, locale.languageCode).format(this);
  }

  String welcomeMassage(BuildContext context) {
    final hour = this.hour;
    String massage = '';

    if (hour >= 0 && hour < 6) {
      massage = Translator.night(context);
    } else if (hour >= 6 && hour < 11) {
      massage = Translator.morning(context);
    } else if (hour >= 11 && hour < 16) {
      massage = Translator.noon(context);
    } else if (hour >= 16 && hour < 18) {
      massage = Translator.evening(context);
    } else if (hour >= 18 && hour < 24) {
      massage = Translator.night(context);
    }

    return massage;
  }
}

extension IterableEx<T> on Iterable<T> {
  List<T> takeFirst([int listLength = 10]) {
    final itemCount = length;
    final takeCount = itemCount > listLength ? listLength : itemCount;
    return take(takeCount).toList();
  }
}

extension MaterialStateSet on Set<MaterialState> {
  bool get isHovered => contains(MaterialState.hovered);
  bool get isFocused => contains(MaterialState.focused);
  bool get isPressed => contains(MaterialState.pressed);
  bool get isDragged => contains(MaterialState.dragged);
  bool get isSelected => contains(MaterialState.selected);
  bool get isScrolledUnder => contains(MaterialState.scrolledUnder);
  bool get isDisabled => contains(MaterialState.disabled);
  bool get isError => contains(MaterialState.error);
}

extension WidgetEx on Widget {
  Widget conditionalExpanded(bool condition, [int flex = 1]) =>
      condition ? Expanded(flex: flex, child: this) : this;
}

extension AnimationEx on Animation<double> {
  Animation<double> withCurve(Curve curve) =>
      CurvedAnimation(parent: this, curve: curve);
}

/// Extension methods for Map
extension MapEx<K, V> on Map<K, V> {
  V? firstNoneNull() =>
      isEmpty ? null : values.firstWhereOrNull((e) => e != null);

  V? valueOrFirst(String? key, String? defKey, [V? defaultValue]) {
    return this[key] ?? this[defKey] ?? defaultValue;
  }
}
