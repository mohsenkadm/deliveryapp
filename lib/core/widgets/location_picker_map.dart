import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';

/// خريطة تفاعلية لتحديد موقع المتجر — flutter_map + OpenStreetMap (مجاني).
class LocationPickerMap extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<LatLng> onLocationChanged;
  final double height;

  const LocationPickerMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
    this.height = 220,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  static const _defaultCenter = LatLng(33.3152, 44.3661); // بغداد

  final _mapController = MapController();
  late LatLng _position;

  @override
  void initState() {
    super.initState();
    _position = LatLng(
      widget.initialLatitude ?? _defaultCenter.latitude,
      widget.initialLongitude ?? _defaultCenter.longitude,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLocationChanged(_position);
    });
  }

  void _updatePosition(LatLng point) {
    setState(() => _position = point);
    widget.onLocationChanged(point);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'حدّد موقع المتجر على الخريطة (انقر لوضع الدبوس)',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: widget.height,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _position,
                initialZoom: 15,
                onTap: (_, point) => _updatePosition(point),
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
                  userAgentPackageName: 'com.alaman.deliveryapp',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _position,
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}',
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
