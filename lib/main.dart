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



   void addToCart(Map<String, dynamic> item) {
    setState(() {
      cart.add(item);
    });
  }
  Future<void> purchaseItems() async {
    try {
      final response = await http.post(
        Uri.parse(server + "/purchase.php"),
        body: {"cart": jsonEncode(cart)},
      );

      if (response.statusCode == 200) {
        setState(() {
          cart.clear(); // ✅ Clear cart after purchase
          getData(); // ✅ Refresh the item list (stock updates)
        });
        showSuccessDialog();
      } else {
        print("Purchase failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error purchasing: $e");
    }
  }

  void showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Purchase Successful"),
          content: Text("Your order has been placed successfully!"),
          actions: [
            CupertinoButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }