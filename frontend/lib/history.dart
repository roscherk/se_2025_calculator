import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint_0_calculator/constants.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constants = ref.watch(constantsProvider);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(systemNavigationBarColor: const Color(0xFF9D9D9D)));
    var history = _getHistory();
    return Scaffold(
      backgroundColor: const Color(0xFF9D9D9D),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 194,
              child: Padding(
                padding: EdgeInsets.only(left: constants.paddingUnit * 3),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        overlayColor: Colors.transparent,
                        shape: const BeveledRectangleBorder(),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                      child: Text(
                        'Back to the calc',
                        style: TextStyle(
                            fontSize: constants.paddingUnit * 5,
                            color: Colors.black),
                      )),
                ),
              ),
            ),
            Expanded(
              flex: 646,
              child: Scaffold(
                  backgroundColor: const Color(0xFF9D9D9D),
                  body: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: constants.paddingUnit * 3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                          border: Border.all(
                              color: Colors.black,
                              width: constants.paddingUnit),
                          borderRadius:
                              BorderRadius.circular(constants.dOuterRadius)),
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constrains) {
                        debugPrint(constrains.toString());
                        var expressionsOnPage =
                            (constrains.maxHeight / 70).ceil();
                        var notificationBarHeight =
                            MediaQuery.of(context).viewPadding.top;
                        var availableHeight = constrains.maxHeight -
                            notificationBarHeight -
                            MediaQuery.of(context).viewPadding.bottom;
                        var expressionListHeight = availableHeight *
                            (expressionsOnPage - 1) /
                            expressionsOnPage;
                        return Padding(
                          padding: EdgeInsets.only(top: notificationBarHeight),
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              debugPrint('dx: ${details.delta.dx.toString()}');
                              debugPrint(
                                  'dy: ${details.delta.dy.abs().toString()}');
                              const xSensitivity = 8;
                              const ySensitivity = 4;
                              if (details.delta.dx <= -xSensitivity &&
                                  details.delta.dy.abs() <= ySensitivity) {
                                Navigator.pop(context);
                              }
                            },
                            child: SizedBox(
                              height: expressionListHeight,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                children: List.generate(
                                    history.length,
                                    (index) => SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          reverse: true,
                                          child: SizedBox(
                                            height: availableHeight /
                                                expressionsOnPage,
                                            child: TextButton(
                                              onLongPress: () {
                                                Navigator.pop(
                                                    context, history[index][0]);
                                              },
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, history[index][1]);
                                              },
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '${history[index][0]} = ${history[index][1]}',
                                                  style: TextStyle(color: Colors.black, fontSize: constants.paddingUnit * 5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  List<List<String>> _getHistory() {
    // TODO: сделать запрос к серверу и получить список с историей выражений
    // for lulz and testing
    return [
      ['2+2', '4'],
      ['2+2*2', '6'],
      ['request', 'result'],
      ['request', 'result'],
      ['Very-very-very-very-very-very-very request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['Very-very-very-very-very-very-very request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
      ['request', 'result'],
    ];
  }
}
