import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_colors.dart';

/// خريطة تفاعلية لتحديد موقع المتجر — google_maps_flutter.
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

  GoogleMapController? _mapController;
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
          'حدّد موقع المتجر على الخريطة',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: widget.height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _position,
                zoom: 15,
              ),
              onMapCreated: (c) => _mapController = c,
              onTap: _updatePosition,
              markers: {
                Marker(
                  markerId: const MarkerId('store'),
                  position: _position,
                  draggable: true,
                  onDragEnd: _updatePosition,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRose,
                  ),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
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
