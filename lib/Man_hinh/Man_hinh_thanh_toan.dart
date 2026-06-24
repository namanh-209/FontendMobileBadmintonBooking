import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Mau_du_lieu/Co_so.dart';
import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li_api/Dat_san_api.dart';
import '../Xu_li_api/Thanh_toan_api.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_vnpay_webview.dart';

class ManHinhThanhToan extends StatefulWidget {
  final DatSan? datSan;
  final CoSo? coSo;
  final List<Map<String, dynamic>>? chiTiet;
  final String ghiChu;

  const ManHinhThanhToan({
    super.key,
    this.datSan,
    this.coSo,
    this.chiTiet,
    this.ghiChu = '',
  });

  @override
  State<ManHinhThanhToan> createState() => _ManHinhThanhToanState();
}

class _ManHinhThanhToanState extends State<ManHinhThanhToan> {
  final DatSanApi datSanApi = DatSanApi();
  final ThanhToanApi thanhToanApi = ThanhToanApi();
  final TextEditingController ghiChuController = TextEditingController();

  DatSan? datSan;

  bool dangTai = false;
  bool dangGuiThanhToan = false;
  bool dangHuy = false;

  String? loi;
  String loaiThanhToan = 'deposit';

  @override
  void initState() {
    super.initState();
    datSan = widget.datSan;
    ghiChuController.text = widget.ghiChu;
    Future.microtask(chuanBiThanhToan);
  }

  @override
  void dispose() {
    ghiChuController.dispose();
    super.dispose();
  }

  Future<void> chuanBiThanhToan() async {
    final taiKhoan = context.read<XuLiTaiKhoan>();

    if (!taiKhoan.daDangNhap) {
      setState(() {
        loi = 'Bạn phải đăng nhập trước khi đặt sân';
      });
      return;
    }

    final token = await taiKhoan.layTokenDangNhap();
    GoiApi.ganToken(token);

    if (datSan != null) return;

    if (widget.coSo == null ||
        widget.chiTiet == null ||
        widget.chiTiet!.isEmpty) {
      setState(() {
        loi = 'Thiếu thông tin đặt sân';
      });
      return;
    }

    setState(() {
      dangTai = true;
      loi = null;
    });

    try {
      final ketQua = await datSanApi.taoDatSan(
        coSoId: widget.coSo!.id,
        chiTiet: widget.chiTiet!,
        ghiChu: ghiChuController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        datSan = ketQua;
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

  String dinhDangThoiGian(DateTime? value) {
    if (value == null) return 'Không có';

    final ngay = value.day.toString().padLeft(2, '0');
    final thang = value.month.toString().padLeft(2, '0');
    final gio = value.hour.toString().padLeft(2, '0');
    final phut = value.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/${value.year} $gio:$phut';
  }

  double tongTien(DatSan ds) {
    if (ds.thanhTien > 0) return ds.thanhTien;
    if (ds.tongTien > 0) return ds.tongTien;

    return ds.chiTiet.fold(
      0,
      (sum, item) => sum + item.gia,
    );
  }

  double tienCoc(DatSan ds) {
    if (ds.tienCoc > 0) return ds.tienCoc;

    final phanTramCoc = widget.coSo?.phanTramCoc ?? 30;
    return (tongTien(ds) * phanTramCoc / 100).roundToDouble();
  }

  double tienCanThanhToan(DatSan ds) {
    if (loaiThanhToan == 'full') return tongTien(ds);
    return tienCoc(ds);
  }

  double tienConLai(DatSan ds) {
    final value = tongTien(ds) - tienCanThanhToan(ds);
    return value < 0 ? 0 : value;
  }

  Future<void> moManHinhVnpay(String paymentUrl) async {
    final ketQua = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhVnpayWebView(
          paymentUrl: paymentUrl,
        ),
      ),
    );

    if (!mounted) return;

    if (ketQua == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công'),
        ),
      );

      Navigator.pop(context, true);
    } else if (ketQua == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã rời màn thanh toán'),
        ),
      );
    }
  }

  Future<void> taoThanhToanVnpay() async {
    final ds = datSan;

    if (ds == null) return;

    setState(() {
      dangGuiThanhToan = true;
    });

    try {
      final paymentUrl = await thanhToanApi.taoLinkThanhToanVnpay(
        datSanId: ds.id,
        loaiThanhToan: loaiThanhToan,
      );

      if (!mounted) return;

      await moManHinhVnpay(paymentUrl);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      dangGuiThanhToan = false;
    });
  }

  Future<void> huyGiuChoVaQuayLai() async {
    final ds = datSan;

    if (ds == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      dangHuy = true;
    });

    try {
      if (ds.coTheHuyGiuCho) {
        await datSanApi.huyGiuCho(ds.id);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      dangHuy = false;
    });
  }

  Widget theTrang({
    required String tieuDe,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: const Color(0xff2454ff),
              ),
              const SizedBox(width: 8),
              Text(
                tieuDe,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget dongThongTin(String trai, String phai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              trai,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              phai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chiTietLich(DatSan ds) {
    if (ds.chiTiet.isEmpty) {
      return const Text(
        'Không có chi tiết khung giờ',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      children: ds.chiTiet.map((item) {
        final tenSan = item.tenSan.isEmpty ? 'Sân ${item.sanId}' : item.tenSan;
        final gio = '${item.gioBatDau} - ${item.gioKetThuc}';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xfff8fafc),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sports_tennis_rounded,
                size: 17,
                color: Color(0xff2454ff),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenSan,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gio,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dinhDangTien(item.gia),
                style: const TextStyle(
                  color: Color(0xff2454ff),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget chonLoaiThanhToan(DatSan ds) {
    Widget luaChon({
      required String value,
      required String tieuDe,
      required String tien,
    }) {
      final dangChon = loaiThanhToan == value;

      return InkWell(
        onTap: () {
          setState(() {
            loaiThanhToan = value;
          });
        },
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dangChon ? const Color(0xffeef4ff) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: dangChon
                  ? const Color(0xff2454ff)
                  : const Color(0xffe2e8f0),
              width: dangChon ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tieuDe,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tien,
                      style: const TextStyle(
                        color: Color(0xff2454ff),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                dangChon ? Icons.radio_button_checked : Icons.radio_button_off,
                color: const Color(0xff2454ff),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        luaChon(
          value: 'deposit',
          tieuDe: 'Thanh toán tiền cọc',
          tien: dinhDangTien(tienCoc(ds)),
        ),
        const SizedBox(height: 10),
        luaChon(
          value: 'full',
          tieuDe: 'Thanh toán toàn bộ',
          tien: dinhDangTien(tongTien(ds)),
        ),
      ],
    );
  }

  Widget noiDung(DatSan ds) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        children: [
          theTrang(
            tieuDe: 'Thông tin giữ chỗ',
            icon: Icons.receipt_long_rounded,
            children: [
              dongThongTin('Mã đặt sân', '#${ds.id}'),
              dongThongTin(
                'Cơ sở',
                ds.tenCoSo.isEmpty
                    ? (widget.coSo?.tenCoSo ?? 'Sân cầu lông')
                    : ds.tenCoSo,
              ),
              dongThongTin('Trạng thái', ds.tenTrangThai),
              dongThongTin('Hết hạn', dinhDangThoiGian(ds.thoiGianHetHan)),
            ],
          ),
          const SizedBox(height: 13),
          theTrang(
            tieuDe: 'Chi tiết lịch đặt',
            icon: Icons.calendar_month_rounded,
            children: [
              chiTietLich(ds),
              const Divider(height: 22),
              dongThongTin('Tổng tiền', dinhDangTien(tongTien(ds))),
              if (ds.tienGiam > 0)
                dongThongTin(
                  'Khuyến mãi',
                  '-${dinhDangTien(ds.tienGiam)}',
                ),
              dongThongTin('Thành tiền', dinhDangTien(tongTien(ds))),
            ],
          ),
          const SizedBox(height: 13),
          theTrang(
            tieuDe: 'Ghi chú',
            icon: Icons.note_alt_outlined,
            children: [
              TextField(
                controller: ghiChuController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ghi chú cho cơ sở nếu có',
                  filled: true,
                  fillColor: const Color(0xfff8fafc),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          theTrang(
            tieuDe: 'Phương thức thanh toán',
            icon: Icons.account_balance_wallet_rounded,
            children: [
              chonLoaiThanhToan(ds),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    dongThongTin(
                      'Cần thanh toán',
                      dinhDangTien(tienCanThanhToan(ds)),
                    ),
                    dongThongTin(
                      'Còn lại',
                      dinhDangTien(tienConLai(ds)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget thanhDuoi(DatSan ds) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xffe2e8f0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 45,
              child: OutlinedButton(
                onPressed:
                    dangHuy || dangGuiThanhToan ? null : huyGiuChoVaQuayLai,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(
                    color: Color(0xffcbd5e1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: dangHuy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Hủy',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: ElevatedButton.icon(
                  onPressed:
                      dangGuiThanhToan || dangHuy ? null : taoThanhToanVnpay,
                  icon: dangGuiThanhToan
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.credit_card_rounded,
                          size: 18,
                        ),
                  label: Text(
                    dangGuiThanhToan
                        ? 'Đang mở VNPay'
                        : loaiThanhToan == 'full'
                            ? 'Thanh toán toàn bộ'
                            : 'Thanh toán cọc',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2454ff),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daDangNhap = context.watch<XuLiTaiKhoan>().daDangNhap;
    final ds = datSan;

    return Scaffold(
      backgroundColor: const Color(0xfff5f9ff),
      appBar: AppBar(
        title: const Text(
          'Xác nhận đặt sân',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color(0xfff5f9ff),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed:
              dangGuiThanhToan || dangHuy ? null : huyGiuChoVaQuayLai,
          icon: const Icon(
            Icons.chevron_left_rounded,
          ),
        ),
      ),
      body: !daDangNhap
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 54,
                      color: Color(0xff2454ff),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn cần đăng nhập để thanh toán giữ chỗ',
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
                            builder: (_) => const ManHinhDangNhap(),
                          ),
                        );
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            )
          : dangTai
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : loi != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          loi!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : ds == null
                      ? const Center(
                          child: Text('Không có dữ liệu đặt sân'),
                        )
                      : noiDung(ds),
      bottomNavigationBar: daDangNhap && ds != null ? thanhDuoi(ds) : null,
    );
  }
}