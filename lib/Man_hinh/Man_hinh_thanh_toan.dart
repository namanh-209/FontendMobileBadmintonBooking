import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li_api/Dat_san_api.dart';
import '../Xu_li_api/Thanh_toan_api.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_lich_dat_san.dart';
import 'Man_hinh_vnpay_webview.dart';
import '../Dung_lai/Hieu_ung_tai.dart';

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

class _KhuyenMai {
  final int id;
  final String ma;
  final String ten;
  final String moTa;
  final String loaiGiam;
  final double giaTri;
  final double giamToiDa;
  final double donToiThieu;
  final int soLuotConLai;

  const _KhuyenMai({
    required this.id,
    required this.ma,
    required this.ten,
    required this.moTa,
    required this.loaiGiam,
    required this.giaTri,
    required this.giamToiDa,
    required this.donToiThieu,
    required this.soLuotConLai,
  });

  factory _KhuyenMai.fromJson(Map<String, dynamic> json) {
    final rawLoaiGiam =
        '${json['loai_giam'] ?? json['loaiGiam'] ?? json['loai'] ?? json['kieu_giam'] ?? json['kieuGiam'] ?? json['kieu'] ?? json['hinh_thuc'] ?? json['hinhThuc'] ?? json['hinh_thuc_giam'] ?? json['hinhThucGiam'] ?? json['type'] ?? json['discount_type'] ?? ''}'
            .toLowerCase();

    final coFieldPhanTram = json.containsKey('phan_tram_giam') ||
        json.containsKey('phanTramGiam') ||
        json.containsKey('giam_phan_tram') ||
        json.containsKey('percent') ||
        json.containsKey('percentage');

    final giaTriDocDuoc = _doubleTuJson(
      json['gia_tri'] ??
          json['giaTri'] ??
          json['gia_tri_giam'] ??
          json['giaTriGiam'] ??
          json['phan_tram_giam'] ??
          json['phanTramGiam'] ??
          json['giam_phan_tram'] ??
          json['percent'] ??
          json['percentage'] ??
          json['so_tien_giam'] ??
          json['soTienGiam'] ??
          json['muc_giam'] ??
          json['mucGiam'] ??
          json['discount_value'] ??
          json['value'],
    );

    final laTienMat = rawLoaiGiam.contains('tien') ||
        rawLoaiGiam.contains('tiền') ||
        rawLoaiGiam.contains('money') ||
        rawLoaiGiam.contains('amount') ||
        rawLoaiGiam.contains('fixed') ||
        rawLoaiGiam.contains('cash');

    final laPhanTram = coFieldPhanTram ||
        rawLoaiGiam.contains('phan_tram') ||
        rawLoaiGiam.contains('phần trăm') ||
        rawLoaiGiam.contains('percent') ||
        rawLoaiGiam.contains('percentage') ||
        rawLoaiGiam.contains('%');

    String loaiGiamFix;

    if (laPhanTram) {
      loaiGiamFix = 'phan_tram';
    } else if (laTienMat) {
      loaiGiamFix = 'tien_mat';
    } else if (giaTriDocDuoc > 0 && giaTriDocDuoc <= 100) {
      loaiGiamFix = 'phan_tram';
    } else {
      loaiGiamFix = 'tien_mat';
    }

    return _KhuyenMai(
      id: _intTuJson(
        json['id'] ??
            json['khuyen_mai_id'] ??
            json['khuyenMaiId'] ??
            json['promotion_id'] ??
            json['voucher_id'],
      ),
      ma:
          '${json['ma'] ?? json['ma_khuyen_mai'] ?? json['maKhuyenMai'] ?? json['code'] ?? json['coupon_code'] ?? ''}',
      ten:
          '${json['ten'] ?? json['ten_khuyen_mai'] ?? json['tenKhuyenMai'] ?? json['title'] ?? json['name'] ?? 'Mã giảm giá'}',
      moTa:
          '${json['mo_ta'] ?? json['moTa'] ?? json['description'] ?? json['noi_dung'] ?? json['noiDung'] ?? json['ghi_chu'] ?? ''}',
      loaiGiam: loaiGiamFix,
      giaTri: giaTriDocDuoc,
      giamToiDa: _doubleTuJson(
        json['giam_toi_da'] ??
            json['giamToiDa'] ??
            json['gia_tri_toi_da'] ??
            json['giaTriToiDa'] ??
            json['max_discount'] ??
            json['so_tien_giam_toi_da'],
      ),
      donToiThieu: _doubleTuJson(
        json['don_toi_thieu'] ??
            json['donToiThieu'] ??
            json['gia_tri_don_toi_thieu'] ??
            json['giaTriDonToiThieu'] ??
            json['min_order'] ??
            json['don_hang_toi_thieu'],
      ),
      soLuotConLai: _intTuJson(
        json['so_luot_con_lai'] ??
            json['soLuotConLai'] ??
            json['con_lai'] ??
            json['conLai'] ??
            json['remaining'] ??
            json['remaining_uses'],
      ),
    );
  }

  bool get laGiamPhanTram {
    final value = loaiGiam.toLowerCase();

    return value.contains('phan_tram') ||
        value.contains('percent') ||
        value.contains('%') ||
        value.contains('percentage');
  }

  double tinhTienGiam(double tongTien) {
    if (donToiThieu > 0 && tongTien < donToiThieu) return 0;

    double giam;

    if (laGiamPhanTram) {
      giam = tongTien * giaTri / 100;

      if (giamToiDa > 0 && giam > giamToiDa) {
        giam = giamToiDa;
      }
    } else {
      giam = giaTri;
    }

    if (giam < 0) return 0;
    if (giam > tongTien) return tongTien;

    return giam;
  }

  String tieuDeHienThi() {
    if (ma.isNotEmpty) return ma;
    return ten;
  }

  String nhanGiam() {
    if (laGiamPhanTram) {
      final so = giaTri == giaTri.roundToDouble()
          ? giaTri.toStringAsFixed(0)
          : giaTri.toStringAsFixed(1);

      if (giamToiDa > 0) {
        return 'Giảm $so% tối đa ${_dinhDangTienTinh(giamToiDa)}';
      }

      return 'Giảm $so%';
    }

    return 'Giảm ${_dinhDangTienTinh(giaTri)}';
  }

  String dieuKienHienThi() {
    if (moTa.trim().isNotEmpty) return moTa;

    if (donToiThieu > 0) {
      return 'Đơn từ ${_dinhDangTienTinh(donToiThieu)}';
    }

    return 'Áp dụng cho đơn đặt sân';
  }
}

int _intTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _doubleTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();

  var text = '$value'
      .replaceAll('đ', '')
      .replaceAll(' ', '')
      .trim();

  if (text.contains('.') && text.contains(',')) {
    text = text.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
    text = text.replaceAll('.', '');
  } else {
    text = text.replaceAll(',', '.');
  }

  return double.tryParse(text) ?? 0;
}

String _layText(dynamic value) {
  if (value == null) return '';
  return '$value'.trim();
}

String _dinhDangTienTinh(double value) {
  return '${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}đ';
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

List<dynamic> _layDanhSachKhuyenMai(dynamic data) {
  final keys = [
    'data',
    'items',
    'khuyen_mai',
    'khuyenMai',
    'ma_khuyen_mai',
    'maKhuyenMai',
    'ma_phu_hop',
    'maPhuHop',
    'promotions',
    'vouchers',
    'coupons',
    'discounts',
    'results',
  ];

  final list = _layMang(data, keys);
  if (list.isNotEmpty) return list;

  if (data is Map) {
    for (final value in data.values) {
      final found = _layDanhSachKhuyenMai(value);
      if (found.isNotEmpty) return found;
    }
  }

  return [];
}

class _ManHinhThanhToanState extends State<ManHinhThanhToan> {
  final DatSanApi datSanApi = DatSanApi();
  final ThanhToanApi thanhToanApi = ThanhToanApi();
  final GoiApi api = GoiApi();

  final TextEditingController ghiChuController = TextEditingController();
  final TextEditingController maGiamGiaController = TextEditingController();
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();

  DatSan? datSan;

  bool dangTai = false;
  bool dangTaiKhuyenMai = false;
  bool dangGuiThanhToan = false;
  bool dangHuy = false;

  String? loi;
  String loaiThanhToan = 'deposit';

  List<_KhuyenMai> danhSachKhuyenMai = [];
  _KhuyenMai? khuyenMaiDangChon;

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
    maGiamGiaController.dispose();
    hoTenController.dispose();
    soDienThoaiController.dispose();
    super.dispose();
  }

  String laySoDienThoaiTaiKhoan(dynamic nguoiDung) {
    if (nguoiDung == null) return '';

    final getters = <String Function()>[
      () => _layText(nguoiDung.soDienThoai),
      () => _layText(nguoiDung.so_dien_thoai),
      () => _layText(nguoiDung.sdt),
      () => _layText(nguoiDung.dienThoai),
      () => _layText(nguoiDung.phone),
      () => _layText(nguoiDung.phoneNumber),
      () => _layText(nguoiDung.mobile),
    ];

    for (final getter in getters) {
      try {
        final value = getter();
        if (value.isNotEmpty && value != 'null') {
          return value;
        }
      } catch (_) {}
    }

    return '';
  }

  void ganThongTinLienHeTuTaiKhoan() {
    final taiKhoan = context.read<XuLiTaiKhoan>();
    final nguoiDung = taiKhoan.nguoiDung;

    final hoTen = _layText(nguoiDung?.hoTen);
    final soDienThoai = laySoDienThoaiTaiKhoan(nguoiDung);

    if (hoTenController.text.trim().isEmpty) {
      hoTenController.text = hoTen;
    }

    if (soDienThoaiController.text.trim().isEmpty) {
      soDienThoaiController.text = soDienThoai;
    }
  }

  Future<void> chuanBiThanhToan() async {
    final taiKhoan = context.read<XuLiTaiKhoan>();

    if (!taiKhoan.daDangNhap) {
      setState(() {
        loi = 'Bạn phải đăng nhập trước khi đặt sân';
      });
      return;
    }

    ganThongTinLienHeTuTaiKhoan();

    final token = await taiKhoan.layTokenDangNhap();
    GoiApi.ganToken(token);

    setState(() {
      dangTai = true;
      loi = null;
    });

    try {
      if (datSan == null) {
        if (widget.coSo == null ||
            widget.chiTiet == null ||
            widget.chiTiet!.isEmpty) {
          throw Exception('Thiếu thông tin đặt sân');
        }

        final ketQua = await datSanApi.taoDatSan(
          coSoId: widget.coSo!.id,
          chiTiet: widget.chiTiet!,
          ghiChu: ghiChuController.text.trim(),
        );

        datSan = ketQua;
      }

      await taiKhuyenMai();
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

  Future<void> taiKhuyenMai() async {
    setState(() {
      dangTaiKhuyenMai = true;
    });

    try {
      final ds = datSan;
      final coSoId = widget.coSo?.id ?? 0;
      final tongTien = ds == null ? 0 : tongTienGoc(ds);

      final data = await api.get(
        '/khuyen-mai/cong-khai',
        query: {
          if (coSoId > 0) 'co_so_id': coSoId,
          if (tongTien > 0) 'tong_tien': tongTien,
          if (tongTien > 0) 'thanh_tien': tongTien,
          if (tongTien > 0) 'gia_tri_don_hang': tongTien,
        },
      );

      final rawList = _layDanhSachKhuyenMai(data);

      final list = rawList
          .whereType<Map>()
          .map((item) {
            final map = Map<String, dynamic>.from(item);

            if (map['khuyen_mai'] is Map) {
              final inner = Map<String, dynamic>.from(map['khuyen_mai']);
              inner.addAll(map);
              return _KhuyenMai.fromJson(inner);
            }

            if (map['promotion'] is Map) {
              final inner = Map<String, dynamic>.from(map['promotion']);
              inner.addAll(map);
              return _KhuyenMai.fromJson(inner);
            }

            if (map['voucher'] is Map) {
              final inner = Map<String, dynamic>.from(map['voucher']);
              inner.addAll(map);
              return _KhuyenMai.fromJson(inner);
            }

            return _KhuyenMai.fromJson(map);
          })
          .where((item) => item.ma.trim().isNotEmpty || item.giaTri > 0)
          .toList();

      if (!mounted) return;

      setState(() {
        danhSachKhuyenMai = list;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        danhSachKhuyenMai = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được mã giảm giá: $e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      dangTaiKhuyenMai = false;
    });
  }

  String dinhDangTien(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String catGio(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 5) return text.substring(0, 5);
    return text;
  }

  String dinhDangNgayTuApi(String ngay) {
    if (ngay.trim().isEmpty) return 'Chưa có';

    try {
      final date = DateTime.parse(ngay);
      final d = date.day.toString().padLeft(2, '0');
      final m = date.month.toString().padLeft(2, '0');
      final thu =
          date.weekday == DateTime.sunday ? 'CN' : 'T${date.weekday + 1}';
      return '$thu, $d/$m/${date.year}';
    } catch (_) {
      return ngay;
    }
  }

  String ngayChoi(DatSan ds) {
    final raw = widget.chiTiet != null && widget.chiTiet!.isNotEmpty
        ? '${widget.chiTiet!.first['ngay'] ?? ''}'
        : '';

    if (raw.isNotEmpty) return dinhDangNgayTuApi(raw);

    return 'Chưa có';
  }

  String khungGioChoi(DatSan ds) {
    if (ds.chiTiet.isEmpty) return 'Chưa có';

    final batDau = ds.chiTiet.map((e) => catGio(e.gioBatDau)).toList()
      ..sort();

    final ketThuc = ds.chiTiet.map((e) => catGio(e.gioKetThuc)).toList()
      ..sort();

    return '${batDau.first} - ${ketThuc.last}';
  }

  List<String> danhSachTenSan(DatSan ds) {
    final setTen = <String>{};

    for (final item in ds.chiTiet) {
      final ten = item.tenSan.isEmpty ? 'Sân ${item.sanId}' : item.tenSan;
      setTen.add(ten);
    }

    return setTen.toList();
  }

  double doiGioThanhSo(String gio) {
    final parts = gio.split(':');
    if (parts.length < 2) return 0;

    final h = double.tryParse(parts[0]) ?? 0;
    final m = double.tryParse(parts[1]) ?? 0;

    return h + m / 60;
  }

  double thoiLuongGio(DatSan ds) {
    double tong = 0;

    for (final item in ds.chiTiet) {
      final bd = doiGioThanhSo(catGio(item.gioBatDau));
      final kt = doiGioThanhSo(catGio(item.gioKetThuc));

      if (kt >= bd) {
        tong += kt - bd;
      }
    }

    if (tong <= 0 && ds.chiTiet.isNotEmpty) {
      tong = ds.chiTiet.length * 0.5;
    }

    return tong;
  }

  String dinhDangThoiLuong(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toStringAsFixed(0)} giờ';
    }

    return '${value.toStringAsFixed(1)} giờ';
  }

  double tongTienGoc(DatSan ds) {
    if (ds.tongTien > 0) return ds.tongTien;

    final tongChiTiet = ds.chiTiet.fold<double>(
      0,
      (sum, item) => sum + item.gia,
    );

    if (tongChiTiet > 0) return tongChiTiet;
    if (ds.thanhTien > 0) return ds.thanhTien;

    return 0;
  }

  double tienGiam(DatSan ds) {
    final giamApi = ds.tienGiam;

    final giamKhuyenMai = khuyenMaiDangChon?.tinhTienGiam(
          tongTienGoc(ds),
        ) ??
        0;

    if (giamKhuyenMai > giamApi) return giamKhuyenMai;
    return giamApi;
  }

  double thanhTienSauGiam(DatSan ds) {
    final value = tongTienGoc(ds) - tienGiam(ds);
    return value < 0 ? 0 : value;
  }

  double tienCoc(DatSan ds) {
    final phanTramCoc = widget.coSo?.phanTramCoc ?? 30;
    return (thanhTienSauGiam(ds) * phanTramCoc / 100).roundToDouble();
  }

  String linkAnhTuText(String value) {
    final text = value.trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return '';

    return DuongDanApi.linkAnh(text);
  }

  String linkAnhCoSo() {
    final hinhAnh = widget.coSo?.hinhAnh.trim() ?? '';
    final url = linkAnhTuText(hinhAnh);

    debugPrint('ANH CO SO THANH TOAN: $url');

    return url;
  }

  DatSan capNhatTienDatSanTuApi(
    DatSan ds,
    Map<String, dynamic> data,
  ) {
    final khuyenMaiRaw = data['khuyen_mai'];
    int? khuyenMaiId = ds.khuyenMaiId;

    if (khuyenMaiRaw is Map) {
      final rawId = khuyenMaiRaw['id'] ?? khuyenMaiRaw['khuyen_mai_id'];
      khuyenMaiId = _intTuJson(rawId);
    }

    return DatSan.fromJson({
      ...ds.toJson(),
      'id': ds.id,
      'dat_san_id': ds.id,
      'khuyen_mai_id': khuyenMaiId,
      'tong_tien': _doubleTuJson(data['tong_tien'] ?? ds.tongTien),
      'tien_giam': _doubleTuJson(data['tien_giam'] ?? ds.tienGiam),
      'thanh_tien': _doubleTuJson(data['thanh_tien'] ?? ds.thanhTien),
      'tien_coc': _doubleTuJson(data['tien_coc'] ?? ds.tienCoc),
      'chi_tiet': ds.chiTiet.map((item) => item.toJson()).toList(),
    });
  }

  Future<DatSan> capNhatMaGiamGiaTruocThanhToan(DatSan ds) async {
    final maKhuyenMai = khuyenMaiDangChon?.ma.trim() ?? '';

    if (maKhuyenMai.isEmpty) return ds;

    final data = await api.patch(
      '/dat-san/${ds.id}/khuyen-mai',
      body: {
        'ma_khuyen_mai': maKhuyenMai,
      },
    );

    if (data is Map) {
      final dsMoi = capNhatTienDatSanTuApi(
        ds,
        Map<String, dynamic>.from(data),
      );

      if (mounted) {
        setState(() {
          datSan = dsMoi;
        });
      }

      return dsMoi;
    }

    return ds;
  }

  void moManHinhDatSanThanhCong(DatSan ds) {
    final tenSanList = danhSachTenSan(ds);
    final soTienDaThanhToan = loaiThanhToan == 'full'
        ? thanhTienSauGiam(ds)
        : tienCoc(ds);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ManHinhDatSanThanhCong(
          tenCoSo: widget.coSo?.tenCoSo ?? ds.tenCoSo,
          ngayChoi: ngayChoi(ds),
          khungGio: khungGioChoi(ds),
          tenSan: tenSanList.isEmpty ? 'Sân đã chọn' : tenSanList.join(', '),
          thoiLuong: dinhDangThoiLuong(thoiLuongGio(ds)),
          maDatSan: 'DS${ds.id}',
          maGiamGia: khuyenMaiDangChon?.ma ?? '',
          tongTien: dinhDangTien(soTienDaThanhToan),
        ),
      ),
      (route) => route.isFirst,
    );
  }

  Future<void> moManHinhVnpay(
    String paymentUrl,
    DatSan dsDaCapNhatTien,
  ) async {
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
      moManHinhDatSanThanhCong(dsDaCapNhatTien);
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
      final dsDaCapNhatTien = await capNhatMaGiamGiaTruocThanhToan(ds);

      final paymentUrl = await thanhToanApi.taoLinkThanhToanVnpay(
        datSanId: dsDaCapNhatTien.id,
        loaiThanhToan: loaiThanhToan,
      );

      if (!mounted) return;

      await moManHinhVnpay(
        paymentUrl,
        dsDaCapNhatTien,
      );
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

  void apDungMaNhap() {
    final maNhap = maGiamGiaController.text.trim().toLowerCase();

    if (maNhap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa nhập mã giảm giá'),
        ),
      );
      return;
    }

    _KhuyenMai? timThay;

    for (final item in danhSachKhuyenMai) {
      if (item.ma.toLowerCase() == maNhap) {
        timThay = item;
        break;
      }
    }

    if (timThay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ'),
        ),
      );
      return;
    }

    setState(() {
      khuyenMaiDangChon = timThay;
      maGiamGiaController.text = timThay!.ma;
    });

    Navigator.pop(context);
  }

  void moChonKhuyenMai(DatSan ds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void chonMa(_KhuyenMai item) {
              setState(() {
                khuyenMaiDangChon = item;
                maGiamGiaController.text = item.ma;
              });

              setModalState(() {});
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.55,
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Mã giảm giá',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                        child: Container(
                          height: 58,
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
                                size: 28,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: maGiamGiaController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'Nhập mã giảm giá',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 36,
                                width: 78,
                                child: ElevatedButton(
                                  onPressed: apDungMaNhap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2454ff),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
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
                        ),
                      ),
                      Expanded(
                        child: dangTaiKhuyenMai
                            ? const HieuUngTai(
                                text: 'Đang tải voucher...',
                                kichThuocLogo: 58,
                                kichThuocChu: 12,
                              )
                            : danhSachKhuyenMai.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Hiện chưa có mã giảm giá',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(
                                      18,
                                      6,
                                      18,
                                      18,
                                    ),
                                    itemCount: danhSachKhuyenMai.length,
                                    itemBuilder: (context, index) {
                                      final item = danhSachKhuyenMai[index];
                                      final dangChon =
                                          khuyenMaiDangChon?.ma == item.ma;

                                      return InkWell(
                                        onTap: () {
                                          chonMa(item);
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 106,
                                          margin:
                                              const EdgeInsets.only(bottom: 14),
                                          padding: const EdgeInsets.fromLTRB(
                                            18,
                                            14,
                                            16,
                                            14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: dangChon
                                                  ? const Color(0xff2454ff)
                                                  : Colors.black,
                                              width: dangChon ? 1.9 : 1.25,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xfff5edff),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xff9b6bff,
                                                      ).withOpacity(0.35),
                                                      width: 1.1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 45,
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.percent,
                                                            color: Color(
                                                              0xff9b6bff,
                                                            ),
                                                            size: 27,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: double.infinity,
                                                        color: const Color(
                                                          0xff9b6bff,
                                                        ).withOpacity(0.22),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                            10,
                                                            6,
                                                            7,
                                                            5,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 7,
                                                                  vertical: 3,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      const Color(
                                                                    0xff9b6bff,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    5,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  item
                                                                      .nhanGiam(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        8.8,
                                                                    height: 1,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                item
                                                                    .tieuDeHienThi(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Color(
                                                                    0xff2454ff,
                                                                  ),
                                                                  fontSize: 19,
                                                                  height: 1,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 2,
                                                              ),
                                                              Text(
                                                                item
                                                                    .dieuKienHienThi(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  fontSize: 8,
                                                                  height: 1,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Icon(
                                                dangChon
                                                    ? Icons
                                                        .radio_button_checked_rounded
                                                    : Icons
                                                        .radio_button_off_rounded,
                                                color: const Color(0xff2454ff),
                                                size: 26,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2454ff),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                khuyenMaiDangChon == null
                                    ? 'Áp dụng'
                                    : 'Áp dụng ${khuyenMaiDangChon!.ma}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget nenTrang({required Widget child}) {
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

  Widget thanhTieuDe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          InkWell(
            onTap: dangGuiThanhToan || dangHuy ? null : huyGiuChoVaQuayLai,
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
          const Expanded(
            child: Text(
              'Thanh toán',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
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

  Widget anhMacDinh() {
    return Container(
      color: const Color(0xffe7f1ff),
      child: const Icon(
        Icons.sports_tennis_rounded,
        color: Color(0xff2454ff),
        size: 36,
      ),
    );
  }

  Widget thongTinCoSo() {
    final url = linkAnhCoSo();
    final ten = widget.coSo?.tenCoSo ?? datSan?.tenCoSo ?? 'Sân cầu lông';
    final diaChi = widget.coSo?.tinhThanh.isNotEmpty == true
        ? widget.coSo!.tinhThanh
        : 'TP. Hồ Chí Minh';

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 78,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: url.isEmpty
                  ? anhMacDinh()
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, ___) {
                        debugPrint('LOI TAI ANH THANH TOAN: $url - $error');
                        return anhMacDinh();
                      },
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ten,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xff2454ff),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4,9 (297 đánh giá)',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '1,2 Km',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade600,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        diaChi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget theTrang({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget dongThongTinDatSan({
    required IconData icon,
    required String label,
    required Widget value,
    bool coDuongKe = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: coDuongKe
            ? Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 0.8,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.black87,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: value,
            ),
          ),
        ],
      ),
    );
  }

  Widget chipXanh(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff2454ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget oNhapLienHe({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.grey.shade500,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.black87,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                isDense: true,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget thongTinDatSan(DatSan ds) {
    final tenSanList = danhSachTenSan(ds);

    return theTrang(
      children: [
        dongThongTinDatSan(
          icon: Icons.calendar_month_outlined,
          label: 'Ngày chơi',
          value: Text(
            ngayChoi(ds),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xff2454ff),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        dongThongTinDatSan(
          icon: Icons.access_time,
          label: 'Khung giờ',
          value: Text(
            khungGioChoi(ds),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xff2454ff),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        dongThongTinDatSan(
          icon: Icons.stadium_outlined,
          label: 'Chọn sân',
          value: Wrap(
            alignment: WrapAlignment.end,
            spacing: 5,
            runSpacing: 5,
            children: tenSanList.map((ten) => chipXanh(ten)).toList(),
          ),
        ),
        dongThongTinDatSan(
          icon: Icons.timer_outlined,
          label: 'Thời lượng',
          value: chipXanh(
            dinhDangThoiLuong(thoiLuongGio(ds)),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 19,
                    color: Colors.black87,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Thông tin liên hệ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              oNhapLienHe(
                icon: Icons.person_outline,
                controller: hoTenController,
                hint: 'Họ tên',
              ),
              oNhapLienHe(
                icon: Icons.phone_outlined,
                controller: soDienThoaiController,
                hint: 'Số điện thoại',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget voucher(DatSan ds) {
    final daChon = khuyenMaiDangChon != null;
    final text = daChon
        ? '${khuyenMaiDangChon!.ma} - ${khuyenMaiDangChon!.nhanGiam()}'
        : 'Chọn hoặc nhập mã giảm giá';

    return InkWell(
      onTap: () {
        moChonKhuyenMai(ds);
      },
      borderRadius: BorderRadius.circular(8),
      child: theTrang(
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 31,
                color: Colors.black,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voucher/Mã giảm giá',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: daChon ? const Color(0xff2454ff) : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tongTienCard(DatSan ds) {
    Widget dong(String label, String value, {Color? color, bool dam = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color ?? Colors.black,
                  fontWeight: dam ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.black,
                fontWeight: dam ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final giam = tienGiam(ds);

    return theTrang(
      children: [
        dong('Thời lượng', dinhDangThoiLuong(thoiLuongGio(ds))),
        dong('Giá sân', dinhDangTien(tongTienGoc(ds))),
        dong(
          'Giảm giá',
          giam > 0 ? '-${dinhDangTien(giam)}' : '0đ',
          color: giam > 0 ? Colors.green.shade700 : Colors.black,
        ),
        Divider(
          color: Colors.grey.shade600,
          height: 18,
        ),
        dong(
          'Tổng tiền',
          dinhDangTien(thanhTienSauGiam(ds)),
          color: const Color(0xff2454ff),
          dam: true,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    loaiThanhToan = 'deposit';
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      loaiThanhToan == 'deposit'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 17,
                      color: const Color(0xff2454ff),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Cọc',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      dinhDangTien(tienCoc(ds)),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff2454ff),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    loaiThanhToan = 'full';
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      loaiThanhToan == 'full'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 17,
                      color: const Color(0xff2454ff),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Toàn bộ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget noiDung(DatSan ds) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 185),
      child: Column(
        children: [
          thongTinCoSo(),
          thongTinDatSan(ds),
          const SizedBox(height: 12),
          voucher(ds),
          const SizedBox(height: 18),
          tongTienCard(ds),
        ],
      ),
    );
  }

  Widget thanhDuoi(DatSan ds) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
        color: Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 105,
              height: 43,
              child: OutlinedButton(
                onPressed:
                    dangHuy || dangGuiThanhToan ? null : huyGiuChoVaQuayLai,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xffcbd5e1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: dangHuy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Hủy',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 43,
                child: ElevatedButton(
                  onPressed:
                      dangGuiThanhToan || dangHuy ? null : taoThanhToanVnpay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2454ff),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: dangGuiThanhToan
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          loaiThanhToan == 'full'
                              ? 'Thanh toán'
                              : 'Thanh toán cọc',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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

  Widget noiDungLoi(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daDangNhap = context.watch<XuLiTaiKhoan>().daDangNhap;
    final ds = datSan;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfff5f9ff),
      body: nenTrang(
        child: Column(
          children: [
            thanhTieuDe(),
            Expanded(
              child: !daDangNhap
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
                      ? const HieuUngTai(
                          text: 'Đang tải thanh toán...',
                        )
                      : loi != null
                          ? noiDungLoi(loi!)
                          : ds == null
                              ? noiDungLoi('Không có dữ liệu đặt sân')
                              : noiDung(ds),
            ),
          ],
        ),
      ),
      bottomNavigationBar: daDangNhap && ds != null ? thanhDuoi(ds) : null,
    );
  }
}
class ManHinhDatSanThanhCong extends StatelessWidget {
  final String tenCoSo;
  final String ngayChoi;
  final String khungGio;
  final String tenSan;
  final String thoiLuong;
  final String maDatSan;
  final String maGiamGia;
  final String tongTien;

  const ManHinhDatSanThanhCong({
    super.key,
    required this.tenCoSo,
    required this.ngayChoi,
    required this.khungGio,
    required this.tenSan,
    required this.thoiLuong,
    required this.maDatSan,
    required this.maGiamGia,
    required this.tongTien,
  });

  Widget dongThongTin({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool dam = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xff2454ff),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: dam ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void veTrangChu(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void xemLichDaDat(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const ManHinhLichDatSan(),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f9ff),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              DuongDanAnh.Nen2,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => veTrangChu(context),
                        borderRadius: BorderRadius.circular(30),
                        child: const SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Đặt sân thành công',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 38),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xff22c55e),
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đặt sân thành công!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xff2454ff),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đã đặt sân thành công,\nchúc bạn có buổi chơi thật vui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(1, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin đặt sân',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        dongThongTin(
                          icon: Icons.home_work_outlined,
                          label: 'Tên sân',
                          value: tenCoSo,
                        ),
                        dongThongTin(
                          icon: Icons.calendar_month_outlined,
                          label: 'Ngày chơi',
                          value: ngayChoi,
                          valueColor: const Color(0xff2454ff),
                          dam: true,
                        ),
                        dongThongTin(
                          icon: Icons.access_time,
                          label: 'Khung giờ',
                          value: khungGio,
                          valueColor: const Color(0xff2454ff),
                          dam: true,
                        ),
                        dongThongTin(
                          icon: Icons.stadium_outlined,
                          label: 'Sân',
                          value: tenSan,
                          valueColor: const Color(0xff2454ff),
                          dam: true,
                        ),
                        dongThongTin(
                          icon: Icons.timer_outlined,
                          label: 'Thời lượng',
                          value: thoiLuong,
                          valueColor: const Color(0xff2454ff),
                          dam: true,
                        ),
                        dongThongTin(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Mã đặt sân',
                          value: maDatSan,
                        ),
                        dongThongTin(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Thanh toán',
                          value: 'Đã thanh toán',
                          valueColor: const Color(0xff16a34a),
                          dam: true,
                        ),
                        dongThongTin(
                          icon: Icons.local_offer_outlined,
                          label: 'Mã giảm giá',
                          value: maGiamGia.isEmpty ? '-' : maGiamGia,
                          valueColor: const Color(0xff2454ff),
                          dam: maGiamGia.isNotEmpty,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 20,
                                color: Color(0xff2454ff),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Tổng tiền',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                tongTien,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff2454ff),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => xemLichDaDat(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2454ff),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 21),
                          SizedBox(width: 10),
                          Text(
                            'Xem lịch đã đặt',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.chevron_right_rounded, size: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => veTrangChu(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff2454ff),
                        side: const BorderSide(
                          color: Color(0xff2454ff),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_outlined, size: 21),
                          SizedBox(width: 10),
                          Text(
                            'Về trang chủ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.chevron_right_rounded, size: 24),
                        ],
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
}
