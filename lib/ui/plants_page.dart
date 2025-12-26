import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/model/plants_list_response.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/services/plants_hive_service.dart';
import 'package:arumbu/widgets/image_carousel_card.dart';
import 'package:provider/provider.dart';

class PlantsPage extends StatefulWidget {
  final String? id;
  const PlantsPage({super.key, required this.id});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  bool isLoading = false;
  String? description;
  List<DetailRow> details = [];
  String? _activeLanguageCode;

  Plant? plantData;
  @override
  void initState() {
    super.initState();
    getPlantData();
  }

  Future<void> getPlantData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final plant = await PlantsListResponse.getplantsData(
        context,
        body: widget.id,
      );
      if (!mounted) return;

      final localization = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );

      setState(() {
        plantData = plant;
      });
      _applyLanguage(localization);
    } catch (e, s) {
      log("error : $e $s");
      await _loadCachedPlant();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCachedPlant() async {
    final id = widget.id;
    if (id == null) return;
    final cached = PlantsHiveService.getPlantById(id);
    if (cached == null) return;
    if (!mounted) return;
    final localization = Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      plantData = Plant.fromSyncChange(cached);
    });
    _applyLanguage(localization);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localization = Provider.of<LanguageProvider>(context);
    _applyLanguage(localization);
  }

  void _applyLanguage(LanguageProvider localization) {
    if (!mounted) {
      return;
    }

    final langCode = localization.currentLang;
    final languages = plantData?.languages ?? [];
    Languages? selectedLanguage;

    if (languages.isNotEmpty) {
      selectedLanguage = languages.firstWhere(
        (lang) => lang.langCode == langCode,
        orElse: () => languages.first,
      );
    }

    final selectedDescription = _clean(selectedLanguage?.description);
    final fallbackDescription = _clean(
      languages.isNotEmpty ? languages.first.description : null,
    );
    final effectiveDescription = selectedDescription.isNotEmpty
        ? selectedDescription
        : fallbackDescription;
    final detailRows = _buildDetailRows(localization, selectedLanguage);
    final resolvedLangCode = selectedLanguage?.langCode ?? langCode;

    setState(() {
      _activeLanguageCode = resolvedLangCode;
      description = effectiveDescription.isNotEmpty
          ? effectiveDescription
          : null;
      details = detailRows;
    });
  }

  List<DetailRow> _buildDetailRows(
    LanguageProvider localization,
    Languages? language,
  ) {
    return [
      DetailRow(
        label: localization.translate('Habit'),
        value: _clean(plantData?.habitName[localization.currentLang]),
        icon: Icons.eco_rounded,
      ),
      DetailRow(
        label: localization.translate('Family'),
        value: _clean(plantData?.familyName),
        icon: Icons.family_restroom_rounded,
      ),
      DetailRow(
        label: localization.translate('Habitat'),
        value: _clean(language?.habitat),
        icon: Icons.terrain_rounded,
      ),
      DetailRow(
        label: localization.translate('Propagation'),
        value: _clean(language?.propagation),
        icon: Icons.agriculture_rounded,
      ),
      DetailRow(
        label: localization.translate('Distribution'),
        value: _clean(language?.distribution),
        icon: Icons.public_rounded,
      ),
      DetailRow(
        label: localization.translate('Medicinal Uses'),
        value: _clean(language?.medicinalUsed),
        icon: Icons.medical_services_rounded,
      ),
      DetailRow(
        label: localization.translate('Other Uses'),
        value: _clean(language?.otherUsed),
        icon: Icons.handyman_rounded,
      ),
      DetailRow(
        label: localization.translate('Religious Significance'),
        value: _clean(language?.religiousSignificance),
        icon: Icons.church_rounded,
      ),
    ];
  }

  String _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : '';
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final bannerHeight = screenHeight * 0.2;
    final topPadding = screenHeight * 0.1;
    final horizontalPadding = screenWidth * 0.05;
    // final titleFontSize = screenWidth * 0.08;
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF166534)))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(height: 300),
                          SizedBox(
                            height: bannerHeight,
                            width: double.infinity,
                            child: Image.asset(
                              ImageConstants.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: topPadding, // can be negative to “hang”
                            left: horizontalPadding,
                            right: horizontalPadding,
                            child: SizedBox(
                              height: 250,
                              child: ImageCarouselCard(
                                images: plantData?.images ?? [],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: IconButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              iconSize: 30,
                              tooltip: "Back",
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: bannerHeight * 0.2),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              plantData?.botanicalName ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Color(0xFF166534),
                                fontSize: 24, // a bit smaller helps
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                height: 1.1, // 0.61 was causing clipping
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 35,
                            height: 35,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFD1FFE3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(59),
                              ),
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Color(0xFF166534),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF86EFAC),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: const Color(0xFF86EFAC)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: (plantData?.languages ?? []).map<Widget>((
                            e,
                          ) {
                            final langCode =
                                _activeLanguageCode ?? localization.currentLang;
                            final isActive = e.langCode == langCode;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 76,
                                  minHeight: 25,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF166534)
                                      : const Color(0xFFE6F4EA),
                                  border: Border.all(
                                    color: const Color(0xFF166534),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Center(
                                  child: Text(
                                    e.name ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF166534),
                                      fontSize: 11,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        child: Text(
                          description ?? "No Description",
                          style: TextStyle(
                            color: const Color(0xFF166534),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.70,
                          ),
                        ),
                      ),
                    ),

                    DetailTiles(items: details),
                  ],
                ),
              ),
      ),
    );
  }
}

class DetailRow {
  final String label;
  final String value;
  final IconData? icon; // optional

  DetailRow({required this.label, required this.value, this.icon});
}

class DetailTiles extends StatelessWidget {
  const DetailTiles({
    super.key,
    required this.items,
    this.emptyValuePlaceholder = '—',
  });

  final List<DetailRow> items;
  final String emptyValuePlaceholder;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD1FFE3); // mint
    const fg = Color(0xFF166534); // deep green

    return Column(
      children: items.where((e) => (e.value).trim().isNotEmpty).map((e) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(59),
            ),
            child: Icon(
              (e.icon ?? Icons.info_outline_rounded),
              color: fg,
              size: 20,
            ),
          ),
          title: Text(
            e.label,
            style: const TextStyle(
              color: fg,
              fontSize: 10,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.30,
            ),
          ),
          subtitle: Text(
            e.value.isEmpty ? emptyValuePlaceholder : e.value,
            style: const TextStyle(
              color: fg,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              height: 1.42,
            ),
          ),
          horizontalTitleGap: 10,
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }
}
