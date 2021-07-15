library wchat.globals;

import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MesasgeData extends GetxController {
  bool viewChart = false;
  var chatMessage = {};
  List<dynamic> messages = [];
  List<dynamic> userList = [];
  String currentUser = "";
  String currentIP = "";
  late String toUser = "";
  late IO.Socket socket;
  TextEditingController chatInputText = TextEditingController();
  ScrollController scrollController = ScrollController();

  addNewMassage(data) {
    if (chatMessage[toUser] == null) {
      chatMessage[toUser] = [];
      chatMessage[toUser].add(data);
    } else {
      chatMessage[toUser].add(data);
    }
    if (viewChart) {
      //scrollController.position.maxScrollExtent + 100,
      messages.insert(0, data);
      scrollController.animateTo(0,
          duration: Duration(milliseconds: 1000), curve: Curves.fastOutSlowIn);
      chatInputText.clear();
    }
    update();
  }

  void connect() {
    socket = IO.io('http://' + currentIP + ':3000', <String, dynamic>{
      "transport": ["websocket"],
      "autoConnect": false
    });
    socket.connect();
    socket.onConnect((_) {
      print('connected');
      socket.emit('userIdReceived', currentUser);
      update();
    });

    socket.on("newonline", (data) {
      userList.forEach((element) {
        if (element["USERNAME"] == data) element["ONLINE"] = true;
      });
      print("New  online : " + data.toString());

      update();
    });

    socket.on('offline', (data) {
      userList.forEach((element) {
        if (element["USERNAME"] == data) element["ONLINE"] = false;
      });
      print("offline");
      update();
    });
    socket.on('userlist', (data) {
      userList = [];
      userList.addAll(data);
      print("User List Loaded");
      update();
    });

    socket.on('readMessage', (data) {
      if (toUser == data["user"]) {
        for (var i = 0; i < messages.length; i++) {
          messages[i]["READ"] = 1;
        }
        update();
      }
    });

    socket.on('message_rec', (getdata) {
      if (toUser == getdata["user"]) {
        socket
            .emit("readMessageServer", {"user": currentUser, "sendto": toUser});
      }

      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('h:mm a');
      var data = {
        "ID": null,
        "MESSAGE": getdata["message"],
        "TO_USER": getdata["sendto"],
        "FROM_USER": getdata["user"],
        "DATE_TIME": formatter.format(now),
        "READ": getdata["user"] == toUser ? 1 : 0,
        "TYPE": "text",
      };
      messages.insert(0, data);
      scrollController.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);

      if (chatMessage[getdata["user"]] == null) {
        chatMessage[getdata["user"]] = [];
        chatMessage[getdata["user"]].add(data);
      } else {
        chatMessage[getdata["user"]].add(data);
      }

      if (toUser != getdata["user"]) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]["USERNAME"] == getdata["user"]) {
            userList[i]["UNREAD"] =
                (int.parse(userList[i]["UNREAD"]) + 1).toString();
            break;
          }
        }
      }
      update();
    });
  }
}
