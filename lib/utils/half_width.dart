String toHalfWidth(String input) {
  return input.replaceAllMapped(RegExp(r'[\uFF01-\uFF5E]'), (match) {
    // 全角英数字・記号 → 半角
    final fullWidthChar = match.group(0)!;
    final halfWidthChar = String.fromCharCode(fullWidthChar.codeUnitAt(0) - 0xFEE0);
    return halfWidthChar;
  }).replaceAll('　', ' '); // 全角スペース → 半角スペース
}
