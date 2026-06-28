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

class ManHinhLichDatSan extends StatefulWidget {
  const ManHinhLichDatSan({super.key});

  @override
  State<ManHinhLichDatSan> createState() => _ManHinhLichDatSanState();
}

class _ManHinhLichDatSanState extends State<ManHinhLichDatSan> {
  final DatSanApi api = DatSanApi();

  bool dangTai = false;
  String? loi;

  List<DatSan> tatCaLich = [];

  final Set<int> danhSachDangHuy = {};
  final Set<int> danhSachDaGuiYeuCauHuy = {};

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
        loi = 'Bạn phải đăng nhập để xem lịch đặt sân';
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
        loi = 'Tải lịch đặt sân quá lâu, vui lòng thử lại';
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

  bool laLichDangDat(DatSan datSan) {
    final biLoiVnPay = laLoiVnPay(datSan);
    final biHuy = laDonBiHuy(datSan);
    final hetHan = daHetHanGiuCho(datSan);
    final quaGio = daQuaGioChoi(datSan);
    final thanhToanDu = daThanhToanDu(datSan);
    final thanhToanCoc = daThanhToanCoc(datSan);

    return !biLoiVnPay &&
        !biHuy &&
        !hetHan &&
        !quaGio &&
        (thanhToanDu ||
            thanhToanCoc ||
            datSan.trangThai == 0 ||
            datSan.trangThai == 1);
  }

  List<DatSan> layDanhSachLichDatSan() {
    final list = tatCaLich.where(laLichDangDat).toList();

    list.sort((a, b) {
      final ngayA = layNgaySapXep(a) ?? a.ngayTao ?? DateTime(1900);
      final ngayB = layNgaySapXep(b) ?? b.ngayTao ?? DateTime(1900);

      return ngayA.compareTo(ngayB);
    });

    return list;
  }

  bool coTheHuyLich(DatSan datSan) {
    if (danhSachDaGuiYeuCauHuy.contains(datSan.id)) return false;
    if (laLoiVnPay(datSan)) return false;
    if (laDonBiHuy(datSan)) return false;
    if (daQuaGioChoi(datSan)) return false;
    if (daHetHanGiuCho(datSan)) return false;

    return datSan.trangThai == 0 || datSan.trangThai == 1;
  }

  Future<String?> hienHopThoaiNhapLyDoHuy(DatSan datSan) async {
    String lyDoDangChon = 'Đổi lịch / đặt nhầm';

    final danhSachLyDo = [
      'Đổi lịch / đặt nhầm',
      'Không còn nhu cầu sử dụng sân',
      'Bận việc cá nhân',
      'Muốn đổi sang khung giờ khác',
      'Lý do khác',
    ];

    final coHoanTien = datSan.daThanhToan > 0;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Hủy lịch đặt sân',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      coHoanTien
                          ? 'Chọn lý do hủy lịch. Vì đơn này đã cọc/thanh toán, hệ thống sẽ tạo yêu cầu hoàn tiền sau khi hủy.'
                          : 'Chọn lý do hủy lịch đặt sân.',
                      style: const TextStyle(
                        fontSize: 12.8,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    if (coHoanTien) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff7ed),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Số tiền đã thanh toán: ${dinhDangTien(datSan.daThanhToan)}\nSau khi hủy sẽ tạo yêu cầu hoàn tiền.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.orange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ...danhSachLyDo.map((lyDo) {
                      return RadioListTile<String>(
                        value: lyDo,
                        groupValue: lyDoDangChon,
                        dense: true,
                        activeColor: const Color(0xff2454ff),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          lyDo,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;

                          setModalState(() {
                            lyDoDangChon = value;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(bottomSheetContext);
                            },
                            child: const Text('Đóng'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                bottomSheetContext,
                                lyDoDangChon,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Xác nhận hủy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> huyLich(DatSan datSan) async {
    if (danhSachDangHuy.contains(datSan.id)) return;

    if (danhSachDaGuiYeuCauHuy.contains(datSan.id)) {
      hienThongBao('Bạn đã gửi yêu cầu hủy/hoàn tiền cho đơn này rồi');
      return;
    }

    if (daQuaGioChoi(datSan)) {
      hienThongBao('Lịch này đã qua giờ chơi, không thể hủy');
      return;
    }

    final lyDo = await hienHopThoaiNhapLyDoHuy(datSan);

    if (lyDo == null || lyDo.trim().isEmpty) return;

    if (!mounted) return;

    setState(() {
      danhSachDangHuy.add(datSan.id);
    });

    try {
      await api
          .huyDatSan(
            datSanId: datSan.id,
            lyDoHuy: lyDo.trim(),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (!mounted) return;

      setState(() {
        danhSachDaGuiYeuCauHuy.add(datSan.id);
      });

      final coHoanTien = datSan.daThanhToan > 0;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Hủy lịch thành công'),
            content: Text(
              coHoanTien
                  ? 'Đơn đặt sân đã được hủy.\n\nHệ thống đã tạo yêu cầu hoàn tiền cho đơn này. Bạn không cần gửi lại yêu cầu nữa.'
                  : 'Đơn đặt sân đã được hủy thành công. Bạn không cần gửi lại yêu cầu nữa.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Đã hiểu'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      setState(() {
        tatCaLich.removeWhere((item) => item.id == datSan.id);
      });

      taiDuLieu(hienLoading: false);
    } on TimeoutException {
      if (!mounted) return;
      hienThongBao('Hủy lịch quá lâu, vui lòng thử lại');
    } catch (e) {
      if (!mounted) return;
      hienThongBao('$e');
    } finally {
      if (mounted) {
        setState(() {
          danhSachDangHuy.remove(datSan.id);
        });
      }
    }
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

  Widget nutHuyLich(DatSan datSan) {
    final dangHuy = danhSachDangHuy.contains(datSan.id);

    return TextButton.icon(
      onPressed: dangHuy
          ? null
          : () {
              huyLich(datSan);
            },
      icon: dangHuy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 18,
            ),
      label: Text(
        dangHuy ? 'Đang hủy...' : 'Hủy lịch',
        style: TextStyle(
          color: dangHuy ? Colors.grey : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget cardLich(DatSan datSan) {
    final tongTien = tongTienHienThi(datSan);
    final tenTrangThai = tenTrangThaiDung(datSan);
    final mau = mauTrangThai(datSan);
    final hienNutHuy = coTheHuyLich(datSan);

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
                  Icons.sports_tennis_rounded,
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
          if (hienNutHuy) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: nutHuyLich(datSan),
            ),
          ],
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
              'Bạn cần đăng nhập để xem lịch đặt sân',
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
        text: 'Đang tải lịch đặt sân...',
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

    final danhSach = layDanhSachLichDatSan();

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
                  'Bạn chưa có lịch đặt sân',
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

    return RefreshIndicator(
      onRefresh: () => taiDuLieu(hienLoading: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        itemCount: danhSach.length,
        itemBuilder: (context, index) {
          return cardLich(danhSach[index]);
        },
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
                          'Lịch đặt sân',
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