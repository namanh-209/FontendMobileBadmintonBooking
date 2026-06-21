import 'package:flutter/material.dart';

import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li_api/Co_so_api.dart';
import 'Man_hinh_xem_lich_dat_san.dart';

class ManHinhChiTietSan extends StatefulWidget {
  final CoSo? coSo;
  final CoSo? coSoHienTai;

  const ManHinhChiTietSan({
    super.key,
    this.coSo,
    this.coSoHienTai,
  });

  @override
  State<ManHinhChiTietSan> createState() => _ManHinhChiTietSanState();
}

class _ManHinhChiTietSanState extends State<ManHinhChiTietSan> {
  late CoSo coSoHienTai;
  bool dangXemBangGia = false;
  int anhDangChon = 0;

  @override
  void initState() {
    super.initState();

    coSoHienTai = widget.coSoHienTai ??
        widget.coSo ??
        CoSo(
          id: 0,
          ten: 'Sân cầu lông',
          diaChi: 'Chưa cập nhật địa chỉ',
          moTa: 'Sân cầu lông sạch sẽ, thoáng mát, phù hợp để đặt lịch tập luyện và thi đấu.',
          hinhAnh: '',
          danhGia: 0,
        );

    Future.microtask(taiChiTietCoSo);
  }

  Future<void> taiChiTietCoSo() async {
    if (coSoHienTai.id <= 0) return;

    try {
      final chiTiet = await CoSoApi().layChiTietCoSo(coSoHienTai.id);

      if (!mounted) return;

      setState(() {
        coSoHienTai = chiTiet;
      });
    } catch (_) {
      // Giữ dữ liệu cũ nếu API chi tiết chưa sẵn sàng.
    }
  }

  String layUrlAnh(String duongDanAnh) {
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

  String tenSan() {
    if (coSoHienTai.ten.trim().isNotEmpty) return coSoHienTai.ten.trim();
    if (coSoHienTai.tenCoSo.trim().isNotEmpty) return coSoHienTai.tenCoSo.trim();
    return 'Sân cầu lông của NA';
  }

  String diaChiSan() {
    if (coSoHienTai.diaChi.trim().isNotEmpty) return coSoHienTai.diaChi.trim();
    return 'Bình Tân, TP Hồ Chí Minh';
  }

  String moTaSan() {
    return 'Sân cầu lông trong nhà có mặt sân tốt, ánh sáng rõ, không gian rộng rãi và phù hợp cho luyện tập hoặc thi đấu giao lưu. '
        'Người dùng có thể xem lịch sân, chọn khung giờ trống và đặt sân nhanh ngay trên ứng dụng.';
  }

  void moManHinhLichSan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhXemLichSan(coSo: coSoHienTai),
      ),
    );
  }

  Widget nenTrang() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffd9ecff),
              Color(0xfff7fbff),
              Color(0xffd7ecff),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -45,
              right: -45,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.38),
                ),
              ),
            ),
            Positioned(
              top: 72,
              left: -70,
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff73b7ff).withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: 130,
              right: -72,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff73b7ff).withOpacity(0.18),
                ),
              ),
            ),
            Positioned(
              top: 22,
              right: 18,
              child: Transform.rotate(
                angle: -0.55,
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 76,
                  color: Colors.white.withOpacity(0.78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nutBack() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 18,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(20),
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget tieuDeTrang() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 14,
      left: 70,
      right: 70,
      child: const Text(
        'Chi tiết sân',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget anhMacDinh() {
    return Container(
      width: double.infinity,
      height: 145,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffdbeafe), Color(0xffbfdbfe)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          color: Color(0xff2454ff),
          size: 46,
        ),
      ),
    );
  }

  Widget anhSan() {
    final urlAnh = layUrlAnh(coSoHienTai.hinhAnh);

    return Container(
      height: 145,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            urlAnh.isEmpty
                ? anhMacDinh()
                : Image.network(
                    urlAnh,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => anhMacDinh(),
                  ),
            Positioned(
              right: 10,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  '5 sân',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Positioned(
              bottom: 7,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final dangChon = index == anhDangChon;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: dangChon ? 8 : 6,
                    height: dangChon ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dangChon ? Colors.white : Colors.white.withOpacity(0.48),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget thongTinTenSan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tenSan(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 15, color: Colors.grey.shade600),
            const SizedBox(width: 5),
            Text(
              '5:00 - 22:00',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 18),
            Icon(Icons.location_on_rounded, size: 15, color: Colors.grey.shade600),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                diaChiSan(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xff2454ff), size: 16),
            const SizedBox(width: 5),
            Text(
              coSoHienTai.danhGia > 0
                  ? '${coSoHienTai.danhGia.toStringAsFixed(1)}(297 đánh giá)'
                  : '4,9(297 đánh giá)',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 9),
            Text('•', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(width: 9),
            Text(
              '1,2 Km',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget thanhTab() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      child: Row(
        children: [
          Expanded(
            child: nutTab(
              text: 'Thông tin',
              dangChon: !dangXemBangGia,
              onTap: () => setState(() => dangXemBangGia = false),
            ),
          ),
          Expanded(
            child: nutTab(
              text: 'Bảng giá',
              dangChon: dangXemBangGia,
              onTap: () => setState(() => dangXemBangGia = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget nutTab({required String text, required bool dangChon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: dangChon ? FontWeight.w800 : FontWeight.w500),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: dangChon ? 68 : 0,
            height: 1.5,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(99)),
          ),
        ],
      ),
    );
  }

  Widget cardThongTinSan() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(1, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin sân',
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            moTaSan(),
            style: const TextStyle(color: Colors.black87, fontSize: 12.5, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget bangGia() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1),
      ),
      child: Column(
        children: [
          oBangGia(cells: const ['Khách Hàng'], isHeader: true, height: 38),
          oBangGia(cells: const ['Thứ', 'Khung giờ', 'Cố định', 'Vãng lai'], isHeader: true, height: 36),
          dongGiaGop(
            thu: 'T2 - T6',
            khungGio: const ['6h - 15h', '15h - 18h', '18h - 22h', '22h - 24h'],
            coDinh: const ['40.000 đ', '100.000 đ', '120.000 đ', '90.000 đ'],
            vangLai: const ['40.000 đ', '100.000 đ', '130.000 đ', '100.000 đ'],
          ),
          oBangGia(cells: const ['T7', '5h - 24h', '110.000 đ', '120.000 đ'], height: 42),
          oBangGia(cells: const ['CN', '5h - 24h', '100.000 đ', '110.000 đ'], height: 42),
        ],
      ),
    );
  }

  Widget oBangGia({required List<String> cells, bool isHeader = false, double height = 40}) {
    if (cells.length == 1) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.25), width: 1)),
        ),
        child: Text(
          cells.first,
          style: const TextStyle(color: Color(0xff2f6b55), fontSize: 13, fontWeight: FontWeight.w900),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(cells.length, (index) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: index == cells.length - 1
                      ? BorderSide.none
                      : BorderSide(color: Colors.black.withOpacity(0.22), width: 1),
                  bottom: BorderSide(color: Colors.black.withOpacity(0.22), width: 1),
                ),
              ),
              child: Text(
                cells[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xff3a6f5e),
                  fontSize: isHeader ? 12.5 : 12,
                  fontWeight: isHeader ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget dongGiaGop({required String thu, required List<String> khungGio, required List<String> coDinh, required List<String> vangLai}) {
    return SizedBox(
      height: 164,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.black.withOpacity(0.22), width: 1),
                  bottom: BorderSide(color: Colors.black.withOpacity(0.22), width: 1),
                ),
              ),
              child: Text(
                thu,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xff3a6f5e), fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(khungGio.length, (index) {
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(child: cellGia(khungGio[index])),
                      Expanded(child: cellGia(coDinh[index])),
                      Expanded(child: cellGia(vangLai[index], laCotCuoi: true)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget cellGia(String text, {bool laCotCuoi = false}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: laCotCuoi ? BorderSide.none : BorderSide(color: Colors.black.withOpacity(0.22), width: 1),
          bottom: BorderSide(color: Colors.black.withOpacity(0.16), width: 1),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xff4a7b6c), fontSize: 11.5, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget cardDanhGia() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.13), blurRadius: 7, offset: const Offset(1, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đánh giá', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: Column(
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: '4.9', style: TextStyle(color: Colors.black, fontSize: 27, fontWeight: FontWeight.w900)),
                          TextSpan(text: '/5', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xff2454ff), size: 18)),
                    ),
                    Text('297 lượt đánh giá', style: TextStyle(color: Colors.grey.shade600, fontSize: 9.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(width: 1, height: 78, color: Colors.grey.shade200),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    dongSao(5, 246, 0.92),
                    dongSao(4, 38, 0.42),
                    dongSao(3, 8, 0.15),
                    dongSao(2, 3, 0.07),
                    dongSao(1, 2, 0.04),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          itemDanhGia('Minh Anh', 'Sân đẹp, sạch sẽ, ánh sáng tốt. Nhân viên thân thiện!', '2 ngày trước'),
          itemDanhGia('Khánh', 'Đặt sân dễ dàng, giá hợp lý. Sẽ ủng hộ dài dài!', '3 ngày trước'),
          itemDanhGia('Huy', 'Có nhà tắm sạch sẽ, giờ xe rộng rãi. Rất hài lòng.', '5 ngày trước'),
        ],
      ),
    );
  }

  Widget dongSao(int sao, int soLuong, double tyLe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.2),
      child: Row(
        children: [
          Text('$sao', style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w600)),
          const SizedBox(width: 3),
          const Icon(Icons.star_rounded, color: Color(0xff2454ff), size: 10),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: tyLe,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2454ff)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text('$soLuong', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600, fontSize: 9.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget itemDanhGia(String ten, String noiDung, String thoiGian) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(9, 7, 7, 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xffdbeafe),
            child: Icon(Icons.person, size: 18, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ten, style: const TextStyle(color: Colors.black, fontSize: 10.5, fontWeight: FontWeight.w900)),
                Row(children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xff2454ff), size: 11))),
                Text(
                  noiDung,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 9.8, height: 1.25, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(thoiGian, style: TextStyle(color: Colors.grey.shade500, fontSize: 8.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget vungNoiDung() {
    return Positioned.fill(
      top: MediaQuery.of(context).padding.top + 88,
      bottom: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 205),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            anhSan(),
            const SizedBox(height: 18),
            thongTinTenSan(),
            thanhTab(),
            dangXemBangGia ? bangGia() : cardThongTinSan(),
            if (!dangXemBangGia) cardDanhGia(),
          ],
        ),
      ),
    );
  }

  Widget nutDuoi({required String text, required IconData icon, required bool filled, required VoidCallback onTap}) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: filled ? const Color(0xff2454ff) : Colors.white,
            foregroundColor: filled ? Colors.white : const Color(0xff2454ff),
            elevation: filled ? 2 : 0,
            side: BorderSide(color: const Color(0xff2454ff), width: filled ? 0 : 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            visualDensity: VisualDensity.compact,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 7),
                Text(text, style: const TextStyle(fontSize: 12.2, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget thanhNutDatSan() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 92,
      child: Row(
        children: [
          nutDuoi(text: 'Xem lịch', icon: Icons.calendar_month_rounded, filled: false, onTap: moManHinhLichSan),
          const SizedBox(width: 18),
          nutDuoi(text: 'Đặt sân ngay', icon: Icons.event_available_rounded, filled: true, onTap: moManHinhLichSan),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ThanhDuoi(viTriDangChon: 1),
      body: Stack(
        children: [
          nenTrang(),
          vungNoiDung(),
          nutBack(),
          tieuDeTrang(),
          thanhNutDatSan(),
        ],
      ),
    );
  }
}
