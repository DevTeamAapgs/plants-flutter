import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/providers/gallery_provider.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/utility/scroll_notification_listener.dart';
import 'package:arumbu/widgets/data_not_available.dart';
import 'package:provider/provider.dart';
import 'package:arumbu/widgets/gallery_item_card.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool isLoading = false;
  var params = {};
  @override
  void initState() {
    // TODO: implement initState
    _getGalleryImages();
    super.initState();
  }

  _getGalleryImages() {
    Provider.of<GalleryProvider>(context, listen: false).resetProvider();
    setState(() {
      isLoading = true;
    });

    Provider.of<GalleryProvider>(context, listen: false)
        .getGalleryImages(context, body: params)
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
              child: Container(
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
                            localization.translate('Gallery'),
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
                              'Explore our collection of beautiful plant images from around the world.',
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
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : listGalleryImages(),
            ),
          ],
        ),
      ),
    );
  }

  Widget listGalleryImages() {
    return Consumer<GalleryProvider>(
      builder: (ctx, data, child) {
        return data.listofitems.isEmpty
            ? const DataNotAvailable()
            : ScrollNotificationListener(
                future: Provider.of<GalleryProvider>(
                  context,
                  listen: false,
                ).getGalleryImages,
                params: {},
                child: ListView.separated(
                  itemBuilder: (context, position) {
                    if (position >= data.listofitems.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    var obj = data.listofitems[position];

                    return GalleryItemCard(item: obj);
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
