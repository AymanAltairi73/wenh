import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wenh/models/worker_model.dart';
import 'package:wenh/utils/map_utils.dart';
import 'package:wenh/core/theme/app_colors.dart';

class CustomerMapView extends StatefulWidget {
  final LatLng userLocation;
  final List<WorkerModel> workers;
  final Function(WorkerModel) onWorkerTap;

  const CustomerMapView({
    super.key,
    required this.userLocation,
    required this.workers,
    required this.onWorkerTap,
  });

  @override
  State<CustomerMapView> createState() => _CustomerMapViewState();
}

class _CustomerMapViewState extends State<CustomerMapView> {
  final double _searchRadius = 5000; // 5km in meters

  List<WorkerModel> _nearbyWorkers = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateNearbyWorkers();
  }

  @override
  void didUpdateWidget(CustomerMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workers != widget.workers ||
        oldWidget.userLocation != widget.userLocation) {
      _updateNearbyWorkers();
    }
  }

  void _updateNearbyWorkers() {
    final operationId = DateTime.now().millisecondsSinceEpoch;
    debugPrint(
      '[$operationId] [CustomerMapView] Updating nearby workers. Total: ${widget.workers.length}',
    );

    try {
      final List<WorkerModel> filtered = [];
      for (final worker in widget.workers) {
        if (worker.latitude == null || worker.longitude == null) continue;

        final distance = MapUtils.calculateDistance(
          lat1: widget.userLocation.latitude,
          lon1: widget.userLocation.longitude,
          lat2: worker.latitude!,
          lon2: worker.longitude!,
        );

        if (distance <= _searchRadius) {
          filtered.add(worker);
        }
      }

      debugPrint(
        '[$operationId] [CustomerMapView] Nearby workers found: ${filtered.length}',
      );

      // Generate markers outside of build()
      final Set<Marker> newMarkers = {
        // User Marker
        Marker(
          markerId: const MarkerId('me'),
          position: widget.userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'موقعي'),
        ),
        // Worker Markers
        ...filtered.map(
          (worker) => Marker(
            markerId: MarkerId('worker_${worker.uid}'),
            position: LatLng(worker.latitude!, worker.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            onTap: () => widget.onWorkerTap(worker),
            infoWindow: InfoWindow(
              title: worker.name,
              snippet: worker.profession,
            ),
          ),
        ),
      };

      setState(() {
        _nearbyWorkers = filtered;
        _markers = newMarkers;
      });
    } catch (e) {
      debugPrint(
        '[$operationId] [CustomerMapView] Error filtering workers: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.userLocation,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              debugPrint('[CustomerMapView] Map Created');
            },
            onCameraMove: (position) {
              debugPrint('[CustomerMapView] Camera Move: ${position.target}');
            },
            onCameraIdle: () {
              debugPrint('[CustomerMapView] Camera Idle');
            },
            markers: _markers,
            circles: {
              Circle(
                circleId: const CircleId('radius'),
                center: widget.userLocation,
                radius: _searchRadius,
                fillColor: AppColors.primary.withOpacity(0.1),
                strokeColor: AppColors.primary.withOpacity(0.2),
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
        ),

        // Nearby Info Overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppColors.softShadow],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'يوجد ${_nearbyWorkers.length} عامل متاح بالقرب منك',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
