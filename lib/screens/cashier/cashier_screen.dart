import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:idn_pos/models/products.dart';
import 'package:idn_pos/screens/cashier/components/checkout_panel.dart';
import 'package:idn_pos/screens/cashier/components/printer_selector.dart';
import 'package:idn_pos/screens/cashier/components/product_card.dart';
import 'package:idn_pos/screens/cashier/components/qr_result_modal.dart';
import 'package:idn_pos/utils/currency_format.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _Connected = false;
  final Map<Product, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  // LOGIKA BLUETOOTH
  Future<void> _initBluetooth() async {
    // minta izin lokasi dan bluetooth (wajib)
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();// untuk memproses izin yg sudah diminta

    List<BluetoothDevice> devices = [
      //list ini akan otomatis terisi ketika ada device bluetooth menyala dan siap di koneksikan 
    ];
    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      debugPrint("Error bluetooth: $e");
    }

    if (mounted) {
      setState(() {
        _devices = devices; // ketika bluetooth aktiv 
      });
    }

    bluetooth.onStateChanged().listen((state) {
      if (mounted) {
        setState(() {
          _Connected = state == BlueThermalPrinter.CONNECTED;  // cek status koneksi
        });
      }
    });
  }

  void _connectToDevice(BluetoothDevice? device) {
    // if / kondisi utama , yang memeplopori if-if selanjutnya
    if (device != null) { // jika device tidak null (nenek)

    // if yg merupakan anak atau cabang dari if utama,
    // if ini memiliki sebuah kondisi yang menjawab pertanyaan atau statement dari kondisi utama
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == false) { // jika belum konek (ibu)
          bluetooth.connect(device).catchError((error) {

            // if ini wajib memiliki opini yg sama uf yg kedua
            if(mounted) setState(() => _Connected = false); // jika gagal konek (anak)
          });

          // statement didalam if ini akan di jalankan ketika if-if sebelumnya tidak terpenuhi,
          // if ini adalah opsi terakhir yg akan dijalan ketika if sebelumnya tidak terpenuhi(tidak berjalan)
        if (mounted) setState(() => _selectedDevice = device); // jika berhasil konek (tante)
        }
      });
    }
  }

  // LOGIKA CART
  void _addToCart(Product product) {
    setState(() {
      //update untuk user beli lebih dari satu, kalau ifAbsent cuman untuk membeli satu.
      _cart.update(
        //untuk mendefinisikan produk yg ada di menu.
        product, 
        // logika matematis, yang dijalankan ketika 1 product sudah berada di keranjang, dan user klik + yg nantinya jumlahnya akan ditambah 1.
        (value) => value + 1,
        // jika user tidak menambahkan lagi jumlah produk, hanya satu dikeranjang, maka default jumlah dari barang tersebut adalah 1.
         ifAbsent: () => 1); 
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
     if (_cart.containsKey(product) && _cart[product]! > 1) {
       _cart[product] = _cart[product]! - 1; // perbedaan bankopearator(!) itu wajib ada valuenya, kalau not kebalikannya
     } else {
       _cart.remove(product); // ini untuk dijalankan kalau misalkan codingannya ada error
     }
    });
  }

  int _calculateTotal() {
    int total = 0;
    _cart.forEach((key, value) => total += (key.price * value));
    return total;
  }

  //LOGIKA PRINTING
  void _handlePrint() async {
    int total = _calculateTotal();
    if (total == 0 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Keranjang masih kosong!"))
      );
    }

    String trxId = "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";//untuk membuat id transaksi unik berdasarkan waktu skrg
    String qrData = "PAY :$trxId:$total"; // data yg akan di encode ke qr code
    bool isPrinting = false;

    // menyiapkan tanggal saat ini (current date)
    DateTime now = DateTime.now(); // mendapatkan tanggal dan waktu saat ini
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(now); // untuk menyimpan format tanggal dan waktu dengan rapi

    // LAYOUTING STRUK PRINTING
    if (_selectedDevice != null && await bluetooth.isConnected == true) {
      // header struk 
      bluetooth.printNewLine();  // untuk ngasih enteran baru
      bluetooth.printCustom("IDN CAFE", 3, 1); // nama cafe, judul besar (center)
      bluetooth.printNewLine();
      bluetooth.printCustom("JL. Bagus Dayeuh,", 1, 1); // alamat cafe, text sedang (center)

      //tanggal dan id transaksi
      bluetooth.printNewLine();
      bluetooth.printLeftRight("Waktu:", formattedDate, 1);

      // data items
      bluetooth.printCustom("--------------------------------", 1, 1);
      _cart.forEach((product, qty) {
        String priceTotal = formatRupiah(product.price * qty);
        // untuk cetak nama barang X qty 
        bluetooth.printLeftRight("${product.name} x${qty}", priceTotal, 1);
      });
      bluetooth.printCustom("--------------------------------", 1, 1);
      // total & qr
      bluetooth.printLeftRight("TOTAL", formatRupiah(total), 3);
      bluetooth.printNewLine();
      bluetooth.printCustom("Scan QR dibawah:", 1, 1);
      bluetooth.printQRcode(qrData, 200, 200, 1);// mencetak qr code
      bluetooth.printNewLine();
      bluetooth.printCustom("ThankYou!", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      isPrinting = true;
      }

      //untuk menampilkan modal hasil Qr code yang bentuknya adalah popup
      _showQRModal(qrData, total, isPrinting);
  }

  void _showQRModal(String qrData, int total, bool isPrinting){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrResultModal(
        qrData: qrData,
        total: total,
        isPrinting: isPrinting,
        onClose: () => Navigator.pop(context),
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "Menu Kasir",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // DROPDWON SELECT PRINTER BLUETOOTH
          PrinterSelector(
            devices: _devices,
            selectedDevice: _selectedDevice,
            isConnected: _Connected,
            onSelected: _connectToDevice,
          ),

          // GRID FOR PRODUCT LIST
          Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisExtent: 15
            ),
            itemCount: menus.length,
            itemBuilder: (context, index){
              final product = menus[index];
              final qty = _cart[product] ?? 0;

              // PEMANGGILA PRODUCT LIST PADA PRODUCT CARD
              return ProductCard(
                product: product,
                qty: qty,
                onAdd: () => _addToCart(product),
                onRemove: () => _removeFromCart(product),
              );
            },
          ),
          ),

          // BOTTOM SHEET PANEL
          CheckoutPanel(
            total: _calculateTotal(),
            onPressed: _handlePrint,
          )
        ],
      ),
    );
  }
}