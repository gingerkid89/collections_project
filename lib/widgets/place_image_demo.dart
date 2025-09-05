// lib/widgets/place_image_demo.dart
// Demo widget to showcase default place images

import 'package:flutter/material.dart';
import '../utils/default_place_images.dart';

class PlaceImageDemo extends StatelessWidget {
  const PlaceImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Default Place Images Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Restaurant Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildImageRow([
              _buildImageCard(
                'restaurant', 
                'Terra Rossa', 
                '🍝',
                'Italian Restaurant'
              ),
              _buildImageCard(
                'restaurant', 
                'Sushi Zen', 
                '🍣',
                'Japanese Restaurant'
              ),
              _buildImageCard(
                'restaurant', 
                'Burger Palace', 
                '🍔',
                'American Restaurant'
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              'Museum Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildImageRow([
              _buildImageCard(
                'museum', 
                'Art Gallery Munich', 
                '🎨',
                'Art Museum'
              ),
              _buildImageCard(
                'museum', 
                'History Museum Berlin', 
                '🏛️',
                'History Museum'
              ),
              _buildImageCard(
                'museum', 
                'Science Center Hamburg', 
                '🔬',
                'Science Museum'
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              'Different Names - Same Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Notice how each place gets a unique color based on its name',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildImageRow([
              _buildImageCard(
                'restaurant', 
                'Pizza Roma', 
                '🍕',
                'Gets one color'
              ),
              _buildImageCard(
                'restaurant', 
                'Pasta Milano', 
                '🍝',
                'Gets different color'
              ),
              _buildImageCard(
                'restaurant', 
                'Gelato Firenze', 
                '🍨',
                'Gets third color'
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              'Error Handling',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNetworkImageCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageRow(List<Widget> children) {
    return Row(
      children: children
          .map((child) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: child,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildImageCard(String type, String name, String emoji, String subtitle) {
    return Card(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: DefaultPlaceImages.generateDefaultImage(
                placeType: type,
                placeName: name,
                emoji: emoji,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImageCard() {
    return Card(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: DefaultPlaceImages.buildPlaceImage(
                placeType: 'restaurant',
                placeName: 'Network Error Demo',
                imageUrl: 'https://invalid-url-that-will-fail.com/image.jpg',
                emoji: '🚫',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Network Error Demo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Falls back to default when network image fails',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}