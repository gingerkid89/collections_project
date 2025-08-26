// lib/screens/place_creation/widgets/photo_upload_section.dart

import 'package:flutter/material.dart';

class PhotoUploadSection extends StatelessWidget {
  final List<String> photos;
  final String? primaryPhoto;
  final Function(List<String> photos, String? primaryPhoto) onPhotosChanged;

  const PhotoUploadSection({
    super.key,
    required this.photos,
    required this.primaryPhoto,
    required this.onPhotosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Primary Photo Upload
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (primaryPhoto != null)
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF3F4F6),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Primary Photo Preview',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removePrimaryPhoto(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => _showPhotoSourceDialog(context, true),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          style: BorderStyle.solid,
                        ),
                        color: const Color(0xFFF9FAFB),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add Primary Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Required • This will be the main photo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Additional Photos Section
          if (primaryPhoto != null) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Additional Photos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${photos.length}/5)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAdditionalPhotosGrid(context),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalPhotosGrid(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Existing additional photos
        ...photos.map((photo) => _buildPhotoThumbnail(photo)),
        
        // Add photo button (if less than 5)
        if (photos.length < 5)
          GestureDetector(
            onTap: () => _showPhotoSourceDialog(context, false),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  style: BorderStyle.solid,
                ),
                color: const Color(0xFFF9FAFB),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 24,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(String photo) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF3F4F6),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 32,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(height: 4),
                Text(
                  'Photo',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(photo),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoSourceDialog(BuildContext context, bool isPrimary) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPrimary ? 'Add Primary Photo' : 'Add Photo',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _PhotoSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _takePicture(isPrimary);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PhotoSourceOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery(isPrimary);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _takePicture(bool isPrimary) {
    // TODO: Implement camera functionality
    final dummyPath = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
    _addPhoto(dummyPath, isPrimary);
  }

  void _pickFromGallery(bool isPrimary) {
    // TODO: Implement gallery picker
    final dummyPath = 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
    _addPhoto(dummyPath, isPrimary);
  }

  void _addPhoto(String photoPath, bool isPrimary) {
    if (isPrimary) {
      onPhotosChanged(photos, photoPath);
    } else {
      final newPhotos = List<String>.from(photos);
      newPhotos.add(photoPath);
      onPhotosChanged(newPhotos, primaryPhoto);
    }
  }

  void _removePhoto(String photo) {
    final newPhotos = List<String>.from(photos);
    newPhotos.remove(photo);
    onPhotosChanged(newPhotos, primaryPhoto);
  }

  void _removePrimaryPhoto() {
    onPhotosChanged(photos, null);
  }
}

class _PhotoSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PhotoSourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}