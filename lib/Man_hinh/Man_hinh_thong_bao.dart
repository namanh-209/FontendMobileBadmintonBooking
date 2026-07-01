import 'package:flutter/material.dart';

import '../Mau_du_lieu/Thong_bao.dart';
import '../Xu_li_api/Thong_bao_api.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Chung/Duong_dan_anh.dart';

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
    futureThongBao = ThongBaoApi.layDanhSachThongBao();
  }

  Future<void> taiLai() async {
    setState(() {
      futureThongBao = ThongBaoApi.layDanhSachThongBao();
    });
  }

  IconData iconTheoLoai(String? loai)
  {
    switch (loai?.toUpperCase()) {
      case 'DAT_SAN':
        return Icons.sports_tennis_rounded;
      case 'THANH_TOAN':
        return Icons.payments_rounded;
      case 'CO_SO':
        return Icons.store_rounded;
      case 'DANH_GIA':
        return Icons.star_rounded;
      case 'KHIEU_NAI':
        return Icons.report_problem_rounded;
      case 'HUY_LICH':
        return Icons.cancel_schedule_send_rounded;
      case 'KHUYEN_MAI':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Future<void> xuLyBamThongBao(ThongBao tb) async {
    try {
      if (tb.daDoc == 0) {
        await ThongBaoApi.danhDauDaDoc(tb.id);
        await taiLai();
      }
    } catch (_) {}

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tb.tieuDe),
        content: Text(tb.noiDung),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
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
      padding: EdgeInsets.only(top: 42, bottom: 24),
      child: Center(
        child: Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget thongBaoRong() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: Color(0xffe8f1ff),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_rounded,
                size: 48,
                color: Color(0xff2454ff),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có thông báo nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Khi có thông báo mới, chúng tôi sẽ cập nhật cho bạn tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemThongBao(ThongBao tb) {
    final chuaDoc = tb.daDoc == 0;

    return InkWell(
      onTap: () => xuLyBamThongBao(tb),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: chuaDoc
              ? Colors.white.withOpacity(0.98)
              : Colors.white.withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: chuaDoc ? const Color(0xff2454ff) : Colors.white,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: chuaDoc ? const Color(0xffe8f1ff) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconTheoLoai(tb.loaiThongBao),
                color: chuaDoc ? const Color(0xff2454ff) : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tb.tieuDe,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: chuaDoc ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tb.noiDung,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (tb.ngayTao != null && tb.ngayTao!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      tb.ngayTao!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (chuaDoc)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: Color(0xffff3b30),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
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
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'Không thể tải thông báo\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ds = snapshot.data ?? [];

          if (ds.isEmpty) {
            return thongBaoRong();
          }

          return RefreshIndicator(
            onRefresh: taiLai,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 95),
              itemCount: ds.length,
              itemBuilder: (context, index) {
                return itemThongBao(ds[index]);
              },
            ),
          );
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