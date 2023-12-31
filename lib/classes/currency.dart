import 'package:intl/intl.dart';

class Currency {
  NumberFormat getPLN() {
    return NumberFormat.currency(locale: "pl_PL", symbol: "zł");
  }
}
