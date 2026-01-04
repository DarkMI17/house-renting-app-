class Apartment {
  final int id;
  final double price; // تم تغييره لـ double لأن الباك آند يستخدم float
  final String governorate;
  final String city;
  final double space; // تم تغييره لـ double ليتوافق مع 'area' في الباك آند
  final List<String> images; // الباك آند يرسل مصفوفة صور وليس مساراً واحداً
  final String? title;
  final String? description;
  final int? numberOfRooms;
  final int? numberOfBathrooms;
  final String? addressDetails; // إضافة الحقل المفقود ليتوافق مع address_details
  final bool hasElevator;
  final bool hasBalcony;

  Apartment({
    required this.id,
    required this.price,
    required this.governorate,
    required this.city,
    required this.space,
    required this.images,
    this.title,
    this.description,
    this.numberOfRooms,
    this.numberOfBathrooms,
    this.addressDetails,
    required this.hasElevator,
    required this.hasBalcony,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    // معالجة الصور القادمة كـ Array من الباك آند
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    }

    return Apartment(
      id: int.tryParse(json['id'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // الباك آند يرسل 'province' و 'city' كـ Objects أحياناً، لذا نأخذ الاسم
      governorate: json['province'] != null ? json['province']['name'].toString() : (json['governorate']?.toString() ?? ''),
      city: json['city'] != null ? json['city']['name'].toString() : (json['city']?.toString() ?? ''),
      space: double.tryParse(json['area']?.toString() ?? json['space']?.toString() ?? '0') ?? 0.0,
      images: imagesList,
      title: json['title'],
      description: json['description'],
      numberOfRooms: int.tryParse(json['number_of_rooms']?.toString() ?? '0'),
      numberOfBathrooms: int.tryParse(json['number_of_bathrooms']?.toString() ?? '0'),
      addressDetails: json['address_details'],
      // تحويل القيم 0 و 1 إلى true و false
      hasElevator: json['has_elevator'] == 1 || json['has_elevator'] == true,
      hasBalcony: json['has_balcony'] == 1 || json['has_balcony'] == true,
    );
  }

  // دالة للحصول على الصورة الأولى فقط للعرض المصغر
  String get firstImage => images.isNotEmpty ? images[0] : "https://via.placeholder.com/300";
}