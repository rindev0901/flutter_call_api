class Product {
  String name;
  String description;
  double price;
  String image;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json["name"],
      description: json["description"],
      price: json["price"],
      image: json["image"],
    );
  }
}
