import 'package:dio/dio.dart';

class UserApi {
  static Future<List<dynamic>> getCategorySuggestions(
      String userID, String currentUser, String currentIP) async {
    try {
      var response = await Dio().post(
          'http://' + currentIP + ':3000/get_message',
          data: {'id': userID, 'send': currentUser});
      return response.data;
    } catch (e) {
      print(e);
      throw Exception();
    }

    /* var body = json.encode({"id": "ANSARY"});
    var url = Uri.parse('http://localhost:3000/get_message');
    var response = await http
        .post(url, body: body, headers: {'Content-Type': 'application/json'});

    print("View api call2");
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);

      return data;
    } else {
      throw Exception();
    } */
  }
}
