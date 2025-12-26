import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/providers/sector_provider.dart';
import 'package:arumbu/ui/sector_based_plants_page.dart';
import 'package:arumbu/utility/scroll_notification_listener.dart';
import 'package:arumbu/widgets/data_not_available.dart';
import 'package:arumbu/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:arumbu/constants/urls.dart';

class SectorPage extends StatefulWidget {
  const SectorPage({super.key});

  @override
  State<SectorPage> createState() => _SectorPageState();
}

class _SectorPageState extends State<SectorPage> {
  bool isLoading = false;
  var params = {};
  @override
  void initState() {
    _getSector();
    super.initState();
  }

  _getSector() {
    Provider.of<SectorProvider>(context, listen: false).resetProvider();
    setState(() {
      isLoading = true;
    });

    Provider.of<SectorProvider>(context, listen: false)
        .getSectorList(context, body: params)
        .then(
          (value) => {
            setState(() {
              isLoading = false;
            }),
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);
    final bannerHeight = MediaQuery.of(context).size.height * 0.22;
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Stack(
                children: [
                  Container(
                    height: bannerHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(ImageConstants.banner),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                localization.translate('sector'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                localization.translate(
                                  'select a sector to explore its features.',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 16,
                    child: ExpandingSearchBar(
                      hintText: Provider.of<LanguageProvider>(
                        context,
                        listen: false,
                      ).translate('Search sector...'),
                      debounce: const Duration(seconds: 2),
                      onSubmitted: (query) {
                        final q = query.trim();
                        setState(() {
                          params = q.isEmpty ? {} : {"searchString": q};
                        });
                        _getSector();
                      },
                      onCancel: () {
                        if (params.isNotEmpty) {
                          setState(() {
                            params = {};
                          });
                          _getSector();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : listSectors(),
            ),
          ],
        ),
      ),
    );
  }

  Widget listSectors() {
    final localization = Provider.of<LanguageProvider>(context);
    return Consumer<SectorProvider>(
      builder: (ctx, data, child) {
        return data.listofitems.isEmpty
            ? const DataNotAvailable()
            : ScrollNotificationListener(
                future: Provider.of<SectorProvider>(
                  context,
                  listen: false,
                ).getSectorList,
                params: params,
                child: ListView.separated(
                  itemBuilder: (context, position) {
                    if (position >= data.listofitems.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = data.listofitems[position];
                    final name =
                        item?.name[localization.currentLang]
                                ?.trim()
                                .isNotEmpty ==
                            true
                        ? item?.name[localization.currentLang]!.trim()
                        : '—';
                    final desc =
                        item?.shortDescription[localization.currentLang]
                                ?.trim()
                                .isNotEmpty ==
                            true
                        ? item!.shortDescription[localization.currentLang]!
                              .trim()
                        : '';
                    final imagePath = item?.image ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SectorBasedPlantsPage(
                                fkSectorId: item?.slug ?? "",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _SectorAvatar(imagePath: imagePath),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF14331F),
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (desc.isNotEmpty)
                                      Text(
                                        desc,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF374151),
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          height: 1.3,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, position) {
                    return const SizedBox(height: 10);
                  },
                  itemCount: data.isLoadingMore
                      ? data.listofitems.length + 1
                      : data.listofitems.length,
                ),
              );
      },
    );
  }
}

class _SectorAvatar extends StatelessWidget {
  const _SectorAvatar({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final resolved = imagePath.startsWith('http')
        ? imagePath
        : (imagePath.isNotEmpty ? '${URLs.imageUrl}$imagePath' : '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 72,
        height: 72,
        color: const Color(0xFFD1FFE3),
        child: resolved.isEmpty
            ? Image.asset(ImageConstants.garden, fit: BoxFit.cover)
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset(ImageConstants.garden, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
