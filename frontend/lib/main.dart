import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:sprint_0_calculator/constants.dart';
import 'package:sprint_0_calculator/calc_button.dart';
import 'package:sprint_0_calculator/history.dart';

void main() {
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsAppWithMediaQuery();
  }
}

class WidgetsAppWithMediaQuery extends StatelessWidget {
  const WidgetsAppWithMediaQuery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          final paddingUnit = MediaQuery.of(context).size.width / 49;
          final bottomPadding = MediaQuery.of(context).padding.bottom / 1.13;
          final topPadding = max(
              0.0,
              MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  Constants.bottomNavigationBarHeight * paddingUnit -
                  Constants.screenHeight * paddingUnit -
                  bottomPadding);
          final constants = Constants(
            paddingUnit: paddingUnit,
            topPadding: topPadding,
            bottomPadding: bottomPadding,
          );

          return ProviderScope(
            overrides: [
              constantsProvider.overrideWithValue(constants),
            ],
            child: const Calculator(),
          );
        },
      ),
    );
  }
}

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.white,
          background: Colors.black,
        ),
        textTheme: GoogleFonts.jersey25TextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends ConsumerStatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  ConsumerState<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends ConsumerState<CalculatorHomePage> {
  String _currentExpression = '';
  TextStyle? _expressionStyle;

  @override
  Widget build(BuildContext context) {
    final constants = ref.watch(constantsProvider);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
      ),
    );

    _expressionStyle ??= Theme.of(context).textTheme.displaySmall;

    const List<List<String>> buttons = [
      ['C', '(', ')', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['.', '0', '±', '=']
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF9D9D9D),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var notificationBarHeight = constants.topPadding;
          // var availableHeight = constraints.maxHeight -
          notificationBarHeight - constants.bottomPadding;
          // var textBoxSize = availableHeight / 3;
          // var keyboardSize = availableHeight * 2 / 3;
          var buttonSize =
              Size(constants.paddingUnit * 9, constants.paddingUnit * 9);

          return SafeArea(
            child: Column(
              children: [
                Expanded(flex: 101, child: Container()),
                Expanded(
                    flex: 93,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: constants.paddingUnit * 3,
                          right: constants.paddingUnit * 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(overlayColor: Colors.transparent),
                              onPressed: () => _navigateToHistory(),
                              child: Text('History',
                                  style: TextStyle(
                                      fontSize: constants.paddingUnit * 5,
                                      color: Colors.black))),
                          SizedBox(
                              width: constants.paddingUnit * 18.5,
                              height: constants.paddingUnit * 5,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              constants.dOuterRadius / 2),
                                          bottomLeft: Radius.circular(
                                              constants.dOuterRadius / 2)),
                                      color: const Color(0xFFB09C98),
                                      border: BoxBorder.fromLTRB(
                                          top: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          bottom: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          right: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 4),
                                          left: BorderSide(
                                              color: Colors.black,
                                              width:
                                                  constants.paddingUnit / 2)),
                                    ),
                                  )),
                                  Expanded(
                                      child: Container(
                                          decoration: BoxDecoration(
                                    color: const Color(0xFFB09C98),
                                    border: BoxBorder.fromLTRB(
                                        top: BorderSide(
                                            color: Colors.black,
                                            width: constants.paddingUnit / 2),
                                        bottom: BorderSide(
                                            color: Colors.black,
                                            width: constants.paddingUnit / 2),
                                        right: BorderSide(
                                            color: Colors.black,
                                            width: constants.paddingUnit / 4),
                                        left: BorderSide(
                                            color: Colors.black,
                                            width: constants.paddingUnit / 4)),
                                  ))),
                                  Expanded(
                                      child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB09C98),
                                      border: BoxBorder.fromLTRB(
                                          top: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          bottom: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          right: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 4),
                                          left: BorderSide(
                                              color: Colors.black,
                                              width:
                                                  constants.paddingUnit / 4)),
                                    ),
                                  )),
                                  Expanded(
                                      child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              constants.dOuterRadius / 2),
                                          bottomRight: Radius.circular(
                                              constants.dOuterRadius / 2)),
                                      color: const Color(0xFFB09C98),
                                      border: BoxBorder.fromLTRB(
                                          top: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          bottom: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          right: BorderSide(
                                              color: Colors.black,
                                              width: constants.paddingUnit / 2),
                                          left: BorderSide(
                                              color: Colors.black,
                                              width:
                                                  constants.paddingUnit / 4)),
                                    ),
                                  )),
                                ],
                              ))
                        ],
                      ),
                    )),
                Expanded(
                  flex: 145,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: constants.paddingUnit * 3,
                        right: constants.paddingUnit * 3,
                        bottom: constants.paddingUnit * 3),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(constants.dOuterRadius),
                          border: Border.all(
                              color: Colors.black,
                              width: constants.paddingUnit)),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: constants.paddingUnit * 2,
                          right: constants.paddingUnit * 2,
                          top: constants.paddingUnit,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                child: Text(
                                  _currentExpression,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: constants.paddingUnit * 6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 493,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: constants.paddingUnit * 3,
                        right: constants.paddingUnit * 3),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // final numRows = buttons.length;
                        // final buttonSide = constants.paddingUnit;

                        return GestureDetector(
                          onPanUpdate: (details) {
                            const xSensitivity = 8;
                            const ySensitivity = 4;
                            if (details.delta.dx >= xSensitivity &&
                                details.delta.dy.abs() <= ySensitivity) {
                              _navigateToHistory();
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Table(
                              // defaultColumnWidth: FixedColumnWidth(buttonSide),
                              children: List<TableRow>.generate(
                                buttons.length,
                                (row) => TableRow(
                                  children: List.generate(
                                    buttons[row].length,
                                    (col) {
                                      const colorA = Color(0xFFB3B3B3); // Серый
                                      const colorB =
                                          Color(0xFFD8BC8C); // Бледно-желтый
                                      const colorC =
                                          Color(0xFFE8E8E8); // Светло-серый

                                      bool isFirstRowSpecial =
                                          row == 0 && col < 3;
                                      bool isLastCol =
                                          col == buttons[row].length - 1;

                                      final backgroundColor = isFirstRowSpecial
                                          ? colorA
                                          : (isLastCol ? colorB : colorC);

                                      return CalcButton(
                                        buttonText: buttons[row][col],
                                        size: buttonSize,
                                        color: backgroundColor,
                                        textSize: constants.paddingUnit * 13,
                                        onPressed: () => _handleButtonPress(
                                            buttons[row][col]),
                                        onLongPress: () =>
                                            _handleButtonLongPress(
                                                buttons[row][col]),
                                        borderColor: Colors.black,
                                        textColor: Colors.black,
                                        margin: EdgeInsets.all(
                                            constants.paddingUnit),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _evaluateExpression(String expression) async {
    try {
      debugPrint("Oh hi, Mark!");
      final userId = await ref.read(userIdProvider.future);
      final response = await http.post(
        Uri.parse(
            'http://${Constants.serverAddress}/calculate'),
        headers: {'Content-Type': 'application/json; charset=utf-8',},
        body: jsonEncode({
          "expression": expression,
          "user_id": userId,
        })
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        setState(() {
          _currentExpression = json["data"].toString();
        });
      } else {
        setState(() {
          _currentExpression = "error";
        });
      }
    } catch (exception, stackTrace) {
      debugPrintStack(stackTrace: stackTrace, label: exception.toString());
    }
  }

  Future<void> _navigateToHistory() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
    if (result != null) {
      setState(() {
        _currentExpression = result.toString();
      });
    }
  }

  void _handleButtonPress(String buttonText) {
    const List<String> operations = ['C', '±', '÷', '×', '-', '+', '='];
    bool endsWithOperator = _currentExpression.isNotEmpty &&
        operations.sublist(3).contains(
            _currentExpression.substring(_currentExpression.length - 1));
    if (operations.contains(buttonText)) {
      if (_currentExpression.isEmpty) {
        return; // do not append anything
      } else if (buttonText == 'C') {
        _delButton();
        return;
      } else if (buttonText == '±') {
        _pmButton();
        return;
      } else if (buttonText == '=') {
        _evaluateExpression(
            _currentExpression.replaceAll('÷', '/').replaceAll('×', '*'));
        return;
      } else if (endsWithOperator) {
        setState(() {
          _currentExpression =
              _currentExpression.substring(0, _currentExpression.length - 1);
        });
      }
    }
    setState(() {
      _currentExpression += buttonText;
    });
  }

  void _handleButtonLongPress(String buttonText) {
    if (buttonText == 'C') {
      setState(() {
        _currentExpression = '';
      });
    }
    if (_currentExpression == '42' && buttonText == '=') {
      if (_expressionStyle == Theme.of(context).textTheme.displaySmall) {
        _expressionStyle = Theme.of(context).textTheme.titleMedium;
        setState(() {
          _currentExpression = 'heapof&gvozd design';
        });
      } else {
        setState(() {
          _expressionStyle = Theme.of(context).textTheme.displaySmall;
        });
      }
    }
  }

  void _delButton() {
    if (_currentExpression.length == 2 && _currentExpression.startsWith('-')) {
      setState(() {
        _currentExpression = '';
      });
    } else {
      setState(() {
        _currentExpression =
            _currentExpression.substring(0, _currentExpression.length - 1);
      });
    }
  }

  void _pmButton() {
    String operators = r'[÷×\-+(]';
    int index = _currentExpression.lastIndexOf(RegExp(operators));
    if (index == -1) {
      setState(() {
        _currentExpression = '-$_currentExpression';
      });
    } else if (_currentExpression[index] == '+') {
      setState(() {
        _currentExpression =
            _currentExpression.replaceRange(index, index + 1, '-');
      });
    } else if (_currentExpression[index] == '-') {
      if (index == 0 ||
          RegExp(operators).hasMatch(_currentExpression[index - 1])) {
        setState(() {
          _currentExpression =
              _currentExpression.replaceRange(index, index + 1, '');
        });
      } else {
        setState(() {
          _currentExpression =
              _currentExpression.replaceRange(index, index + 1, '+');
        });
      }
    } else {
      setState(() {
        _currentExpression =
            _currentExpression.replaceRange(index + 1, index + 1, '-');
      });
    }
  }
}
