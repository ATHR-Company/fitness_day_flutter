import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StaticMapPreview extends StatelessWidget {
  final LatLng coordinates;
  final double height;

  const StaticMapPreview({
    super.key,
    required this.coordinates,
    this.height = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: coordinates,
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fitness.fitness_day',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: coordinates,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
