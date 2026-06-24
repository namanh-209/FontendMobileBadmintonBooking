import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li_api/Dat_san_api.dart';
import 'Man_hinh_dang_nhap.dart';

class ManHinhXemLichDatSan extends StatefulWidget {
  const ManHinhXemLichDatSan({super.key});

  @override
  State<ManHinhXemLichDatSan> createState() => _ManHinhXemLichDatSanState();
}

class _ManHinhXemLichDatSanState extends State<ManHinhXemLichDatSan> {
  final DatSanApi api = DatSanApi();

  bool dangTai = false;
  String? loi;
  List<DatSan> danhSach = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(taiDuLieu);
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
        if (value != null && '$value'.trim().isNotEmpty) return '$value';
      } catch (_) {}
    }
    return null;
  }

  Future<void> taiDuLieu() async {
    final taiKhoan = context.read<XuLiTaiKhoan>();

    if (!taiKhoan.daDangNhap) {
      setState(() {
        loi = 'Bạn phải đăng nhập để xem lịch đã đặt';
      });
      return;
    }

    GoiApi.ganToken(layTokenTuTaiKhoanXuLy(taiKhoan));

    setState(() {
      dangTai = true;
      loi = null;
    });

    try {
      final data = await api.layLichDatCuaToi();
      if (!mounted) return;
      setState(() {
        danhSach = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loi = '$e';
      });
    }

    if (!mounted) return;
    setState(() {
      dangTai = false;
    });
  }

  String dinhDangTien(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String dinhDangNgay(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Color mauTrangThai(int trangThai) {
    if (trangThai == 0) return Colors.orange;
    if (trangThai == 1) return Colors.blue;
    if (trangThai == 2) return Colors.red;
    if (trangThai == 3) return Colors.grey;
    if (trangThai == 4) return Colors.green;
    return Colors.black54;
  }

  Future<void> huyLich(DatSan datSan) async {
    final controller = TextEditingController();

    final lyDo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hủy lịch đặt sân'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhập lý do hủy',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Xác nhận hủy'),
            ),
          ],
        );
      },
    );

    if (lyDo == null || lyDo.trim().isEmpty) return;

    try {
      await api.huyDatSan(datSanId: datSan.id, lyDoHuy: lyDo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy lịch đặt sân')),
      );
      taiDuLieu();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Widget cardLich(DatSan datSan) {
    final coTheHuy = datSan.trangThai == 0 || datSan.trangThai == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  datSan.tenCoSo.isEmpty ? 'Mã đặt sân #${datSan.id}' : datSan.tenCoSo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: mauTrangThai(datSan.trangThai).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  datSan.tenTrangThai,
                  style: TextStyle(
                    color: mauTrangThai(datSan.trangThai),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ngày tạo: ${dinhDangNgay(datSan.ngayTao)}'),
          Text('Tổng tiền: ${dinhDangTien(datSan.thanhTien > 0 ? datSan.thanhTien : datSan.tongTien)}'),
          Text('Đã thanh toán: ${dinhDangTien(datSan.daThanhToan)}'),
          if (datSan.tienCoc > 0) Text('Tiền cọc: ${dinhDangTien(datSan.tienCoc)}'),
          if (datSan.chiTiet.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...datSan.chiTiet.map(
              (ct) => Text(
                '- ${ct.tenSan.isEmpty ? 'Sân ${ct.sanId}' : ct.tenSan} | ${dinhDangNgay(ct.ngay)} | ${ct.gioBatDau}${ct.gioKetThuc.isEmpty ? '' : ' - ${ct.gioKetThuc}'}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
          if (datSan.lyDoHuy.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Lý do hủy: ${datSan.lyDoHuy}'),
          ],
          if (coTheHuy) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => huyLich(datSan),
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text('Hủy lịch', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daDangNhap = context.watch<XuLiTaiKhoan>().daDangNhap;

    return Scaffold(
      backgroundColor: const Color(0xfff5f9ff),
      appBar: AppBar(
        title: const Text('Lịch đã đặt'),
        backgroundColor: const Color(0xfff5f9ff),
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: taiDuLieu,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: !daDangNhap
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 56, color: Color(0xff2454ff)),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn cần đăng nhập để xem lịch đã đặt',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
                        );
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            )
          : dangTai
              ? const Center(child: CircularProgressIndicator())
              : loi != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(loi!, textAlign: TextAlign.center),
                      ),
                    )
                  : danhSach.isEmpty
                      ? const Center(child: Text('Bạn chưa có lịch đặt sân'))
                      : RefreshIndicator(
                          onRefresh: taiDuLieu,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: danhSach.length,
                            itemBuilder: (context, index) => cardLich(danhSach[index]),
                          ),
                        ),
    );
  }
}
