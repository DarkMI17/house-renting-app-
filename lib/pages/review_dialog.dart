// review_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewDialog extends StatefulWidget {
  final int apartmentId;
  final Function(double, String) onSubmit;
  final int? initialRating;
  final String? initialComment;
  final bool isEditMode;

  const ReviewDialog({
    super.key,
    required this.apartmentId,
    required this.onSubmit,
    this.initialRating,
    this.initialComment,
    this.isEditMode = false,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRating != null) {
      _rating = widget.initialRating!;
    }
    if (widget.initialComment != null) {
      _commentController.text = widget.initialComment!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        widget.isEditMode ? 'Edit Your Review' : 'Rate this Apartment',
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'How would you rate this apartment?',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Rating Stars
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 40,
                      color: _rating > index ? Colors.amber : Colors.grey[300],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Your Rating: $_rating/5',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            // Comment Field
            Text(
              'Write your review (optional):',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: _rating == 0
              ? null
              : () {
            widget.onSubmit(
              _rating.toDouble(),
              _commentController.text.trim(),
            );
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(widget.isEditMode ? 'Update' : 'Submit'),
        ),
      ],
    );
  }
}