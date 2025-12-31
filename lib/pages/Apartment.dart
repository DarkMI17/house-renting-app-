import 'dart:convert';
import '../services/config.dart'; // Add this import

class Apartment {
  int? id;
  int? ownerId;
  int? provinceId;
  int? cityId;
  String title;
  String description;
  double price;
  List<String> images;
  int numberOfRooms;
  int numberOfBathrooms;
  String addressDetails;
  String status;
  bool hasElevator;
  bool hasBalcony;
  double area;
  Map<String, dynamic>? owner;
  Map<String, dynamic>? province;
  Map<String, dynamic>? city;
  List<dynamic>? bookings;
  List<dynamic>? reviews;

  Apartment({
    this.id,
    this.ownerId,
    this.provinceId,
    this.cityId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.numberOfRooms,
    required this.numberOfBathrooms,
    required this.addressDetails,
    required this.status,
    required this.hasElevator,
    required this.hasBalcony,
    required this.area,
    this.owner,
    this.province,
    this.city,
    this.bookings,
    this.reviews,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers
    num? parseNumber(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) {
        try {
          return num.tryParse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Helper function to safely parse booleans
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    // Handle images
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        for (var img in json['images']) {
          if (img is String) {
            imagesList.add(img);
          } else if (img != null) {
            imagesList.add(img.toString());
          }
        }
      } else if (json['images'] is String) {
        try {
          List<dynamic> parsed = jsonDecode(json['images']);
          for (var img in parsed) {
            if (img is String) imagesList.add(img);
          }
        } catch (e) {
          imagesList.add(json['images']);
        }
      }
    }

    return Apartment(
      id: parseNumber(json['id'])?.toInt(),
      ownerId: parseNumber(json['owner_id'])?.toInt(),
      provinceId: parseNumber(json['province_id'])?.toInt(),
      cityId: parseNumber(json['city_id'])?.toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: parseNumber(json['price'])?.toDouble() ?? 0.0,
      images: imagesList,
      numberOfRooms: parseNumber(json['number_of_rooms'])?.toInt() ?? 0,
      numberOfBathrooms: parseNumber(json['number_of_bathrooms'])?.toInt() ?? 0,
      addressDetails: json['address_details']?.toString() ?? '',
      status: json['status']?.toString() ?? 'available',
      hasElevator: parseBool(json['has_elevator']),
      hasBalcony: parseBool(json['has_balcony']),
      area: parseNumber(json['area'])?.toDouble() ?? 0.0,
      owner: json['owner'] is Map ? Map<String, dynamic>.from(json['owner'] as Map) : null,
      province: json['province'] is Map ? Map<String, dynamic>.from(json['province'] as Map) : null,
      city: json['city'] is Map ? Map<String, dynamic>.from(json['city'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'province_id': provinceId,
      'city_id': cityId,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'number_of_rooms': numberOfRooms,
      'number_of_bathrooms': numberOfBathrooms,
      'address_details': addressDetails,
      'status': status,
      'has_elevator': hasElevator,
      'has_balcony': hasBalcony,
      'area': area,
      'owner': owner,
      'province': province,
      'city': city,
    };
  }

  String getFormattedPrice() {
    return '\$${price.toStringAsFixed(0)}/month';
  }

  String getLocation() {
    String cityName = city?['name']?.toString() ?? '';
    String provinceName = province?['name']?.toString() ?? '';

    if (cityName.isNotEmpty && provinceName.isNotEmpty) {
      return '$cityName, $provinceName';
    } else if (cityName.isNotEmpty) {
      return cityName;
    } else if (provinceName.isNotEmpty) {
      return provinceName;
    }
    return addressDetails;
  }



  String getFirstImage() {
    if (images.isNotEmpty) {
      return ApiConfig.getImageUrl(images[0]);
    }
    return "https://via.placeholder.com/600x400";
  }


  factory Apartment.fromDynamicMap(Map<dynamic, dynamic> dynamicMap) {
    // Convert Map<dynamic, dynamic> to Map<String, dynamic>
    final Map<String, dynamic> json = {};
    dynamicMap.forEach((key, value) {
      json[key.toString()] = value;
    });

    return Apartment.fromJson(json);
  }
}