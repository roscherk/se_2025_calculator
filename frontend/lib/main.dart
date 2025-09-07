import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);
}

void main() {
  runApp(CalcApp());
}

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalcAppState(),
      child: MaterialApp(
        title: 'Calculator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 244, 186, 26),
          ),
        ),
        home: CalculatorPage(),
      ),
    );
  }
}

class CalcAppState extends ChangeNotifier {
  var history = <Pair<String, double>>[];
  var currentExpression = "1+1";
  var answer = 0.0;

  void doCalc() {
    // получаем ответ
    history.add(Pair(currentExpression, answer));
    print(history);
    currentExpression = answer.toString();
    notifyListeners();
  }

  void addSymbolToExp(String symbol) {
    currentExpression += symbol;
    notifyListeners();
  }

  void clearSymbolInExp() {
    if (currentExpression == "") {
      notifyListeners();
      return;
    }
    currentExpression = currentExpression.substring(
      0,
      currentExpression.length - 1,
    );
    notifyListeners();
  }

  void getAnswer() {}
}

// class HistoryPage extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {

//     throw UnimplementedError();
//   }
// }

class CalculatorPage extends StatefulWidget {
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  @override
  Widget build(BuildContext context) {
    var calcAppState = context.watch<CalcAppState>();
    var currExp = calcAppState.currentExpression;
    return Center(
      child: SizedBox(
        height: 600,
        width: 400,
        child: Container(
          color: const Color.fromARGB(255, 81, 81, 81),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ViewPanel(currExp: currExp),
                ),
                Row(
                  children: [
                    Expanded(child: Container()),
                    ButtonsPanel(calcAppState: calcAppState),
                    Expanded(child: Container()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonsPanel extends StatelessWidget {
  const ButtonsPanel({super.key, required this.calcAppState});

  final CalcAppState calcAppState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CalcButton(
              symbol: 'C',
              color: const Color.fromARGB(255, 138, 138, 138),
              onPressed_: () {
                calcAppState.clearSymbolInExp();
              },
            ),
            CalcButton(
              symbol: '(',
              color: const Color.fromARGB(255, 138, 138, 138),
              onPressed_: () {
                calcAppState.addSymbolToExp('(');
              },
            ),
            CalcButton(
              symbol: ')',
              color: const Color.fromARGB(255, 138, 138, 138),
              onPressed_: () {
                calcAppState.addSymbolToExp(')');
              },
            ),
            CalcButton(
              symbol: '÷',
              color: const Color.fromARGB(255, 248, 151, 67),
              onPressed_: () {
                calcAppState.addSymbolToExp('÷');
              },
            ),
          ],
        ),
        Row(
          children: [
            CalcButton(
              symbol: '7',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('7');
              },
            ),
            CalcButton(
              symbol: '8',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('8');
              },
            ),
            CalcButton(
              symbol: '9',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('9');
              },
            ),
            CalcButton(
              symbol: '×',
              color: const Color.fromARGB(255, 248, 151, 67),
              onPressed_: () {
                calcAppState.addSymbolToExp('×');
              },
            ),
          ],
        ),
        Row(
          children: [
            CalcButton(
              symbol: '4',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('4');
              },
            ),
            CalcButton(
              symbol: '5',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('5');
              },
            ),
            CalcButton(
              symbol: '6',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('6');
              },
            ),
            CalcButton(
              symbol: '-',
              color: const Color.fromARGB(255, 248, 151, 67),
              onPressed_: () {
                calcAppState.addSymbolToExp('-');
              },
            ),
          ],
        ),
        Row(
          children: [
            CalcButton(
              symbol: '1',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('1');
              },
            ),
            CalcButton(
              symbol: '2',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('2');
              },
            ),
            CalcButton(
              symbol: '3',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('3');
              },
            ),
            CalcButton(
              symbol: '+',
              color: const Color.fromARGB(255, 248, 151, 67),
              onPressed_: () {
                calcAppState.addSymbolToExp('+');
              },
            ),
          ],
        ),
        Row(
          children: [
            CalcButton(
              symbol: '.',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('.');
              },
            ),
            CalcButton(
              symbol: '0',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('0');
              },
            ),
            CalcButton(
              symbol: '±',
              color: const Color.fromARGB(255, 200, 200, 200),
              onPressed_: () {
                calcAppState.addSymbolToExp('±');
              },
            ),
            CalcButton(
              symbol: '=',
              color: const Color.fromARGB(255, 248, 151, 67),
              onPressed_: () {
                calcAppState.doCalc();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ViewPanel extends StatelessWidget {
  const ViewPanel({super.key, required this.currExp});

  final String currExp;

  @override
  Widget build(BuildContext context) {
    print(currExp);
    return Card(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 50,
          width: 236,
          child: Row(
            children: [
              Expanded(child: Container(color: Colors.grey)),
              Column(
                children: [
                  Expanded(child: Container(color: Colors.grey)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Или Axis.horizontal
                    child: Text(
                      currExp,
                      style: TextStyle(color: Colors.black, fontSize: 25.0),
                      overflow: TextOverflow.clip
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalcButton extends StatelessWidget {
  final double height;
  final double width;
  final double elevation;
  final String symbol;
  final Color color;
  final double padding;
  final VoidCallback onPressed_;

  const CalcButton({
    super.key,
    required this.symbol,
    required this.color,
    required this.onPressed_,
    this.padding = 5.0,
    this.height = 50.0,
    this.width = 10.0,
    this.elevation = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    // Если вы используете Provider для CalcAppState, то оставьте; иначе удалите строку.
    // CalcAppState appState = context.watch<CalcAppState>();
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        onPressed: onPressed_,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            // или ContinuousRectangleBorder()
            borderRadius: BorderRadius.circular(3.5), // Для квадратной кнопки
          ),
          elevation: elevation,
          fixedSize: Size(width, height),
          backgroundColor: color,
        ),
        child: Text(
          symbol,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
