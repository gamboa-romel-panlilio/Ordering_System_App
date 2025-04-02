import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  final String server;
  final Function refreshItems;

  const AddProductPage({super.key, required this.server, required this.refreshItems});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  bool isLoading = false;

  Future<void> addProduct() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${widget.server}/add_product.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "item_name": nameController.text.trim(),
          "price": priceController.text.trim(),
          "stock": stockController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["success"] == true) {
          widget.refreshItems();
          Navigator.pop(context);
        } else {
          showErrorDialog(responseData["message"]);
        }
      } else {
        showErrorDialog("Server error: ${response.statusCode}");
      }
    } catch (e) {
      showErrorDialog("Error adding product: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          CupertinoButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Add Product"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: nameController,
                placeholder: "Item Name",
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6, // Light background
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(10),
                ),
                style: TextStyle(color: CupertinoColors.white), // Text color white
                placeholderStyle: TextStyle(color: CupertinoColors.inactiveGray),
              ),
              SizedBox(height: 12),
              CupertinoTextField(
                controller: priceController,
                placeholder: "Price",
                keyboardType: TextInputType.number,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(10),
                ),
                style: TextStyle(color: CupertinoColors.white), // Text color white
                placeholderStyle: TextStyle(color: CupertinoColors.inactiveGray),
              ),
              SizedBox(height: 12),
              CupertinoTextField(
                controller: stockController,
                placeholder: "Stock",
                keyboardType: TextInputType.number,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(10),
                ),
                style: TextStyle(color: CupertinoColors.white), // Text color white
                placeholderStyle: TextStyle(color: CupertinoColors.inactiveGray),
              ),
              SizedBox(height: 24),
              CupertinoButton(
                child: isLoading
                    ? CupertinoActivityIndicator()
                    : Text(
                  "Add Product",
                  style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white), // Bold text, white color
                ),
                onPressed: isLoading ? null : addProduct,
                padding: EdgeInsets.symmetric(vertical: 16),
                borderRadius: BorderRadius.circular(12),
                color: CupertinoColors.activeBlue, // Blue button
              ),
            ],
          ),
        ),
      ),
    );
  }
}