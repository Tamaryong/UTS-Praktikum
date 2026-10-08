import 'package:flutter/material.dart';

class OrderFormScreen extends StatefulWidget {
  final String namaProduk;
  final int hargaProduk;

  OrderFormScreen({
    required this.namaProduk,
    required this.hargaProduk,
  });

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  // Pilihan Radio Button Kurir
  String kurir = 'Reguler';

  // Pilihan Checkbox Layanan Ekstra
  bool cekAsuransi = false;
  bool cekBubble = false;
  bool cekPackingKayu = false;

  // Jadwal Tanggal & Waktu
  DateTime tanggal = DateTime.now();
  TimeOfDay waktu = TimeOfDay.now();

  // Slider Diskon & Switch Kado
  double diskon = 0.0;
  bool isKado = false;

  // Fungsi Pemilih Tanggal
  Future<void> pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != tanggal) {
      setState(() {
        tanggal = picked;
      });
    }
  }

  // Fungsi Pemilih Jam
  Future<void> pilihWaktu(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: waktu,
    );
    if (picked != null && picked != waktu) {
      setState(() {
        waktu = picked;
      });
    }
  }

  // Menghitung perkiraan total
  int hitungTotal() {
    int total = widget.hargaProduk;
    int nilaiDiskon = (total * (diskon / 100)).toInt();
    total = total - nilaiDiskon;
    if (cekAsuransi) total += 5000;
    if (cekBubble) total += 3000;
    if (cekPackingKayu) total += 10000;
    if (isKado) total += 5000;
    return total;
  }

  // Membuka BottomSheet Rincian
  void prosesTransaksi(BuildContext context) {
    int totalAkhir = hitungTotal();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rincian Biaya Pemesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Text('Produk: ${widget.namaProduk}'),
              Text('Kurir: $kurir'),
              Text('Diskon: ${diskon.toInt()}%'),
              Text('Total Bayar: Rp $totalAkhir', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 45),
                ),
                child: Text('Konfirmasi Transaksi', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(sheetContext); // Tutup BottomSheet
                  tampilkanDialogKonfirmasi(totalAkhir);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Membuka AlertDialog Persetujuan
  void tampilkanDialogKonfirmasi(int totalAkhir) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Persetujuan Kasir'),
          content: Text('Setujui transaksi pemesanan sebesar Rp $totalAkhir?'),
          actions: [
            ElevatedButton(
              child: Text('Batal'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Setujui', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup AlertDialog
                // Tutup Halaman Order & Kembalikan Data ke Layar Utama
                Navigator.pop(context, {
                  'produk': widget.namaProduk,
                  'total': totalAkhir,
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulir Pemesanan'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            widget.namaProduk,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text('Harga Dasar: Rp ${widget.hargaProduk}'),
          Divider(height: 25),

          // Radio Button Metode Pengiriman
          Text('Metode Pengiriman:', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile(
            title: Text('Reguler'),
            value: 'Reguler',
            groupValue: kurir,
            onChanged: (val) => setState(() => kurir = val.toString()),
          ),
          RadioListTile(
            title: Text('Kargo'),
            value: 'Kargo',
            groupValue: kurir,
            onChanged: (val) => setState(() => kurir = val.toString()),
          ),
          RadioListTile(
            title: Text('Instan'),
            value: 'Instan',
            groupValue: kurir,
            onChanged: (val) => setState(() => kurir = val.toString()),
          ),
          Divider(height: 25),

          // Checkbox Layanan Ekstra
          Text('Layanan Ekstra Proteksi:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: Text('Asuransi Pengiriman (+Rp 5.000)'),
            value: cekAsuransi,
            onChanged: (val) => setState(() => cekAsuransi = val!),
          ),
          CheckboxListTile(
            title: Text('Bubble Wrap Ekstra (+Rp 3.000)'),
            value: cekBubble,
            onChanged: (val) => setState(() => cekBubble = val!),
          ),
          CheckboxListTile(
            title: Text('Packing Kayu (+Rp 10.000)'),
            value: cekPackingKayu,
            onChanged: (val) => setState(() => cekPackingKayu = val!),
          ),
          Divider(height: 25),

          // Date & Time Picker
          Text('Jadwal Penjemputan Barang:', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text('Tanggal: ${tanggal.toLocal()}'.split(' ')[0]),
              IconButton(
                icon: Icon(Icons.date_range),
                onPressed: () => pilihTanggal(context),
              ),
              SizedBox(width: 15),
              Text('${waktu.hour.toString().padLeft(2, '0')} : ${waktu.minute.toString().padLeft(2, '0')}'),
              IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () => pilihWaktu(context),
              ),
            ],
          ),
          Divider(height: 25),

          // Slider Diskon Member
          Text('Diskon Member: ${diskon.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: diskon,
            min: 0,
            max: 50,
            divisions: 5,
            label: '${diskon.toInt()}%',
            onChanged: (newVal) {
              setState(() {
                diskon = newVal;
              });
            },
          ),

          // Switch Bungkus Kado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bungkus Kado / Dropship (+Rp 5.000):'),
              Switch(
                value: isKado,
                activeColor: Colors.blue,
                onChanged: (newVal) {
                  setState(() {
                    isKado = newVal;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 25),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('Proses Transaksi', style: TextStyle(fontSize: 16, color: Colors.white)),
            onPressed: () => prosesTransaksi(context),
          ),
        ],
      ),
    );
  }
}