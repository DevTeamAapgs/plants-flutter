import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/model/dashboard_response.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/providers/plants_provider.dart';
import 'package:arumbu/ui/about_us_page.dart';
import 'package:arumbu/ui/gallery_page.dart';
import 'package:arumbu/ui/plants_list_page.dart';
import 'package:arumbu/ui/plants_page.dart';
import 'package:arumbu/ui/sector_based_plants_page.dart';
import 'package:arumbu/ui/sector_page.dart';
import 'package:arumbu/utility/qr_scanner.dart';
import 'package:arumbu/utility/snackbar.dart';
import 'package:arumbu/widgets/language_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:arumbu/constants/image_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isSyncing = false;
  int _plantsTabIndex = 0;
  String? _selectedHabitId;
  bool _isLoading = true;
  DashboardResponsePage _dashboardResponse = DashboardResponsePage();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleCategoryTap(int tabIndex, [int pageIndex = 1, String? habitId]) {
    setState(() {
      _selectedIndex = pageIndex;
      _plantsTabIndex = tabIndex;
      _selectedHabitId = habitId;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return PlantsListPage(
          index: _plantsTabIndex,
          habits: _dashboardResponse.data?.habit ?? const <Habit>[],
          initialHabitId: _selectedHabitId,
        );
      case 2:
        return GalleryPage();
      case 3:
        return SectorPage();
      default:
        return HomepageContent(
          onCategoryTap: _handleCategoryTap,
          dashboardData: _dashboardResponse.data,
        );
    }
  }

  @override
  void initState() {
    getDashboardData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final basePage = _buildBody();
    // final body = (_selectedIndex == 0)
    //     ? Stack(
    //         children: [
    //           Positioned.fill(child: basePage),
    //           Positioned(
    //             right: 20,
    //             bottom: 120,
    //             child: _SyncFab(
    //               isSyncing: _isSyncing,
    //               onPressed: _handleSync,
    //             ),
    //           ),
    //         ],
    //       )
    //     : basePage;
    final body = basePage;
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator()) : body,
      floatingActionButton: FloatingActionButton(
        heroTag: 'qrScannerFab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScanner()),
          );
        },
        elevation: 1,
        backgroundColor: const Color(0xFFD1FFE3),
        shape: const CircleBorder(),
        child: Icon(
          Icons.qr_code_scanner,
          size: 28,
          color: const Color(0xFF166534),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), // left corner
          topRight: Radius.circular(20), // right corner
        ),
        child: BottomAppBar(
          elevation: 0,
          height: 60,
          shape: const CircularNotchedRectangle(),
          surfaceTintColor: Colors.transparent,
          notchMargin: 0,
          color: const Color(0xFF166534),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0, Color(0xFF166534)),
              _buildNavItem(Icons.energy_savings_leaf, 1, Color(0xFF166534)),
              const SizedBox(width: 30), // space for FAB
              _buildNavItem(Icons.photo_library, 2, Color(0xFF166534)),
              _buildNavItem(Icons.dashboard_outlined, 3, Color(0xFF166534)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
    });

    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final plantsProvider = Provider.of<PlantsProvider>(context, listen: false);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(),
    );

    bool success = false;
    try {
      success = await plantsProvider.performOfflineSync(context);
    } finally {
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        final text = success
            ? 'Plants sync completed'
            : 'Unable to sync plants right now';
        messenger.showSnackBar(
          SnackBar(
            content: Text(text),
            backgroundColor: success ? const Color(0xFF166534) : Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildNavItem(IconData icon, int index, Color bgColor) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1FFE3) : Colors.transparent,
          // backgroundColor: isSelected ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? bgColor : Colors.white, size: 24),
            // Text(
            //   label,
            //   style: TextStyle(
            //     fontSize: 11,
            //     color: isSelected ? bgColor : Colors.white,
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  getDashboardData() async {
    try {
      var dashboardCount = await DashboardResponsePage.getDashboardData(
        context,
      );
      if (dashboardCount.success == true) {
        setState(() {
          _dashboardResponse.data = dashboardCount.data;
        });
      } else {
        showToastMessage("Error Loading Dashboard Data. Please Try Again");
      }
    } on Exception catch (e, s) {
      // TODO
      print("Error in Dashboard Count $e - $s");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Widget _lottieCard(
  BuildContext context,
  String lottiePath,
  String title,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.20,
          height: MediaQuery.of(context).size.height * 0.15,
          // padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 80,
                child: Lottie.asset(lottiePath, repeat: true, animate: true),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF14331F),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomepageContent extends StatelessWidget {
  const HomepageContent({
    super.key,
    required this.onCategoryTap,
    required this.dashboardData,
  });
  final Data? dashboardData;
  final void Function(int, [int, String?]) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final bannerHeight = screenHeight * 0.4;
    final topPadding = screenHeight * 0.10;
    final horizontalPadding = screenWidth * 0.05;
    // final titleFontSize = screenWidth * 0.08;
    // final iconSize = screenWidth * 0.1;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  ImageConstants.banner,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: bannerHeight,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: screenHeight * 0.065,
                    // height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(ImageConstants.governmentLogo),
                        Image.asset(ImageConstants.sipcotLogo),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: topPadding,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        // Responsive font sizes with sensible min/max
                        double titleSize = (w * 0.085).clamp(22.0, 40.0);
                        double subtitleSize = (w * 0.05).clamp(14.0, 24.0);

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title + subtitle
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.translate('SIPCOT HerbGarden'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleSize,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localization.translate('subtitle'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: subtitleSize,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Language switcher
                            LanguageButton(
                              current: localization.currentLang,
                              onChanged: (code) {
                                if (code != localization.currentLang) {
                                  localization.loadLanguage(code);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                Positioned(
                  top: bannerHeight - 150,
                  left: horizontalPadding,
                  right: horizontalPadding,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsPage()),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 125,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD0FFE2),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFF86EFAC)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: localization.translate(
                                        'Description',
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 1.70,
                                      ),
                                    ),
                                    TextSpan(
                                      text: localization.translate(
                                        'Read more...',
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.70,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                ImageConstants.banner,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildHabitCards(
                    context,
                    localization,
                    dashboardData?.habit,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: InkWell(
                onTap: () => onCategoryTap(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        localization.translate('Extinction Species'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF166534),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      localization.translate('See more...'),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dashboardData?.extinctSpecies?.length,
                  itemBuilder: (context, index) {
                    var item = dashboardData?.extinctSpecies?[index];
                    final langCode = localization.currentLang;
                    final languages = item?.languages ?? [];
                    Languages? selectedLanguage;

                    if (languages.isNotEmpty) {
                      selectedLanguage = languages.firstWhere(
                        (lang) => lang.langCode == langCode,
                        orElse: () => languages.first,
                      );
                    }
                    final name = selectedLanguage?.name;
                    final description = selectedLanguage?.text;
                    final imagePath = item?.images?.first ?? "";

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 1,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantsPage(id: item?.slug),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Background Image
                              RoundedImage(imagePath: imagePath),
                              // Image.asset(
                              //   ImageConstants.neemTree,
                              //   width: MediaQuery.of(context).size.width * 0.44,
                              //   height: MediaQuery.of(context).size.width * 0.3,
                              //   fit: BoxFit.cover,
                              // ),

                              // Gradient overlay at bottom
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(
                                          alpha: 0.6,
                                        ), // darkens bottom only
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Text content
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: description ?? "",
                                            style: TextStyle(
                                              letterSpacing: 0.5,
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              height: 1.20,
                                            ),
                                          ),
                                          TextSpan(
                                            text: localization.translate(
                                              'Read more...',
                                            ),
                                            style: const TextStyle(
                                              color: Colors.lightGreenAccent,
                                              fontSize: 10,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                              height: 1.20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: InkWell(
                onTap: () => onCategoryTap(0, 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        localization.translate('sector'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF166534),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      localization.translate('See more...'),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dashboardData?.sector?.length,
                  itemBuilder: (context, index) {
                    var item = dashboardData?.sector?[index];
                    final langCode = localization.currentLang;
                    final name = item?.name[langCode];
                    final description = item?.shortDescription[langCode];
                    final imagePath = item?.image ?? "";

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 1,
                      ),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Background Image
                              RoundedImage(imagePath: imagePath),
                              // Image.asset(
                              //   ImageConstants.neemTree,
                              //   width: MediaQuery.of(context).size.width * 0.44,
                              //   height: MediaQuery.of(context).size.width * 0.3,
                              //   fit: BoxFit.cover,
                              // ),

                              // Gradient overlay at bottom
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(
                                          alpha: 0.6,
                                        ), // darkens bottom only
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Text content
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: description ?? "",
                                            style: TextStyle(
                                              letterSpacing: 0.5,
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              height: 1.20,
                                            ),
                                          ),
                                          TextSpan(
                                            text: localization.translate(
                                              'Read more...',
                                            ),
                                            style: const TextStyle(
                                              color: Colors.lightGreenAccent,
                                              fontSize: 10,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                              height: 1.20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: 10.0,
              ),
              child: InkWell(
                onTap: () => onCategoryTap(0, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.translate('Gallery'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        height: 0.85,
                      ),
                    ),
                    Text(
                      localization.translate('See more...'),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: GridView.builder(
                // If this sits inside another scrollable (e.g., ListView), keep these:
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemCount: dashboardData?.gallery?.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 per row
                  crossAxisSpacing: 8, // same as your Row spacing
                  mainAxisSpacing: 10, // matches your vertical padding gap
                  // Your old tiles were ~0.44w x 0.25w → aspect ≈ 1.76 (w/h)
                  childAspectRatio: 1.75,
                ),
                itemBuilder: (context, index) {
                  final obj = dashboardData?.gallery?[index];
                  final imagePath = obj?.image ?? "";
                  return RoundedImage(imagePath: imagePath);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHabitCards(
    BuildContext context,
    LanguageProvider localization,
    List<Habit>? habits,
  ) {
    final list = <Widget>[];
    final items = (habits ?? const <Habit>[]);

    if (items.isEmpty) {
      // Fallback to static four if no data
      return [
        _lottieCard(
          context,
          LottieCostants.trees,
          localization.translate('Trees'),
          () => onCategoryTap(0),
        ),
        _lottieCard(
          context,
          LottieCostants.plants,
          localization.translate('Plants'),
          () => onCategoryTap(1),
        ),
        _lottieCard(
          context,
          LottieCostants.climbers,
          localization.translate('Climbers'),
          () => onCategoryTap(2),
        ),
        _lottieCard(
          context,
          LottieCostants.shrubs,
          localization.translate('Shrubs'),
          () => onCategoryTap(3),
        ),
      ];
    }

    for (final h in items) {
      final title = _resolveHabitTitle(h, localization);
      final asset = _assetForHabitName(h.name['en']);
      final tabIndex = _indexForHabitName(title);
      list.add(
        _lottieCard(
          context,
          asset,
          title,
          () => onCategoryTap(tabIndex, 1, h.id),
        ),
      );
    }
    return list;
  }

  String _resolveHabitTitle(Habit habit, LanguageProvider localization) {
    final name = habit.name;
    if (name is String) {
      return name;
    }
    if (name is Map) {
      final lang = localization.currentLang;
      final dynamic v =
          name[lang] ?? (name.values.isNotEmpty ? name.values.first : null);
      if (v is String && v.trim().isNotEmpty) return v;
    }
    // Fallbacks
    return localization.translate('Plants');
  }

  String _assetForHabitName(String name) {
    final v = name.toLowerCase().trim();
    if (v.contains('tree')) return LottieCostants.trees;
    if (v.contains('climb')) return LottieCostants.climbers;
    if (v.contains('shrub')) return LottieCostants.shrubs;
    return LottieCostants.plants;
  }

  int _indexForHabitName(String name) {
    final v = name.toLowerCase().trim();
    if (v.contains('tree')) return 0;
    if (v.contains('plant')) return 1;
    if (v.contains('climb')) return 2;
    if (v.contains('shrub')) return 3;
    return 1; // default to Plants tab
  }
}

class RoundedImage extends StatelessWidget {
  final String imagePath;
  const RoundedImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final resolved = imagePath.startsWith('http')
        ? imagePath
        : (imagePath.isNotEmpty ? '${URLs.imageUrl}$imagePath' : '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: resolved.isEmpty
          ? Image.asset(
              ImageConstants.garden,
              width: MediaQuery.of(context).size.width * 0.44,
              height: MediaQuery.of(context).size.width * 0.3,
              fit: BoxFit.cover,
            )
          : Image.network(
              resolved,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.44,
              height: MediaQuery.of(context).size.width * 0.3,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(ImageConstants.garden, fit: BoxFit.cover),
            ),
    );
  }
}

class _SyncFab extends StatelessWidget {
  const _SyncFab({required this.isSyncing, required this.onPressed});

  final bool isSyncing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'syncFab',
      onPressed: () {
        if (!isSyncing) {
          onPressed();
        }
      },
      backgroundColor: const Color(0xFF166534),
      icon: isSyncing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.sync_rounded, color: Colors.white),
      label: Text(
        isSyncing ? 'Syncing...' : 'Sync Offline',
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Color(0xFF166534)),
            SizedBox(height: 16),
            Text(
              'Syncing plants...',
              style: TextStyle(
                color: Color(0xFF166534),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
