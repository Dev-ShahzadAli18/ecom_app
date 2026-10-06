class ProductModel {
  String id;
  String name;
  double price;
  String category;
  String description;
  String imageUrl;
  String section;
  String userId;

  ProductModel({
    this.id = "",
    this.name = "",
    this.price = 0,
    this.category = "",
    this.description = "",
    this.imageUrl = "",
    this.section = "",
    this.userId = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
      "category": category,
      "description": description,
      "imageUrl": imageUrl,
      "section": section,
      "userId": userId,
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map["name"] ?? "",
      price: (map["price"] ?? 0).toDouble(),
      category: map["category"] ?? "",
      description: map["description"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      section: map["section"] ?? "",
      userId: map["userId"] ?? "",
    );
  }
}
