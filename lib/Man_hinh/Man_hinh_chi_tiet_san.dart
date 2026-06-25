import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_api.dart';
import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Server/Goi_api.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li_api/Co_so_api.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_thanh_toan.dart';

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

class _KhungGioLich {
  final int id;
  final String batDau;
  final String ketThuc;

  const _KhungGioLich({
    required this.id,
    required this.batDau,
    required this.ketThuc,
  });

  factory _KhungGioLich.fromJson(Map<String, dynamic> json) {
    return _KhungGioLich(
      id: _intTuJson(
        json['id'] ?? json['khung_gio_mau_id'] ?? json['khungGioMauId'],
      ),
      batDau: _catGio(
        json['gio_bat_dau'] ?? json['bat_dau'] ?? json['gioBatDau'],
      ),
      ketThuc: _catGio(
        json['gio_ket_thuc'] ?? json['ket_thuc'] ?? json['gioKetThuc'],
      ),
    );
  }
}

class _SlotLich {
  final int sanId;
  final int khungGioMauId;
  final String batDau;
  final String ketThuc;
  final String trangThai;
  final double gia;

  const _SlotLich({
    required this.sanId,
    required this.khungGioMauId,
    required this.batDau,
    required this.ketThuc,
    required this.trangThai,
    required this.gia,
  });

  factory _SlotLich.fromJson(Map<String, dynamic> json, int sanId) {
    return _SlotLich(
      sanId: _intTuJson(json['san_id'] ?? json['sanId'] ?? sanId),
      khungGioMauId: _intTuJson(
        json['khung_gio_mau_id'] ?? json['khungGioMauId'] ?? json['id'],
      ),
      batDau: _catGio(
        json['gio_bat_dau'] ?? json['bat_dau'] ?? json['gioBatDau'],
      ),
      ketThuc: _catGio(
        json['gio_ket_thuc'] ?? json['ket_thuc'] ?? json['gioKetThuc'],
      ),
      trangThai: '${json['trang_thai'] ?? json['trangThai'] ?? 'trong'}',
      gia: _doubleTuJson(
        json['gia'] ?? json['gia_hien_tai'] ?? json['price'],
      ),
    );
  }

  bool get coTheChon => trangThai == 'trong';
}

class _SanLich {
  final int id;
  final String ten;
  final String tenDanhMuc;
  final List<_SlotLich> slots;

  const _SanLich({
    required this.id,
    required this.ten,
    required this.tenDanhMuc,
    required this.slots,
  });

  factory _SanLich.fromJson(Map<String, dynamic> json) {
    final id = _intTuJson(
      json['id'] ?? json['san_id'] ?? json['sanId'],
    );

    final rawSlots = _layMang(
      json,
      const ['slots', 'lich', 'khung_gio', 'khungGio'],
    );

    return _SanLich(
      id: id,
      ten:
          '${json['ten'] ?? json['ten_san'] ?? json['tenSan'] ?? 'Sân cầu lông'}',
      tenDanhMuc:
          '${json['ten_danh_muc'] ?? json['tenDanhMuc'] ?? json['danh_muc'] ?? ''}',
      slots: rawSlots
          .whereType<Map>()
          .map(
            (item) => _SlotLich.fromJson(
              Map<String, dynamic>.from(item),
              id,
            ),
          )
          .toList(),
    );
  }

  bool get laVip => tenDanhMuc.toLowerCase().contains('vip');
}

class _KetQuaLich {
  final List<_SanLich> san;
  final List<_KhungGioLich> khungGio;

  const _KetQuaLich({
    required this.san,
    required this.khungGio,
  });
}

class _MucDaChon {
  final String key;
  final int sanId;
  final String tenSan;
  final int khungGioMauId;
  final String batDau;
  final String ketThuc;
  final double gia;

  const _MucDaChon({
    required this.key,
    required this.sanId,
    required this.tenSan,
    required this.khungGioMauId,
    required this.batDau,
    required this.ketThuc,
    required this.gia,
  });
}

int _intTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _doubleTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

String _catGio(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.length >= 5) return text.substring(0, 5);
  return text;
}

List<dynamic> _layMang(dynamic data, List<String> keys) {
  if (data is List) return data;

  if (data is Map) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
    }

    if (data['data'] is Map) {
      return _layMang(data['data'], keys);
    }
  }

  return [];
}

class _ManHinhChiTietSanState extends State<ManHinhChiTietSan> {
  final CoSoApi coSoApi = CoSoApi();
  final GoiApi api = GoiApi();
  final TextEditingController ghiChuController = TextEditingController();

  late CoSo coSo;
  String anhCoSoDuPhong = '';

  DateTime ngayDangChon = DateTime.now();

  List<_SanLich> danhSachSan = [];
  List<_KhungGioLich> danhSachKhungGio = [];
  List<dynamic> bangGia = [];

  Set<String> oDangChon = {};

  bool dangTai = false;
  bool dangTaiLich = false;
  bool dangXemLich = false;
  bool dangXemBangGia = false;

  String? loi;

  @override
  void initState() {
    super.initState();

    coSo = widget.coSoHienTai ??
        widget.coSo ??
        CoSo(
          id: 0,
          ten: 'Sân cầu lông',
          diaChi: 'Chưa cập nhật địa chỉ',
          moTa: 'Sân cầu lông sạch sẽ, thoáng mát.',
        );

    anhCoSoDuPhong = coSo.hinhAnh.trim();

    Future.microtask(taiDuLieuLanDau);
  }

  @override
  void dispose() {
    ghiChuController.dispose();
    super.dispose();
  }

  DateTime get ngayToiDa {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 2, 0);
  }

  String get diaChiDayDu {
    return [coSo.diaChi, coSo.phuongXa, coSo.tinhThanh]
        .where((item) => item.trim().isNotEmpty)
        .join(', ');
  }

  double get tongTamTinh {
    return mucDaChon.fold(0, (sum, item) => sum + item.gia);
  }

  List<_MucDaChon> get mucDaChon {
    final list = <_MucDaChon>[];

    for (final key in oDangChon) {
      final parts = key.split('-');
      if (parts.length != 2) continue;

      final sanId = int.tryParse(parts[0]) ?? 0;
      final khungGioId = int.tryParse(parts[1]) ?? 0;

      _SanLich? san;
      for (final item in danhSachSan) {
        if (item.id == sanId) {
          san = item;
          break;
        }
      }

      if (san == null) continue;

      _SlotLich? slot;
      for (final item in san.slots) {
        if (item.khungGioMauId == khungGioId) {
          slot = item;
          break;
        }
      }

      if (slot == null) continue;

      list.add(
        _MucDaChon(
          key: key,
          sanId: san.id,
          tenSan: san.ten,
          khungGioMauId: slot.khungGioMauId,
          batDau: slot.batDau,
          ketThuc: slot.ketThuc,
          gia: slot.gia,
        ),
      );
    }

    list.sort((a, b) {
      final cmpSan = a.tenSan.compareTo(b.tenSan);
      if (cmpSan != 0) return cmpSan;
      return a.batDau.compareTo(b.batDau);
    });

    return list;
  }

  String ngayApi(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  String dinhDangNgay(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String dinhDangTien(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String linkAnhTuText(String value) {
    final text = value.trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return '';

    return DuongDanApi.linkAnh(text);
  }

  String linkAnhCoSo() {
    final hinhAnhMoi = coSo.hinhAnh.trim();
    final hinhAnh = hinhAnhMoi.isNotEmpty ? hinhAnhMoi : anhCoSoDuPhong;
    final url = linkAnhTuText(hinhAnh);

    debugPrint('ANH CO SO CHI TIET/LICH: $url');

    return url;
  }

  Future<void> taiDuLieuLanDau() async {
    if (coSo.id <= 0) return;

    setState(() {
      dangTai = true;
      loi = null;
    });

    try {
      final chiTietCoSo = await coSoApi.layChiTietCoSo(coSo.id);
      final gia = await _layBangGia();

      if (!mounted) return;

      setState(() {
        final anhCu = coSo.hinhAnh.trim().isNotEmpty
            ? coSo.hinhAnh.trim()
            : anhCoSoDuPhong;

        if (chiTietCoSo.hinhAnh.trim().isEmpty && anhCu.isNotEmpty) {
          coSo = chiTietCoSo.copyWith(
            hinhAnh: anhCu,
          );
          anhCoSoDuPhong = anhCu;
        } else {
          coSo = chiTietCoSo;
          anhCoSoDuPhong = chiTietCoSo.hinhAnh.trim();
        }

        bangGia = gia;
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

  Future<void> moManHinhLich() async {
    setState(() {
      dangXemLich = true;
    });

    if (danhSachSan.isEmpty || danhSachKhungGio.isEmpty) {
      await taiLichTheoNgay();
    }
  }

  Future<void> taiLichTheoNgay() async {
    if (coSo.id <= 0) return;

    setState(() {
      dangTaiLich = true;
      loi = null;
      oDangChon.clear();
    });

    try {
      final lich = await _layLichTheoNgay();

      if (!mounted) return;

      setState(() {
        danhSachSan = lich.san;
        danhSachKhungGio = lich.khungGio;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loi = '$e';
      });
    }

    if (!mounted) return;

    setState(() {
      dangTaiLich = false;
    });
  }

  Future<_KetQuaLich> _layLichTheoNgay() async {
    final data = await api.get(
      DuongDanApi.lichDatSanCongKhai,
      query: {
        'co_so_id': coSo.id,
        'ngay': ngayApi(ngayDangChon),
      },
    );

    final sanRaw = _layMang(
      data,
      const ['san', 'data', 'danh_sach_san', 'items'],
    );

    final gioRaw = _layMang(
      data,
      const ['khung_gio', 'time_slots', 'khungGio'],
    );

    final dsSan = sanRaw
        .whereType<Map>()
        .map(
          (item) => _SanLich.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.id > 0)
        .toList();

    final dsGio = gioRaw
        .whereType<Map>()
        .map(
          (item) => _KhungGioLich.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.id > 0)
        .toList();

    if (dsGio.isEmpty && dsSan.isNotEmpty) {
      final map = <int, _KhungGioLich>{};

      for (final san in dsSan) {
        for (final slot in san.slots) {
          map[slot.khungGioMauId] = _KhungGioLich(
            id: slot.khungGioMauId,
            batDau: slot.batDau,
            ketThuc: slot.ketThuc,
          );
        }
      }

      final danhSach = map.values.toList()
        ..sort((a, b) => a.batDau.compareTo(b.batDau));

      return _KetQuaLich(
        san: dsSan,
        khungGio: danhSach,
      );
    }

    return _KetQuaLich(
      san: dsSan,
      khungGio: dsGio,
    );
  }

  Future<List<dynamic>> _layBangGia() async {
    try {
      final data = await api.get(
        DuongDanApi.bangGiaCongKhai,
        query: {
          'co_so_id': coSo.id,
        },
      );

      return _layMang(
        data,
        const ['bang_gia', 'data', 'items'],
      );
    } catch (_) {
      return [];
    }
  }

  Future<void> chonNgay() async {
    final date = await showDatePicker(
      context: context,
      initialDate: ngayDangChon,
      firstDate: DateTime.now(),
      lastDate: ngayToiDa,
    );

    if (date == null) return;

    setState(() {
      ngayDangChon = date;
    });

    await taiLichTheoNgay();
  }

  void doiChonSlot(_SanLich san, _SlotLich slot) {
    if (!slot.coTheChon) return;

    final key = '${san.id}-${slot.khungGioMauId}';

    setState(() {
      if (oDangChon.contains(key)) {
        oDangChon.remove(key);
      } else {
        oDangChon.add(key);
      }
    });
  }

  Color mauSlot(_SanLich san, _SlotLich? slot) {
    if (slot == null) return const Color(0xffd9d9d9);

    final key = '${san.id}-${slot.khungGioMauId}';

    if (slot.trangThai == 'khong_co_gia' || slot.trangThai == 'qua_gio') {
      return const Color(0xffd9d9d9);
    }

    if (slot.trangThai == 'da_dat_qua_gio') {
      return const Color(0xffff4d4d);
    }

    if (slot.trangThai == 'da_dat' || slot.trangThai == 'giu_cho') {
      return const Color(0xffff0000);
    }

    if (oDangChon.contains(key)) {
      return const Color(0xff9aa7ff);
    }

    return Colors.white;
  }

  Future<void> diDenThanhToan() async {
    if (mucDaChon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa chọn khung giờ'),
        ),
      );
      return;
    }

    final taiKhoan = context.read<XuLiTaiKhoan>();

    if (!taiKhoan.daDangNhap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đặt sân'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ManHinhDangNhap(),
        ),
      );
      return;
    }

    final token = await taiKhoan.layTokenDangNhap();
    GoiApi.ganToken(token);

    if (!mounted) return;

    final chiTiet = mucDaChon
        .map(
          (item) => {
            'san_id': item.sanId,
            'ten_san': item.tenSan,
            'ngay': ngayApi(ngayDangChon),
            'khung_gio_mau_id': item.khungGioMauId,
            'gio_bat_dau': item.batDau,
            'gio_ket_thuc': item.ketThuc,
            'gia': item.gia,
          },
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhThanhToan(
          coSo: coSo,
          chiTiet: chiTiet,
          ghiChu: ghiChuController.text.trim(),
        ),
      ),
    );
  }

  void bamQuayLai() {
    if (dangXemLich) {
      setState(() {
        dangXemLich = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget nenTrang({
    required Widget child,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            DuongDanAnh.Nen2,
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          bottom: false,
          child: child,
        ),
      ],
    );
  }

  Widget thanhTieuDe(String tieuDe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          InkWell(
            onTap: bamQuayLai,
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              tieuDe,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget anhCoSoLon() {
    final url = linkAnhCoSo();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 135,
        width: double.infinity,
        color: const Color(0xffe7f1ff),
        child: Stack(
          children: [
            Positioned.fill(
              child: url.isEmpty
                  ? const Icon(
                      Icons.sports_tennis_rounded,
                      size: 60,
                      color: Color(0xff2454ff),
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, ___) {
                        debugPrint('LOI TAI ANH CO SO LON: $url - $error');
                        return const Icon(
                          Icons.sports_tennis_rounded,
                          size: 60,
                          color: Color(0xff2454ff),
                        );
                      },
                    ),
            ),
            Positioned(
              right: 10,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${coSo.soLuongSan} sân',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabNho(
    String text,
    bool dangChon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: dangChon ? const Color(0xff2454ff) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: dangChon ? const Color(0xff2454ff) : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget theThongTinSan() {
    final moTa = coSo.moTa.isEmpty
        ? 'Sân cầu lông sạch sẽ, thoáng mát, phù hợp để đặt lịch tập luyện, giao lưu và thi đấu.'
        : coSo.moTa;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin sân',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            moTa,
            softWrap: true,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget theBangGia() {
    if (bangGia.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 7,
              offset: Offset(1, 3),
            ),
          ],
        ),
        child: const Text(
          'Cơ sở này hiện chưa có bảng giá.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng giá',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...bangGia.map((item) {
            if (item is! Map) return const SizedBox.shrink();

            final giaTu = _doubleTuJson(
              item['gia_thap_nhat'] ?? item['gia_tu'] ?? item['gia'],
            );

            final giaDen = _doubleTuJson(
              item['gia_cao_nhat'] ?? item['gia_den'] ?? item['gia'],
            );

            final tenLoaiNgay =
                '${item['ten_loai_ngay'] ?? item['loai_ngay'] ?? 'Loại ngày'}';

            final tenLoaiGio =
                '${item['ten_loai_gio'] ?? item['loai_gio'] ?? 'Khung giờ'}';

            final giaText = giaDen <= 0 || giaTu == giaDen
                ? dinhDangTien(giaTu)
                : '${dinhDangTien(giaTu)} - ${dinhDangTien(giaDen)}';

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenLoaiNgay,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tenLoaiGio,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    giaText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xff2454ff),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget theDanhGia() {
    Widget sao() {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Color(0xff2454ff), size: 14),
          Icon(Icons.star, color: Color(0xff2454ff), size: 14),
          Icon(Icons.star, color: Color(0xff2454ff), size: 14),
          Icon(Icons.star, color: Color(0xff2454ff), size: 14),
          Icon(Icons.star, color: Color(0xff2454ff), size: 14),
        ],
      );
    }

    Widget dongDanhGia(String ten, String noiDung, String ngay) {
      return Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                ten[0],
                style: const TextStyle(
                  color: Color(0xff2454ff),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ten,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  sao(),
                  const SizedBox(height: 2),
                  Text(
                    noiDung,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              ngay,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 88,
                child: Column(
                  children: [
                    Text(
                      '4,9',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '297 lượt đánh giá',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final value = [0.9, 0.35, 0.12, 0.05, 0.02][index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${5 - index}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Color(0xff2454ff),
                            size: 9,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 3,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xff2454ff),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          dongDanhGia(
            'Minh Anh',
            'Sân đẹp, sạch sẽ, nhân viên thân thiện.',
            '2 ngày trước',
          ),
          dongDanhGia(
            'Khanh',
            'Đặt sân dễ dàng, giá hợp lý.',
            '3 ngày trước',
          ),
        ],
      ),
    );
  }

  Widget noiDungChiTiet() {
    if (dangTai) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          anhCoSoLon(),
          const SizedBox(height: 12),
          Text(
            coSo.tenCoSo,
            softWrap: true,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '5:00 - 22:00',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      diaChiDayDu.isEmpty
                          ? 'Chưa cập nhật địa chỉ'
                          : diaChiDayDu,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              if (coSo.giaThapNhat > 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xff2454ff),
                      ),
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.white,
                    ),
                    child: Text(
                      'Chỉ từ\n${dinhDangTien(coSo.giaThapNhat)}/giờ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xff2454ff),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xff2454ff),
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                '4,9(297 đánh giá)',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.near_me,
                size: 12,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '1.2 Km',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              tabNho(
                'Thông tin',
                !dangXemBangGia,
                () {
                  setState(() {
                    dangXemBangGia = false;
                  });
                },
              ),
              tabNho(
                'Bảng giá',
                dangXemBangGia,
                () {
                  setState(() {
                    dangXemBangGia = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          dangXemBangGia ? theBangGia() : theThongTinSan(),
          if (loi != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xfffff1f2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                loi!,
                style: const TextStyle(
                  color: Color(0xffbe123c),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (!dangXemBangGia) ...[
            const SizedBox(height: 14),
            theDanhGia(),
          ],
        ],
      ),
    );
  }

  Widget nutNgay({
    required String dong1,
    required String dong2,
    required bool dangChon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: dangChon ? const Color(0xffeef4ff) : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: dangChon ? const Color(0xff2454ff) : Colors.black54,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: dangChon ? const Color(0xff2454ff) : Colors.black87,
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dong1,
                    style: TextStyle(
                      color:
                          dangChon ? const Color(0xff2454ff) : Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    dong2,
                    style: TextStyle(
                      color:
                          dangChon ? const Color(0xff2454ff) : Colors.black87,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget thanhChonNgay() {
    final homNay = DateTime.now();
    final ngayMai = homNay.add(const Duration(days: 1));

    final laHomNay = ngayApi(ngayDangChon) == ngayApi(homNay);
    final laNgayMai = ngayApi(ngayDangChon) == ngayApi(ngayMai);

    return Row(
      children: [
        nutNgay(
          dong1: 'Hôm nay',
          dong2: dinhDangNgay(homNay).substring(0, 5),
          dangChon: laHomNay,
          onTap: () async {
            setState(() {
              ngayDangChon = homNay;
            });
            await taiLichTheoNgay();
          },
        ),
        const SizedBox(width: 10),
        nutNgay(
          dong1: 'Ngày mai',
          dong2: dinhDangNgay(ngayMai).substring(0, 5),
          dangChon: laNgayMai,
          onTap: () async {
            setState(() {
              ngayDangChon = ngayMai;
            });
            await taiLichTheoNgay();
          },
        ),
        const SizedBox(width: 10),
        nutNgay(
          dong1: 'Chọn',
          dong2: 'ngày',
          dangChon: !laHomNay && !laNgayMai,
          onTap: chonNgay,
        ),
      ],
    );
  }

  Widget chuGiai() {
    Widget item(Color color, String text, {bool border = false}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: border
                  ? Border.all(
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          item(Colors.white, 'Trống', border: true),
          item(const Color(0xff9aa7ff), 'Đang chọn'),
          item(const Color(0xffd9d9d9), 'Khóa', border: true),
          item(const Color(0xffff0000), 'Đã đặt'),
        ],
      ),
    );
  }

  Widget theTomTatSan() {
    final url = linkAnhCoSo();

    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 112,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(11),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: url.isEmpty
                        ? Container(
                            color: const Color(0xffe7f1ff),
                            child: const Icon(
                              Icons.sports_tennis_rounded,
                              color: Color(0xff2454ff),
                              size: 38,
                            ),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, ___) {
                              debugPrint('LOI TAI ANH TOM TAT SAN: $url - $error');
                              return Container(
                                color: const Color(0xffe7f1ff),
                                child: const Icon(
                                  Icons.sports_tennis_rounded,
                                  color: Color(0xff2454ff),
                                  size: 38,
                                ),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${coSo.soLuongSan} sân',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coSo.tenCoSo,
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xff2454ff),
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '4,9(297 đánh giá)',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          coSo.tinhThanh.isEmpty
                              ? 'TP. Hồ Chí Minh'
                              : coSo.tinhThanh,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '5:00 - 22:00',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffeef4ff),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Còn sân',
                      style: TextStyle(
                        color: Color(0xff2454ff),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget bangChonSan(String tieuDe, List<_SanLich> dsSan) {
    if (dsSan.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Row(
                children: [
                  oTenSan(
                    tieuDe,
                    laTieuDe: true,
                  ),
                  for (final gio in danhSachKhungGio)
                    oTieuDeGio(
                      gio.batDau,
                    ),
                ],
              ),
              for (final san in dsSan)
                Row(
                  children: [
                    oTenSan(san.ten),
                    for (final gio in danhSachKhungGio) oSlot(san, gio),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget oTenSan(String text, {bool laTieuDe = false}) {
    return Container(
      width: 86,
      height: 42,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xff9a9a9a),
          ),
          bottom: BorderSide(
            color: Color(0xff9a9a9a),
          ),
        ),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: laTieuDe ? 9 : 13,
          color: Colors.black,
          fontWeight: laTieuDe ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget oTieuDeGio(String text) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xff9a9a9a),
          ),
          bottom: BorderSide(
            color: Color(0xff9a9a9a),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8.5,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget oSlot(_SanLich san, _KhungGioLich gio) {
    _SlotLich? slot;

    for (final item in san.slots) {
      if (item.khungGioMauId == gio.id) {
        slot = item;
        break;
      }
    }

    final key = slot == null ? '' : '${san.id}-${slot.khungGioMauId}';
    final dangChon = key.isNotEmpty && oDangChon.contains(key);

    return InkWell(
      onTap: slot == null || !slot.coTheChon
          ? null
          : () {
              doiChonSlot(san, slot!);
            },
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mauSlot(san, slot),
          border: Border.all(
            color: dangChon ? const Color(0xff2447c6) : const Color(0xff9a9a9a),
          ),
        ),
      ),
    );
  }

  Widget ghiChu() {
    return TextField(
      controller: ghiChuController,
      maxLines: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Ghi chú nếu có',
        hintStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0xffdbeafe),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0xffdbeafe),
          ),
        ),
      ),
    );
  }

  Widget noiDungLich() {
    final sanThuong = danhSachSan.where((item) => !item.laVip).toList();
    final sanVip = danhSachSan.where((item) => item.laVip).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 178),
      child: Column(
        children: [
          theTomTatSan(),
          const SizedBox(height: 10),
          thanhChonNgay(),
          const SizedBox(height: 10),
          chuGiai(),
          const SizedBox(height: 10),
          if (loi != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xfffff1f2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                loi!,
                style: const TextStyle(
                  color: Color(0xffbe123c),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (dangTaiLich)
            const Padding(
              padding: EdgeInsets.only(top: 55),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (danhSachKhungGio.isEmpty || danhSachSan.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'Chưa có lịch sân trong ngày này.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else ...[
            bangChonSan('Sân', sanThuong),
            if (sanVip.isNotEmpty) ...[
              const SizedBox(height: 10),
              bangChonSan('VIP', sanVip),
            ],
          ],
          const SizedBox(height: 12),
          ghiChu(),
        ],
      ),
    );
  }

  Widget thanhDuoiChiTiet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: 172,
              height: 39,
              child: ElevatedButton(
                onPressed: moManHinhLich,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2454ff),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'Đặt sân ngay',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const ThanhDuoi(
          viTriDangChon: 0,
        ),
      ],
    );
  }

  Widget thanhDuoiLich() {
    final ds = mucDaChon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 7,
                offset: Offset(1, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Đang chọn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Text(
                    'Tạm tính',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ds.isEmpty
                          ? 'Chưa chọn khung giờ'
                          : '${ds.first.tenSan}, ${ds.first.batDau} - ${ds.first.ketThuc}${ds.length > 1 ? ' +${ds.length - 1}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    dinhDangTien(tongTamTinh),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff2454ff),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 155,
                height: 42,
                child: ElevatedButton(
                  onPressed: ds.isEmpty ? null : diDenThanhToan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2454ff),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục đặt sân',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const ThanhDuoi(
          viTriDangChon: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieuDe = dangXemLich ? 'Lịch sân' : 'Chi tiết sân';

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f9ff),
      body: nenTrang(
        child: Column(
          children: [
            thanhTieuDe(tieuDe),
            Expanded(
              child: dangXemLich ? noiDungLich() : noiDungChiTiet(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: dangXemLich ? thanhDuoiLich() : thanhDuoiChiTiet(),
    );
  }
}