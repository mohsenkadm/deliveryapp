// عنصر خريطة بسيط لعرض موقع العميل — flutter_map + OpenStreetMap
//
// لا يحتاج مفتاح API (يستخدم OSM tiles المجانية).
// يفتح Google Maps عند النقر للحصول على الاتجاهات.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

class CustomerLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? title;
  final String? subtitle;
  final double height;

  const CustomerLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title,
    this.subtitle,
    this.height = 220,
  });

  Future<void> _openExternal() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.deliveryapp.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 44,
                      height: 44,
                      child: Icon(Icons.location_on,
                          color: AppColors.primary, size: 44),
                    ),
                  ],
                ),
              ],
            ),
            // overlay info card
            if (title != null || subtitle != null)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(title!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            if (subtitle != null)
                              Text(subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.directions, color: Colors.teal),
                        tooltip: 'الاتجاهات',
                        onPressed: _openExternal,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
