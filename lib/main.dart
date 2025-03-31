import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  home: Homepage(),
));

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String server = "http://192.168.1.115/devops";
  List<dynamic> items = [];
  List<Map<String, dynamic>> cart = [];
  bool isLoading = true;

  Future<void> getData() async {
    try {
      final response = await http.get(Uri.parse(server + "/API.php"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          items = data.where((item) => item is Map<String, dynamic>).toList();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> deleteUser(String id) async {
    final response = await http.post(
      Uri.parse(server + "/delete.php"),
      body: {
        "id": id,
      },
    );
    print(response.body);
    getData(); // Refresh the user list after deletion
  }
   @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView.builder(
          itemCount: user.length,
          itemBuilder: (context, int index) {
            final item = user[index];
            TextEditingController _password =
            TextEditingController(text: item['password']);

            return CupertinoListTile(
              title: Text(item['username']),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Icon(CupertinoIcons.trash_fill,
                        color: CupertinoColors.destructiveRed),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text(


                                'Delete user ${item['username']}?'),
                            content: Text('Are you sure you want to delete this user?'),
                            actions: [
                              CupertinoButton(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        color: CupertinoColors.systemGrey)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoButton(
                                child: Text("Delete",
                                    style: TextStyle(
                                        color: CupertinoColors.destructiveRed)),
                                onPressed: () {
                                  deleteUser(item['id']);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
 CupertinoButton(
                    child: Icon(CupertinoIcons.pencil,
                        color: CupertinoColors.systemGreen),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text(
                                'Change password for ${item['username']}'),
                            content: CupertinoTextField(
                              controller: _password,
                              obscureText: true,
                            ),
                            actions: [
                              CupertinoButton(
                                child: Text("Close",
                                    style: TextStyle(
                                        color: CupertinoColors.destructiveRed)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
  CupertinoButton(
                                child: Text("Save",
                                    style: TextStyle(
                                        color: CupertinoColors.systemGreen)),
                                onPressed: () {
                                  updateUser(item['id'], _password.text);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
