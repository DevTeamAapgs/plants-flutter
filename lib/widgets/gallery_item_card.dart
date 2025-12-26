import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/model/gallery_response.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/ui/image_viewer_page.dart';
import 'package:provider/provider.dart';

class GalleryItemCard extends StatelessWidget {
  const GalleryItemCard({super.key, required this.item, this.onTap});

  final Items? item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);
    final images = (item?.images ?? <String>[])
        .where((e) => e.isNotEmpty)
        .toList();
    final title =
        item?.title[localization.currentLang]?.trim().isNotEmpty == true
        ? item!.title[localization.currentLang]!.trim()
        : 'Untitled';
    final preview = images.take(6).toList();
    final overflow = images.length - preview.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              onTap ??
              () {
                final images = (item?.images ?? <String>[])
                    .where((e) => e.isNotEmpty)
                    .toList();
                if (images.isEmpty) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageViewerPage(
                      images: images,
                      initialIndex: 0,
                      title:
                          item?.title[localization.currentLang]
                                  ?.trim()
                                  .isNotEmpty ==
                              true
                          ? item!.title[localization.currentLang]!.trim()
                          : 'Untitled',
                    ),
                  ),
                );
              },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row at top like system gallery
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CountPill(count: images.length),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Thumbnails grid below title (3 columns, up to 6 items)
                  if (preview.isEmpty)
                    Container(
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.photo,
                        color: Color(0xFF9CA3AF),
                        size: 36,
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1,
                          ),
                      itemCount: preview.length,
                      itemBuilder: (context, index) {
                        final path = preview[index];
                        final isLast =
                            index == preview.length - 1 && overflow > 0;
                        return GestureDetector(
                          onTap: () {
                            final images = (item?.images ?? <String>[])
                                .where((e) => e.isNotEmpty)
                                .toList();
                            if (images.isEmpty) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ImageViewerPage(
                                  images: images,
                                  initialIndex: index,
                                  title:
                                      item?.title[localization.currentLang]
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                      ? item!.title[localization.currentLang]!
                                            .trim()
                                      : 'Untitled',
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _image(path, fit: BoxFit.cover),
                                if (isLast)
                                  Container(
                                    color: Colors.black.withOpacity(0.45),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+$overflow',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _image(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('file://')) {
      final cleaned = path.replaceFirst('file://', '');
      final file = File(cleaned);
      if (file.existsSync()) {
        return Image.file(file, fit: fit);
      }
    }
    final resolved = path.startsWith('http') ? path : '${URLs.imageUrl}$path';
    return Image.network(resolved, fit: fit);
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
