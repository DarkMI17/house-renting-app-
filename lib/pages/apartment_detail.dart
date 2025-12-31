import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'apartment.dart';

class ApartmentDetailPage extends StatelessWidget {
  final Apartment apartment;

  const ApartmentDetailPage({Key? key, required this.apartment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
              title: Text(
                apartment.getFormattedPrice(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareApartment(),
              ),
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () => _toggleFavorite(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          apartment.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(apartment.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apartment.status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          apartment.getLocation(),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    apartment.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 24),

                  // Features Grid
                  Text(
                    'Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                    children: [
                      _featureTile(Icons.bed, '${apartment.numberOfRooms} Rooms'),
                      _featureTile(Icons.bathtub, '${apartment.numberOfBathrooms} Bath'),
                      _featureTile(Icons.square_foot, '${apartment.area} m²'),
                      _featureTile(Icons.elevator, apartment.hasElevator ? 'Elevator' : 'No Elevator'),
                      _featureTile(Icons.balcony, apartment.hasBalcony ? 'Balcony' : 'No Balcony'),
                      _featureTile(Icons.star, apartment.status),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Address
                  Text(
                    'Address Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.home, color: Colors.teal),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            apartment.addressDetails,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Owner Info (if available)
                  if (apartment.owner != null) ...[
                    Text(
                      'Owner Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal[100],
                            child: Icon(Icons.person, color: Colors.teal),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${apartment.owner?['first_name'] ?? ''} ${apartment.owner?['last_name'] ?? ''}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  apartment.owner?['phone']?.toString() ?? 'No phone',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.phone, color: Colors.teal),
                            onPressed: () => _contactOwner(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _bookNow(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.calendar_today, color: Colors.white),
                          label: Text(
                            'Book Now',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _sendMessage(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.teal),
                          ),
                          icon: Icon(Icons.message, color: Colors.teal),
                          label: Text(
                            'Message',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    if (apartment.images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(Icons.home, size: 100, color: Colors.grey[400]),
        ),
      );
    }

    return PageView.builder(
      itemCount: apartment.images.length,
      itemBuilder: (context, index) {
        String imageUrl = apartment.images[index];
        if (!imageUrl.startsWith('http')) {
          if (imageUrl.startsWith('/storage/')) {
            imageUrl = "http://192.168.0.103:8000${imageUrl}";
          } else {
            imageUrl = "http://192.168.0.103:8000/storage/$imageUrl";
          }
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text('Image not available', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _featureTile(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.teal),
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'booked':
        return Colors.orange;
      case 'rented':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _shareApartment() {
    Get.snackbar(
      'Share',
      'Sharing ${apartment.title}',
      duration: Duration(seconds: 2),
    );
  }

  void _toggleFavorite() {
    Get.snackbar(
      'Favorite',
      'Added to favorites',
      duration: Duration(seconds: 2),
    );
  }

  void _contactOwner() {
    if (apartment.owner?['phone'] != null) {
      Get.snackbar(
        'Contact Owner',
        'Calling ${apartment.owner!['phone']}',
        duration: Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'No phone number available',
        duration: Duration(seconds: 2),
      );
    }
  }

  void _bookNow() {
    Get.snackbar(
      'Booking',
      'Booking apartment: ${apartment.title}',
      duration: Duration(seconds: 2),
    );
  }

  void _sendMessage() {
    Get.snackbar(
      'Message',
      'Send message to owner',
      duration: Duration(seconds: 2),
    );
  }
}