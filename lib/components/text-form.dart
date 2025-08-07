import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nantokanaru/utils/csv_loader.dart';
import 'package:nantokanaru/utils/csv_format.dart';

class TextFormPage extends StatefulWidget {
  const TextFormPage({super.key});

  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _yenFormat =
      NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);
  int _chipIndex = 0;
  int _tabIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<String> _csvData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _dayController.text =
        "${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日(${DateFormat.E('ja_JP').format(_selectedDate)})";

    _amountController.addListener(() {
      final raw = _amountController.text.replaceAll(RegExp(r'[¥,]'), '');

      if (raw.isEmpty) return;

      final number = int.tryParse(raw);
      if (number == null) return;

      final newText = _yenFormat.format(number);

      // カーソル位置補正
      final selectionIndexFromRight =
          _amountController.text.length - _amountController.selection.end;

      _amountController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length - selectionIndexFromRight,
        ),
      );
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await loadCsvFromAssets('assets/data_j.csv');
    final formattedData = formatNameAndCode(data);
    setState(() {
      _csvData = formattedData;
    });
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250, // ボトムシートの高さを設定
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date, // 日付モードに設定
            initialDateTime: _selectedDate, // 初期日付
            minimumDate: DateTime(1950, 1, 1), // 最小日付（1950年1月1日）
            maximumDate: DateTime.now(), // 最大日付（今日の日付）
            onDateTimeChanged: (DateTime newDate) {
              // 日付変更時にテキストフィールドに反映
              setState(() {
                _selectedDate = newDate;
                _dayController.text =
                    "${newDate.year}年${newDate.month}月${newDate.day}日(${DateFormat.E('ja_JP').format(newDate)})";
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent, // ← 空白も検出できるように
        onTap: () {
          FocusScope.of(context).unfocus(); // ← フォーカスを外す
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Text Form'),
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            backgroundColor: _tabIndex == 0
                // ? Theme.of(context).colorScheme.primary
                ? Colors.red[300]
                : Colors.blue[300],
            bottom: TabBar(
              // controller: tabController,
              tabs: const <Widget>[
                Tab(text: "支出"),
                Tab(text: "収入"),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelColor: Colors.grey[400],
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              onTap: (int index) {
                setState(() {
                  _tabIndex = index; // 選択中インデックスを更新
                });
              },
            ),
          ),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _dayController,
                    readOnly: true, // タップでのみ日付選択可能
                    decoration: const InputDecoration(
                      labelText: "日付",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    // フィールドがタップされた時に日付ピッカーを表示
                    onTap: () => _showDatePicker(context),
                  ),
                  const SizedBox(height: 10),
                  Autocomplete(
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: '銘柄を検索',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (value) => onFieldSubmitted(),
                      );
                    },
                    optionsBuilder: (textEdigingValue) {
                      return _csvData.where(
                          (option) => option.contains(textEdigingValue.text));
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.only(
                              right: 32.0), // ← 右側にPaddingを追加
                          child: Material(
                            elevation: 4.0,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(option),
                                    dense: true,
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '金額',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: 0.785398, // 45度
                              child: const Icon(Icons.push_pin,
                                  size: 24, color: Color(0xffc3b491)),
                            ),
                            const Text("株式投資(信用)"),
                          ],
                        ),
                        labelStyle: const TextStyle(fontSize: 10),
                        selected: _chipIndex == 0,
                        side: _chipIndex == 0
                            ? const BorderSide(
                                color: Colors.black87, width: 0.5)
                            : const BorderSide(
                                color: Colors.transparent, width: 0.5),
                        backgroundColor: Colors.white,
                        selectedColor: Colors.white,
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          setState(() {
                            _chipIndex = 0;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: 0.785398, // 45度
                              child: const Icon(Icons.push_pin,
                                  size: 24, color: Color(0xff676767)),
                            ),
                            const Text("株式投資(現物)"),
                          ],
                        ),
                        labelStyle: const TextStyle(fontSize: 10),
                        selected: _chipIndex == 1,
                        side: _chipIndex == 1
                            ? const BorderSide(
                                color: Colors.black87, width: 0.5)
                            : const BorderSide(
                                color: Colors.transparent, width: 0.5),
                        backgroundColor: Colors.white,
                        selectedColor: Colors.white,
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          setState(() {
                            _chipIndex = 1;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // 送信処理を書く
                      print('送信ボタンが押されました');
                    },
                    child: Text(_tabIndex == 0 ? '支出を入力する' : '収入を入力する'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
