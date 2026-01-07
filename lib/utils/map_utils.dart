import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for map-related operations
class MapUtils {
  /// Calculate distance between two coordinates in kilometers
  /// Uses the Haversine formula for accuracy
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format distance for display
  /// Returns "X.X km" or "X m" depending on distance
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters م';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} كم';
    }
  }

  /// Get current user location with permission request
  static Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Request continuous location permission
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خدمات الموقع غير مفعلة. يرجى تفعيلها.'),
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض الوصول إلى الموقع')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تفعيل صلاحيات الموقع من إعدادات الهاتف'),
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Open Google Maps with directions to a location
  static Future<bool> openGoogleMaps({
    required double destinationLat,
    required double destinationLng,
    String? destinationLabel,
  }) async {
    final label = destinationLabel ?? 'موقع الزبون';

    // Try to open in Google Maps app first
    final googleMapsUrl = Uri.parse(
      'google.navigation:q=$destinationLat,$destinationLng',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      return await launchUrl(googleMapsUrl);
    }

    // Fallback to web version
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&destination_label=$label',
    );

    return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }

  /// Open Waze with directions to a location
  static Future<bool> openWaze({
    required double destinationLat,
    required double destinationLng,
  }) async {
    final wazeUrl = Uri.parse(
      'waze://?ll=$destinationLat,$destinationLng&navigate=yes',
    );

    if (await canLaunchUrl(wazeUrl)) {
      return await launchUrl(wazeUrl);
    }

    // Fallback to web version
    final webUrl = Uri.parse(
      'https://waze.com/ul?ll=$destinationLat,$destinationLng&navigate=yes',
    );

    return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }

  /// Show a dialog to choose navigation app
  static Future<void> showNavigationOptions({
    required dynamic context,
    required double destinationLat,
    required double destinationLng,
    String? destinationLabel,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر تطبيق الملاحة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text('خرائط جوجل'),
              onTap: () async {
                Navigator.pop(context);
                final success = await openGoogleMaps(
                  destinationLat: destinationLat,
                  destinationLng: destinationLng,
                  destinationLabel: destinationLabel,
                );
                if (!success && context.mounted) {
                  _showErrorSnackBar(context, 'لم نتمكن من فتح خرائط جوجل');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation, color: Colors.cyan),
              title: const Text('Waze'),
              onTap: () async {
                Navigator.pop(context);
                final success = await openWaze(
                  destinationLat: destinationLat,
                  destinationLng: destinationLng,
                );
                if (!success && context.mounted) {
                  _showErrorSnackBar(context, 'لم نتمكن من فتح Waze');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackBar(dynamic context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
