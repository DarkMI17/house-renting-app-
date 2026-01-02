import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';


class ApartmentCard extends StatelessWidget {


  final dynamic apartment; // بيانات الشقة
  final String baseServerUrl; // ApiConfig.baseUrl بدون /api
  final VoidCallback onTap;

  const ApartmentCard({
    super.key,
    required this.apartment,
    required this.baseServerUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagesCarousel(context),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment['title'] ?? "No Title",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${apartment['city']?['name'] ?? ''}, ${apartment['province']?['name'] ?? ''}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "\$${apartment['price'] ?? 'N/A'}",
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carousel للصور
  Widget _buildImagesCarousel(BuildContext context) {
    List<dynamic> images = apartment['images'] ?? [];

    if (images.isEmpty) {
      return _placeholder();
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        itemBuilder: (context, index) {
          String imgName = images[index];
          String imgUrl = "$baseServerUrl/storage/apartments/$imgName";

          return GestureDetector(
            onTap: () => _showFullScreenImage(context, imgUrl),
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => _placeholder(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }

  // تكبير الصورة عند الضغط عليها
  void _showFullScreenImage(BuildContext context, String url) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => _placeholder(),
              ),
            ),
            Positioned(
              top: 30,
              right: 30,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}