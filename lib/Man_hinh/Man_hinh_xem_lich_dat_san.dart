import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Mau_du_lieu/Lich_co_so.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li_api/Co_so_api.dart';
import '../Xu_li_api/Dat_san_api.dart';

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
  DateTime ngayDangChon = DateTime.now();

  bool dangTai = false;
  bool dangDatSan = false;
  String? thongBaoLoi;

  List<LichSanCon> danhSachLich = [];

  int? sanIdDangChon;
  LichKhungGio? khungGioDangChon;

  @override
  void initState() {
    super.initState();
    layLichCoSo();
  }

  String dinhDangNgayApi(DateTime date) {
    final nam = date.year.toString();
    final thang = date.month.toString().padLeft(2, '0');
    final ngay = date.day.toString().padLeft(2, '0');

    return '$nam-$thang-$ngay';
  }

  String dinhDangNgayNgan(DateTime date) {
    final ngay = date.day.toString().padLeft(2, '0');
    final thang = date.month.toString().padLeft(2, '0');

    return '$ngay/$thang';
  }

  String dinhDangGia(double gia) {
    return '${gia.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  Future<void> layLichCoSo() async {
    setState(() {
      dangTai = true;
      thongBaoLoi = null;
      sanIdDangChon = null;
      khungGioDangChon = null;
    });

    try {
      final data = await CoSoApi().layLichCoSo(
        coSoId: widget.coSo.id,
        ngay: dinhDangNgayApi(ngayDangChon),
      );

      if (!mounted) return;

      setState(() {
        danhSachLich = data;
        dangTai = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        dangTai = false;
        thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> giuChoTamThoi() async {
    final lich = khungGioDangChon;

    if (sanIdDangChon == null || lich == null) return;

    final xuLiTaiKhoan = context.read<XuLiTaiKhoan>();
    final token = await xuLiTaiKhoan.layTokenDangNhap();

    if (token.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đặt sân'),
        ),
      );
      return;
    }

    setState(() {
      dangDatSan = true;
    });

    try {
      final ketQua = await DatSanApi().giuChoTamThoi(
        coSoId: widget.coSo.id,
        ngay: dinhDangNgayApi(ngayDangChon),
        slots: [
          {
            'san_id': sanIdDangChon,
            'khung_gio_mau_id': lich.khungGioMauId,
          },
        ],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ketQua['message']?.toString() ??
                'Đã giữ chỗ ${tenSanDangChon()} ${lich.gioBatDau} - ${lich.gioKetThuc}',
          ),
        ),
      );

      await layLichCoSo();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          dangDatSan = false;
        });
      }
    }
  }

  Future<void> chonNgay() async {
    final ngayMoi = await showDatePicker(
      context: context,
      initialDate: ngayDangChon,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff2454ff),
            ),
          ),
          child: child!,
        );
      },
    );

    if (ngayMoi == null) return;

    setState(() {
      ngayDangChon = ngayMoi;
    });

    layLichCoSo();
  }

  Widget nutNgay({
    required String tieuDe,
    required String phuDe,
    required bool dangChon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: dangChon ? const Color(0xffeef4ff) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dangChon ? const Color(0xff2454ff) : Colors.black54,
            width: dangChon ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: dangChon ? const Color(0xff2454ff) : Colors.black87,
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieuDe,
                  style: TextStyle(
                    color: dangChon ? const Color(0xff2454ff) : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phuDe,
                  style: TextStyle(
                    color: dangChon ? const Color(0xff2454ff) : Colors.black54,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget khuChonNgay() {
    final homNay = DateTime.now();
    final ngayMai = DateTime.now().add(const Duration(days: 1));

    final dangChonHomNay =
        dinhDangNgayApi(ngayDangChon) == dinhDangNgayApi(homNay);
    final dangChonNgayMai =
        dinhDangNgayApi(ngayDangChon) == dinhDangNgayApi(ngayMai);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        nutNgay(
          tieuDe: 'Hôm nay',
          phuDe: dinhDangNgayNgan(homNay),
          dangChon: dangChonHomNay,
          onTap: () {
            setState(() {
              ngayDangChon = homNay;
            });
            layLichCoSo();
          },
        ),
        nutNgay(
          tieuDe: 'Ngày mai',
          phuDe: dinhDangNgayNgan(ngayMai),
          dangChon: dangChonNgayMai,
          onTap: () {
            setState(() {
              ngayDangChon = ngayMai;
            });
            layLichCoSo();
          },
        ),
        nutNgay(
          tieuDe: 'Chọn ngày',
          phuDe: dinhDangNgayNgan(ngayDangChon),
          dangChon: !dangChonHomNay && !dangChonNgayMai,
          onTap: chonNgay,
        ),
      ],
    );
  }

  Widget chuThich() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          oChuThich(
            mau: Colors.white,
            vien: Colors.black54,
            text: 'Trống',
          ),
          oChuThich(
            mau: const Color(0xff91a7ff),
            vien: const Color(0xff2454ff),
            text: 'Đang chọn',
          ),
          oChuThich(
            mau: Colors.red,
            vien: Colors.red,
            text: 'Đã đặt',
          ),
        ],
      ),
    );
  }

  Widget oChuThich({
    required Color mau,
    required Color vien,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: mau,
            border: Border.all(color: vien),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget oGio({
    required LichSanCon san,
    required LichKhungGio lich,
  }) {
    final dangChon = sanIdDangChon == san.sanId &&
        khungGioDangChon?.khungGioMauId == lich.khungGioMauId;

    Color mauNen;
    Color mauVien;
    Color mauChu;

    if (!lich.conTrong) {
      mauNen = Colors.red;
      mauVien = Colors.red;
      mauChu = Colors.white;
    } else if (dangChon) {
      mauNen = const Color(0xff91a7ff);
      mauVien = const Color(0xff2454ff);
      mauChu = const Color(0xff2454ff);
    } else {
      mauNen = Colors.white;
      mauVien = Colors.grey.shade600;
      mauChu = Colors.black87;
    }

    return InkWell(
      onTap: lich.conTrong
          ? () {
              setState(() {
                sanIdDangChon = san.sanId;
                khungGioDangChon = lich;
              });
            }
          : null,
      child: Container(
        width: 58,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mauNen,
          border: Border.all(
            color: mauVien,
            width: 0.9,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '${lich.gioBatDau}\n${lich.gioKetThuc}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: mauChu,
            fontSize: 8.2,
            fontWeight: FontWeight.bold,
            height: 1.05,
          ),
        ),
      ),
    );
  }

  Widget bangLich() {
    if (dangTai) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (thongBaoLoi != null) {
      return Expanded(
        child: Center(
          child: Text(
            thongBaoLoi!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (danhSachLich.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'Chưa có lịch sân',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final danhSachGio = danhSachLich.first.lich;

    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          border: Border.all(
            color: const Color(0xff2454ff),
            width: 1.3,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 70 + danhSachGio.length * 58,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 70),
                    ...danhSachGio.map((lich) {
                      return SizedBox(
                        width: 58,
                        height: 22,
                        child: Text(
                          lich.gioBatDau,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: danhSachLich.map((san) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 46,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  san.tenSan,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: san.lich.map((lich) {
                                return oGio(
                                  san: san,
                                  lich: lich,
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String tenSanDangChon() {
    if (sanIdDangChon == null) return '';

    final san = danhSachLich.where((e) => e.sanId == sanIdDangChon).toList();

    if (san.isEmpty) return '';

    return san.first.tenSan;
  }

  Widget thongTinDangChon() {
    final lich = khungGioDangChon;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đang chọn',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lich == null
                      ? 'Chưa chọn khung giờ'
                      : '${tenSanDangChon()}, ${lich.gioBatDau} - ${lich.gioKetThuc}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Tạm tính',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lich == null ? '0đ' : dinhDangGia(lich.gia),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff2454ff),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget nutTiepTuc() {
    return SizedBox(
      width: 160,
      height: 38,
      child: ElevatedButton(
        onPressed: khungGioDangChon == null || dangDatSan
            ? null
            : giuChoTamThoi,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2454ff),
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const Text(
          'Tiếp tục đặt sân',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget anhMacDinh() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xffe7f1ff),
      child: const Icon(
        Icons.sports_tennis_rounded,
        color: Color(0xff2454ff),
      ),
    );
  }

  Widget thongTinCoSoNho() {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
            child: widget.coSo.hinhAnh.isNotEmpty
                ? Image.network(
                    widget.coSo.hinhAnh,
                    width: 88,
                    height: 86,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return anhMacDinh();
                    },
                  )
                : anhMacDinh(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coSo.tenCoSo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.coSo.diaChi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.coSo.soLuongSan} sân con',
                    style: const TextStyle(
                      color: Color(0xff2454ff),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              DuongDanAnh.Nen2,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 19,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Lịch sân',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 10),
                  thongTinCoSoNho(),
                  const SizedBox(height: 10),
                  khuChonNgay(),
                  const SizedBox(height: 8),
                  chuThich(),
                  bangLich(),
                  const SizedBox(height: 10),
                  thongTinDangChon(),
                  const SizedBox(height: 10),
                  nutTiepTuc(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}