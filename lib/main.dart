import 'dart:developer';

import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isShowLoading = false;
  List<String> resultStrings = [];

  @override
  void initState() {
    super.initState();
    Backendless.initApp(
        applicationId: "9EA6F9C0-7ACB-4204-B813-8A0881565F6F",
        androidApiKey: "472FA85F-E4AE-4CA5-B43E-49E7016ABC1A",
        iosApiKey: "BACCCE8F-36F6-42B1-9374-D138DD453F67",
        jsApiKey: "DE6C4322-E25A-4CF7-9F44-13072387EC86");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white // background
                      ),
                  onPressed: () {
                    getCommentsUsingTransaction();
                    // getCommentsWITHOUTTransaction();
                  },
                  child: const Text("Get comments")),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 2, top: 2),
                      child: Text(resultStrings[index]),
                    );
                  },
                  itemCount: resultStrings.length,
                ),
              )
            ],
          ),
          if (isShowLoading)
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
        ],
      ),
    );
  }

  Future<void> getCommentsUsingTransaction() async {
    setState(() {
      resultStrings.clear();
      isShowLoading = true;
    });
    final unitOfWork = UnitOfWork();

    DataQueryBuilder findCommentsBuilder = DataQueryBuilder();

    findCommentsBuilder.whereClause =
        "eventId = '6C3C55EF-6B22-4048-9852-7DFF6A578694'";
    findCommentsBuilder.related = ["createdBy"];

    findCommentsBuilder.sortBy = ["created DESC"];
    findCommentsBuilder.pageSize = 10;
    findCommentsBuilder.offset = 0;
    findCommentsBuilder.addAllProperties();

    final findCommentsResult =
        unitOfWork.find("BLComments", findCommentsBuilder);
    String? findCommentsResultJsonKey = findCommentsResult.opResultId;

    final result = await unitOfWork.execute();
    setState(() {
      isShowLoading = false;
    });
    if (result.success == true) {
      final commentsJson = result.results![findCommentsResultJsonKey]?.result;
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      commentsJson.forEach((element) {
        String resultString = "content:${element['content']} "
            "- createdBy ${element['createdBy']?['displayName']} "
            "- createdAt  ${dateFormat.format(parseDataToDateTime(element['created'])!)} ";
        resultStrings.add(resultString);
        log(resultString);
        setState(() {});
      });
    }
  }

  Future<void> getCommentsWITHOUTTransaction() async {
    setState(() {
      resultStrings.clear();
      isShowLoading = true;
    });

    DataQueryBuilder findCommentsBuilder = DataQueryBuilder();

    findCommentsBuilder.whereClause =
        "eventId = '6C3C55EF-6B22-4048-9852-7DFF6A578694'";
    findCommentsBuilder.related = ["createdBy"];

    findCommentsBuilder.sortBy = ["created DESC"];
    findCommentsBuilder.pageSize = 10;
    findCommentsBuilder.offset = 0;
    findCommentsBuilder.addAllProperties();

    final commentsJson =
        await Backendless.data.of("BLComments").find(findCommentsBuilder);

    setState(() {
      isShowLoading = false;
    });
    if (commentsJson != null) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      commentsJson.forEach((element) {
        String resultString = "content:${element!['content']} "
            "- createdBy ${element['createdBy']?['displayName']} "
            "- createdAt  ${dateFormat.format(parseDataToDateTime(element['created'])!)} ";
        resultStrings.add(resultString);
        log(resultString);
        setState(() {});
      });
    }
  }

  DateTime? parseDataToDateTime(var input) {
    if (input == null) {
      return null;
    }
    if (input is DateTime) {
      return input;
    }
    if (input is int) {
      return DateTime.fromMillisecondsSinceEpoch(input);
    }
    if (input is double) {
      return DateTime.fromMillisecondsSinceEpoch(input.floor());
    }
    // if (input is Timestamp) {
    //   return input.toDate();
    // }
    if (input is String) {
      return DateTime.parse(input);
    }
    return null;
  }
}
