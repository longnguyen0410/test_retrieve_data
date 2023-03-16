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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EventHandler<Map>? eventChangesHandler;

  bool isShowLoading = false;
  List<String> resultStrings = [];
  BackendlessUser? user;

  @override
  void initState() {
    super.initState();
    Backendless.initApp(
        applicationId: "9EA6F9C0-7ACB-4204-B813-8A0881565F6F",
        androidApiKey: "472FA85F-E4AE-4CA5-B43E-49E7016ABC1A",
        iosApiKey: "BACCCE8F-36F6-42B1-9374-D138DD453F67",
        jsApiKey: "DE6C4322-E25A-4CF7-9F44-13072387EC86");
    Backendless.rt.addConnectListener(() {
      print("client connected");
    });

    Backendless.rt.addDisconnectListener((result) {
      print("client disconnected");
    });
  }

  @override
  void dispose() {
    stopListenRealtimeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white // background
                      ),
                  onPressed: () {
                    user == null ? login() : logOut();
                  },
                  child: Text(user == null ? "Login" : "Log out")),
              if (user != null)
                Column(
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white // background
                            ),
                        onPressed: () {
                          getAllComment();
                        },
                        child: const Text("Get comments")),
                    TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white // background
                            ),
                        onPressed: () {
                          listenRealtimeData();
                        },
                        child: const Text("Listen realtime data")),
                  ],
                ),
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

  // Future<void> getCommentsUsingTransaction() async {
  //   setState(() {
  //     resultStrings.clear();
  //     isShowLoading = true;
  //   });
  //   final unitOfWork = UnitOfWork();
  //
  //   DataQueryBuilder findCommentsBuilder = DataQueryBuilder();
  //
  //   findCommentsBuilder.whereClause =
  //       "eventId = '6C3C55EF-6B22-4048-9852-7DFF6A578694'";
  //   findCommentsBuilder.related = ["createdBy"];
  //
  //   findCommentsBuilder.sortBy = ["created DESC"];
  //   findCommentsBuilder.pageSize = 10;
  //   findCommentsBuilder.offset = 20;
  //   findCommentsBuilder.addAllProperties();
  //
  //   final findCommentsResult =
  //       unitOfWork.find("BLComments", findCommentsBuilder);
  //   String? findCommentsResultJsonKey = findCommentsResult.opResultId;
  //
  //   final result = await unitOfWork.execute();
  //   setState(() {
  //     isShowLoading = false;
  //   });
  //   if (result.success == true) {
  //     final commentsJson = result.results![findCommentsResultJsonKey]?.result;
  //     DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  //     commentsJson.forEach((element) {
  //       String resultString = "content:${element['content']} "
  //           "- createdBy ${element['createdBy']?['displayName']} "
  //           "- createdAt  ${dateFormat.format(parseDataToDateTime(element['created'])!)} ";
  //       resultStrings.add(resultString);
  //       log(resultString);
  //       setState(() {});
  //     });
  //   }
  // }

  // Future<void> getCommentsWITHOUTTransaction() async {
  //   setState(() {
  //     resultStrings.clear();
  //     isShowLoading = true;
  //   });
  //
  //   DataQueryBuilder findCommentsBuilder = DataQueryBuilder();
  //
  //   findCommentsBuilder.whereClause =
  //       "eventId = '6C3C55EF-6B22-4048-9852-7DFF6A578694'";
  //   findCommentsBuilder.related = ["createdBy"];
  //
  //   findCommentsBuilder.sortBy = ["created DESC"];
  //   findCommentsBuilder.pageSize = 10;
  //   findCommentsBuilder.offset = 0;
  //   findCommentsBuilder.addAllProperties();
  //
  //   final commentsJson =
  //       await Backendless.data.of("BLComments").find(findCommentsBuilder);
  //
  //   setState(() {
  //     isShowLoading = false;
  //   });
  //   if (commentsJson != null) {
  //     DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  //     commentsJson.forEach((element) {
  //       String resultString = "content:${element!['content']} "
  //           "- createdBy ${element['createdBy']?['displayName']} "
  //           "- createdAt  ${dateFormat.format(parseDataToDateTime(element['created'])!)} ";
  //       resultStrings.add(resultString);
  //       log(resultString);
  //       setState(() {});
  //     });
  //   }
  // }

  Future<void> getAllComment() async {
    setState(() {
      resultStrings.clear();
      isShowLoading = true;
    });

    DataQueryBuilder findCommentsBuilder = DataQueryBuilder();

    findCommentsBuilder.related = ["createdBy"];

    findCommentsBuilder.sortBy = ["created DESC"];
    findCommentsBuilder.pageSize = 10;
    findCommentsBuilder.offset = 0;
    findCommentsBuilder.addAllProperties();

    try {
      final commentsJson =
          await Backendless.data.of("BLComments").find(findCommentsBuilder);
      if (commentsJson != null) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        commentsJson.forEach((element) {
          String resultString = "content:${element!['content']} "
              "- createdBy ${element['createdBy']?['displayName']} "
              "- createdAt  ${dateFormat.format(parseDataToDateTime(element['created'])!)} ";
          resultStrings.add(resultString);
          log(resultString);
        });
      }
    } catch (error) {
      resultStrings.add("getAllComment error ${error.toString()}");
      log("getAllComment error ${error.toString()}");
    }
    setState(() {
      isShowLoading = false;
    });
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

  Future<void> login() async {
    setState(() {
      isShowLoading = true;
      resultStrings.clear();
    });
    try {
      user =
          await Backendless.userService.login("test@test.com", "123456", true);
    } catch (error) {
      resultStrings.add("login error ${error.toString()}");
      log("login error ${error.toString()}");
    }
    setState(() {
      isShowLoading = false;
    });
  }

  Future<void> logOut() async {
    setState(() {
      isShowLoading = true;
      resultStrings.clear();
    });
    try {
      await Backendless.userService.logout();
      user = null;
      stopListenRealtimeData();
    } catch (error) {
      resultStrings.add("logOut error ${error.toString()}");
      log("logOut error ${error.toString()}");
    }
    setState(() {
      isShowLoading = false;
    });
  }

  void listenRealtimeData() {
    stopListenRealtimeData(); //stop exist listens
    eventChangesHandler ??= Backendless.data.of("BLComments").rt();
    String whereClause =
        "created after ${DateTime.now().millisecondsSinceEpoch}";
    eventChangesHandler?.addCreateListener((createdObject) {
      print(
          "New object has been created. Object ID - ${createdObject['objectId']}");
    }, onError: (error) {
      print("addCreateListener error: $error");
    }, whereClause: whereClause);

    eventChangesHandler?.addUpdateListener((updatedEvent) {
      print(
          "An Event object has been updated. Object ID - ${updatedEvent['objectId']}");
    }, whereClause: whereClause);
    eventChangesHandler?.addDeleteListener((deletedEvent) {
      print(
          "An Event object has been deleted. Object ID - ${deletedEvent['objectId']}");
    }, whereClause: whereClause);
  }

  void stopListenRealtimeData() {
    eventChangesHandler?.removeCreateListeners();
    eventChangesHandler?.removeUpdateListeners();
    eventChangesHandler?.removeDeleteListeners();
  }
}
