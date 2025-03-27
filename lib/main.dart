// commit by romel
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
  String server = "http://192.168.100.95/devops";
  List<dynamic> user = [];

  Future<void> getData() async {
    final response = await http.get(Uri.parse(server + "/API.php"));
    setState(() {
      user = jsonDecode(response.body);
    });
  }

  Future<void> updateUser(String id, String password) async {
    final response = await http.post(
      Uri.parse(server + "/update.php"),
      body: {
        "id": id,
        "password": password,
      },
    );
    print(response.body);
    getData(); // Refresh the user list
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

