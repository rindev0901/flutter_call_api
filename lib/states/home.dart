import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_call_api/constants/index.dart';
import 'package:flutter_call_api/models/product.dart';
import 'package:flutter_call_api/models/response.dart';
import 'package:flutter_call_api/pages/home.dart';
import 'package:http/http.dart' as http;

class MyHomePageState extends State<MyHomePage> {
  late Future<Response<List<Product>>> futureProducts;

  Response<List<Product>> parseResponse(String responseJson) {
    // Ensure we decode only once
    final Map<String, dynamic> jsonMap = jsonDecode(responseJson);

    return Response<List<Product>>.fromJson(
      jsonMap,
      (data) =>
          (data as List<dynamic>)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<Response<List<Product>>> fetchProducts() async {
    try {
      final url = Uri.parse("${Constants.BASE_URL}/Product/list");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return parseResponse(response.body);
      }
    } catch (e) {
      print("Error: $e");
    }
    return Response<List<Product>>(
      success: false,
      message: "Error fetching data",
      statusCode: 500,
      data: [],
    ); // ✅ Ensure non-null return
  }

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255, // Alpha (opacity) - 255 means fully opaque
      random.nextInt(256), // Red (0-255)
      random.nextInt(256), // Green (0-255)
      random.nextInt(256), // Blue (0-255)
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<Response<List<Product>>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || !snapshot.data!.success) {
            return Center(
              child: Text(snapshot.data?.message ?? "Data not available"),
            );
          }

          // Display list of posts
          List<Product> products = snapshot.data?.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color of the container
                      borderRadius: BorderRadius.circular(
                        5,
                      ), // Optional: Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(50), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset: Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ), // Optional: Add margin
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200.0,
                          height: 100.0,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              // Remove border radius
                              borderRadius:
                                  BorderRadius.zero, // Set borderRadius to zero
                            ),
                            color:
                                getRandomColor(), // Assign a random color to each card
                            child: Center(
                              child: Text(
                                products[index].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          // Use Expanded to constrain the ListTile's width
                          child: ListTile(
                            title: Center(
                              child: Text(
                                products[index].name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                Text(
                                  products[index].description,
                                  textAlign: TextAlign.center,
                                ),
                                Text("Price: ${products[index].price}"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  spacing: 20,
                                  children: [
                                    Icon(
                                      Icons.star_border,
                                      color: Colors.red,
                                      size: 24.0,
                                      semanticLabel: 'Rating',
                                    ),
                                    Icon(
                                      Icons.star_border,
                                      color: Colors.red,
                                      size: 24.0,
                                      semanticLabel: 'Rating',
                                    ),
                                    Icon(
                                      Icons.star_border,
                                      color: Colors.red,
                                      size: 24.0,
                                      semanticLabel: 'Rating',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
