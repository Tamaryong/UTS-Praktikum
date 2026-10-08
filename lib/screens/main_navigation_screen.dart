import 'package:flutter/material.dart';
import 'order_form_screen.dart';
import 'login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

// Model sederhana untuk ExpansionPanel Promo
class PromoItem {
  String judul;
  String isi;
  bool isExpanded;

  PromoItem({
    required this.judul,
    required this.isi,
    this.isExpanded = false,
  });
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Data produk katalog
  final List<Map<String, dynamic>> daftarProduk = [
    {
      'nama': 'Mouse Wireless Logitech',
      'harga': 150000,
      'stok': 'Tersedia 10 pcs',
      'promo': 'Diskon 10%',
    },
    {
      'nama': 'Kertas HVS A4 1 Rim',
      'harga': 55000,
      'stok': 'Tersedia 50 rim',
      'promo': 'Best Seller',
    },
    {
      'nama': 'Keyboard Mechanical USB',
      'harga': 350000,
      'stok': 'Tersedia 5 pcs',
      'promo': 'Diskon 5%',
    },
  ];

  // Data promo untuk ExpansionPanelList
  List<PromoItem> daftarPromo = [
    PromoItem(
      judul: 'Syarat Diskon Member',
      isi: 'Diskon member hanya berlaku jika sudah terdaftar sebagai kasir/pelanggan tetap.',
    ),
    PromoItem(
      judul: 'Ketentuan Ekstra Proteksi',
      isi: 'Barang elektronik wajib menggunakan asuransi dan packing kayu demi keamanan pengiriman.',
    ),
  ];

  // Data riwayat transaksi kasir untuk DataTable
  List<Map<String, String>> riwayatTransaksi = [
    {
      'id': 'TRX-001',
      'produk': 'Mouse Wireless Logitech',
      'total': 'Rp 160.000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 3 Halaman untuk BottomNavigationBar
    final List<Widget> pages = [
      // 1. Menu Katalog (Memiliki 2 Tab)
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
            title: Text('Katalog Ritel'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.shopping_bag), text: "Produk"),
                Tab(icon: Icon(Icons.local_offer), text: "Ketentuan Promo"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // TAB PRODUK (ListView.builder + Stack + Positioned)
              ListView.builder(
                itemCount: daftarProduk.length,
                itemBuilder: (context, index) {
                  var item = daftarProduk[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            color: Colors.blue[100],
                            child: Icon(Icons.inventory, color: Colors.blue),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              color: Colors.red,
                              padding: EdgeInsets.all(2),
                              child: Text(
                                item['promo'],
                                style: TextStyle(color: Colors.white, fontSize: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(item['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Rp ${item['harga']} | ${item['stok']}'),
                      trailing: ElevatedButton(
                        child: Text('Pesan'),
                        onPressed: () async {
                          // Buka layar OrderFormScreen dan bawa data produk
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderFormScreen(
                                namaProduk: item['nama'],
                                hargaProduk: item['harga'],
                              ),
                            ),
                          );

                          // Respon balikan: tampilkan SnackBar
                          if (result != null) {
                            setState(() {
                              riwayatTransaksi.add({
                                'id': 'TRX-00${riwayatTransaksi.length + 1}',
                                'produk': result['produk'],
                                'total': 'Rp ${result['total']}',
                              });
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Transaksi untuk ${result['produk']} Sukses Disetujui!'),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),

              // TAB KETENTUAN PROMO (ExpansionPanelList)
              ListView(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        daftarPromo[index].isExpanded = !daftarPromo[index].isExpanded;
                      });
                    },
                    children: daftarPromo.map((PromoItem item) {
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(item.judul, style: TextStyle(fontWeight: FontWeight.bold)),
                          );
                        },
                        body: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(item.isi),
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // 2. Menu Riwayat (DataTable)
      Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Riwayat Transaksi'),
        ),
        body: ListView(
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Produk')),
                DataColumn(label: Text('Total')),
              ],
              rows: riwayatTransaksi.map((trx) {
                return DataRow(
                  cells: [
                    DataCell(Text(trx['id']!)),
                    DataCell(Text(trx['produk']!)),
                    DataCell(Text(trx['total']!)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),

      // 3. Menu Informasi Toko (SelectableText)
      Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Informasi Toko'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SmartRetail Tama Office & Electronic',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Kode Lisensi Resmi Toko:'),
              SizedBox(height: 5),
              // SelectableText agar bisa di-copy
              SelectableText(
                'SR-SUBANG-2026-LIC-D4TRPL',
                style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text('Alamat Cabang:'),
              SelectableText('Jl. Brigjen Katamso No. 37, Subang, Jawa Barat.'),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('SmartRetail Tama POS App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Kasir: Admin Toko', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('Status: Aktif', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Katalog'),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Riwayat'),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Informasi Toko'),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Informasi Toko',
          ),
        ],
      ),
    );
  }
}