import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/model/plants_list_response.dart';
import 'package:arumbu/model/dashboard_response.dart' show Habit;
import 'package:arumbu/providers/plants_provider.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/ui/plants_page.dart';
import 'package:arumbu/utility/scroll_notification_listener.dart';
import 'package:arumbu/widgets/data_not_available.dart';
import 'package:arumbu/widgets/plant_list_card.dart';
import 'package:arumbu/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class PlantsListPage extends StatefulWidget {
  final int index;
  final List<Habit> habits;
  final String? initialHabitId;
  const PlantsListPage({
    super.key,
    required this.index,
    required this.habits,
    this.initialHabitId,
  });

  @override
  State<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends State<PlantsListPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  var params = {};
  late final TabController _controller;
  late List<Habit> _habits;
  String? _activeHabitId;

  @override
  void initState() {
    super.initState();
    _habits = List<Habit>.from(widget.habits);
    final initialIndex = _initialIndexFromInput();
    _controller = TabController(
      length: _effectiveTabCount,
      vsync: this,
      initialIndex: initialIndex,
    );
    _activeHabitId = _habitIdAt(initialIndex);

    _controller.addListener(() {
      if (_controller.indexIsChanging) return;
      final newId = _habitIdAt(_controller.index);
      if (newId == _activeHabitId) return;
      setState(() {
        _activeHabitId = newId;
        // Keep any existing searchString, but update fk_habit_id
        params = {
          ...params,
          if (_activeHabitId != null) 'fk_habit_id': _activeHabitId,
        };
      });
      Provider.of<PlantsProvider>(context, listen: false).resetProvider();
      getPlants();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void didUpdateWidget(covariant PlantsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final nextIndex = _clampIndex(widget.index);
      if (nextIndex != _controller.index) {
        _controller.animateTo(nextIndex);
      }
    }
  }

  Future<void> _bootstrap() async {
    final provider = Provider.of<PlantsProvider>(context, listen: false);
    provider.resetProvider();
    await provider.loadFromCache();
    if (mounted && provider.listofitems.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await provider.performOfflineSync(context);
    // Seed params with active habit id if present
    setState(() {
      if (_activeHabitId != null) {
        params = {...params, 'fk_habit_id': _activeHabitId};
      }
    });
    await getPlants();
  }

  Future<void> getPlants() async {
    final provider = Provider.of<PlantsProvider>(context, listen: false);
    final shouldShowLoader = provider.listofitems.isEmpty;
    if (shouldShowLoader && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await provider.getPlantsList(context, body: params);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                                localization.translate('Plants'),
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
                                  'Explore and learn about our living collection',
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
                      ).translate('Search plants...'),
                      debounce: const Duration(seconds: 2),
                      onSubmitted: (query) {
                        final q = query.trim();
                        setState(() {
                          params = {
                            if (q.isNotEmpty) "searchString": q,
                            if (_activeHabitId != null)
                              'fk_habit_id': _activeHabitId,
                          };
                        });
                        Provider.of<PlantsProvider>(
                          context,
                          listen: false,
                        ).resetProvider();
                        getPlants();
                      },
                      onCancel: () {
                        if (params.isNotEmpty) {
                          setState(() {
                            params = {
                              if (_activeHabitId != null)
                                'fk_habit_id': _activeHabitId,
                            };
                          });
                          Provider.of<PlantsProvider>(
                            context,
                            listen: false,
                          ).resetProvider();
                          getPlants();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _listWidget(localization),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _effectiveTabCount =>
      _habits.isNotEmpty ? _habits.length : _fallbackCategories.length;
  static const List<String> _fallbackCategories = [
    'Trees',
    'Plants',
    'Climbers',
    'Shrubs',
  ];

  Widget _listWidget(LanguageProvider localization) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF166534)),
      );
    }
    return Consumer<PlantsProvider>(
      builder: (ctx, data, child) {
        if (data.listofitems.isEmpty) {
          return const DataNotAvailable();
        }

        final Map<String, List<Plant?>> groupedByHabit = {};
        final labels = <String, String>{}; // id -> label
        if (_habits.isNotEmpty) {
          for (final h in _habits) {
            final id = h.id ?? '';
            groupedByHabit[id] = <Plant?>[];
            labels[id] = _resolveHabitTitle(h, localization);
          }
        } else {
          // Fallback: group by legacy categories using speciesType mapping
          for (final key in _fallbackCategories) {
            groupedByHabit[key] = <Plant?>[];
            labels[key] = localization.translate(key);
          }
        }

        for (final plant in data.listofitems) {
          if (_habits.isNotEmpty) {
            final id = plant?.fkHabitId ?? '';
            groupedByHabit.putIfAbsent(id, () => <Plant?>[]);
            groupedByHabit[id]!.add(plant);
          } else {
            final key = _categoryKeyForSpecies(plant?.speciesType);
            groupedByHabit.putIfAbsent(key, () => <Plant?>[]);
            groupedByHabit[key]!.add(plant);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: _controller,
              isScrollable: true,
              labelColor: const Color(0xFF166534),
              unselectedLabelColor: const Color(0xFF4B5563),
              indicatorColor: const Color(0xFF166534),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs:
                  (_habits.isNotEmpty
                          ? _habits
                                .map((h) => labels[h.id ?? ''] ?? '')
                                .toList()
                          : _fallbackCategories
                                .map(localization.translate)
                                .toList())
                      .map((label) => Tab(text: label))
                      .toList(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children:
                    (_habits.isNotEmpty
                            ? _habits.map((h) => h.id ?? '').toList()
                            : _fallbackCategories)
                        .map(
                          (key) => _buildCategoryList(
                            context,
                            labels[key] ?? key,
                            groupedByHabit[key] ?? const <Plant?>[],
                            data,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  int _clampIndex(int index) {
    final max = _effectiveTabCount;
    if (max <= 0) return 0;
    if (index < 0) return 0;
    if (index >= max) return max - 1;
    return index;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCategoryList(
    BuildContext context,
    String category,
    List<Plant?> plants,
    PlantsProvider provider,
  ) {
    if (plants.isEmpty) {
      if (provider.isLoadingMore) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF166534)),
        );
      }
      return const DataNotAvailable();
    }

    final listView = ListView.separated(
      key: PageStorageKey<String>('plants_tab_$category'),
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: plants.length + (provider.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, position) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (index >= plants.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF166534)),
            ),
          );
        }
        final plant = plants[index];
        return PlantListCard(
          plant: plant,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlantsPage(id: plant?.slug),
              ),
            );
          },
        );
      },
    );

    return ScrollNotificationListener(
      params: params,
      future: Provider.of<PlantsProvider>(context, listen: false).getPlantsList,
      child: listView,
    );
  }

  String _categoryKeyForSpecies(String? speciesType) {
    final value = speciesType?.toLowerCase().trim() ?? '';
    if (value.contains('tree')) return 'Trees';
    if (value.contains('climb')) return 'Climbers';
    if (value.contains('shrub')) return 'Shrubs';
    if (value.contains('plant')) return 'Plants';
    return 'Plants';
  }

  String _resolveHabitTitle(Habit habit, LanguageProvider localization) {
    final name = habit.name;
    if (name is String) return name;
    if (name is Map) {
      final lang = localization.currentLang;
      final dynamic v =
          name[lang] ?? (name.values.isNotEmpty ? name.values.first : null);
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return localization.translate('Plants');
  }

  int _initialIndexFromInput() {
    if (_habits.isEmpty) return _clampIndex(widget.index);
    if (widget.initialHabitId != null) {
      final idx = _habits.indexWhere((h) => h.id == widget.initialHabitId);
      if (idx >= 0) return idx;
    }
    return _clampIndex(widget.index);
  }

  String? _habitIdAt(int index) {
    if (_habits.isEmpty) return null;
    if (index < 0 || index >= _habits.length) return null;
    return _habits[index].id;
  }
}
