import 'package:flutter/material.dart';
import 'package:idn_pos/screens/home/components/home_header.dart';
import 'package:idn_pos/screens/home/components/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          HomeHeader(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //tambahkan widget menu card disini
                  MenuCard(
                    title: "Mode Cashsier",
                    subtitle: "Buat pesanan & cetak struk",
                    icon: Icons.point_of_sale_rounded,
                    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                    ontap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Placeholder())),
                  ),
                  SizedBox(height: 20),

                  MenuCard(
                    title: "Menu pelanggan",
                    subtitle: "Scan QR dan lakukan pembayaran",
                    icon: Icons.qr_code_scanner_rounded,
                    colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                    ontap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Placeholder())),
                  )
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "v1.0.0 - IDN cafe POS",
              style: TextStyle(
                color: Colors.grey
              ),
            ),
          )
        ],
      ),
    );
  }
}