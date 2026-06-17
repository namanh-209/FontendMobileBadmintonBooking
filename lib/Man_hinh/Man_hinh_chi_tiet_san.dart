import 'package:flutter/material.dart';

import '../Dung_lai/Hieu_ung_chuyen_trang.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li_api/Co_so_api.dart';
import 'Man_hinh_xem_lich_dat_san.dart';

class ManHinhChiTietSan extends StatefulWidget {
  final dynamic san;
  final dynamic coSo;
  final dynamic coSoHienTai;
  final int? coSoId;

  const ManHinhChiTietSan({
    super.key,
    this.san,
    this.coSo,
    this.coSoHienTai,
    this.coSoId,
  });

  @override
  State<ManHinhChiTietSan> createState() => _ManHinhChiTietSanState();
}

class _ManHinhChiTietSanState extends State<ManHinhChiTietSan> {
  late CoSo coSoHienTai;

  int tabDangChon = 0;
  bool daLayRoute = false;

  @override
  void initState() {
    super.initState();

    coSoHienTai = _taoCoSoTuDuLieu(
      widget.coSoHienTai ?? widget.coSo ?? widget.san,
    );

    if (coSoHienTai.id == 0 && widget.coSoId != null) {
      coSoHienTai = CoSo(
        id: widget.coSoId!,
        ten: 'Sân cầu lông',
        diaChi: 'Chưa cập nhật địa chỉ',
        moTa: 'Sân cầu lông sạch sẽ, thoáng mát, phù hợp để đặt lịch.',
      );
    }

    Future.microtask(_taiChiTietCoSo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (daLayRoute) return;
    daLayRoute = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null &&
        widget.coSo == null &&
        widget.san == null &&
        widget.coSoHienTai == null) {
      coSoHienTai = _taoCoSoTuDuLieu(args);
      Future.microtask(_taiChiTietCoSo);
    }
  }

  CoSo _taoCoSoTuDuLieu(dynamic data) {
    if (data is CoSo) return data;

    if (data is Map<String, dynamic>) {
      return CoSo.fromJson(data);
    }

    if (data is Map) {
      return CoSo.fromJson(Map<String, dynamic>.from(data));
    }

    try {
      final json = data.toJson();

      if (json is Map<String, dynamic>) {
        return CoSo.fromJson(json);
      }

      if (json is Map) {
        return CoSo.fromJson(Map<String, dynamic>.from(json));
      }
    } catch (_) {}

    return CoSo(
      id: 0,
      ten: 'Sân cầu lông của NA',
      diaChi: 'Bình Tân, TP Hồ Chí Minh',
      moTa:
          'Sân cầu lông trong nhà với 5 sân tiêu chuẩn, mặt sân chất lượng cao, ánh sáng đầy đủ, không gian rộng rãi và thoáng mát.',
      hinhAnh: '',
      danhGia: 0,
      giaThapNhat: 120000,
      soLuongSan: 5,
    );
  }

  Future<void> _taiChiTietCoSo() async {
    if (coSoHienTai.id <= 0) return;

    try {
      final chiTiet = await CoSoApi().layChiTietCoSo(coSoHienTai.id);

      if (!mounted) return;

      setState(() {
        coSoHienTai = chiTiet;
      });
    } catch (_) {
      // Nếu API chi tiết lỗi thì vẫn giữ dữ liệu đã truyền từ trang trước.
    }
  }

  String _formatGia(double gia) {
    if (gia <= 0) return '120.000';

    return gia.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
  }

  String get _tenSan {
    if (coSoHienTai.tenCoSo.trim().isNotEmpty) return coSoHienTai.tenCoSo;
    if (coSoHienTai.ten.trim().isNotEmpty) return coSoHienTai.ten;
    return 'Sân cầu lông của NA';
  }

  String get _diaChi {
    if (coSoHienTai.diaChi.trim().isNotEmpty) return coSoHienTai.diaChi;
    return 'Bình Tân, TP Hồ Chí Minh';
  }

  String get _moTa {
    if (coSoHienTai.moTa.trim().isNotEmpty) return coSoHienTai.moTa;

    return 'Sân cầu lông trong nhà với 5 sân tiêu chuẩn, mặt sân chất lượng cao, ánh sáng đầy đủ, không gian rộng rãi và thoáng mát. Sân phù hợp cho luyện tập, thi đấu giao lưu và đặt lịch chơi theo nhóm. Hỗ trợ đặt sân nhanh, thanh toán tiện lợi và có đầy đủ tiện ích đi kèm.';
  }

  String get _gia {
    return _formatGia(coSoHienTai.giaThapNhat);
  }

  int get _soLuongSan {
    if (coSoHienTai.soLuongSan > 0) return coSoHienTai.soLuongSan;
    return 5;
  }

  double get _danhGia {
    if (coSoHienTai.danhGia > 0) return coSoHienTai.danhGia;
    return 4.9;
  }

  void _moXemLich() {
    Navigator.push(
      context,
      HieuUngChuyenTrang(
        manHinh: ManHinhXemLichSan(
          coSo: coSoHienTai,
        ),
      ),
    );
  }

  void _moDatSan() {
    Navigator.push(
      context,
      HieuUngChuyenTrang(
        manHinh: ManHinhXemLichSan(
          coSo: coSoHienTai,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf5ff),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/nen.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffd8ecff),
                        Color(0xfff7fbff),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _tieuDe(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 106),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _anhSan(),
                        const SizedBox(height: 14),
                        _thongTinCoBan(),
                        const SizedBox(height: 10),
                        _tabThongTin(),
                        const SizedBox(height: 12),
                        if (tabDangChon == 0) _noiDungThongTin(),
                        if (tabDangChon == 1) _bangGia(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _nutDuoi(),
          const ThanhDuoi(
            viTriDangChon: 0,
          ),
        ],
      ),
    );
  }

  Widget _tieuDe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: Colors.black,
            ),
          ),
          const Expanded(
            child: Text(
              'Chi tiết sân',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _anhSan() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          coSoHienTai.hinhAnh.isEmpty
              ? _anhMacDinh()
              : Image.network(
                  coSoHienTai.hinhAnh,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _anhMacDinh();
                  },
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == 1 ? 8 : 6,
                  height: index == 1 ? 8 : 6,
                  decoration: BoxDecoration(
                    color: index == 1
                        ? Colors.white
                        : Colors.white.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$_soLuongSan sân',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _anhMacDinh() {
    return Image.asset(
      'assets/images/banner1.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xffbde1ff),
          child: const Icon(
            Icons.sports_tennis_rounded,
            size: 60,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _thongTinCoBan() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tenSan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '5:00 - 22:00',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on_rounded,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _diaChi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xff2457ff),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_danhGia.toStringAsFixed(1)}(297 đánh giá)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '1,2 Km',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xff2457ff),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xffeef4ff),
          ),
          child: Column(
            children: [
              const Text(
                'Chỉ từ',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2457ff),
                ),
              ),
              Text(
                '$_giađ/giờ',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2457ff),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabThongTin() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                tabDangChon = 0;
              });
            },
            child: Column(
              children: [
                Text(
                  'Thông tin',
                  style: TextStyle(
                    fontSize: 10,
                    color: tabDangChon == 0 ? Colors.black : Colors.black54,
                    fontWeight:
                        tabDangChon == 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 70,
                  height: 1,
                  color: tabDangChon == 0 ? Colors.black : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                tabDangChon = 1;
              });
            },
            child: Column(
              children: [
                Text(
                  'Bảng giá',
                  style: TextStyle(
                    fontSize: 10,
                    color: tabDangChon == 1 ? Colors.black : Colors.black54,
                    fontWeight:
                        tabDangChon == 1 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 70,
                  height: 1,
                  color: tabDangChon == 1 ? Colors.black : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _noiDungThongTin() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: _trangTriThe(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin sân',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                _moTa,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.35,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _danhGiaWidget(),
      ],
    );
  }

  Widget _danhGiaWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: _trangTriThe(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Text(
                      '${_danhGia.toStringAsFixed(1)}/5',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (_) => const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xff2457ff),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '297 lượt đánh giá',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _dongSao('5', 246, 0.92),
                    _dongSao('4', 38, 0.42),
                    _dongSao('3', 8, 0.18),
                    _dongSao('2', 3, 0.08),
                    _dongSao('1', 2, 0.04),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _binhLuan(
            ten: 'Minh Anh',
            noiDung: 'Sân đẹp, sạch sẽ, ánh sáng tốt. Nhân viên thân thiện!',
            thoiGian: '2 ngày trước',
          ),
          _binhLuan(
            ten: 'Khánh',
            noiDung: 'Đặt sân dễ dàng, giá hợp lý. Sẽ ủng hộ dài dài.',
            thoiGian: '3 ngày trước',
          ),
          _binhLuan(
            ten: 'Huy',
            noiDung: 'Có nhiều sân sạch sẽ, giờ cao điểm khá đông.',
            thoiGian: '5 ngày trước',
          ),
        ],
      ),
    );
  }

  Widget _dongSao(String sao, int soLuong, double tiLe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text(
            sao,
            style: const TextStyle(fontSize: 8),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.star_rounded,
            size: 8,
            color: Color(0xff2457ff),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: tiLe,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xff2457ff),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 20,
            child: Text(
              '$soLuong',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _binhLuan({
    required String ten,
    required String noiDung,
    required String thoiGian,
  }) {
    final chuDau = ten.isNotEmpty ? ten.substring(0, 1) : '?';

    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xffd9ecff),
            child: Text(
              chuDau,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xff2457ff),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ten,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      thoiGian,
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.more_vert_rounded,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: List.generate(
                    5,
                    (_) => const Icon(
                      Icons.star_rounded,
                      size: 9,
                      color: Color(0xff2457ff),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  noiDung,
                  style: const TextStyle(
                    fontSize: 8,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangGia() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        border: Border.all(
          color: const Color(0xff8fb8a6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.all(
          color: const Color(0xff8fb8a6),
          width: 0.8,
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(1.25),
          2: FlexColumnWidth(1.15),
          3: FlexColumnWidth(1.15),
        },
        children: [
          TableRow(
            children: [
              _oBang('Khách Hàng', dam: true, cao: 38),
              _oBang('', cao: 38),
              _oBang('', cao: 38),
              _oBang('', cao: 38),
            ],
          ),
          TableRow(
            children: [
              _oBang('Thứ', dam: true),
              _oBang('Khung giờ', dam: true),
              _oBang('Cố định', dam: true),
              _oBang('Vãng lai', dam: true),
            ],
          ),
          TableRow(
            children: [
              _oBang('T2 - T6', dam: true, cao: 44),
              _oBang('6h - 15h'),
              _oBang('40.000 đ'),
              _oBang('40.000 đ'),
            ],
          ),
          TableRow(
            children: [
              _oBang('', cao: 36),
              _oBang('15h - 18h'),
              _oBang('100.000 đ'),
              _oBang('100.000 đ'),
            ],
          ),
          TableRow(
            children: [
              _oBang('', cao: 36),
              _oBang('18h - 22h'),
              _oBang('120.000 đ'),
              _oBang('130.000 đ'),
            ],
          ),
          TableRow(
            children: [
              _oBang('', cao: 36),
              _oBang('22h - 24h'),
              _oBang('90.000 đ'),
              _oBang('100.000 đ'),
            ],
          ),
          TableRow(
            children: [
              _oBang('T7', dam: true),
              _oBang('5h - 24h'),
              _oBang('110.000 đ'),
              _oBang('120.000 đ'),
            ],
          ),
          TableRow(
            children: [
              _oBang('CN', dam: true),
              _oBang('5h - 24h'),
              _oBang('100.000 đ'),
              _oBang('110.000 đ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _oBang(
    String text, {
    bool dam = false,
    double cao = 36,
  }) {
    return Container(
      height: cao,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: const Color(0xff2a6a56),
          fontWeight: dam ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _nutDuoi() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      color: Colors.white.withOpacity(0.75),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: _moXemLich,
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Xem lịch',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff2457ff),
                  side: const BorderSide(
                    color: Color(0xff2457ff),
                    width: 1.2,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _moDatSan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2457ff),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xff2457ff).withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text(
                  'Đặt sân ngay',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _trangTriThe() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 7,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}