import 'package:flutter/material.dart';

import '../Mau_du_lieu/Thong_bao.dart';
import '../Xu_li_api/Thong_bao_api.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Chung/Duong_dan_anh.dart';
import '../Mau_du_lieu/Co_so.dart';

import 'Man_hinh_lich_su_dat_san.dart';
import 'Man_hinh_chi_tiet_san.dart';
import 'Man_hinh_tai_khoan.dart';
import 'Man_hinh_trang_chu.dart';

class ManHinhThongBao extends StatefulWidget {
  const ManHinhThongBao({super.key});

  @override
  State<ManHinhThongBao> createState() => _ManHinhThongBaoState();
}

class _ManHinhThongBaoState extends State<ManHinhThongBao> {
  late Future<List<ThongBao>> futureThongBao;

  @override
  void initState() {
    super.initState();
    taiThongBao();
  }

  void taiThongBao() {
    futureThongBao = ThongBaoApi.layDanhSachThongBao();
  }

  Future<void> taiLai() async {
    setState(() {
      taiThongBao();
    });
  }

  IconData iconTheoLoai(String? loai) {
    switch (loai?.toUpperCase()) {
      case 'DAT_SAN':
        return Icons.event_available_rounded;
      case 'THANH_TOAN':
        return Icons.payments_rounded;
      case 'CO_SO':
        return Icons.store_rounded;
      case 'DANH_GIA':
        return Icons.star_rounded;
      case 'KHIEU_NAI':
        return Icons.report_problem_rounded;
      case 'HUY_LICH':
        return Icons.cancel_rounded;
      case 'KHUYEN_MAI':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String layThoiGian(String? ngayTao) {
    if (ngayTao == null || ngayTao.isEmpty) return '';

    try {
      final ngay = DateTime.parse(ngayTao).toLocal();
      final now = DateTime.now();
      final diff = now.difference(ngay);

      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      return '${diff.inDays} ngày trước';
    } catch (_) {
      return ngayTao;
    }
  }

  String layTenCoSoTuNoiDung(String noiDung) {
    final regex = RegExp(r'tại\s+"?([^",]+)"?');
    final match = regex.firstMatch(noiDung);

    if (match != null) {
      return match.group(1)?.trim() ?? 'Sân cầu lông';
    }

    return 'Sân cầu lông';
  }

  int layIdTuDuongDan(String duongDan) {
    final regex = RegExp(r'/dat-san/(\d+)');
    final match = regex.firstMatch(duongDan);

    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }

    return 0;
  }

  Future<void> danhDauDaDoc(ThongBao tb) async {
    if (tb.daDoc != 0) return;

    try {
      await ThongBaoApi.danhDauDaDoc(tb.id);
      await taiLai();
    } catch (_) {}
  }

 Future<void> bamThongBao(ThongBao tb) async {
  await danhDauDaDoc(tb);

  if (!mounted) return;

  final duongDan = tb.duongDan.trim();
  final tieuDe = tb.tieuDe.toLowerCase();
  final noiDung = tb.noiDung.toLowerCase();
  final loai = tb.loaiThongBao.toUpperCase();

  // 1. Khách đặt sân thành công / thanh toán / lịch sử đặt sân
  if (duongDan == '/lich-su-dat-san' ||
      tieuDe.contains('đặt sân thành công') ||
      tieuDe.contains('thanh toán') ||
      noiDung.contains('mã đơn') ||
      loai == 'THANH_TOAN') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhLichSuDatSan(),
      ),
    );
    return;
  }

  // 2. Chủ sân có đơn đặt lịch mới
  if (tieuDe.contains('có đơn đặt lịch mới') ||
      tieuDe.contains('đơn đặt lịch mới') ||
      noiDung.contains('vừa có đơn đặt lịch mới')) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhLichSuDatSan(),
      ),
    );
    return;
  }

  // 3. Giữ chỗ hết hạn -> qua trang lịch sân/chi tiết sân
  if (duongDan.startsWith('/dat-san/') ||
      tieuDe.contains('giữ chỗ') ||
      tieuDe.contains('hết hạn giữ chỗ') ||
      tieuDe.contains('hết hạn') ||
      noiDung.contains('đã hết hạn')) {
    final coSoId = layIdTuDuongDan(duongDan);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhChiTietSan(
          coSo: CoSo(
            id: coSoId,
            ten: layTenCoSoTuNoiDung(tb.noiDung),
            diaChi: '',
            moTa: '',
          ),
        ),
      ),
    );

    return;
  }

  // 4. Hủy lịch / hủy sân
  if (tieuDe.contains('hủy') ||
      noiDung.contains('đã hủy') ||
      loai == 'HUY_LICH') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhLichSuDatSan(),
      ),
    );
    return;
  }

  // 5. Đánh giá mới
  if (loai == 'DANH_GIA' ||
      tieuDe.contains('đánh giá') ||
      noiDung.contains('nhận đánh giá')) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhLichSuDatSan(),
      ),
    );
    return;
  }

  // 6. Thông báo cơ sở
  if (loai == 'CO_SO' ||
      tieuDe.contains('cơ sở') ||
      noiDung.contains('cơ sở')) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhTrangChu(),
      ),
    );
    return;
  }

  // 7. Khuyến mãi
  if (loai == 'KHUYEN_MAI' || tieuDe.contains('khuyến mãi')) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhTrangChu(),
      ),
    );
    return;
  }

  // 8. Khiếu nại / tài khoản
  if (loai == 'KHIEU_NAI' ||
      tieuDe.contains('khiếu nại') ||
      noiDung.contains('khiếu nại')) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhTaiKhoan(),
      ),
    );
    return;
  }

  // 9. Nếu không xác định được thì mở lịch sử đặt sân thay vì hiện dialog
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ManHinhLichSuDatSan(),
    ),
  );
}

  Widget nenManHinh() {
    return Positioned.fill(
      child: Image.asset(
        DuongDanAnh.Nen,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget tieuDe() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 30, 22, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xff0f172a),
          ),
        ),
      ),
    );
  }

  Widget thongBaoRong() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe5e7eb)),
        ),
        child: const Text(
          'Chưa có thông báo nào',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget itemThongBao(ThongBao tb, int index) {
    final chuaDoc = tb.daDoc == 0;

    return Material(
      color: chuaDoc ? const Color(0xfff8fafc) : Colors.white,
      child: InkWell(
        onTap: () => bamThongBao(tb),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xffeef4ff),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconTheoLoai(tb.loaiThongBao),
                  color: const Color(0xff2454ff),
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tb.tieuDe,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        color: const Color(0xff0f172a),
                        fontWeight:
                            chuaDoc ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tb.noiDung,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Color(0xff475569),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      layThoiGian(tb.ngayTao),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff94a3b8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (chuaDoc) ...[
                const SizedBox(width: 8),
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xffff3b30),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget danhSachThongBao(List<ThongBao> ds) {
    return RefreshIndicator(
      onRefresh: taiLai,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 105),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xffe5e7eb),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(
                ds.length,
                (index) => itemThongBao(ds[index], index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget noiDung() {
    return Expanded(
      child: FutureBuilder<List<ThongBao>>(
        future: futureThongBao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff2454ff),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Không thể tải thông báo\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ds = snapshot.data ?? [];

          if (ds.isEmpty) return thongBaoRong();

          return danhSachThongBao(ds);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ThanhDuoi(
        viTriDangChon: 3,
      ),
      body: Stack(
        children: [
          nenManHinh(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                tieuDe(),
                noiDung(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}