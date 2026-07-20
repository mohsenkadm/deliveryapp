import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_colors.dart';
import '../utils/snackbar_helper.dart';

/// خريطة تفاعلية لتحديد موقع المتجر — flutter_map + OpenStreetMap.
/// يدعم زر «تحديد موقعي الآن» عبر GPS الجهاز.
class LocationPickerMap extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<LatLng> onLocationChanged;
  final double height;

  /// إن true يُعتبر الموضع الحالي مُلتقَطاً من GPS/المستخدم وليس الافتراضي فقط.
  final ValueChanged<bool>? onGpsCapturedChanged;

  const LocationPickerMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
    this.height = 220,
    this.onGpsCapturedChanged,
  });

  @override
  State<LocationPickerMap> createState() => LocationPickerMapState();
}

class LocationPickerMapState extends State<LocationPickerMap> {
  static const _defaultCenter = LatLng(33.3152, 44.3661); // بغداد — عرض فقط

  final _mapController = MapController();
  late LatLng _position;
  bool _userSetLocation = false;
  bool _locating = false;

  /// هل حدّد المستخدم/GPS موضعاً فعلياً (وليس الافتراضي وحده).
  bool get hasUserLocation => _userSetLocation;

  LatLng get currentPosition => _position;

  @override
  void initState() {
    super.initState();
    final hasInitial =
        widget.initialLatitude != null && widget.initialLongitude != null;
    _position = LatLng(
      widget.initialLatitude ?? _defaultCenter.latitude,
      widget.initialLongitude ?? _defaultCenter.longitude,
    );
    _userSetLocation = hasInitial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasInitial) {
        widget.onLocationChanged(_position);
        widget.onGpsCapturedChanged?.call(true);
      }
    });
  }

  void _updatePosition(LatLng point, {required bool fromUser}) {
    setState(() {
      _position = point;
      if (fromUser) _userSetLocation = true;
    });
    widget.onLocationChanged(point);
    if (fromUser) widget.onGpsCapturedChanged?.call(true);
  }

  /// يطلب الصلاحية ويلتقط الموقع الحالي للجهاز.
  Future<LatLng?> locateMe({bool showErrors = true}) async {
    setState(() => _locating = true);
    try {
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        if (showErrors) {
          SnackbarHelper.showError(
            status.isPermanentlyDenied
                ? 'تم رفض صلاحية الموقع نهائياً. فعّلها من إعدادات الجهاز ثم أعد المحاولة.'
                : 'يلزم السماح بصلاحية الموقع لتحديد موقع المتجر. اضغط «تحديد موقعي الآن» للمحاولة مجدداً.',
          );
        }
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showErrors) {
          SnackbarHelper.showError(
            'خدمة الموقع معطّلة على الجهاز. فعّل GPS ثم أعد المحاولة.',
          );
        }
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final point = LatLng(pos.latitude, pos.longitude);
      _updatePosition(point, fromUser: true);
      try {
        _mapController.move(point, 16);
      } catch (_) {}
      return point;
    } catch (_) {
      if (showErrors) {
        SnackbarHelper.showError(
          'تعذّر الحصول على الموقع الحالي. تأكد من تفعيل GPS وأعد المحاولة.',
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'حدّد موقع المتجر (الموقع الحالي للجهاز)',
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
                onTap: (_, point) => _updatePosition(point, fromUser: true),
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
                if (_userSetLocation)
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
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _locating ? null : () => locateMe(),
          icon: _locating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            _locating ? 'جاري تحديد الموقع...' : 'تحديد موقعي الآن',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _userSetLocation
              ? '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}'
              : 'لم يُحدَّد موقع بعد — اضغط «تحديد موقعي الآن»',
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
