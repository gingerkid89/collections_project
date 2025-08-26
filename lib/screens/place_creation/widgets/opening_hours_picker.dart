// lib/screens/place_creation/widgets/opening_hours_picker.dart

import 'package:flutter/material.dart';

class OpeningHoursPicker extends StatefulWidget {
  final Map<String, String> openingHours;
  final Function(Map<String, String>) onHoursChanged;

  const OpeningHoursPicker({
    super.key,
    required this.openingHours,
    required this.onHoursChanged,
  });

  @override
  State<OpeningHoursPicker> createState() => _OpeningHoursPickerState();
}

class _OpeningHoursPickerState extends State<OpeningHoursPicker> {
  late Map<String, String> _hours;
  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _hours = Map.from(widget.openingHours);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header with quick actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Set Opening Hours',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _QuickActionButton(
                      label: 'Copy Mon-Fri',
                      onPressed: _copyMondayToFriday,
                    ),
                    const SizedBox(width: 8),
                    _QuickActionButton(
                      label: 'Same All Week',
                      onPressed: _copySameAllWeek,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Days list
          ...List.generate(_weekdays.length, (index) {
            final day = _weekdays[index];
            return _buildDayRow(day);
          }),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day) {
    final hours = _hours[day.toLowerCase()] ?? '';
    final isClosed = hours.isEmpty || hours.toLowerCase() == 'closed';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Closed toggle
          Row(
            children: [
              Switch(
                value: !isClosed,
                onChanged: (isOpen) {
                  if (isOpen) {
                    _updateHours(day, '09:00-17:00'); // Default hours
                  } else {
                    _updateHours(day, 'closed');
                  }
                },
                activeColor: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                isClosed ? 'Closed' : 'Open',
                style: TextStyle(
                  fontSize: 14,
                  color: isClosed ? const Color(0xFF6B7280) : const Color(0xFF374151),
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Hours input
          if (!isClosed)
            GestureDetector(
              onTap: () => _showHoursDialog(day, hours),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hours.isNotEmpty ? hours : 'Set hours',
                      style: TextStyle(
                        fontSize: 14,
                        color: hours.isNotEmpty 
                          ? const Color(0xFF374151)
                          : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showHoursDialog(String day, String currentHours) {
    String openTime = '09:00';
    String closeTime = '17:00';
    
    if (currentHours.isNotEmpty && currentHours.contains('-')) {
      final parts = currentHours.split('-');
      if (parts.length == 2) {
        openTime = parts[0];
        closeTime = parts[1];
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Set Hours for $day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Open: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimeSelector(
                      time: openTime,
                      onTimeChanged: (time) {
                        setDialogState(() => openTime = time);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Close: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimeSelector(
                      time: closeTime,
                      onTimeChanged: (time) {
                        setDialogState(() => closeTime = time);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateHours(day, '$openTime-$closeTime');
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateHours(String day, String hours) {
    setState(() {
      _hours[day.toLowerCase()] = hours;
    });
    widget.onHoursChanged(_hours);
  }

  void _copyMondayToFriday() {
    final mondayHours = _hours['monday'] ?? '09:00-17:00';
    setState(() {
      for (String day in ['tuesday', 'wednesday', 'thursday', 'friday']) {
        _hours[day] = mondayHours;
      }
    });
    widget.onHoursChanged(_hours);
  }

  void _copySameAllWeek() {
    final mondayHours = _hours['monday'] ?? '09:00-17:00';
    setState(() {
      for (String day in _weekdays) {
        _hours[day.toLowerCase()] = mondayHours;
      }
    });
    widget.onHoursChanged(_hours);
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String time;
  final Function(String) onTimeChanged;

  const _TimeSelector({
    required this.time,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.schedule,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) async {
    final parts = time.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      onTimeChanged(formattedTime);
    }
  }
}