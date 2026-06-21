import 'package:flutter/material.dart';

import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import 'Man_hinh_thanh_toan.dart';

String layUrlAnhSan(String duongDanAnh) {
  final path = duongDanAnh.trim();

  if (path.isEmpty) return '';

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }

  if (path.startsWith('/')) {
    return 'http://10.0.2.2:3000$path';
  }

  return 'http://10.0.2.2:3000/$path';
}

String dinhDangTien(double gia) {
  final soTien = gia.round().toString();
  final ketQua = soTien.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '${ketQua}đ';
}

String layTenCoSo(CoSo coSo) {
  if (coSo.tenCoSo.trim().isNotEmpty) return coSo.tenCoSo.trim();
  if (coSo.ten.trim().isNotEmpty) return coSo.ten.trim();
  return 'Sân cầu lông của NA';
}

String layDiaChiCoSo(CoSo coSo) {
  if (coSo.diaChi.trim().isNotEmpty) return coSo.diaChi.trim();
  return 'Bình Tân, TP Hồ Chí Minh';
}

class ManHinhXemLichSan extends StatefulWidget {
  final CoSo coSo;

  const ManHinhXemLichSan({
    super.key,
    required this.coSo,
  });

  @override
  State<ManHinhXemLichSan> createState() => _ManHinhXemLichSanState();
}

class _ManHinhXemLichSanState extends State<ManHinhXemLichSan> {
  final Set<String> oDangChon = {};

  final List<String> danhSachGio = const [
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
  ];

  int ngayDangChon = 0;

  double get giaTheoGio {
    if (widget.coSo.giaThapNhat > 0) return widget.coSo.giaThapNhat;
    return 120000;
  }

  double get giaMotO => giaTheoGio / 2;

  double get tamTinh => oDangChon.length * giaMotO;

  String get ngayDangChonText {
    if (ngayDangChon == 0) return 'T5, 28/5/2026';
    if (ngayDangChon == 1) return 'T6, 29/5/2026';
    return 'T7, 30/5/2026';
  }

  String taoKey(int san, int cot) => '$san-$cot';

  bool laODaDat(int san, int cot) {
    const dsDaDat = {
      '1-4',
      '2-4',
      '2-5',
      '3-3',
      '3-4',
      '3-5',
      '5-2',
      '5-3',
      '5-4',
      '5-5',
      '5-6',
      '6-2',
      '6-3',
      '6-4',
      '6-5',
      '6-6',
      '7-3',
      '7-4',
      '7-5',
    };

    return dsDaDat.contains('$san-$cot');
  }

  bool laOKhoa(int cot) => cot < 2;

  void bamO(int san, int cot) {
    if (laOKhoa(cot) || laODaDat(san, cot)) return;

    final key = taoKey(san, cot);

    setState(() {
      if (oDangChon.contains(key)) {
        oDangChon.remove(key);
      } else {
        oDangChon.add(key);
      }
    });
  }

  void chonNgay(int index) {
    setState(() {
      ngayDangChon = index;
      oDangChon.clear();
    });
  }

  String laySanDangChon() {
    if (oDangChon.isEmpty) return 'Chưa chọn';

    final danhSach = oDangChon.map((key) {
      final tach = key.split('-');
      return 'Sân ${tach.first}';
    }).toSet().toList();

    danhSach.sort();

    if (danhSach.length == 1) return danhSach.first;
    return '${danhSach.first} + ${danhSach.length - 1} sân';
  }

  String layKhungGioDangChon() {
    if (oDangChon.isEmpty) return 'Chưa chọn';

    final cotDaChon = oDangChon.map((key) {
      final tach = key.split('-');
      return int.parse(tach[1]);
    }).toList();

    cotDaChon.sort();

    final dau = cotDaChon.first;
    final cuoi = cotDaChon.last + 1;
    final gioCuoi = cuoi >= danhSachGio.length ? '08:30' : danhSachGio[cuoi];

    if (oDangChon.length == 1) {
      return '${danhSachGio[dau]} - $gioCuoi';
    }

    return '${danhSachGio[dau]} - $gioCuoi (${oDangChon.length} ô)';
  }

  String layMoTaDangChon() {
    if (oDangChon.isEmpty) return 'Chọn ô giờ trên bảng lịch';
    return '${laySanDangChon()}, ${layKhungGioDangChon()}';
  }

  void moThanhToan() {
    if (oDangChon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa chọn khung giờ'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhThanhToanDemo(
          coSo: widget.coSo,
          ngayChoi: ngayDangChonText,
          khungGio: layKhungGioDangChon(),
          sanDaChon: laySanDangChon(),
          soO: oDangChon.length,
          tongTien: tamTinh,
          giaTheoGio: giaTheoGio,
        ),
      ),
    );
  }

  Widget nenTrang({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffd9ecff),
            Color(0xfff9fcff),
            Color(0xffdff2ff),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -35,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff60a5fa).withOpacity(0.13),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: 35,
            child: Transform.rotate(
              angle: -0.45,
              child: Icon(
                Icons.sports_tennis_rounded,
                size: 68,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget nutBack() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 22,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget anhCoSo() {
    final url = layUrlAnhSan(widget.coSo.hinhAnh);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: url.isEmpty
          ? Container(
              color: const Color(0xffdbeafe),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: Color(0xff2454ff),
                size: 42,
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xffdbeafe),
                  child: const Icon(
                    Icons.sports_tennis_rounded,
                    color: Color(0xff2454ff),
                    size: 42,
                  ),
                );
              },
            ),
    );
  }

  Widget cardThongTinCoSo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 112,
            child: Stack(
              children: [
                Positioned.fill(child: anhCoSo()),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Color(0xff334155),
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  left: 7,
                  bottom: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.52),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      '5 sân',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layTenCoSo(widget.coSo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xff2454ff), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '4,9 (297 đánh giá)',
                      style: TextStyle(
                        color: Color(0xff64748b),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xff64748b), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        layDiaChiCoSo(widget.coSo),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff64748b),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Color(0xff64748b), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '5:00 - 22:00',
                      style: TextStyle(
                        color: Color(0xff64748b),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xffeef4ff),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Còn sân',
                    style: TextStyle(
                      color: Color(0xff2454ff),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget nutNgay({
    required int index,
    required String title,
    required String sub,
  }) {
    final dangChon = ngayDangChon == index;

    return Expanded(
      child: InkWell(
        onTap: () => chonNgay(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: dangChon ? const Color(0xff2454ff) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xff2454ff),
              width: dangChon ? 0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: dangChon ? Colors.white : const Color(0xff1e3a8a),
                size: 17,
              ),
              const SizedBox(width: 7),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: dangChon ? Colors.white : const Color(0xff0f172a),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: dangChon ? Colors.white.withOpacity(0.86) : const Color(0xff64748b),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget hangChonNgay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          nutNgay(index: 0, title: 'Hôm nay', sub: 'T4, 27/5'),
          const SizedBox(width: 8),
          nutNgay(index: 1, title: 'Ngày mai', sub: 'T5, 28/5'),
          const SizedBox(width: 8),
          nutNgay(index: 2, title: 'Chọn ngày', sub: 'Ngày khác'),
        ],
      ),
    );
  }

  Widget chuThich() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          itemChuThich('Trống', Colors.white, border: Colors.black54),
          itemChuThich('Đang chọn', const Color(0xff9db2ff), border: const Color(0xff2454ff)),
          itemChuThich('Khóa', const Color(0xffe5e7eb), border: Colors.grey),
          itemChuThich('Đã đặt', const Color(0xffff1515), border: const Color(0xffff1515)),
        ],
      ),
    );
  }

  Widget itemChuThich(String text, Color color, {required Color border}) {
    return Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: border, width: 1),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget oLichSan({required int san, required int cot}) {
    final key = taoKey(san, cot);
    final daChon = oDangChon.contains(key);
    final daDat = laODaDat(san, cot);
    final khoa = laOKhoa(cot);

    Color mauNen = Colors.white;
    Color mauVien = const Color(0xff8a8a8a);

    if (khoa) {
      mauNen = const Color(0xffe5e7eb);
      mauVien = const Color(0xff9ca3af);
    }

    if (daDat) {
      mauNen = const Color(0xffff1414);
      mauVien = const Color(0xffc90000);
    }

    if (daChon) {
      mauNen = const Color(0xff9db2ff);
      mauVien = const Color(0xff2454ff);
    }

    return GestureDetector(
      onTap: () => bamO(san, cot),
      child: Container(
        width: 44,
        height: 42,
        decoration: BoxDecoration(
          color: mauNen,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: mauVien, width: 1.2),
        ),
      ),
    );
  }

  Widget bangLichSan() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 13, 8, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 70),
                ...danhSachGio.map((gio) {
                  return SizedBox(
                    width: 44,
                    child: Text(
                      gio.replaceAll(':00', ':00').replaceAll(':30', ':30'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 4),
            ...List.generate(7, (index) {
              final san = index + 1;

              return Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 42,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sân $san',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(danhSachGio.length, (cot) {
                    return oLichSan(san: san, cot: cot);
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget cardTamTinh() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 9,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Đang chọn',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Tạm tính',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  layMoTaDangChon(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff334155),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                dinhDangTien(tamTinh),
                style: const TextStyle(
                  color: Color(0xff2454ff),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget nutTiepTuc() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 14, 56, 120),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: oDangChon.isEmpty ? null : moThanhToan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2454ff),
            disabledBackgroundColor: const Color(0xff93c5fd),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Tiếp tục đặt sân',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xffeaf6ff),
      bottomNavigationBar: const ThanhDuoi(viTriDangChon: 1),
      body: nenTrang(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
                      child: Row(
                        children: [
                          nutBack(),
                          const Expanded(
                            child: Text(
                              'Lịch sân',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    cardThongTinCoSo(),
                    hangChonNgay(),
                    chuThich(),
                    bangLichSan(),
                    cardTamTinh(),
                    nutTiepTuc(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
