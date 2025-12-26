import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/ui/home_page.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.animationAsset});

  /// Provide a custom Lottie animation json under assets/lottie/ if desired.
  final String? animationAsset;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // Fallback only if animation doesn't load within 5s
    Future.delayed(const Duration(seconds: 3), () {
      if (!_loaded) _goNext();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animationPath =
        widget.animationAsset ?? LottieCostants.splashAnimation;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final localization = Provider.of<LanguageProvider>(context);

    double titleFontSize = width * 0.2; // ~10% of width
    double subtitleFontSize = width * 0.020; // ~5% of width

    // Clamp values for extreme screen sizes
    titleFontSize = titleFontSize.clamp(28.0, 48.0);
    subtitleFontSize = subtitleFontSize.clamp(16.0, 26.0);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FBF8),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: height * 0.05,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFFDF5), Color(0xFFDFFBEA)],
              ),
            ),
            child: Text(
              localization.translate('Developed by AAPGS'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFFDF5), Color(0xFFDFFBEA)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.05,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageConstants.governmentStatement),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    ImageConstants.sipcotLogo,
                    height: height * 0.15,
                  ),
                ),
                const SizedBox(height: 35),
                Text(
                  localization.translate('SIPCOT HerbGarden'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF166534),
                    fontSize: titleFontSize,
                    fontFamily: 'Noto Serif Tamil',
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localization.translate('subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF166534),
                    fontSize: subtitleFontSize,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 4.0,
                    ),
                    child: Lottie.asset(
                      animationPath,
                      controller: _controller,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        _loaded = true;
                        _controller
                          ..duration = composition.duration
                          ..forward();
                        _controller.addStatusListener((status) {
                          if (status == AnimationStatus.completed) _goNext();
                        });
                        Future.delayed(
                          composition.duration +
                              const Duration(milliseconds: 300),
                          _goNext,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
