import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wenh/models/request_model.dart';
import 'package:wenh/models/worker_model.dart';
import 'package:wenh/models/user_model.dart';
import 'package:wenh/core/theme/app_colors.dart';

class AdminMapView extends StatefulWidget {
  final List<RequestModel> requests;
  final List<WorkerModel> workers;
  final List<UserModel> customers;

  const AdminMapView({
    super.key,
    required this.requests,
    required this.workers,
    required this.customers,
  });

  @override
  State<AdminMapView> createState() => _AdminMapViewState();
}

class _AdminMapViewState extends State<AdminMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _showRequests = true;
  bool _showWorkers = true;
  bool _showCustomers = true;
  bool _isHeatmapMode = false;
  bool _hasInitialMarkersFitted = false;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(AdminMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests ||
        oldWidget.workers != widget.workers ||
        oldWidget.customers != widget.customers) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    final operationId = DateTime.now().millisecondsSinceEpoch;
    debugPrint(
      '[$operationId] [AdminMapView] Updating markers. Requests: ${widget.requests.length}, Workers: ${widget.workers.length}, Customers: ${widget.customers.length}',
    );
    final Set<Marker> newMarkers = {};
    final Set<Circle> newCircles = {};

    try {
      if (_showRequests) {
        for (final request in widget.requests) {
          if (request.latitude != null && request.longitude != null) {
            newMarkers.add(
              Marker(
                markerId: MarkerId('request_${request.id}'),
                position: LatLng(request.latitude!, request.longitude!),
                clusterManagerId: const ClusterManagerId('requests_cluster'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  request.status == 'new'
                      ? BitmapDescriptor.hueOrange
                      : BitmapDescriptor.hueGreen,
                ),
                infoWindow: InfoWindow(
                  title: request.type,
                  snippet: '${request.area} - ${request.status}',
                ),
              ),
            );

            if (_isHeatmapMode) {
              newCircles.add(
                Circle(
                  circleId: CircleId('heat_${request.id}'),
                  center: LatLng(request.latitude!, request.longitude!),
                  radius: 500,
                  fillColor: Colors.red.withOpacity(0.2),
                  strokeWidth: 0,
                ),
              );
            }
          }
        }
      }

      if (_showWorkers) {
        for (final worker in widget.workers) {
          if (worker.latitude != null && worker.longitude != null) {
            newMarkers.add(
              Marker(
                markerId: MarkerId('worker_${worker.uid}'),
                position: LatLng(worker.latitude!, worker.longitude!),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
                infoWindow: InfoWindow(
                  title: 'عامل: ${worker.name}',
                  snippet: worker.isSubscriptionActive ? 'نشط' : 'غير نشط',
                ),
              ),
            );
          }
        }
      }

      if (_showCustomers) {
        for (final customer in widget.customers) {
          if (customer.latitude != null && customer.longitude != null) {
            newMarkers.add(
              Marker(
                markerId: MarkerId('customer_${customer.uid}'),
                position: LatLng(customer.latitude!, customer.longitude!),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                ),
                infoWindow: InfoWindow(
                  title: 'زبون: ${customer.name}',
                  snippet: customer.phone ?? 'لا يوجد رقم هاتف',
                ),
              ),
            );
          }
        }
      }

      debugPrint(
        '[$operationId] [AdminMapView] Markers generated: ${newMarkers.length}',
      );
    } catch (e) {
      debugPrint('[$operationId] [AdminMapView] Error generating markers: $e');
    }

    setState(() {
      _markers = newMarkers;
      _circles = newCircles;
    });

    // Move camera to fit all markers ONLY ONCE when data first arrives
    if (_markers.isNotEmpty &&
        _mapController != null &&
        !_hasInitialMarkersFitted) {
      debugPrint('[$operationId] [AdminMapView] Initial marker fit');
      _fitMarkers();
      _hasInitialMarkersFitted = true;
    }
  }

  void _fitMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng)
        minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng)
        maxLng = marker.position.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0, // Padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.3152, 44.3661), // Baghdad default
              zoom: 11,
            ),
            onMapCreated: (controller) {
              debugPrint('[AdminMapView] Map Created');
              _mapController = controller;
            },
            onCameraMove: (position) {
              debugPrint('[AdminMapView] Camera Move: ${position.target}');
            },
            onCameraIdle: () {
              debugPrint('[AdminMapView] Camera Idle');
            },
            onTap: (position) {
              debugPrint('[AdminMapView] Map Tapped: $position');
            },
            clusterManagers: {
              ClusterManager(
                clusterManagerId: const ClusterManagerId('requests_cluster'),
                onClusterTap: (cluster) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(cluster.position, 14),
                  );
                },
              ),
            },
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
        ),

        // Controls Overlay
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildControlItem(
                enabled: _showRequests,
                onTap: () {
                  setState(() => _showRequests = !_showRequests);
                  _updateMarkers();
                },
                icon: Icons.assignment_outlined,
                label: 'الطلبات',
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildControlItem(
                enabled: _showWorkers,
                onTap: () {
                  setState(() => _showWorkers = !_showWorkers);
                  _updateMarkers();
                },
                icon: Icons.person_pin_circle_outlined,
                label: 'العمال',
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildControlItem(
                enabled: _showCustomers,
                onTap: () {
                  setState(() => _showCustomers = !_showCustomers);
                  _updateMarkers();
                },
                icon: Icons.people_outline,
                label: 'الزبائن',
                color: Colors.purple,
              ),
              const SizedBox(height: 8),
              _buildControlItem(
                enabled: _isHeatmapMode,
                onTap: () {
                  setState(() => _isHeatmapMode = !_isHeatmapMode);
                  _updateMarkers();
                },
                icon: Icons.layers_outlined,
                label: 'كثافة الطلب',
                color: Colors.red,
              ),
            ],
          ),
        ),

        // Stats Summary at Bottom
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'طلبات',
                  widget.requests.length.toString(),
                  Colors.orange,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.withOpacity(0.3),
                ),
                _buildStatItem(
                  'عمال',
                  widget.workers.length.toString(),
                  Colors.blue,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.withOpacity(0.3),
                ),
                _buildStatItem(
                  'نشطين',
                  widget.workers
                      .where((w) => w.isSubscriptionActive)
                      .length
                      .toString(),
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlItem({
    required bool enabled,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: enabled ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
