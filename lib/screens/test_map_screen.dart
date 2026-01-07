import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestMapScreen extends StatefulWidget {
  const TestMapScreen({super.key});

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  GoogleMapController? _controller;
  bool _isMapCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار الخريطة'),
        actions: [
          if (_isMapCreated)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const Icon(Icons.cancel, color: Colors.red),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              'إذا رأيت شعار Google في الزاوية، فهذا يعني أن الإعدادات صحيحة. '
              'إذا كانت الخريطة فارغة، فتحقق من مفتاح API.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(33.3152, 44.3661), // Baghdad
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    debugPrint('[TestMap] Map Created Successfully');
                    setState(() {
                      _controller = controller;
                      _isMapCreated = true;
                    });
                  },
                  onCameraMove: (pos) =>
                      debugPrint('[TestMap] Camera Move: ${pos.target}'),
                  onCameraIdle: () => debugPrint('[TestMap] Camera Idle'),
                  myLocationEnabled: true,
                ),
                if (!_isMapCreated)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(const LatLng(33.3152, 44.3661), 14),
          );
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
