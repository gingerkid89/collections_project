// lib/screens/place_detail_implementations/restaurant_detail_view.dart

import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../models/place_statistic.dart';
import '../place_detail_view_interface.dart';
import '../add_visit_implementations/add_restaurant_visit_dialog.dart';

class RestaurantDetailView extends PlaceDetailViewInterface {
  final Restaurant restaurant;

  const RestaurantDetailView({
    super.key,
    required this.restaurant,
  }) : super(place: restaurant);

  @override
  String get specialTabLabel => 'Men�';

  @override
  String get specialTabIcon => 'restaurant_menu';

  @override
  List<PlaceStatistic> getSpecificStats(BuildContext? context) {
    final avgCost = _calculateAverageCost();
    final dishCount = restaurant.menu.length;
    final avgRating = _calculateAverageMenuRating();

    return [
      PlaceStatistic.number(
        label: 'Gerichte',
        value: dishCount,
      ),
      if (avgCost > 0)
        PlaceStatistic.currency(
          label: '� Preis',
          value: avgCost,
        ),
      if (avgRating > 0)
        PlaceStatistic.number(
          label: '� Bewertung',
          value: avgRating,
          unit: '',
        ),
    ];
  }

  @override
  List<Widget> getOverviewContent(BuildContext context) {
    return [
      _buildRestaurantInfoCard(),
      const SizedBox(height: 16),
      _buildQuickMenuPreview(),
      const SizedBox(height: 16),
      _buildCuisineAndPriceCard(),
    ];
  }

  @override
  Widget buildSpecialTab(BuildContext context) {
    return _buildMenuTab();
  }

  @override
  Widget? getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _addRestaurantVisit(context),
      backgroundColor: Colors.green,
      child: const Icon(Icons.restaurant_menu, color: Colors.white),
    );
  }

  Widget _buildRestaurantInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Restaurant Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('K�che', restaurant.cuisine),
            _buildInfoRow('Preiskategorie', restaurant.priceCategory),
            if (restaurant.hasReservation)
              _buildFeatureChip('Reservierungen m�glich'),
            if (restaurant.hasDelivery)
              _buildFeatureChip('Lieferservice'),
            if (restaurant.hasTakeout)
              _buildFeatureChip('Abholung'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenuPreview() {
    final topDishes = restaurant.menu.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Beliebte Gerichte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${restaurant.menu.length} Gerichte',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topDishes.map((dish) => _buildQuickDishTile(dish)),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineAndPriceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.public, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.cuisine,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'K�che',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    restaurant.priceCategory,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    'Preisklasse',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTab() {
    final categorizedMenu = _categorizeMenu();

    return categorizedMenu.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Keine Men�-Informationen verf�gbar'),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categorizedMenu.length,
            itemBuilder: (context, index) {
              final category = categorizedMenu.keys.elementAt(index);
              final dishes = categorizedMenu[category]!;
              return _buildMenuCategory(category, dishes);
            },
          );
  }

  Widget _buildMenuCategory(String category, List<MenuItem> dishes) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getCategoryEmoji(category),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${dishes.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...dishes.map((dish) => _buildDetailedDishTile(dish)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDishTile(MenuItem dish) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            _getDishEmoji(dish.category),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dish.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            dish.formattedPrice,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedDishTile(MenuItem dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dish.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                dish.formattedPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (dish.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dish.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          if (dish.dietaryLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: dish.dietaryLabels.map((label) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (dish.userRating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < dish.userRating! ? Icons.star : Icons.star_border,
                  size: 12,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      margin: const EdgeInsets.only(top: 4, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        feature,
        style: TextStyle(
          fontSize: 12,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  // Helper Methods
  Map<String, List<MenuItem>> _categorizeMenu() {
    final Map<String, List<MenuItem>> categorized = {};
    for (final dish in restaurant.menu) {
      if (!categorized.containsKey(dish.category)) {
        categorized[dish.category] = [];
      }
      categorized[dish.category]!.add(dish);
    }
    return categorized;
  }

  double _calculateAverageCost() {
    if (restaurant.menu.isEmpty) return 0;
    final total = restaurant.menu.fold<double>(0, (sum, dish) => sum + dish.price);
    return total / restaurant.menu.length;
  }

  double _calculateAverageMenuRating() {
    final ratedDishes = restaurant.menu.where((dish) => dish.userRating != null);
    if (ratedDishes.isEmpty) return 0;
    final total = ratedDishes.fold<double>(0, (sum, dish) => sum + dish.userRating!);
    return total / ratedDishes.length;
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'vorspeisen': return '>W';
      case 'hauptgerichte': return '<V';
      case 'pasta': return '<]';
      case 'pizza': return '<U';
      case 'desserts': return '<p';
      case 'getr�nke': return '>d';
      case 'salate': return '>l';
      default: return '<}';
    }
  }

  String _getDishEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'pasta': return '<]';
      case 'pizza': return '<U';
      case 'vorspeisen': return '>�';
      case 'desserts': return '<p';
      case 'hauptgerichte': return '<V';
      case 'salate': return '>W';
      case 'getr�nke': return '>d';
      default: return '<}';
    }
  }

  void _addRestaurantVisit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddRestaurantVisitDialog(restaurant: restaurant),
    );
  }

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  @override
  Widget build(BuildContext context) {
    return GenericPlaceDetailView(placeView: widget);
  }
}