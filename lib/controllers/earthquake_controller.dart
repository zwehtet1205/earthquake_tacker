import 'package:get/get.dart';
import '../models/earthquake.dart';
import '../services/earthquake_service.dart';

class EarthquakeController extends GetxController {
  var earthquakes = <Earthquake>[].obs;
  var isLoading = true.obs;
  var isExpanded = true.obs;
  var isLoadingMore = false.obs; // For loading more data
  var currentOffset = 1.obs; // Start at 1 as per USGS API requirement
  final int limit = 25; // Number of items per page

  @override
  void onInit() {
    fetchEarthquakes();
    super.onInit();
  }

  void fetchEarthquakes() async {
    try {
      isLoading(true);
      currentOffset.value = 1; // Start at 1 for initial fetch
      print('Fetching initial earthquakes with offset: ${currentOffset.value}');
      final data = await EarthquakeService().fetchEarthquakes(
        limit: limit,
        offset: currentOffset.value,
      );
      print('Fetched ${data.length} earthquakes');
      earthquakes.assignAll(data);
    } catch (e) {
      print('Error in fetchEarthquakes: $e');
      Get.snackbar('Error', 'Failed to load earthquakes: $e');
    } finally {
      isLoading(false);
    }
  }

  void fetchMoreEarthquakes() async {
    if (isLoadingMore.value) {
      print('Already loading more, skipping fetch');
      return; // Prevent multiple simultaneous requests
    }

    try {
      isLoadingMore(true);
      currentOffset.value += limit; // Increment offset for the next page (e.g., 1 -> 26 -> 51)
      print('Fetching more earthquakes with offset: ${currentOffset.value}');
      final data = await EarthquakeService().fetchEarthquakes(
        limit: limit,
        offset: currentOffset.value,
      );
      print('Fetched ${data.length} more earthquakes');
      if (data.isNotEmpty) {
        earthquakes.addAll(data); // Append new data to the existing list
      } else {
        print('No more earthquakes to load');
        Get.snackbar('Info', 'No more earthquakes to load');
        currentOffset.value -= limit; // Revert offset if no more data
      }
    } catch (e) {
      print('Error in fetchMoreEarthquakes: $e');
      Get.snackbar('Error', 'Failed to load more earthquakes: $e');
      currentOffset.value -= limit; // Revert offset on error
    } finally {
      isLoadingMore(false);
    }
  }

  void toggleExpanded() {
    isExpanded.toggle();
  }
}