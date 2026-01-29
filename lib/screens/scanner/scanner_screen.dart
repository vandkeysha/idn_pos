import 'package:flutter/material.dart';
import 'package:idn_pos/screens/scanner/components/payment_modal.dart';
import 'package:idn_pos/screens/scanner/components/scanner_header.dart';
import 'package:idn_pos/screens/scanner/components/scanner_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // untuk membuat detection tidak ada delay
    returnImage: false,
  );

  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAMERA SCANNER
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if(_isScanned) return;
              // kondisi yg ada di perulangan for adalah kondisi ketika Qrcode sudah berhasil ditangkap oleh kamera
              for (final barcode in capture.barcodes) {
                _handleQrCode(barcode.rawValue);
              }
            },
          ),

          ScannerOverlay(),
          ScannnerHeader(controller: controller)
        ],
      ),
    );
  }

  void _handleQrCode(String? code) {
    if (code != null) {
      if (code.startsWith("PAY:")) {
        // Qrcode valid
        setState(() {
          _isScanned = true;

          final parts = code.split(":");
          final id = parts[1];
          final total = int.tryParse(parts[2]) ?? 0; 

          _showPaymentModal(id, total);
        });
      } else {
        // Qr code tidak valid
          ScaffoldMessenger.of(context).hideCurrentSnackBar();//untuk menghindari snackbar 2x
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white,),
                  SizedBox(width: 10),
                  Expanded(child: Text("QR Tidak di kenalin $code", overflow: TextOverflow.ellipsis,))
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(milliseconds: 1000),
          )
        );
      }
    }
  }

  //TAMPILKAN MODAL PAYMENT
  void _showPaymentModal(String id, int total) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (paymentContext) => PaymentModal(
        id: id,
        total: total,
        onPay: () {
          Navigator.pop(paymentContext); 
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pembayaran Berhasil"),
            backgroundColor: Colors.green,
            )
          );
        },
        onCancel: () {
          Navigator.pop(paymentContext);
          setState(() {
            _isScanned = false; // ini untuk meriset state agar bisa scan lagi dari awal
          });
        },
      )
    ).then((_){
      if (_isScanned) setState(() => _isScanned = false);
    });
  }
}