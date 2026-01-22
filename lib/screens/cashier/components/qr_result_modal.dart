import 'package:flutter/material.dart';
import 'package:idn_pos/utils/currency_format.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrResultModal extends StatefulWidget {
  final String qrData;
  final int total;
  final bool isPrinting;
  final VoidCallback onClose;


  const QrResultModal({super.key, required this.qrData, required this.total, required this.isPrinting, required this.onClose});

  @override
  State<QrResultModal> createState() => _QrResultModalState();
}

class _QrResultModalState extends State<QrResultModal> {
  // variabel untuk menyimpan status pencetakan
  late bool _printFinished;

  @override
  void initState(){
    super.initState();
    // awalnya anggap proses print belum selesai
     _printFinished = false; // ketika status belum selesai

     // jika mode mencetak atau printer nyala kita buat simulasi loading
     if (widget.isPrinting) {
       Future.delayed(Duration(seconds: 2), () {
        // cek jika proses delay sesuai dengan waktu yang di butuhkan ketika mencetak
        if (mounted) { // mounted adalah ketika widgetnya masih aktif
          setState(() {
            _printFinished = true; // ubah status menjadi selesai
          });
        }
       }); 
     }
  }

  @override
  Widget build(BuildContext context) {
    // tentukan warna dan text berdasarkan status
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String statusText;

    if (!widget.isPrinting) {
      // kondisi 1 : printer mati atau mode tanpa printer
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.shade50;
      statusIcon = Icons.print_disabled;
      statusText = "Mode Tanpa printer";
    } else if (!_printFinished) {
      // kondisi 2 : ketika sedang proses mencetak struk
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
      statusIcon = Icons.print;
      statusText = "Mencetak Struk Fisik...";
    } else  {
      // kondisi 3 : Ketika Sudah selesai mencetak struk
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = "Cetak Selesai";
    }
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,//untuk mengtur tinggi layar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // handle bar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          SizedBox(height: 20),
          // status pecetakan
          AnimatedContainer(
            duration: Duration(milliseconds: 300), // efek animasi halus
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 20, color: statusColor),
                SizedBox(width: 10),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),

          SizedBox(height: 20),
          // Menampikan data QR code
          Text(
            'SCAN UNTUK MEMBAYAR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2E3192)
            ),
          ),

          SizedBox(height: 5),
          Text(
            'Total : ${formatRupiah(widget.total)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
          SizedBox(height: 20),
          
          //ini untuk tempat qr code container
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 15,
                )
              ]
            ),
            child: QrImageView(
              data: widget.qrData,
              version: QrVersions.auto,// versi qr codenya otomatis
              size: 220.0,
              ),
          ),

          Spacer(),// untuk mendorong tombol sesuai devices
          // close button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,

            ),
            onPressed: widget.onClose,
            child: Text('Tutup'),
            )
          )
        ],
      ),
    );
  }
}