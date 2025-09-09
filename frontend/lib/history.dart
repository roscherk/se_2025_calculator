import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sprint_0_calculator/constants.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constants = ref.watch(constantsProvider);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(systemNavigationBarColor: const Color(0xFF9D9D9D)));
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
                              child: FutureBuilder(
                                future: _getHistory(),
                                builder: (context, snapshot) {
                                  debugPrint("Oh hi, Mark! snapshot = $snapshot");
                                  if (snapshot.hasData) {
                                    final history = snapshot.data!;
                                    return ListView(
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
                                                      context, history[index].split('=')[0]);
                                                },
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context, history[index].split('=')[1]);
                                                },
                                                child: Align(
                                                  alignment:
                                                  Alignment.centerRight,
                                                  child: Text(
                                                    history[index],
                                                    style: TextStyle(color: Colors.black, fontSize: constants.paddingUnit * 5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                    );
                                  } else if (snapshot.hasError) {
                                    debugPrint("returning error state");
                                    return Container(child: Text("Error occurred :("));
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                }
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

  Future<List<String>> _getHistory() async {
    final response = await http.get(
        Uri.parse(
            'http://${Constants.serverAddress}/history/1')
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint("json = $json, returning ${json["data"]}");
      return List<String>.from(json["data"]);
    }
    return [
      '2+2 = 4',
      'wth+wtf=hell nah'
    ];
  }
}
