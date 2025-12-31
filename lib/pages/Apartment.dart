class Apartment {
  final int id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final int numberOfRooms;
  final int numberOfBathrooms;
  final double area;
  final String addressDetails;
  final bool hasElevator;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.numberOfRooms,
    required this.numberOfBathrooms,
    required this.area,
    required this.addressDetails,
    required this.hasElevator,
  });

  // هنا "السحر" الذي يحل مشكلة String to int
  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // السعر أحياناً يأتي من الباك أند كـ String، هنا نحوله لـ double
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // معالجة مصفوفة الصور
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      numberOfRooms: int.tryParse(json['number_of_rooms'].toString()) ?? 0,
      numberOfBathrooms: int.tryParse(json['number_of_bathrooms'].toString()) ?? 0,
      area: double.tryParse(json['area'].toString()) ?? 0.0,
      addressDetails: json['address_details'] ?? '',
      // تحويل 0 أو 1 القادم من قاعدة البيانات إلى true/false
      hasElevator:
      json['has_elevator'] == 1 ||
          json['has_elevator'] == true ||
          json['has_elevator'] == "1",

    );
  }
}