import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:arumbu/constants/hive_boxes.dart';
import 'package:arumbu/model/sync_plants_response.dart';
import 'package:arumbu/providers/gallery_provider.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/providers/loading_provider.dart';
import 'package:arumbu/providers/plants_provider.dart';
import 'package:arumbu/providers/sector_based_plants_provider.dart';
import 'package:arumbu/providers/sector_provider.dart';
import 'package:arumbu/ui/splash_page.dart';
import 'package:arumbu/utility/check_connectivity.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Hive.initFlutter();
  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage('en');
  final dataAdapter = DataAdapter();
  if (!Hive.isAdapterRegistered(dataAdapter.typeId)) {
    Hive.registerAdapter(dataAdapter);
  }
  final changesAdapter = ChangesAdapter();
  if (!Hive.isAdapterRegistered(changesAdapter.typeId)) {
    Hive.registerAdapter(changesAdapter);
  }
  final languagesAdapter = LanguagesAdapter();
  if (!Hive.isAdapterRegistered(languagesAdapter.typeId)) {
    Hive.registerAdapter(languagesAdapter);
  }
  await Hive.openBox<Data>(HiveBoxes.syncPlants);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageProvider),
        ChangeNotifierProvider(create: (_) => ApiLoadingState()),
        ChangeNotifierProvider(create: (_) => PlantsProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => SectorProvider()),
        ChangeNotifierProvider(create: (_) => SectorBasedPlantsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    NetworkToast().start();
    super.initState();
  }

  @override
  void dispose() {
    NetworkToast().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
