import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.name});
  final String? name;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final msgController = TextEditingController();
  final scrollController = ScrollController();
  Future postRequest() async {
    var url = Uri.parse('http://10.0.2.2/api_polling/view.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (err) {
      print(err);
    }
  }

  List messages = [];

  Future getMessages() async {
    final response = await postRequest();
    if (response['status'] == 'success') {
      setState(() {
        messages = response['data'];
        // .sort((a, b) => (b['id'] as int).compareTo((a['id'] as int)));
      });
    } else {
      return response['status'];
    }
  }

  Future sendMessage() async {
    var url = Uri.parse('http://10.0.2.2/api_polling/create.php');
    try {
      final response = await http.post(url, body: {
        'username': widget.name,
        'message': msgController.text,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return response.statusCode;
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      return getMessages();
    });
  }

  bool order = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            reverse: true,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: scrollController,
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment:
                        widget.name == messages[index]['username']
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: 200,
                        alignment: widget.name == messages[index]['username']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: widget.name == messages[index]['username']
                                ? Colors.purple
                                : Color.fromARGB(255, 118, 6, 36),
                            borderRadius:
                                widget.name == messages[index]['username']
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30))
                                    : const BorderRadius.only(
                                        bottomRight: Radius.circular(30),
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30))),
                        child: Column(
                          crossAxisAlignment:
                              widget.name == messages[index]['username']
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Text(
                              messages[index]['username'],
                              textAlign:
                                  widget.name == messages[index]['username']
                                      ? TextAlign.right
                                      : TextAlign.left,
                            ),
                            SizedBox(height: 5),
                            Text(messages[index]['message']),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          )),
          TextFormField(
              controller: msgController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () async {
                        if (msgController.text.isEmpty) {
                          return;
                        }
                        await sendMessage();
                        setState(() {
                          order = false;
                        });
                        msgController.clear();
                      },
                      icon: const Icon(Icons.send)),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )))
        ],
      ),
    );
  }
}
