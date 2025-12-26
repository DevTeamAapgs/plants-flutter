import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/providers/sector_based_plants_provider.dart';
import 'package:arumbu/ui/plants_page.dart';
import 'package:arumbu/utility/scroll_notification_listener.dart';
import 'package:arumbu/widgets/data_not_available.dart';
import 'package:arumbu/widgets/plant_list_card.dart';
import 'package:arumbu/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class SectorBasedPlantsPage extends StatefulWidget {
  final String fkSectorId;
  const SectorBasedPlantsPage({super.key, required this.fkSectorId});

  @override
  State<SectorBasedPlantsPage> createState() => _SectorBasedPlantsPageState();
}

class _SectorBasedPlantsPageState extends State<SectorBasedPlantsPage> {
  bool isLoading = false;
  var params = {};

  @override
  void initState() {
    // params = {"slug": widget.fkSectorId};
    params = {
      "filter": {"sector": widget.fkSectorId},
    };
    _getSectorBasedplants();
    super.initState();
  }

  _getSectorBasedplants() {
    Provider.of<SectorBasedPlantsProvider>(
      context,
      listen: false,
    ).resetProvider();
    setState(() {
      isLoading = true;
    });

    Provider.of<SectorBasedPlantsProvider>(context, listen: false)
        .getSectorBasedPlantList(context, body: params)
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(bannerHeight),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageConstants.banner),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      iconSize: 30,
                      tooltip: "Back",
                      icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ExpandingSearchBar(
                        hintText: Provider.of<LanguageProvider>(
                          context,
                          listen: false,
                        ).translate('Search plants...'),
                        debounce: const Duration(seconds: 2),
                        onSubmitted: (query) {
                          final q = query.trim();
                          setState(() {
                            if (q.isEmpty) {
                              // Only remove the searchString, keep existing filters
                              params.remove('searchString');
                            } else {
                              params['searchString'] = q;
                            }
                          });
                          _getSectorBasedplants();
                        },
                        onCancel: () {
                          setState(() {
                            // Only remove the searchString, keep existing filters
                            params.remove('searchString');
                          });
                          _getSectorBasedplants();
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 4,
                  ),
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
                          'select a sector based plant to explore its features',
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
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 5,
                      ),
                      child: listPlantsbasedSectors(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listPlantsbasedSectors() {
    return Consumer<SectorBasedPlantsProvider>(
      builder: (ctx, data, child) {
        return data.listofitems.isEmpty
            ? const DataNotAvailable()
            : ScrollNotificationListener(
                future: Provider.of<SectorBasedPlantsProvider>(
                  context,
                  listen: false,
                ).getSectorBasedPlantList,
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

                    return PlantListCard(
                      plant: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantsPage(id: item?.slug),
                          ),
                        );
                      },
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
