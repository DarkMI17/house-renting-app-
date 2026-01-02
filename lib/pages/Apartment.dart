class Apartment {
  final int id;
  final int price;
  final String governorate;
  final String city;
  final int space;
  final String imagePath;
  // إضافة الحقول الأخرى إذا كنتِ تستخدمينها في الواجهة
  final String? title;
  final String? description;
  final int? numberOfRooms;
  final bool hasElevator;

  Apartment({
    required this.id,
    required this.price,
    required this.governorate,
    required this.city,
    required this.space,
    required this.imagePath,
    this.title,
    this.description,
    this.numberOfRooms,
    required this.hasElevator,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    // --- 1. منطق معالجة وتنظيف رابط الصورة ---
    String rawPath = '';
    if (json['main_image'] != null && json['main_image']['path'] != null) {
      rawPath = json['main_image']['path'].toString();
    } else if (json['image_path'] != null) {
      rawPath = json['image_path'].toString();
    }

    String cleanedPath = rawPath
        .replaceAll('[', '')    // حذف [
        .replaceAll(']', '')    // حذف ]
        .replaceAll('"', '')    // حذف "
        .replaceAll('\\', '')   // حذف الباك سلاش
        .replaceAll('//', '/'); // تصحيح السلاش المزدوج

    // تصحيح الـ IP (تأكدي من مطابقة الـ IP لجهازك)
    String correctedPath = cleanedPath.replaceAll('localhost', '192.168.1.7');

    // إذا كان الرابط لا يبدأ بـ http، نقوم بإضافة الـ Base URL (اختياري حسب إعداداتك)
    if (correctedPath.isNotEmpty && !correctedPath.startsWith('http')) {
      // correctedPath = "http://192.168.1.7:8000" + correctedPath;
    }

    // --- 2. إرجاع الكائن مع دمج الحقول ---
    return Apartment(
      id: int.tryParse(json['id'].toString()) ?? 0,
      price: int.tryParse(json['price'].toString()) ?? 0,
      // استخدام capitalize() التي عرفتيها سابقاً
      governorate: (json['governorate']?.toString() ?? '').capitalize(),
      city: (json['city']?.toString() ?? '').capitalize(),
      space: int.tryParse(json['space']?.toString() ?? '0') ?? 0,
      imagePath: correctedPath,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      numberOfRooms: int.tryParse(json['number_of_rooms']?.toString() ?? '0'),
      // معالجة حقل الـ Boolean (المصعد)
      hasElevator: json['has_elevator'] == 1 ||
          json['has_elevator'] == true ||
          json['has_elevator'].toString() == "1",
    );
  }
}

// لا تنسي إضافة الـ Extension الخاص بكِ أسفل الملف لكي يعمل capitalize()
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}