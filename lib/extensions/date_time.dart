import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String format({String pattern = 'dd.MM.yyyy', String locale = "TR"}) {
    if (locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  String formatDate({String locale = "TR"}) {
    return format(pattern: 'dd.MM.yyyy', locale: locale);
  }

  String formatDateTime({String locale = "TR"}) {
    return format(pattern: 'dd.MM.yyyy HH:mm', locale: locale);
  }

  DateTime toLocalDateTime({String format = "yyyy-MM-dd HH:mm:ss"}) {
    var dateTime = DateFormat(format).parse(toString(), true);
    return dateTime.toLocal();
  }
}
