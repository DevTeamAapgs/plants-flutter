import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/model/plants_list_response.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:provider/provider.dart';

class PlantListCard extends StatelessWidget {
  const PlantListCard({super.key, required this.plant, this.onTap});

  final Plant? plant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final botanicalName = _clean(plant?.botanicalName);
    final family = _clean(plant?.familyName);
    // final localName = _clean(
    //   (plant?.languages?.isNotEmpty ?? false)
    //       ? plant!.languages!.first.name
    //       : null,
    // );

    final localization = Provider.of<LanguageProvider>(context);
    final habit = _clean(plant?.habitName[localization.currentLang]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlantThumbnail(
                imageUrl: (plant?.images?.isNotEmpty ?? false)
                    ? plant!.images!.first
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      botanicalName.isNotEmpty ? botanicalName : '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF14532D),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _FactRow(
                      label: localization.translate('Family'),
                      value: family,
                    ),
                    _FactRow(
                      label: localization.translate('Habit'),
                      value: habit,
                    ),
                    // if (localName.isNotEmpty)
                    //   _FactRow(
                    //     label: localization.translate('Local Name'),
                    //     value: localName,
                    //   ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : '';
  }
}

class _PlantThumbnail extends StatelessWidget {
  const _PlantThumbnail({super.key, this.imageUrl, this.size = 86});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final placeholder = Image.asset(
      ImageConstants.garden,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );

    Widget image;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = _buildImage(imageUrl!, size, placeholder);
    } else {
      image = placeholder;
    }

    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  Widget _buildImage(String path, double size, Widget placeholder) {
    if (path.startsWith('file://')) {
      final filePath = path.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(file, width: size, height: size, fit: BoxFit.cover);
      }
    }

    final resolved = path.startsWith('http') ? path : "${URLs.imageUrl}$path";
    return Image.network(
      resolved,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF166534),
            ),
          ),
        );
      },
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isNotEmpty ? value : '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4C594A),
          ),
          children: [
            TextSpan(
              text: displayValue,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
