import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openMapOptions({
  required BuildContext context,
  required double latitude,
  required double longitude,
  required String name,
  required String address,
  required String city,
}) async {
  final query = Uri.encodeComponent('$name, $address, $city');
  final googleMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=$query';
  final appleMapsUrl = 'http://maps.apple.com/?q=$query';
  if (kIsWeb) {
    final url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
    return;
  }

  final List<_MapOption> options = [
    _MapOption(
      name: 'Google Maps',
      url: Platform.isIOS
          ? 'comgooglemaps://?q=$latitude,$longitude'
          : 'geo:$latitude,$longitude?q=$latitude,$longitude',
      fallback: googleMapsUrl,
    ),
    if (Platform.isIOS)
      _MapOption(
        name: 'Apple Maps',
        url: appleMapsUrl,
      ),
    _MapOption(
      name: 'Waze',
      url: 'waze://?ll=$latitude,$longitude&navigate=yes',
      fallback: 'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes',
    ),
  ];

  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        return ListTile(
          title: Text(option.name),
          onTap: () async {
            Navigator.pop(context);
            try {
              final uri = Uri.parse(option.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else if (option.fallback != null) {
                await launchUrl(Uri.parse(option.fallback!));
              } else {
                await launchUrl(Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'));
              }
            } catch (_) {
              await launchUrl(Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'));
            }
          },
        );
      }).toList(),
    ),
  );
}

class _MapOption {
  final String name;
  final String url;
  final String? fallback;
  _MapOption({required this.name, required this.url, this.fallback});
}
