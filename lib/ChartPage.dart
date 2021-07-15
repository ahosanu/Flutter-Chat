import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:web_chat/UserData.dart';

import 'messageData.dart';

class ChartPage extends StatelessWidget {
  final MesasgeData ctrl;
  final int index;
  const ChartPage({Key? key, required this.ctrl, required this.index})
      : super(key: key);

  final lastKeyPressTime = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color primaryColor = Theme.of(context).primaryColor;
    /* ctrl.scrollController.animateTo(
        ctrl.scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn); */
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            ctrl.toUser = "";
            ctrl.viewChart = false;
            ctrl.messages = [];
            Get.back();
          },
        ),
        title: GetBuilder<MesasgeData>(
            builder: (context) => Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("unnamed.png")
                      /* Image.network(userName["avatar"]).image */,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ctrl.userList[index]["FULL_NAME"].toString()),
                        Text(
                          ctrl.userList[index]["ONLINE"] ? "Online" : "Offline",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                )),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20 * .75, right: 20 * .75, bottom: 5),
        child: FutureBuilder<List<dynamic>>(
          future: UserApi.getCategorySuggestions(
              ctrl.toUser, ctrl.currentUser, ctrl.currentIP),
          builder: (context, snapshort) {
            if (snapshort.hasData) {
              ctrl.messages = snapshort.data ?? [];
            }
            return snapshort.hasData
                ? GetBuilder<MesasgeData>(
                    builder: (context) {
                      return ListView(
                        controller: ctrl.scrollController,
                        shrinkWrap: false,
                        reverse: true,
                        children: ctrl.messages.map((element) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                ctrl.currentUser == element["FROM_USER"]
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              ctrl.currentUser != element["FROM_USER"]
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0, right: 10),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            AssetImage("unnamed.png"),
                                      ),
                                    )
                                  : Container(),
                              Flexible(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: size.width * .7,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20 * .75, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: primaryColor.withOpacity(
                                            ctrl.currentUser ==
                                                    element["FROM_USER"]
                                                ? 1
                                                : 0.08)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          element["MESSAGE"].toString(),
                                          style: TextStyle(
                                              color: ctrl.currentUser ==
                                                      element["FROM_USER"]
                                                  ? Colors.white
                                                  : null),
                                          maxLines: null,
                                          softWrap: true,
                                        ),
                                        Stack(
                                          children: [
                                            ctrl.currentUser ==
                                                    element["FROM_USER"]
                                                ? Positioned(
                                                    top: 3,
                                                    left: 0,
                                                    child: Icon(Icons.done_all,
                                                        size: 20,
                                                        color: element[
                                                                    "READ"] ==
                                                                0
                                                            ? Colors.blueGrey
                                                            : Colors
                                                                .greenAccent))
                                                : Container(
                                                    width: 0,
                                                  ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0, left: 25),
                                              child: Text(
                                                element["DATE_TIME"].toString(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: ctrl.currentUser ==
                                                          element["FROM_USER"]
                                                      ? Colors.white
                                                      : null,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      );
                    },
                  )
                : Container(
                    child: Center(child: CircularProgressIndicator()),
                  );
          },
        ),
      ),
      bottomNavigationBar: chatMessageBar(),
    );
  }

  Widget chatMessageBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black54,
        )
      ]),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: GetBuilder<MesasgeData>(
              builder: (context) => RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    /* if (event.isShiftPressed) {
                      print("Text Fiel Shift key Press");
                    }
                    print("Pressed : " +
                        event.isKeyPressed(event.logicalKey).toString());
                    print(event.logicalKey.keyLabel);
                    print(event.isShiftPressed);
                    print("Text Fiel key Press"); */

                    if (ctrl.chatInputText.text.trim().length > 0 &&
                        !event.isShiftPressed &&
                        !event.isKeyPressed(event.logicalKey) &&
                        (event.logicalKey.keyLabel == "Enter" ||
                            event.logicalKey.keyLabel == "Numpad Enter")) {
                      addNewMessage();
                    }
                  },
                  child: TextField(
                    controller: ctrl.chatInputText,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 6,
                    decoration: InputDecoration(
                        hintText: "Enter your message",
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none),
                  )),
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.all(20),
            shape: CircleBorder(),
            onPressed: () {
              addNewMessage();
            },
            child: Icon(Icons.send),
          )
        ],
      ),
    );
  }

  void addNewMessage() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('h:mm a');
    ctrl.socket.emit("message", {
      "user": ctrl.currentUser,
      "sendto": ctrl.userList[index]["USERNAME"].toString(),
      "message": ctrl.chatInputText.text.trim().toString()
    });
    ctrl.addNewMassage({
      "ID": null,
      "MESSAGE": ctrl.chatInputText.text.trim().toString(),
      "TO_USER": ctrl.userList[index]["USERNAME"].toString(),
      "FROM_USER": ctrl.currentUser,
      "DATE_TIME": formatter.format(now),
      "READ": 0,
      "TYPE": "text",
    });
  }
}
