import 'package:flutter/material.dart';

class ApartmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> apartment;

  const ApartmentDetailPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailPage> createState() => _ApartmentDetailPageState();
}

class _ApartmentDetailPageState extends State<ApartmentDetailPage> {
  bool isFavorite = false;
  int currentImageIndex = 0;

  // Sample apartment data (in real app, this would come from the widget parameter)
  final Map<String, dynamic> apartment = {
    'title': 'Modern Luxury Apartment',
    'location': 'Downtown Los Angeles, CA',
    'price': '\$1,200/month',
    'description': 'This beautiful modern apartment features floor-to-ceiling windows with stunning city views. Recently renovated with high-end finishes, stainless steel appliances, and smart home features. Perfect for professionals looking for luxury living in the heart of the city.',
    'bedrooms': 2,
    'bathrooms': 1,
    'area': '850 sq ft',
    'floor': '12th Floor',
    'yearBuilt': '2020',
    'parking': '1 Reserved Spot',
    'amenities': [
      'Swimming Pool',
      'Fitness Center',
      '24/7 Security',
      'Concierge Service',
      'Pet Friendly',
      'Laundry Room',
    ],
    'images': [
      'https://via.placeholder.com/400x300/4DB6AC/FFFFFF?text=Living+Room',
      'https://via.placeholder.com/400x300/4DB6AC/FFFFFF?text=Kitchen',
      'https://via.placeholder.com/400x300/4DB6AC/FFFFFF?text=Bedroom',
      'https://via.placeholder.com/400x300/4DB6AC/FFFFFF?text=Bathroom',
      'https://via.placeholder.com/400x300/4DB6AC/FFFFFF?text=View',
    ],
    'owner': {
      'name': 'John Smith',
      'phone': '(555) 123-4567',
      'email': 'john.smith@example.com',
      'rating': 4.8,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: apartment['images'].length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        apartment['images'][index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        apartment['images'].length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentImageIndex == index
                                ? Colors.teal
                                : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          apartment['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      Text(
                        apartment['price'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          apartment['location'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Basic Features
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(Icons.bed, '${apartment['bedrooms']} Bed'),
                        _buildFeatureItem(Icons.bathtub, '${apartment['bathrooms']} Bath'),
                        _buildFeatureItem(Icons.square_foot, apartment['area']),
                        _buildFeatureItem(Icons.sports_hockey, apartment['floor']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    apartment['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Details
                  const Text(
                    "Property Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow("Year Built", apartment['yearBuilt']),
                  _buildDetailRow("Parking", apartment['parking']),
                  _buildDetailRow("Property Type", "Apartment"),
                  _buildDetailRow("Availability", "Available Now"),
                  const SizedBox(height: 20),

                  // Amenities
                  const Text(
                    "Amenities",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: apartment['amenities'].map<Widget>((amenity) {
                      return Chip(
                        label: Text(amenity),
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        labelStyle: const TextStyle(color: Colors.teal),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Contact Owner
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Contact Owner",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildContactItem(Icons.person, apartment['owner']['name']),
                        _buildContactItem(Icons.phone, apartment['owner']['phone']),
                        _buildContactItem(Icons.email, apartment['owner']['email']),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              "${apartment['owner']['rating']} Owner Rating",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            // Call owner
                          },
                          color: Colors.white,
                          textColor: Colors.teal,
                          height: 50,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone),
                              SizedBox(width: 10),
                              Text("Call Owner"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            // Message owner
                          },
                          color: Colors.white,
                          textColor: Colors.teal,
                          height: 50,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.message),
                              SizedBox(width: 10),
                              Text("Message"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      // Schedule visit
                    },
                    color: Colors.teal,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    height: 50,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        Text(
                          "Schedule a Visit",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 30),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}