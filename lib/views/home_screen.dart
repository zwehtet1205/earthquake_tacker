import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/earthquake_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/earthquake.dart';
import '../widgets/earthquake_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const LatLng defaultMapCenter = LatLng(20.0, 96.0); // Andaman Sea
  static const double initialZoom = 5.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 2.0;

  @override
  Widget build(BuildContext context) {
    final EarthquakeController controller = Get.put(EarthquakeController());
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double bottomBarHeight = 60;
              final halfScreenHeight = constraints.maxHeight / 2;

              return Stack(
                children: [
                  // Map (Background)
                  Positioned.fill(child: _buildMap(controller)),

                  // Main Content
                  Column(
                    children: [
                      // Search Bar and Theme Switch
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(child: _buildSearchBar(context, isDarkMode)),
                            const SizedBox(width: 10),
                            _buildThemeSwitchButton(context, themeController, isDarkMode),
                          ],
                        ),
                      ),

                      // Spacer to push the list to the bottom
                      const Spacer(),

                      // Earthquake List
                      Obx(() {
                        return controller.isExpanded.value
                            ? _buildEarthquakeList(
                                context, controller, isDarkMode, halfScreenHeight)
                            : const SizedBox.shrink();
                      }),
                    ],
                  ),

                  // Collapsible Bottom Bar
                  Obx(() {
                    return controller.isExpanded.value
                        ? const SizedBox.shrink()
                        : _buildBottomBar(context, controller, isDarkMode, bottomBarHeight);
                  }),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  // Builds the map widget
  Widget _buildMap(EarthquakeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.earthquakes.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading earthquake data...'),
            ],
          ),
        );
      }

      return FlutterMap(
        options: MapOptions(
          initialCenter: controller.earthquakes.isNotEmpty
              ? LatLng(
                  controller.earthquakes[0].latitude,
                  controller.earthquakes[0].longitude,
                )
              : defaultMapCenter,
          initialZoom: initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.earthquake_tracker',
            maxZoom: maxZoom,
            minZoom: minZoom,
          ),
          MarkerLayer(
            markers: controller.earthquakes.map<Marker>((earthquake) {
              return Marker(
                point: LatLng(earthquake.latitude, earthquake.longitude),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 30,
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  // Builds the search bar widget
  Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).inputDecorationTheme.fillColor
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for locations',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          // Add search functionality later
        },
      ),
    );
  }

  // Builds the theme switch button
  Widget _buildThemeSwitchButton(BuildContext context, ThemeController themeController, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).inputDecorationTheme.fillColor // Ensure 'context' is passed here.
            : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onPressed: () => themeController.toggleTheme(),
      ),
    );
  }

// Updated Usage Inside Widget Tree

  // Builds the earthquake list widget
  Widget _buildEarthquakeList(
      BuildContext context,
      EarthquakeController controller,
      bool isDarkMode,
      double height) {
    return Container(
      height: height,
      color: isDarkMode ? Colors.black : Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent earthquakes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Add filter functionality later
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.expand_less),
                      onPressed: () => controller.toggleExpanded(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  final metrics = scrollNotification.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent - 100) {
                    controller.fetchMoreEarthquakes();
                  }
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.earthquakes.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.earthquakes.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final earthquake = controller.earthquakes[index];
                  return EarthquakeCard(earthquake: earthquake);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the collapsible bottom bar
  Widget _buildBottomBar(BuildContext context, EarthquakeController controller,
      bool isDarkMode, double height) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => controller.toggleExpanded(),
        child: Container(
          color: isDarkMode
              ? Theme.of(context).inputDecorationTheme.fillColor
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent earthquakes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Add filter functionality later
                    },
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}