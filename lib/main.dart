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

   @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Item List"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.cart, color: CupertinoColors.activeBlue),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => CartPage(cart, purchaseItems)),
            );
          },
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : items.isEmpty
            ? Center(
            child: Text("No items available",
                style: TextStyle(color: CupertinoColors.white)))
            : ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, int index) {
            final item = items[index];

            return CupertinoListTile(
              title: Text(item['item_name'] ?? "Unknown Item"),
              subtitle: Text(
                "Stock: ${item['stock'] ?? '0'} | Price: ₱${item['price'] ?? '0.00'}",
              ),
              trailing: CupertinoButton(
                child: Icon(CupertinoIcons.add_circled,
                    color: CupertinoColors.systemBlue),
                onPressed: () => addToCart(item),
              ),
            );
          },
        ),
      ),
    );
  }
}
