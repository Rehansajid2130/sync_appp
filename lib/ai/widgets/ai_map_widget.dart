import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/chat_models.dart';

/// Simple map widget that shows provider pins.
/// Only visible when providers have been found.
class AiMapWidget extends StatelessWidget {
  final List<ProviderResult> providers;
  final ProviderResult? selectedProvider;
  final ValueChanged<ProviderResult>? onProviderTapped;

  const AiMapWidget({
    super.key,
    required this.providers,
    this.selectedProvider,
    this.onProviderTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();

    // Calculate center point from providers
    final avgLat =
        providers.map((p) => p.latitude).reduce((a, b) => a + b) /
            providers.length;
    final avgLng =
        providers.map((p) => p.longitude).reduce((a, b) => a + b) /
            providers.length;

    return Container(
      height: 200,
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(avgLat, avgLng),
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.helperhive.app',
          ),
          MarkerLayer(
            markers: providers.map((provider) {
              final isSelected = selectedProvider?.id == provider.id;
              return Marker(
                point: LatLng(provider.latitude, provider.longitude),
                width: isSelected ? 50 : 40,
                height: isSelected ? 50 : 40,
                child: GestureDetector(
                  onTap: () => onProviderTapped?.call(provider),
                  child: Icon(
                    Icons.location_pin,
                    color: isSelected ? Colors.green : Colors.red,
                    size: isSelected ? 50 : 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
