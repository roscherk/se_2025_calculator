import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // инициализируем плагин
  await windowManager.ensureInitialized();

  // опции окна: начальный размер и минимальный размер
  const WindowOptions windowOptions = WindowOptions(
    //size: Size(800, 600),
    minimumSize: Size(1000, 1000),
    center: true,
  );

  // ждём, пока окно готово к показу, затем показываем и фокусируем
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await windowManager.setMinimumSize(const Size(1000, 1000));

  runApp(const CalcApp());
}

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 2000.0, minHeight: 2000.0),
      child: ChangeNotifierProvider(
        create: (context) => CalcAppState(),
        child: MaterialApp(
          title: 'Calculator',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 248, 151, 67),
            ),
          ),
          home: HomePage(),
        ),
      ),
    );
  }
}

class CalcAppState extends ChangeNotifier {
  var history = <Pair<String, double>>[];
  var currentExpression = "1+1";
  var answer = 0.0;

  void doCalc() {
    history.add(Pair(currentExpression, answer));
    print(history);
    currentExpression = answer.toString();
    notifyListeners();
  }

  void addSymbolToExp(String symbol) {
    currentExpression += symbol;
    print(symbol);
    notifyListeners();
  }

  void clearSymbolInExp() {
    currentExpression = "";
    notifyListeners();
  }

  void getAnswer() {}
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = CalculatorPage();
      case 1:
        page = HistoryPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 800,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate),
                      label: Text('Calculator'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notes),
                      label: Text('History'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    print('selected: $value');
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CalcAppState appState = context.watch<CalcAppState>();

    return Column(
      children: [
        Row(
          children: const [
            Expanded(flex: 1, child: SizedBox.shrink()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Your operations:",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(flex: 3, child: SizedBox.shrink()),
          ],
        ),

        Expanded(
          child: appState.history.isEmpty
              ? const Center(child: Text(''))
              : ListView.builder(
                  itemCount: appState.history.length,
                  itemBuilder: (context, index) {
                    final pair = appState.history[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('${pair.first} = ${pair.second}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  @override
  Widget build(BuildContext context) {
    var calcAppState = context.watch<CalcAppState>();
    var currExp = calcAppState.currentExpression;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 14, 83),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black, // Задает синий цвет фона
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.black),
          ),
          child: SizedBox(
            height: 400,
            width: 285,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ViewPanel(currExp: currExp),
                  ButtonsPanel(calcAppState: calcAppState),
                ],
              ),
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

class ViewPanel extends StatefulWidget {
  const ViewPanel({super.key, required this.currExp});

  final String currExp;

  @override
  State<ViewPanel> createState() => _ViewPanelState();
}

class _ViewPanelState extends State<ViewPanel> {
  late final ScrollController _hController;

  @override
  void initState() {
    super.initState();
    _hController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hController.hasClients) return;
      final max = _hController.position.maxScrollExtent;
      if (max > 0) {
        _hController.jumpTo(max);
      }
    });
  }

  @override
  void dispose() {
    _hController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currExp);
    return Card(
      color: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 60,
          width: 240,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                controller: _hController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(8),
                notificationPredicate: (_) => true,
                child: SingleChildScrollView(
                  controller: _hController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.currExp,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                          ),
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
