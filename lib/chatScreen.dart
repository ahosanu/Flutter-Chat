import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'messageData.dart';

class ChatScreen extends StatefulWidget {
  final int index;
  final IO.Socket socket;
  final String currentUser;
  const ChatScreen(
      {Key? key,
      required this.index,
      required this.socket,
      required this.currentUser})
      : super(key: key);

  @override
  _ChatScreenState createState() =>
      _ChatScreenState(index, socket, currentUser);
}

class _ChatScreenState extends State<ChatScreen> {
  final MesasgeData ctrl = Get.put(MesasgeData());
  final int index;
  final IO.Socket socket;
  final String currentUser;
  @override
  void initState() {
    super.initState();
    print("Total Message: " + ctrl.messages.length.toString());
    /* for (Map<String, dynamic> msg in ctrl.messages) {
      /* WC_ID, WC_MESSAGE, WC_DATE_TIME, WC_READ, WC_READ_TIME, WC_TYPE, WC_FROM_USER, WC_TO_USER */
      if ((msg["FROM_USER"] == currentUser &&
              msg["TO_USER"] == ctrl.userList[index]["USERNAME"]) ||
          (msg["TO_USER"] == currentUser &&
              msg["FROM_USER"] == ctrl.userList[index]["USERNAME"])) {
        ctrl.chatMessage.add(msg);
      }
    } */
  }

  _ChatScreenState(this.index, this.socket, this.currentUser);

  @override
  Widget build(BuildContext context) {
    var chatInputText = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
                  "Online - ${ctrl.userList[index]["USERNAME"]}",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20 * .75, right: 20 * .75, bottom: 5),
        child: GetBuilder<MesasgeData>(
          builder: (context) {
            return ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: ctrl.chatMessage.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: ctrl.userList[index]["USERNAME"] ==
                          ctrl.chatMessage[index]["FROM_USER"]
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    ctrl.userList[index]["USERNAME"] !=
                            ctrl.chatMessage[index]["FROM_USER"]
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, right: 10),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage("unnamed.png"),
                            ),
                          )
                        : Container(),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .7,
                        ),
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20 * .75, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).primaryColor.withOpacity(
                                  ctrl.userList[index]["USERNAME"] ==
                                          ctrl.chatMessage[index]["FROM_USER"]
                                      ? 1
                                      : 0.08)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                ctrl.chatMessage[index]["MESSAGE"].toString(),
                                style: TextStyle(
                                    color: ctrl.userList[index]["USERNAME"] ==
                                            ctrl.chatMessage[index]["FROM_USER"]
                                        ? Colors.white
                                        : null),
                                maxLines: null,
                                softWrap: true,
                              ),
                              Stack(
                                children: [
                                  ctrl.userList[index]["USERNAME"] ==
                                          ctrl.chatMessage[index]["FROM_USER"]
                                      ? Positioned(
                                          top: 3,
                                          left: 0,
                                          child: Icon(Icons.done_all,
                                              size: 20, color: Colors.white))
                                      : Container(
                                          width: 0,
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, left: 25),
                                    child: Text(
                                      ctrl.chatMessage[index]["DATE_TIME"]
                                          .toString(),
                                      style: TextStyle(
                                        color: ctrl.userList[index]
                                                    ["USERNAME"] ==
                                                ctrl.chatMessage[index]
                                                    ["FROM_USER"]
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
              },
            );
          },
        ),
      ),
      bottomNavigationBar: chatMessageBar(chatInputText, _scrollController),
    );
  }

  Widget chatMessageBar(
      TextEditingController chatInputText, ScrollController _scrollController) {
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
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (chatInputText.text.trim().length > 0 &&
                    !event.isShiftPressed &&
                    event.isKeyPressed(LogicalKeyboardKey.enter)) {
                  setState(() {
                    final DateTime now = DateTime.now();
                    final DateFormat formatter = DateFormat('h:mm a');

                    ctrl.addNewMassage({
                      "ID": ctrl.chatMessage.length,
                      "MESSAGE": chatInputText.text.toString(),
                      "TO_USER": ctrl.userList[index]["USERNAME"],
                      "FROM_USER": currentUser,
                      "DATE_TIME": formatter.format(now),
                      "READ": true,
                      "TYPE": "text",
                    });
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent + 100,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn);

                    socket.emit("message", {
                      "user": currentUser,
                      "sendto": ctrl.userList[index]["USERNAME"],
                      "message": chatInputText.text.toString()
                    });

                    ctrl.messages.add({
                      "ID": ctrl.chatMessage.length,
                      "MESSAGE": chatInputText.text.toString(),
                      "TO_USER": ctrl.userList[index]["USERNAME"],
                      "FROM_USER": currentUser,
                      "DATE_TIME": formatter.format(now),
                      "READ": true,
                      "TYPE": "text",
                    });
                  });
                }
              },
              child: TextField(
                controller: chatInputText,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 6,
                decoration: InputDecoration(
                    hintText: "Enter your message",
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none),
              ),
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.all(20),
            shape: CircleBorder(),
            onPressed: () {
              setState(() {
                final DateTime now = DateTime.now();
                final DateFormat formatter = DateFormat('h:mm a');

                ctrl.addNewMassage({
                  "ID": ctrl.chatMessage.length,
                  "MESSAGE": chatInputText.text.toString(),
                  "TO_USER": ctrl.userList[index]["USERNAME"],
                  "FROM_USER": currentUser,
                  "DATE_TIME": formatter.format(now),
                  "READ": true,
                  "TYPE": "text",
                });
                ctrl.messages.add({
                  "ID": ctrl.chatMessage.length,
                  "MESSAGE": chatInputText.text.toString(),
                  "TO_USER": ctrl.userList[index]["USERNAME"],
                  "FROM_USER": currentUser,
                  "DATE_TIME": formatter.format(now),
                  "READ": true,
                  "TYPE": "text",
                });
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent + 100,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn);

                socket.emit("message", {
                  "user": currentUser,
                  "sendto": ctrl.userList[index]["USERNAME"],
                  "message": chatInputText.text.toString()
                });
              });
            },
            child: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
