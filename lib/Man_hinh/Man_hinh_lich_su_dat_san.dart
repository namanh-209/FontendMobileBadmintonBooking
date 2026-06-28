import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li_api/Dat_san_api.dart';
import 'Man_hinh_dang_nhap.dart';
import '../Dung_lai/Hieu_ung_tai.dart';

class ManHinhLichSuDatSan extends StatefulWidget {
  const ManHinhLichSuDatSan({super.key});

  @override
  State<ManHinhLichSuDatSan> createState() => _ManHinhLichSuDatSanState();
}

class _ManHinhLichSuDatSanState extends State<ManHinhLichSuDatSan> {
  final DatSanApi api = DatSanApi();

  bool dangTai = false;
  String? loi;

  List<DatSan> tatCaLich = [];

  static final Set<int> danhSachLichSuDaXoa = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(taiDuLieu);
  }

  void hienThongBao(String noiDung) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung),
      ),
    );
  }

  String? layTokenTuTaiKhoanXuLy(dynamic taiKhoanXuLy) {
    for (final getter in [
      () => taiKhoanXuLy.token,
      () => taiKhoanXuLy.accessToken,
      () => taiKhoanXuLy.maToken,
      () => taiKhoanXuLy.jwt,
      () => taiKhoanXuLy.nguoiDung?.token,
    ]) {
      try {
        final value = getter();

        if (value != null && '$value'.trim().isNotEmpty) {
          return '$value';
        }
      } catch (_) {}
    }

    return null;
  }

  Future<void> taiDuLieu({
    bool hienLoading = true,
  }) async {
    final taiKhoan = context.read<XuLiTaiKhoan>();

    if (!taiKhoan.daDangNhap) {
      setState(() {
        loi = 'Bạn phải đăng nhập để xem lịch sử đặt sân';
      });
      return;
    }

    String? token;

    try {
      final dynamic taiKhoanDong = taiKhoan;
      token = await taiKhoanDong.layTokenDangNhap();
    } catch (_) {
      token = layTokenTuTaiKhoanXuLy(taiKhoan);
    }

    if (token != null && token.trim().isNotEmpty) {
      GoiApi.ganToken(token);
    }

    if (mounted && hienLoading) {
      setState(() {
        dangTai = true;
        loi = null;
      });
    }

    try {
      final data = await api.layLichDatCuaToi().timeout(
            const Duration(seconds: 20),
          );

      if (!mounted) return;

      setState(() {
        tatCaLich = data;
        loi = null;
      });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        loi = 'Tải lịch sử quá lâu, vui lòng thử lại';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loi = '$e';
      });
    } finally {
      if (!mounted) return;

      if (hienLoading) {
        setState(() {
          dangTai = false;
        });
      }
    }
  }

  DateTime? ghepNgayGio(DateTime? ngay, String gioText) {
    if (ngay == null) return null;

    final ngayLocal = ngay.toLocal();
    final text = gioText.trim();

    if (text.isEmpty) return null;

    final tach = text.split(':');

    if (tach.length < 2) return null;

    final gio = int.tryParse(tach[0]) ?? 0;
    final phut = int.tryParse(tach[1]) ?? 0;

    return DateTime(
      ngayLocal.year,
      ngayLocal.month,
      ngayLocal.day,
      gio,
      phut,
    );
  }

  DateTime? layGioKetThucCuoiCung(DatSan datSan) {
    final list = datSan.chiTiet
        .map((ct) {
          final gioKetThuc =
              ct.gioKetThuc.trim().isNotEmpty ? ct.gioKetThuc : ct.gioBatDau;

          return ghepNgayGio(ct.ngay, gioKetThuc);
        })
        .whereType<DateTime>()
        .toList();

    if (list.isEmpty) return null;

    list.sort();

    return list.last;
  }

  DateTime? layNgayChoiDauTien(DatSan datSan) {
    final list = datSan.chiTiet
        .where((item) => item.ngay != null)
        .map((item) => item.ngay!.toLocal())
        .toList();

    if (list.isEmpty) return null;

    list.sort();

    return list.first;
  }

  DateTime? layNgaySapXep(DatSan datSan) {
    return layNgayChoiDauTien(datSan) ?? datSan.ngayTao?.toLocal();
  }

  bool daQuaGioChoi(DatSan datSan) {
    final gioKetThucCuoi = layGioKetThucCuoiCung(datSan);

    if (gioKetThucCuoi == null) return false;

    return DateTime.now().isAfter(gioKetThucCuoi);
  }

  bool daHetHanGiuCho(DatSan datSan) {
    if (datSan.trangThai != 0) return false;
    if (datSan.daThanhToan > 0) return false;
    if (datSan.thoiGianHetHan == null) return false;

    return DateTime.now().isAfter(datSan.thoiGianHetHan!.toLocal());
  }

  bool laLoiVnPay(DatSan datSan) {
    final lyDo = datSan.lyDoHuy.toLowerCase();

    return lyDo.contains('vnpay') ||
        lyDo.contains('vn pay') ||
        lyDo.contains('thất bại') ||
        lyDo.contains('that bai');
  }

  bool laDonBiHuy(DatSan datSan) {
    return datSan.trangThai == 2;
  }

  bool laHetHanTuLyDo(DatSan datSan) {
    final lyDo = datSan.lyDoHuy.toLowerCase();

    return lyDo.contains('hết hạn') || lyDo.contains('het han');
  }

  bool laNguoiDungHuyThanhToan(DatSan datSan) {
    final lyDo = datSan.lyDoHuy.toLowerCase();

    return lyDo.contains('nguoi dung huy') ||
        lyDo.contains('người dùng hủy') ||
        lyDo.contains('huy thanh toan') ||
        lyDo.contains('hủy thanh toán');
  }

  double tongTienHienThi(DatSan datSan) {
    if (datSan.thanhTien > 0) return datSan.thanhTien;
    if (datSan.tongTien > 0) return datSan.tongTien;

    return datSan.chiTiet.fold<double>(
      0,
      (sum, item) => sum + item.gia,
    );
  }

  bool daThanhToanDu(DatSan datSan) {
    final tong = tongTienHienThi(datSan);

    if (tong <= 0) return false;

    return datSan.daThanhToan >= tong;
  }

  bool daThanhToanCoc(DatSan datSan) {
    if (datSan.daThanhToan <= 0) return false;

    if (datSan.tienCoc <= 0) return true;

    return datSan.daThanhToan >= datSan.tienCoc;
  }

  List<DatSan> layDanhSachLichSu() {
    final list = tatCaLich
        .where((item) => !danhSachLichSuDaXoa.contains(item.id))
        .toList();

    list.sort((a, b) {
      final ngayA = layNgaySapXep(a) ?? a.ngayTao ?? DateTime(1900);
      final ngayB = layNgaySapXep(b) ?? b.ngayTao ?? DateTime(1900);

      return ngayB.compareTo(ngayA);
    });

    return list;
  }

  Future<void> xoaLichSuDatSan(DatSan datSan) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa lịch sử đặt sân'),
          content: Text(
            'Bạn có chắc muốn xóa đơn #${datSan.id} khỏi lịch sử đặt sân không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    if (!mounted) return;

    setState(() {
      danhSachLichSuDaXoa.add(datSan.id);
    });

    hienThongBao('Đã xóa đơn #${datSan.id} khỏi lịch sử');
  }

  String dinhDangTien(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String dinhDangNgay(DateTime? date) {
    if (date == null) return 'Chưa có ngày';

    final local = date.toLocal();

    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year.toString();

    return '$d/$m/$y';
  }

  String dinhDangNgayGio(DateTime? date) {
    if (date == null) return 'Chưa có';

    final local = date.toLocal();

    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year.toString();
    final h = local.hour.toString().padLeft(2, '0');
    final p = local.minute.toString().padLeft(2, '0');

    return '$d/$m/$y $h:$p';
  }

  Color mauTrangThai(DatSan datSan) {
    if (laDonBiHuy(datSan)) return Colors.red;
    if (laLoiVnPay(datSan)) return Colors.red;
    if (daHetHanGiuCho(datSan)) return Colors.grey;
    if (daQuaGioChoi(datSan)) return Colors.grey;
    if (daThanhToanDu(datSan)) return const Color(0xff2454ff);
    if (daThanhToanCoc(datSan)) return const Color(0xff16a34a);
    if (datSan.trangThai == 0) return Colors.orange;
    if (datSan.trangThai == 1) return const Color(0xff16a34a);

    return Colors.black54;
  }

  String tenTrangThaiDung(DatSan datSan) {
    if (laDonBiHuy(datSan)) {
      if (laHetHanTuLyDo(datSan)) return 'Hết hạn';
      return 'Đã hủy';
    }

    if (laLoiVnPay(datSan)) return 'VNPay lỗi';
    if (daHetHanGiuCho(datSan)) return 'Hết hạn';
    if (daQuaGioChoi(datSan)) return 'Đã qua giờ';
    if (daThanhToanDu(datSan)) return 'Đã thanh toán';
    if (daThanhToanCoc(datSan)) return 'Đã cọc';
    if (datSan.trangThai == 0) return 'Giữ chỗ';
    if (datSan.trangThai == 1) return 'Đã cọc';

    return 'Không rõ';
  }

  String lyDoHienThi(DatSan datSan) {
    final lyDo = datSan.lyDoHuy.trim();

    if (lyDo.isEmpty) return '';

    if (laHetHanTuLyDo(datSan)) {
      return 'Hết hạn giữ chỗ';
    }

    if (laNguoiDungHuyThanhToan(datSan)) {
      return 'Người dùng hủy thanh toán';
    }

    if (laLoiVnPay(datSan)) {
      return 'Thanh toán VNPay thất bại';
    }

    if (laDonBiHuy(datSan)) {
      return 'Đơn đặt sân đã bị hủy';
    }

    return lyDo;
  }

  Widget dongThongTin({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget nutXoaLichSu(DatSan datSan) {
    return TextButton.icon(
      onPressed: () {
        xoaLichSuDatSan(datSan);
      },
      icon: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.red,
        size: 18,
      ),
      label: const Text(
        'Xóa lịch sử',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget cardLichSu(DatSan datSan) {
    final tongTien = tongTienHienThi(datSan);
    final tenTrangThai = tenTrangThaiDung(datSan);
    final mau = mauTrangThai(datSan);
    final lyDo = lyDoHienThi(datSan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: Offset(1, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xffe8ecff),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xff2454ff),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  datSan.tenCoSo.isEmpty
                      ? 'Mã đặt sân #${datSan.id}'
                      : datSan.tenCoSo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: mau.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tenTrangThai,
                  style: TextStyle(
                    color: mau,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          dongThongTin(
            icon: Icons.receipt_long_rounded,
            text: 'Mã đặt sân: #${datSan.id}',
          ),
          const SizedBox(height: 6),
          dongThongTin(
            icon: Icons.calendar_month_rounded,
            text: 'Ngày tạo: ${dinhDangNgayGio(datSan.ngayTao)}',
          ),
          const SizedBox(height: 6),
          dongThongTin(
            icon: Icons.payments_rounded,
            text: 'Tổng tiền: ${dinhDangTien(tongTien)}',
          ),
          const SizedBox(height: 6),
          dongThongTin(
            icon: Icons.account_balance_wallet_rounded,
            text: 'Đã thanh toán: ${dinhDangTien(datSan.daThanhToan)}',
          ),
          if (datSan.tienCoc > 0) ...[
            const SizedBox(height: 6),
            dongThongTin(
              icon: Icons.price_check_rounded,
              text: 'Tiền cọc: ${dinhDangTien(datSan.tienCoc)}',
            ),
          ],
          if (datSan.thoiGianHetHan != null) ...[
            const SizedBox(height: 6),
            dongThongTin(
              icon: Icons.timer_outlined,
              text:
                  'Hết hạn giữ chỗ: ${dinhDangNgayGio(datSan.thoiGianHetHan)}',
            ),
          ],
          if (datSan.chiTiet.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xfff3f8ff),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: datSan.chiTiet.map((ct) {
                  final tenSan =
                      ct.tenSan.isEmpty ? 'Sân ${ct.sanId}' : ct.tenSan;

                  final gio = ct.gioKetThuc.isEmpty
                      ? ct.gioBatDau
                      : '${ct.gioBatDau} - ${ct.gioKetThuc}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '$tenSan • ${dinhDangNgay(ct.ngay)} • $gio',
                      style: const TextStyle(
                        fontSize: 12.4,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (datSan.chiTiet.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xfffff7ed),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'Đơn này chưa có chi tiết sân hoặc backend không trả chi tiết.',
                style: TextStyle(
                  fontSize: 12.4,
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (lyDo.isNotEmpty) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lyDo,
                style: const TextStyle(
                  fontSize: 12.7,
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: nutXoaLichSu(datSan),
          ),
        ],
      ),
    );
  }

  Widget thanhDemSoDon(List<DatSan> danhSach) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 18,
            color: Color(0xff2454ff),
          ),
          const SizedBox(width: 8),
          Text(
            'Tổng ${danhSach.length} đơn đặt sân',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget manHinhChuaDangNhap() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 56,
              color: Color(0xff2454ff),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bạn cần đăng nhập để xem lịch sử đặt sân',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManHinhDangNhap(
                      quayLaiTrangTruoc: true,
                    ),
                  ),
                );
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  Widget noiDungTrang() {
    final daDangNhap = context.watch<XuLiTaiKhoan>().daDangNhap;

    if (!daDangNhap) return manHinhChuaDangNhap();

    if (dangTai) {
      return const HieuUngTai(
        text: 'Đang tải lịch sử đặt sân...',
      );
    }

    if (loi != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            loi!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final danhSach = layDanhSachLichSu();

    if (danhSach.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => taiDuLieu(hienLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: const Center(
                child: Text(
                  'Bạn chưa có lịch sử đặt sân',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        thanhDemSoDon(danhSach),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => taiDuLieu(hienLoading: false),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
              itemCount: danhSach.length,
              itemBuilder: (context, index) {
                return cardLichSu(danhSach[index]);
              },
            ),
          ),
        ),
      ],
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
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Lịch sử đặt sân',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          taiDuLieu(hienLoading: false);
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: noiDungTrang(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}