import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String format({String pattern = 'dd.MM.yyyy', String locale = "TR"}) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  DateTime toLocalDateTime({String format = "yyyy-MM-dd HH:mm:ss"}) {
    var dateTime = DateFormat(format).parse(this.toString(), true);
    return dateTime.toLocal();
  }
}
