import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product_page.dart';

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
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("$server/API.php"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          items = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
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
        Uri.parse("$server/purchase.php"),
        body: {"cart": jsonEncode(cart)},
      );

      if (response.statusCode == 200) {
        setState(() {
          cart.clear();
          getData();
        });
        showSuccessDialog();
      } else {
        print("❌ Purchase failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error purchasing: $e");
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
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
 void updateItem(Map<String, dynamic> item) {
    TextEditingController nameController = TextEditingController(text: item['item_name']);
    TextEditingController stockController = TextEditingController(text: item['stock'].toString());
    TextEditingController priceController = TextEditingController(text: item['price'].toString());

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Text("Update Item"),
              content: Column(
                children: [
                  CupertinoTextField(controller: nameController, placeholder: "Item Name"),
                  CupertinoTextField(controller: stockController, placeholder: "Stock", keyboardType: TextInputType.number),
                  CupertinoTextField(controller: priceController, placeholder: "Price", keyboardType: TextInputType.number),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: Text("Update"),
                  onPressed: () async {
                    String itemName = nameController.text.trim();
                    String stock = stockController.text.trim();
                    String price = priceController.text.trim();

                    if (itemName.isEmpty || stock.isEmpty || price.isEmpty) {
                      print("❌ All fields are required");
                      return;
                    }

                    int? stockValue = int.tryParse(stock);
                    double? priceValue = double.tryParse(price);

                    if (stockValue == null || priceValue == null) {
                      print("❌ Invalid stock or price values");
                      return;
                    }

                    Map<String, dynamic> requestData = {
                      "id": item['id'],
                      "item_name": itemName,
                      "stock": stockValue,
                      "price": priceValue,
                    };

                    try {
                      final response = await http.post(
                        Uri.parse("$server/update_item.php"),
                        headers: {
                          "Content-Type": "application/json",
                          "Accept": "application/json",
                        },
                        body: jsonEncode(requestData),
                      );

                      if (response.statusCode == 200) {
                        setState(() {
                          int index = items.indexWhere((element) => element['id'] == item['id']);
                          if (index != -1) {
                            items[index]['item_name'] = itemName;
                            items[index]['stock'] = stockValue.toString();
                            items[index]['price'] = priceValue.toString();
                          }
                        });
                        Navigator.pop(context);
                        getData();  // Reload the data after update
                      } else {
                        print("❌ Update failed: ${response.statusCode}");
                      }
                    } catch (e) {
                      print("❌ Error updating item: $e");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
   void deleteItem(dynamic id) async {
    int itemId = int.tryParse(id.toString()) ?? 0;

    if (itemId == 0) {
      print("❌ Invalid item ID");
      return;
    }

    bool confirmDelete = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Delete Item"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            CupertinoDialogAction(
              child: Text("Delete", style: TextStyle(color: CupertinoColors.systemRed)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (!confirmDelete) return;

    try {
      final response = await http.post(
        Uri.parse("$server/delete_item.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": itemId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["success"] != null) {
          setState(() {
            items.removeWhere((item) => item['id'] == itemId);
          });
          getData();  // Reload the data after deletion
          print("✅ Item deleted successfully");
        } else {
          print("❌ Error deleting item: ${responseData['error']}");
        }
      } else {
        print("❌ Delete request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error deleting item: $e");
    }
  }
