import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';

class StoreMapScreen extends ConsumerStatefulWidget {
  const StoreMapScreen({super.key});

  @override
  ConsumerState<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends ConsumerState<StoreMapScreen> {
  late final MapController _mapController;
  StoreEntity? _focused; // pin tapped by user
  bool _locating = false;
  LatLng? _userLocation;

  static const LatLng _defaultCenter = LatLng(27.7172, 85.3240);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _findNearest() async {
    setState(() => _locating = true);
    try {
      bool svc = await Geolocator.isLocationServiceEnabled();
      if (!svc) {
        SnackbarUtils.showWarning(context, 'Location services are disabled');
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        SnackbarUtils.showWarning(context, 'Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final here = LatLng(pos.latitude, pos.longitude);
      _userLocation = here;

      await ref
          .read(storeViewModelProvider.notifier)
          .fetchNearestStores(latitude: pos.latitude, longitude: pos.longitude);

      // Focus the closest store if results arrived
      final nearest = ref.read(storeViewModelProvider).nearestStores;
      if (nearest.isNotEmpty && nearest.first.coordinates != null) {
        final c = nearest.first.coordinates!;
        final nearLatLng = LatLng(c.latitude, c.longitude);
        _mapController.move(nearLatLng, 14);
        setState(() => _focused = nearest.first);
      } else {
        _mapController.move(here, 13);
        SnackbarUtils.showInfo(context, 'No stores found nearby');
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Could not get location');
    } finally {
      setState(() => _locating = false);
    }
  }

  void _onPinTap(StoreEntity store) {
    setState(() => _focused = store);
    if (store.coordinates != null) {
      _mapController.move(
        LatLng(store.coordinates!.latitude, store.coordinates!.longitude),
        15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final storeState = ref.watch(storeViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    // Combine all stores
    final nearest = storeState.nearestStores;
    final nearestIds = nearest.map((s) => s.storeId).toSet();
    final allStores = [
      ...nearest,
      ...storeState.stores.where((s) => !nearestIds.contains(s.storeId)),
    ].where((s) => s.coordinates != null).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 12,
              onTap: (_, __) => setState(() => _focused = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.project.ease',
              ),
              // User location dot
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              // Store pins
              MarkerLayer(
                markers: allStores.map((store) {
                  final isFocused = _focused?.storeId == store.storeId;
                  final isNearest =
                      nearest.isNotEmpty &&
                      nearest.first.storeId == store.storeId;
                  return Marker(
                    point: LatLng(
                      store.coordinates!.latitude,
                      store.coordinates!.longitude,
                    ),
                    width: isFocused ? 56 : 44,
                    height: isFocused ? 56 : 44,
                    child: GestureDetector(
                      onTap: () => _onPinTap(store),
                      child: _StoreMarker(
                        isFocused: isFocused,
                        isNearest: isNearest,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _MapButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        '${allStores.length} store${allStores.length == 1 ? '' : 's'} on map',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Find nearest button
          Positioned(
            right: 12,
            bottom: _focused != null ? 220 : 100,
            child: _MapButton(
              icon: _locating
                  ? Icons.hourglass_top_rounded
                  : Icons.near_me_rounded,
              color: AppColors.primary,
              onTap: _locating ? null : _findNearest,
            ),
          ),

          // ── Store detail card (when a pin is focused) ─────────────────────
          if (_focused != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: _StoreCard(
                store: _focused!,
                isNearest:
                    nearest.isNotEmpty &&
                    nearest.first.storeId == _focused!.storeId,
                isTablet: isTablet,
                onSelect: () => Navigator.pop(context, _focused),
                onDismiss: () => setState(() => _focused = null),
              ),
            ),
        ],
      ),
    );
  }
}

// Store detail card
class _StoreCard extends StatelessWidget {
  final StoreEntity store;
  final bool isNearest;
  final bool isTablet;
  final VoidCallback onSelect;
  final VoidCallback onDismiss;

  const _StoreCard({
    required this.store,
    required this.isNearest,
    required this.isTablet,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isNearest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Nearest',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (store.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        store.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),

          // Distance chip
          if (store.distance != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.directions_walk_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${store.distance!.toStringAsFixed(1)} km away',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],

          // Pickup instructions
          if (store.pickupInstructions != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    store.pickupInstructions!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Select this store',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Store pin marker
class _StoreMarker extends StatelessWidget {
  final bool isFocused;
  final bool isNearest;

  const _StoreMarker({required this.isFocused, required this.isNearest});

  @override
  Widget build(BuildContext context) {
    final color = isNearest
        ? AppColors.primary
        : isFocused
        ? Colors.deepOrange
        : Colors.black87;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isFocused ? 40 : 32,
          height: isFocused ? 40 : 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: isFocused ? 12 : 6,
              ),
            ],
          ),
          child: Icon(
            Icons.store_rounded,
            size: isFocused ? 22 : 16,
            color: isNearest ? Colors.black : Colors.white,
          ),
        ),
        CustomPaint(
          size: Size(isFocused ? 12 : 8, isFocused ? 8 : 5),
          painter: _PinTailPainter(color: color),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, ui.Paint()..color = color);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Reusable map icon button
class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _MapButton({required this.icon, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: color != null ? Colors.black : Colors.black87,
        ),
      ),
    );
  }
}
