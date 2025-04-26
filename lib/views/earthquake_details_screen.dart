import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../controllers/theme_controller.dart';
import '../models/earthquake.dart';

class EarthquakeDetailsScreen extends StatelessWidget {
  final Earthquake earthquake;

  const EarthquakeDetailsScreen({super.key, required this.earthquake});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode.value;

    // Format the occurredAt time to AM/PM
    final timeFormat = DateFormat('h:mm a, yyyy-MM-dd');
    final formattedTime = timeFormat.format(earthquake.occurredAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Earthquake Details',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Location and Magnitude
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Magnitude Circle with Gradient
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: earthquake.magnitude >= 6
                            ? [Colors.red, Colors.redAccent]
                            : [Colors.orange, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'M ${earthquake.magnitude.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      earthquake.locationDescription,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map showing the earthquake location
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      earthquake.latitude,
                      earthquake.longitude,
                    ),
                    initialZoom: 8.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            earthquake.latitude,
                            earthquake.longitude,
                          ),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: formattedTime,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.arrow_downward,
                    label: 'Depth',
                    value: '${earthquake.depth.toStringAsFixed(1)} km',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.place,
                    label: 'Latitude',
                    value: earthquake.latitude.toStringAsFixed(4),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.place,
                    label: 'Longitude',
                    value: earthquake.longitude.toStringAsFixed(4),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}