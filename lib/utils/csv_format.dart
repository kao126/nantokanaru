import 'package:nantokanaru/utils/half_width.dart';

List<String> formatNameAndCode(List<List<dynamic>> csvData) {
  // 先頭はヘッダーなので除く
  return csvData.skip(1).map((row) {
    final code = row[1].toString();
    final name = toHalfWidth(row[2].toString());
    return '$name($code)';
  }).toList();
}
