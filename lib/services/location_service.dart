import 'dart:math' as math;

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
    );
  }
}

class LocationService {

  // Mock location data for Iraqi cities
  static final Map<String, LocationData> iraqiCities = {
    'بغداد': LocationData(latitude: 33.3128, longitude: 44.3615, address: 'بغداد، العراق'),
    'نينوى': LocationData(latitude: 36.3425, longitude: 43.1582, address: 'نينوى، العراق'),
    'البصرة': LocationData(latitude: 30.4859, longitude: 47.8080, address: 'البصرة، العراق'),
    'صلاح الدين': LocationData(latitude: 34.7625, longitude: 43.7930, address: 'صلاح الدين، العراق'),
    'دهوك': LocationData(latitude: 36.8746, longitude: 42.9856, address: 'دهوك، العراق'),
    'أربيل': LocationData(latitude: 36.1914, longitude: 44.0091, address: 'أربيل، العراق'),
    'السليمانية': LocationData(latitude: 35.5607, longitude: 45.4615, address: 'السليمانية، العراق'),
    'ديالى': LocationData(latitude: 33.7412, longitude: 45.2667, address: 'ديالى، العراق'),
    'واسط': LocationData(latitude: 32.7521, longitude: 45.9167, address: 'واسط، العراق'),
    'ميسان': LocationData(latitude: 31.8343, longitude: 47.6667, address: 'ميسان، العراق'),
    'ذي قار': LocationData(latitude: 31.0089, longitude: 46.2667, address: 'ذي قار، العراق'),
    'المثنى': LocationData(latitude: 31.8000, longitude: 44.3167, address: 'المثنى، العراق'),
    'بابل': LocationData(latitude: 32.5597, longitude: 44.9272, address: 'بابل، العراق'),
    'كربلاء': LocationData(latitude: 32.5597, longitude: 44.0281, address: 'كربلاء، العراق'),
    'النجف': LocationData(latitude: 31.9454, longitude: 44.3569, address: 'النجف، العراق'),
    'الأنبار': LocationData(latitude: 33.8333, longitude: 41.9333, address: 'الأنبار، العراق'),
    'الديوانية (القادسية)': LocationData(latitude: 31.9454, longitude: 44.9272, address: 'الديوانية، العراق'),
    'كركوك': LocationData(latitude: 35.4669, longitude: 44.5892, address: 'كركوك، العراق'),
  };

  // Get location by city name
  static LocationData? getLocationByCity(String cityName) {
    return iraqiCities[cityName];
  }

  // Get all available cities
  static List<String> getAllCities() {
    return iraqiCities.keys.toList();
  }

  // Calculate distance between two coordinates (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  // Format location for display
  static String formatLocation(LocationData location) {
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }

  // Get nearest city to coordinates
  static String? getNearestCity(double latitude, double longitude) {
    String? nearestCity;
    double minDistance = double.infinity;

    iraqiCities.forEach((city, location) {
      final distance = calculateDistance(
        latitude,
        longitude,
        location.latitude,
        location.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    });

    return nearestCity;
  }
}
