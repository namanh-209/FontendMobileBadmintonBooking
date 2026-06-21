import 'package:flutter/material.dart';

class VoucherDemo {
  final String ma;
  final String tieuDe;
  final String moTa;
  final double giamTien;
  final double? phanTram;
  final double giamToiDa;
  final Color mauChinh;
  final Color mauNen;

  const VoucherDemo({
    required this.ma,
    required this.tieuDe,
    required this.moTa,
    required this.giamTien,
    this.phanTram,
    this.giamToiDa = 0,
    required this.mauChinh,
    required this.mauNen,
  });

  double tinhGiam(double tongTien) {
    if (phanTram != null) {
      var tienGiam = tongTien * phanTram!;
      if (giamToiDa > 0 && tienGiam > giamToiDa) {
        tienGiam = giamToiDa;
      }
      return tienGiam > tongTien ? tongTien : tienGiam;
    }

    return giamTien > tongTien ? tongTien : giamTien;
  }
}

class ManHinhChonVoucherDemo extends StatefulWidget {
  final List<VoucherDemo> vouchers;
  final VoucherDemo? voucherDangChon;
  final double tongTien;

  const ManHinhChonVoucherDemo({
    super.key,
    required this.vouchers,
    required this.voucherDangChon,
    required this.tongTien,
  });

  @override
  State<ManHinhChonVoucherDemo> createState() => _ManHinhChonVoucherDemoState();
}

class _ManHinhChonVoucherDemoState extends State<ManHinhChonVoucherDemo> {
  late VoucherDemo? voucherDangChon;
  late final TextEditingController maController;

  @override
  void initState() {
    super.initState();
    voucherDangChon = widget.voucherDangChon;
    maController = TextEditingController(text: widget.voucherDangChon?.ma ?? '');
  }

  @override
  void dispose() {
    maController.dispose();
    super.dispose();
  }

  void chonVoucher(VoucherDemo voucher) {
    setState(() {
      voucherDangChon = voucher;
      maController.text = voucher.ma;
    });
  }

  void apDungTheoMa() {
    final ma = maController.text.trim().toUpperCase();

    if (ma.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập hoặc chọn mã giảm giá')),
      );
      return;
    }

    VoucherDemo? timThay;

    for (final item in widget.vouchers) {
      if (item.ma.toUpperCase() == ma) {
        timThay = item;
        break;
      }
    }

    if (timThay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã giảm giá không hợp lệ')),
      );
      return;
    }

    Navigator.pop(context, timThay);
  }

  String dinhDangTien(double gia) {
    final soTien = gia.round().toString();
    final ketQua = soTien.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '${ketQua}đ';
  }

  Widget dauTrang() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 14, 6),
        child: Row(
          children: [
            const SizedBox(width: 36),
            const Expanded(
              child: Text(
                'Mã giảm giá',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(18),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget oNhapMa() {
    return Container(
      height: 58,
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      padding: const EdgeInsets.fromLTRB(16, 9, 12, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.black,
            size: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: maController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                hintText: 'Nhập mã giảm giá',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 36,
            width: 78,
            child: ElevatedButton(
              onPressed: apDungTheoMa,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2454ff),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget hinhVoucher(VoucherDemo voucher) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: voucher.mauNen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: voucher.mauChinh.withOpacity(0.35),
          width: 1.1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Center(
              child: Icon(
                voucher.phanTram != null
                    ? Icons.percent_rounded
                    : Icons.local_offer_rounded,
                color: voucher.mauChinh,
                size: 27,
              ),
            ),
          ),
          Container(
            width: 1,
            height: double.infinity,
            color: voucher.mauChinh.withOpacity(0.22),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 7, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 96),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: voucher.mauChinh,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      voucher.tieuDe,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.8,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.ma,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff2454ff),
                      fontSize: 19,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    voucher.moTa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 8,
                      height: 1,
                      fontWeight: FontWeight.w600,
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

  Widget itemVoucher(VoucherDemo voucher) {
    final dangChon = voucherDangChon?.ma == voucher.ma;

    return InkWell(
      onTap: () => chonVoucher(voucher),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 106,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dangChon ? const Color(0xff2454ff) : Colors.black,
            width: dangChon ? 1.9 : 1.25,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: hinhVoucher(voucher),
            ),
            const SizedBox(width: 14),
            Icon(
              dangChon
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: const Color(0xff2454ff),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget nutApDungDuoi() {
    final text = voucherDangChon == null
        ? 'Áp dụng'
        : 'Áp dụng ${voucherDangChon!.ma}';

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: apDungTheoMa,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2454ff),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              dauTrang(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 88),
                  child: Column(
                    children: [
                      oNhapMa(),
                      ...widget.vouchers.map(itemVoucher),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: nutApDungDuoi(),
          ),
        ],
      ),
    );
  }
}
