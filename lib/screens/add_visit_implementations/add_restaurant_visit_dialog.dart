// lib/screens/add_visit_implementations/add_restaurant_visit_dialog.dart

import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../models/visit.dart';
import '../../models/visit_activity.dart';

class AddRestaurantVisitDialog extends StatefulWidget {
  final Restaurant restaurant;

  const AddRestaurantVisitDialog({
    super.key,
    required this.restaurant,
  });

  @override
  State<AddRestaurantVisitDialog> createState() => _AddRestaurantVisitDialogState();
}

class _AddRestaurantVisitDialogState extends State<AddRestaurantVisitDialog> {
  // Basic visit data
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final TextEditingController notesController = TextEditingController();
  double overallRating = 0.0;

  // Restaurant-specific data
  List<MenuItem> selectedDishes = [];
  double tipAmount = 0.0;
  double otherCosts = 0.0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  // Getters
  DateTime get visitDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  bool get canSave => overallRating > 0;

  double get totalCost {
    final dishTotal = selectedDishes.fold<double>(0, (sum, dish) => sum + dish.price);
    return dishTotal + tipAmount + otherCosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Besuch: ${widget.restaurant.name}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: canSave ? _saveVisit : null,
            child: const Text(
              'Speichern',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBasicVisitSection(),
            _buildMenuSelectionSection(),
            _buildCostSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicVisitSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Besuchsinformationen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Date and Time Row
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Datum'),
                    subtitle: Text('${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Uhrzeit'),
                    subtitle: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            
            // Rating
            const SizedBox(height: 16),
            const Text('Gesamtbewertung *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => overallRating = index + 1.0),
                  icon: Icon(
                    index < overallRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            
            // Notes
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notizen (optional)',
                hintText: 'Wie war dein Besuch?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSelectionSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.green),
                SizedBox(width: 8),
                Text('Gegessene Gerichte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selected dishes
            if (selectedDishes.isNotEmpty) ...[
              const Text('Ausgewählte Gerichte:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ...selectedDishes.map((dish) => _buildSelectedDishTile(dish)),
              const SizedBox(height: 16),
            ],
            
            // Available dishes
            const Text('Verfügbare Gerichte:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.restaurant.menu.length,
                itemBuilder: (context, index) {
                  final dish = widget.restaurant.menu[index];
                  final isSelected = selectedDishes.any((d) => d.id == dish.id);
                  return ListTile(
                    title: Text(dish.name),
                    subtitle: Text('${dish.formattedPrice} - ${dish.category}'),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.add),
                    onTap: isSelected ? null : () => _addDish(dish),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.euro, color: Colors.green),
                SizedBox(width: 8),
                Text('Kosten', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cost summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gerichte:'),
                      Text('€${(totalCost - tipAmount - otherCosts).toStringAsFixed(2)}'),
                    ],
                  ),
                  if (tipAmount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trinkgeld:'),
                        Text('€${tipAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                  if (otherCosts > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sonstiges:'),
                        Text('€${otherCosts.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gesamt:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '€${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDishTile(MenuItem dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${dish.formattedPrice} - ${dish.category}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeDish(dish),
            icon: const Icon(Icons.close, color: Colors.red),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _addDish(MenuItem dish) {
    setState(() {
      selectedDishes.add(dish);
    });
  }

  void _removeDish(MenuItem dish) {
    setState(() {
      selectedDishes.removeWhere((d) => d.id == dish.id);
    });
  }

  void _saveVisit() {
    try {
      final visit = _createVisit();
      Navigator.of(context).pop(visit);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Besuch erfolgreich gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Visit _createVisit() {
    final dishActivities = selectedDishes.map((dish) {
      return RestaurantDish(
        id: dish.id,
        name: dish.name,
        category: dish.category,
        price: dish.price,
        description: dish.description,
      );
    }).toList();

    return Visit.create(
      date: visitDateTime,
      placeId: widget.restaurant.id,
      placeType: 'restaurant',
      overallRating: overallRating,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      totalCost: totalCost > 0 ? totalCost : null,
      activities: dishActivities,
      metadata: {
        'restaurant_name': widget.restaurant.name,
        'tip_amount': tipAmount,
        'other_costs': otherCosts,
        'dish_count': selectedDishes.length,
      },
    );
  }
}