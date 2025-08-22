// lib/models/place_statistic.dart

class PlaceStatistic {
  final String label;
  final dynamic value;
  final String? unit;
  final StatisticType type;

  const PlaceStatistic({
    required this.label,
    required this.value,
    this.unit,
    required this.type,
  });

  factory PlaceStatistic.number({
    required String label,
    required num value,
    String? unit,
  }) {
    return PlaceStatistic(
      label: label,
      value: value,
      unit: unit,
      type: StatisticType.number,
    );
  }

  factory PlaceStatistic.percentage({
    required String label,
    required double value,
  }) {
    return PlaceStatistic(
      label: label,
      value: value,
      unit: '%',
      type: StatisticType.percentage,
    );
  }

  factory PlaceStatistic.currency({
    required String label,
    required double value,
    String currency = '€',
  }) {
    return PlaceStatistic(
      label: label,
      value: value,
      unit: currency,
      type: StatisticType.currency,
    );
  }

  factory PlaceStatistic.text({
    required String label,
    required String value,
  }) {
    return PlaceStatistic(
      label: label,
      value: value,
      type: StatisticType.text,
    );
  }

  String get formattedValue {
    switch (type) {
      case StatisticType.number:
        return value.toString() + (unit != null ? ' $unit' : '');
      case StatisticType.percentage:
        return '${value.toStringAsFixed(1)}%';
      case StatisticType.currency:
        return '${unit ?? '€'}${(value as double).toStringAsFixed(2)}';
      case StatisticType.text:
        return value.toString();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'unit': unit,
      'type': type.name,
    };
  }

  factory PlaceStatistic.fromJson(Map<String, dynamic> json) {
    return PlaceStatistic(
      label: json['label'],
      value: json['value'],
      unit: json['unit'],
      type: StatisticType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatisticType.text,
      ),
    );
  }
}

enum StatisticType {
  number,
  percentage,
  currency,
  text,
}