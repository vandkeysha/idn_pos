import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:idn_pos/models/products.dart';
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

  void _connectedToDevice(BluetoothDevice? device) {
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
  

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}