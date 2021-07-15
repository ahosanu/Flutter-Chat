// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_chat/ChartPage.dart';

import 'messageData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainScreen());
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final controller = Get.put(MesasgeData());

  String currentUser = "";
  @override
  void initState() {
    controller.currentIP = html.window.location.host.split(":")[0];
    super.initState();
    //html.window.postMessage(jsonEncode({"currentUser": "ANSARY"}), "*");
    html.window.addEventListener('message', listen, true);
  }

  String name = "Web Chat";
  int userID = 0;

  void listen(dynamic event) {
    try {
      var data = jsonDecode(event.data);
      controller.currentUser = data['currentUser'];
      setState(() {
        this.name = "Web Chat | " + controller.currentUser;
      });
      controller.connect();
    } catch (e) {
      print(event.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(name),
      ),
      body: GetBuilder<MesasgeData>(
          builder: (context) => ListView.builder(
                itemCount: controller.userList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      controller.viewChart = true;
                      controller.toUser =
                          controller.userList[index]["USERNAME"];
                      controller.userList[index]["UNREAD"] = "0";
                      controller.messages = [];
                      /* controller.messages =
                          controller.chatMessage[controller.toUser] == null
                              ? []
                              : controller.chatMessage[controller.toUser]; */
                      controller.socket.emit("readMessageServer", {
                        "user": controller.currentUser,
                        "sendto": controller.toUser
                      });
                      Get.to(ChartPage(ctrl: controller, index: index));
                    },
                    title: Row(
                      children: [
                        Stack(children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            backgroundImage: AssetImage("unnamed.png")
                            /* Image.network(userList[index]["avatar"]).image */,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: controller.userList[index]["ONLINE"]
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(36))),
                            ),
                          ),
                        ]),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.userList[index]["FULL_NAME"]
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              Text(controller.userList[index]["EMAIL"] != null
                                  ? controller.userList[index]["EMAIL"]
                                      .toString()
                                  : "")
                            ],
                          ),
                        ),
                        int.parse(controller.userList[index]["UNREAD"]) > 0
                            ? Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(60)),
                                child: Center(
                                    child: Text(
                                  int.parse(controller.userList[index]
                                              ["UNREAD"]) >
                                          99
                                      ? '99+'
                                      : controller.userList[index]["UNREAD"]
                                          .toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                )),
                              )
                            : Container()
                      ],
                    ),
                    subtitle: Divider(),
                  );
                },
              )),
    );
  }
}
