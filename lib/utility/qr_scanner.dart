import 'dart:developer';
import 'dart:io';

import 'package:arumbu/ui/sector_based_plants_page.dart';
import 'package:flutter/material.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/ui/plants_page.dart';
import 'package:arumbu/utility/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  // Extract a plant ID from various QR formats.
  // Supports:
  // - Raw 24-char hex IDs
  // - URLs like .../plants/<id>
  // - URLs with query params like ?id=<id>
  _extractPlantId(String input) {
    final trimmed = input.trim();

    Uri? uri;
    try {
      uri = Uri.tryParse(trimmed);
    } catch (_) {
      uri = null;
    }

    if (uri != null) {
      final segments = uri.pathSegments;

      // Check if URL contains `/sector/<slug>`
      final sectorIndex = segments.indexOf('sector');
      if (sectorIndex != -1 && sectorIndex + 1 < segments.length) {
        print("Found sector slug: ${segments[sectorIndex + 1]}");
        return {"type": "sector", "data": segments[sectorIndex + 1]}; // slug
      }

      // Check if URL contains `/plants/<slug>`
      final plantIndex = segments.indexOf('plants');
      if (plantIndex != -1 && plantIndex + 1 < segments.length) {
        final slug = segments[plantIndex + 1];
        print("Found plant slug: $slug");
        if (slug.isNotEmpty) return {"type": "plant", "data": slug};
      }
    }

    return null; // Nothing found
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(localization.translate("Qr Scanner"))),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: IconButton.outlined(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      icon: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Icon(
                            snapshot.data == false
                                ? Icons.flash_off_rounded
                                : Icons.flash_on_rounded,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        final raw = scanData.code!;
        log("log data $raw");
        var dataOfQR = _extractPlantId(raw);
        final id = dataOfQR["data"];
        final type = dataOfQR["type"];

        if (id != null) {
          this.controller?.pauseCamera();
          if (type == "sector") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SectorBasedPlantsPage(fkSectorId: id),
              ),
            );
          } else if (type == "plant") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PlantsPage(id: id)),
            );
          }
        } else {
          showSnackBar(context, 'Invalid QR code');
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('no Permission')));
      showSnackBar(context, 'no Permission');
    }
  }
}
