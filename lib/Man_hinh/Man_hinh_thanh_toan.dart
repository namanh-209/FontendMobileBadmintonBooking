import 'package:flutter/material.dart';

import '../Mau_du_lieu/Co_so.dart';
import 'Man_hinh_chon_voucher.dart';

String layUrlAnhSanThanhToan(String duongDanAnh) {
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

String dinhDangTienThanhToan(double gia) {
  final soTien = gia.round().toString();
  final ketQua = soTien.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '${ketQua}đ';
}

String layTenCoSoThanhToan(CoSo coSo) {
  if (coSo.tenCoSo.trim().isNotEmpty) return coSo.tenCoSo.trim();
  if (coSo.ten.trim().isNotEmpty) return coSo.ten.trim();
  return 'Sân cầu lông của NA';
}

String layDiaChiCoSoThanhToan(CoSo coSo) {
  if (coSo.diaChi.trim().isNotEmpty) return coSo.diaChi.trim();
  return 'Bình Tân, TP Hồ Chí Minh';
}

class ManHinhThanhToanDemo extends StatefulWidget {
  final CoSo coSo;
  final String ngayChoi;
  final String khungGio;
  final String sanDaChon;
  final int soO;
  final double tongTien;
  final double giaTheoGio;

  const ManHinhThanhToanDemo({
    super.key,
    required this.coSo,
    required this.ngayChoi,
    required this.khungGio,
    required this.sanDaChon,
    required this.soO,
    required this.tongTien,
    required this.giaTheoGio,
  });

  @override
  State<ManHinhThanhToanDemo> createState() => _ManHinhThanhToanDemoState();
}

class _ManHinhThanhToanDemoState extends State<ManHinhThanhToanDemo> {
  final TextEditingController tenController = TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController sdtController = TextEditingController(text: '0912345678');

  String phuongThuc = 'VNPAY';
  VoucherDemo? voucherDangChon;
  bool dangThanhToan = false;

  final List<VoucherDemo> vouchers = const [
    VoucherDemo(
      ma: 'NEW30',
      tieuDe: 'Giảm 30.000đ',
      moTa: 'Đơn tối thiểu 200.000đ',
      giamTien: 30000,
      mauChinh: Color(0xff8b5cf6),
      mauNen: Color(0xfff3edff),
    ),
    VoucherDemo(
      ma: 'NA50K',
      tieuDe: 'Giảm 50.000đ',
      moTa: 'Đơn tối thiểu 300.000đ',
      giamTien: 50000,
      mauChinh: Color(0xff3b82f6),
      mauNen: Color(0xffe8f1ff),
    ),
    VoucherDemo(
      ma: 'ABC10',
      tieuDe: 'Giảm 10%',
      moTa: 'Tối đa 30.000đ',
      giamTien: 0,
      phanTram: 0.1,
      giamToiDa: 30000,
      mauChinh: Color(0xff8b5cf6),
      mauNen: Color(0xfff7f0ff),
    ),
  ];

  @override
  void dispose() {
    tenController.dispose();
    sdtController.dispose();
    super.dispose();
  }

  double get tienGiam {
    final voucher = voucherDangChon;
    if (voucher == null) return 0;
    return voucher.tinhGiam(widget.tongTien);
  }

  double get thanhTien {
    final conLai = widget.tongTien - tienGiam;
    return conLai < 0 ? 0 : conLai;
  }

  void chonVoucher() async {
    final voucher = await Navigator.push<VoucherDemo>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ManHinhChonVoucherDemo(
          vouchers: vouchers,
          voucherDangChon: voucherDangChon,
          tongTien: widget.tongTien,
        ),
      ),
    );

    if (voucher == null) return;

    setState(() {
      voucherDangChon = voucher;
    });
  }

  void thanhToan() async {
    if (tenController.text.trim().isEmpty || sdtController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập đủ thông tin liên hệ')),
      );
      return;
    }

    setState(() {
      dangThanhToan = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      dangThanhToan = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhDatSanThanhCong(
          tenCoSo: layTenCoSoThanhToan(widget.coSo),
          ngayChoi: widget.ngayChoi,
          khungGio: widget.khungGio,
          sanDaChon: widget.sanDaChon,
          thoiLuong: '${widget.soO * 30} phút',
          maGiamGia: voucherDangChon?.ma ?? 'Không có',
          tongTien: thanhTien,
          phuongThuc: phuongThuc,
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
            left: -40,
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
            top: 40,
            right: 16,
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

  Widget dauTrang() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Colors.black),
            ),
          ),
          const Expanded(
            child: Text(
              'Thanh toán',
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
    );
  }

  Widget anhCoSo() {
    final url = layUrlAnhSanThanhToan(widget.coSo.hinhAnh);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: url.isEmpty
          ? Container(
              color: const Color(0xffdbeafe),
              child: const Icon(Icons.sports_tennis_rounded, color: Color(0xff2454ff)),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xffdbeafe),
                  child: const Icon(Icons.sports_tennis_rounded, color: Color(0xff2454ff)),
                );
              },
            ),
    );
  }

  Widget cardSanDauTrang() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 8, 26, 8),
      child: Row(
        children: [
          SizedBox(width: 105, height: 82, child: anhCoSo()),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layTenCoSoThanhToan(widget.coSo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xff2454ff), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '4,9 (297 đánh giá)',
                      style: TextStyle(color: Color(0xff64748b), fontSize: 9.5, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '1,2 Km',
                      style: TextStyle(color: Color(0xff64748b), fontSize: 9.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xff64748b), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        layDiaChiCoSoThanhToan(widget.coSo),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xff64748b), fontSize: 9.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dongThongTin({
    required IconData icon,
    required String label,
    required String value,
    bool pill = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black, size: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              pill
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff2454ff),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            value,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Color(0xff2454ff), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
            ],
          ),
          const SizedBox(height: 7),
          Container(height: 1, color: Colors.black.withOpacity(0.42)),
        ],
      ),
    );
  }

  Widget oLienHe({required TextEditingController controller, required IconData icon}) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(left: 22, right: 22, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: Colors.black),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 10),
        ),
      ),
    );
  }

  Widget cardThongTinDatSan() {
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 26, 0),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 9,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          dongThongTin(icon: Icons.calendar_month_rounded, label: 'Ngày chơi', value: widget.ngayChoi),
          dongThongTin(icon: Icons.access_time_rounded, label: 'Khung giờ', value: widget.khungGio),
          dongThongTin(icon: Icons.stadium_rounded, label: 'Chọn sân', value: widget.sanDaChon, pill: true),
          dongThongTin(icon: Icons.timer_outlined, label: 'Thời lượng', value: '${widget.soO * 30} phút', pill: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded, color: Colors.black, size: 19),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Thông tin liên hệ',
                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          oLienHe(controller: tenController, icon: Icons.person_outline_rounded),
          oLienHe(controller: sdtController, icon: Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget itemPhuongThuc({required String value, required IconData icon, required String title}) {
    final dangChon = phuongThuc == value;

    return InkWell(
      onTap: () {
        setState(() {
          phuongThuc = value;
        });
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.35),
              width: value == 'NGAN_HANG' ? 0 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(dangChon ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: const Color(0xff2454ff), size: 18),
            const SizedBox(width: 22),
            Icon(icon, color: Colors.black, size: 18),
            const SizedBox(width: 9),
            Text(
              title,
              style: TextStyle(color: dangChon ? const Color(0xff2454ff) : Colors.black, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardPhuongThuc() {
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 8, offset: const Offset(1, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.45), width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Column(
              children: [
                itemPhuongThuc(value: 'VNPAY', icon: Icons.account_balance_wallet_outlined, title: 'Ví điện tử'),
                itemPhuongThuc(value: 'NGAN_HANG', icon: Icons.credit_card_rounded, title: 'Ngân hàng'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Demo giao diện, chưa thanh toán thật.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget cardVoucher() {
    return InkWell(
      onTap: chonVoucher,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.fromLTRB(26, 14, 26, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 8, offset: const Offset(1, 3)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined, color: Colors.black, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Voucher/Mã giảm giá', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(
                    voucherDangChon == null ? 'Chọn hoặc nhập mã giảm giá' : 'Đã chọn mã ${voucherDangChon!.ma}',
                    style: TextStyle(color: voucherDangChon == null ? Colors.grey.shade500 : const Color(0xff16a34a), fontSize: 10.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 24),
          ],
        ),
      ),
    );
  }

  Widget dongTongKet(String label, String value, {Color? mau, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: bold ? 13 : 12, fontWeight: bold ? FontWeight.w900 : FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: mau ?? Colors.black, fontSize: bold ? 14 : 12, fontWeight: bold ? FontWeight.w900 : FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget cardTongTien() {
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 16, 26, 0),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 8, offset: const Offset(1, 3)),
        ],
      ),
      child: Column(
        children: [
          dongTongKet('Thời lượng', '${widget.soO * 30} phút'),
          dongTongKet('Giá sân', '${dinhDangTienThanhToan(widget.giaTheoGio)}/giờ'),
          dongTongKet('Giảm giá', '-${dinhDangTienThanhToan(tienGiam)}', mau: const Color(0xff16a34a)),
          const SizedBox(height: 4),
          Container(height: 1, color: Colors.black.withOpacity(0.5)),
          dongTongKet('Tổng tiền', dinhDangTienThanhToan(thanhTien), mau: const Color(0xff2454ff), bold: true),
        ],
      ),
    );
  }

  Widget nutThanhToan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 30),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: dangThanhToan ? null : thanhToan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2454ff),
            disabledBackgroundColor: const Color(0xff93c5fd),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
          child: dangThanhToan
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
              : const Text('Thanh toán', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf6ff),
      body: nenTrang(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                dauTrang(),
                cardSanDauTrang(),
                cardThongTinDatSan(),
                cardPhuongThuc(),
                cardVoucher(),
                cardTongTien(),
                nutThanhToan(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManHinhDatSanThanhCong extends StatelessWidget {
  final String tenCoSo;
  final String ngayChoi;
  final String khungGio;
  final String sanDaChon;
  final String thoiLuong;
  final String maGiamGia;
  final double tongTien;
  final String phuongThuc;

  const ManHinhDatSanThanhCong({
    super.key,
    required this.tenCoSo,
    required this.ngayChoi,
    required this.khungGio,
    required this.sanDaChon,
    required this.thoiLuong,
    required this.maGiamGia,
    required this.tongTien,
    required this.phuongThuc,
  });

  Widget dongThongTin({required IconData icon, required String label, required String value, Color? mauChu}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff2454ff), size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: mauChu ?? const Color(0xff2454ff), fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget nut({required String text, required IconData icon, required bool filled, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? const Color(0xff2454ff) : Colors.white,
          foregroundColor: filled ? Colors.white : const Color(0xff2454ff),
          elevation: 0,
          side: filled ? BorderSide.none : const BorderSide(color: Color(0xff2454ff), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf6ff),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffd9ecff), Color(0xfff9fcff), Color(0xffdff2ff)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Đặt sân thành công',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 38),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xff22c55e), size: 58),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Đặt sân thành công!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff2454ff), fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã đặt sân thành công, chúc bạn có buổi chơi thật vui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.35, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(1, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin đặt sân', style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      dongThongTin(icon: Icons.home_work_rounded, label: 'Tên sân', value: tenCoSo, mauChu: Colors.black87),
                      dongThongTin(icon: Icons.calendar_month_rounded, label: 'Ngày chơi', value: ngayChoi),
                      dongThongTin(icon: Icons.access_time_rounded, label: 'Khung giờ', value: khungGio),
                      dongThongTin(icon: Icons.stadium_rounded, label: 'Sân', value: sanDaChon),
                      dongThongTin(icon: Icons.timer_outlined, label: 'Thời lượng', value: thoiLuong),
                      dongThongTin(icon: Icons.confirmation_number_outlined, label: 'Mã giảm giá', value: maGiamGia),
                      dongThongTin(icon: Icons.wallet_rounded, label: 'Thanh toán', value: phuongThuc == 'VNPAY' ? 'Ví điện tử' : 'Ngân hàng', mauChu: const Color(0xff16a34a)),
                      dongThongTin(icon: Icons.paid_rounded, label: 'Tổng tiền', value: dinhDangTienThanhToan(tongTien)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                nut(text: 'Xem lịch đã đặt', icon: Icons.calendar_month_rounded, filled: true, onTap: () => Navigator.pop(context)),
                const SizedBox(height: 12),
                nut(text: 'Về trang chủ', icon: Icons.home_rounded, filled: false, onTap: () => Navigator.popUntil(context, (route) => route.isFirst)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
