import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_api.dart';
import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li/Xu_li_co_so.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import '../Xu_li/Xu_li_yeu_thich.dart';
import 'Man_hinh_chi_tiet_san.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_tat_ca_san.dart';
import '../Dung_lai/Hieu_ung_tai.dart';

class ManHinhTrangChu extends StatefulWidget {
  const ManHinhTrangChu({
    super.key,
  });

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuState();
}

class _BannerKhuyenMai {
  final int id;
  final CoSo coSo;
  final String tenKhuyenMai;
  final String giaTriHienThi;
  final String moTa;
  final String hanDung;
  final String badge;
  final String nutBam;
  final String anhNen;

  const _BannerKhuyenMai({
    required this.id,
    required this.coSo,
    required this.tenKhuyenMai,
    required this.giaTriHienThi,
    required this.moTa,
    required this.hanDung,
    required this.badge,
    required this.nutBam,
    required this.anhNen,
  });
}

class _ManHinhTrangChuState extends State<ManHinhTrangChu> {
  int bannerDangChon = 0;

  String tinhThanhDangChon = 'Tất cả';
  String sapXepDangChon = 'mac_dinh';
  String tuKhoaTimKiem = '';

  String loaiSanDangChon = 'tat_ca';
  double? giaTuDangChon;
  double? giaDenDangChon;

  DateTime? ngayDangChon;
  TimeOfDay? gioDangChon;

  bool chiHienConSan = false;
  bool chiHienCoGia = false;

  final PageController bannerController = PageController();
  final TextEditingController timKiemController = TextEditingController();


  List<_BannerKhuyenMai> danhSachBannerKhuyenMai = [];
  List<String> danhSachAnhBannerDaCo = [];
  bool dangTaiBannerKhuyenMai = false;

  final Random randomBanner = Random();

  Timer? timerBanner;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await taiDanhSachAnhBanner();

      if (!mounted) return;

      await context.read<XuLiYeuThich>().taiYeuThichDaLuu();

      if (!mounted) return;

      final xuLiCoSo = context.read<XuLiCoSo>();
      await xuLiCoSo.layDanhSachCoSo();

      if (!mounted) return;

      await taiBannerKhuyenMai(xuLiCoSo.danhSachCoSo);
    });

    batDauTuChayBanner();
  }


  @override
  void dispose() {
    timerBanner?.cancel();
    bannerController.dispose();
    timKiemController.dispose();
    super.dispose();
  }

  int soLuongBannerHienTai() {
    if (danhSachBannerKhuyenMai.isNotEmpty) {
      return danhSachBannerKhuyenMai.length > 5
          ? 5
          : danhSachBannerKhuyenMai.length;
    }

    return 5;
  }

  void batDauTuChayBanner() {
    timerBanner?.cancel();

    timerBanner = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        if (!mounted || !bannerController.hasClients) return;

        final soLuong = soLuongBannerHienTai();

        if (soLuong <= 1) return;

        int trangTiepTheo = bannerDangChon;

        while (trangTiepTheo == bannerDangChon) {
          trangTiepTheo = randomBanner.nextInt(soLuong);
        }

        bannerController.animateToPage(
          trangTiepTheo,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  void moDangNhapNeuLaKhach() {
    final taiKhoan = context.read<XuLiTaiKhoan>();

    if (taiKhoan.daDangNhap) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhDangNhap(),
      ),
    );
  }

  String layChuCaiDau(String ten) {
    if (ten.trim().isEmpty) return 'U';

    final tachTen = ten.trim().split(' ');
    final chuCuoi = tachTen.last;

    if (chuCuoi.isEmpty) return 'U';

    return chuCuoi[0].toUpperCase();
  }

  String dinhDangGia(double gia) {
    return '${gia.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String dinhDangNgay(DateTime ngay) {
    final ngayText = ngay.day.toString().padLeft(2, '0');
    final thangText = ngay.month.toString().padLeft(2, '0');

    return '$ngayText/$thangText';
  }

  String dinhDangNgayDayDu(DateTime? ngay) {
    if (ngay == null) return '';

    final ngayText = ngay.day.toString().padLeft(2, '0');
    final thangText = ngay.month.toString().padLeft(2, '0');

    return '$ngayText/$thangText/${ngay.year}';
  }


  String dinhDangGio(TimeOfDay gio) {
    final gioText = gio.hour.toString().padLeft(2, '0');
    final phutText = gio.minute.toString().padLeft(2, '0');

    return '$gioText:$phutText';
  }

  String hienThiSoSan(CoSo coSo) {
    final soSan =
        coSo.soLuongSan > 0 ? coSo.soLuongSan : coSo.danhSachSan.length;

    return '$soSan sân';
  }

  String tenTinhHienThi(String tinh) {
    final text = tinh.trim();

    if (text.isEmpty || text == 'Tất cả') {
      return 'Tất cả';
    }

    return text;
  }

  String tenNutLoc() {
    if (chiHienConSan ||
        chiHienCoGia ||
        loaiSanDangChon != 'tat_ca' ||
        giaTuDangChon != null ||
        giaDenDangChon != null) {
      return 'Đã lọc';
    }

    return 'Lọc';
  }

  String tenNutNgay() {
    if (ngayDangChon == null) return 'Ngày';

    return dinhDangNgay(ngayDangChon!);
  }

  String tenNutGio() {
    if (gioDangChon == null) return 'Giờ';

    return dinhDangGio(gioDangChon!);
  }

  String tenNutSapXep() {
    switch (sapXepDangChon) {
      case 'gia_tang':
        return 'Giá thấp';
      case 'gia_giam':
        return 'Giá cao';
      case 'nhieu_san':
        return 'Nhiều';
      case 'ten_az':
        return 'A-Z';
      case 'mac_dinh':
      default:
        return 'Sắp xếp';
    }
  }

  String tieuDeDanhSach() {
    if (tuKhoaTimKiem.trim().isNotEmpty) {
      return 'Kết quả tìm kiếm "${tuKhoaTimKiem.trim()}"';
    }

    if (tinhThanhDangChon != 'Tất cả') {
      return 'Sân ở ${tenTinhHienThi(tinhThanhDangChon)}';
    }

    if (ngayDangChon != null && gioDangChon != null) {
      return 'Sân ${dinhDangNgay(ngayDangChon!)} - ${dinhDangGio(gioDangChon!)}';
    }

    if (ngayDangChon != null) {
      return 'Sân ngày ${dinhDangNgay(ngayDangChon!)}';
    }

    if (gioDangChon != null) {
      return 'Sân lúc ${dinhDangGio(gioDangChon!)}';
    }

    return 'Gợi ý cho bạn';
  }

  bool gioNamTrongKhungHoatDong() {
    if (gioDangChon == null) return true;

    final tongPhut = gioDangChon!.hour * 60 + gioDangChon!.minute;

    const gioMoCua = 6 * 60;
    const gioDongCua = 22 * 60;

    return tongPhut >= gioMoCua && tongPhut < gioDongCua;
  }

  bool gioDaQua() {
    if (gioDangChon == null) return false;

    final bayGio = DateTime.now();

    final ngayKiemTra = ngayDangChon ??
        DateTime(
          bayGio.year,
          bayGio.month,
          bayGio.day,
        );

    final laHomNay = ngayKiemTra.year == bayGio.year &&
        ngayKiemTra.month == bayGio.month &&
        ngayKiemTra.day == bayGio.day;

    if (!laHomNay) return false;

    final phutDaChon = gioDangChon!.hour * 60 + gioDangChon!.minute;
    final phutHienTai = bayGio.hour * 60 + bayGio.minute;

    return phutDaChon <= phutHienTai;
  }

  bool coSoConSan(CoSo coSo) {
    return coSo.soLuongSan > 0 || coSo.danhSachSan.isNotEmpty;
  }

  bool coSoCoGia(CoSo coSo) {
    return coSo.giaThapNhat > 0;
  }

  double? docGiaTien(String value) {
    final text = value
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('đ', '')
        .replaceAll(' ', '');

    if (text.isEmpty) return null;

    return double.tryParse(text);
  }

  String layThongTinLoaiSan(dynamic san) {
    final getters = <String Function()>[
      () => '${san.tenDanhMuc}',
      () => '${san.ten_danh_muc}',
      () => '${san.loaiSan}',
      () => '${san.loai_san}',
      () => '${san.danhMuc}',
      () => '${san.danh_muc}',
      () => '${san.tenLoai}',
      () => '${san.ten_loai}',
      () => '${san.ten}',
    ];

    for (final getter in getters) {
      try {
        final value = getter().trim();

        if (value.isNotEmpty && value != 'null') {
          return value.toLowerCase();
        }
      } catch (_) {}
    }

    return '';
  }

  bool coSoDungLoaiSan(CoSo coSo) {
    if (loaiSanDangChon == 'tat_ca') {
      return true;
    }

    final danhSachSan = coSo.danhSachSan;

    if (danhSachSan.isEmpty) {
      return true;
    }

    bool coThongTinLoaiSan = false;

    for (final dynamic san in danhSachSan) {
      final text = layThongTinLoaiSan(san);

      if (text.isEmpty) continue;

      coThongTinLoaiSan = true;

      final laVip = text.contains('vip');

      if (loaiSanDangChon == 'vip' && laVip) {
        return true;
      }

      if (loaiSanDangChon == 'thuong' && !laVip) {
        return true;
      }
    }

    if (!coThongTinLoaiSan) {
      return true;
    }

    return false;
  }

  bool coSoDungKhoangGia(CoSo coSo) {
    if (giaTuDangChon == null && giaDenDangChon == null) {
      return true;
    }

    final gia = coSo.giaThapNhat;

    if (gia <= 0) {
      return false;
    }

    if (giaTuDangChon != null && gia < giaTuDangChon!) {
      return false;
    }

    if (giaDenDangChon != null && gia > giaDenDangChon!) {
      return false;
    }

    return true;
  }

  String chuanHoaTimKiem(String text) {
    return text
        .toLowerCase()
        .replaceAll('à', 'a')
        .replaceAll('á', 'a')
        .replaceAll('ạ', 'a')
        .replaceAll('ả', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ầ', 'a')
        .replaceAll('ấ', 'a')
        .replaceAll('ậ', 'a')
        .replaceAll('ẩ', 'a')
        .replaceAll('ẫ', 'a')
        .replaceAll('ă', 'a')
        .replaceAll('ằ', 'a')
        .replaceAll('ắ', 'a')
        .replaceAll('ặ', 'a')
        .replaceAll('ẳ', 'a')
        .replaceAll('ẵ', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ẹ', 'e')
        .replaceAll('ẻ', 'e')
        .replaceAll('ẽ', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ề', 'e')
        .replaceAll('ế', 'e')
        .replaceAll('ệ', 'e')
        .replaceAll('ể', 'e')
        .replaceAll('ễ', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('í', 'i')
        .replaceAll('ị', 'i')
        .replaceAll('ỉ', 'i')
        .replaceAll('ĩ', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ọ', 'o')
        .replaceAll('ỏ', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ồ', 'o')
        .replaceAll('ố', 'o')
        .replaceAll('ộ', 'o')
        .replaceAll('ổ', 'o')
        .replaceAll('ỗ', 'o')
        .replaceAll('ơ', 'o')
        .replaceAll('ờ', 'o')
        .replaceAll('ớ', 'o')
        .replaceAll('ợ', 'o')
        .replaceAll('ở', 'o')
        .replaceAll('ỡ', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('ụ', 'u')
        .replaceAll('ủ', 'u')
        .replaceAll('ũ', 'u')
        .replaceAll('ư', 'u')
        .replaceAll('ừ', 'u')
        .replaceAll('ứ', 'u')
        .replaceAll('ự', 'u')
        .replaceAll('ử', 'u')
        .replaceAll('ữ', 'u')
        .replaceAll('ỳ', 'y')
        .replaceAll('ý', 'y')
        .replaceAll('ỵ', 'y')
        .replaceAll('ỷ', 'y')
        .replaceAll('ỹ', 'y')
        .replaceAll('đ', 'd');
  }

  List<String> layDanhSachTinhThanh(List<CoSo> danhSachCoSo) {
    final setTinh = <String>{};

    for (final coSo in danhSachCoSo) {
      final tinh = coSo.tinhThanh.trim();

      if (tinh.isNotEmpty) {
        setTinh.add(tinh);
      }
    }

    final list = setTinh.toList();
    list.sort();

    return list;
  }

  List<CoSo> locTheoTuKhoa(List<CoSo> danhSachCoSo) {
    final tuKhoa = chuanHoaTimKiem(tuKhoaTimKiem.trim());

    if (tuKhoa.isEmpty) {
      return danhSachCoSo;
    }

    return danhSachCoSo.where((coSo) {
      final ten = chuanHoaTimKiem(coSo.tenCoSo);
      final diaChi = chuanHoaTimKiem(coSo.diaChi);
      final tinh = chuanHoaTimKiem(coSo.tinhThanh);

      return ten.contains(tuKhoa) ||
          diaChi.contains(tuKhoa) ||
          tinh.contains(tuKhoa);
    }).toList();
  }

  List<CoSo> locCoSoTheoTinh(List<CoSo> danhSachCoSo) {
    if (tinhThanhDangChon == 'Tất cả') {
      return danhSachCoSo;
    }

    return danhSachCoSo.where((coSo) {
      return coSo.tinhThanh.trim() == tinhThanhDangChon;
    }).toList();
  }

  List<CoSo> locTheoBoLoc(List<CoSo> danhSachCoSo) {
    var list = [...danhSachCoSo];

    if (chiHienConSan) {
      list = list.where(coSoConSan).toList();
    }

    if (chiHienCoGia) {
      list = list.where(coSoCoGia).toList();
    }

    list = list.where(coSoDungLoaiSan).toList();
    list = list.where(coSoDungKhoangGia).toList();

    return list;
  }

  List<CoSo> sapXepDanhSach(List<CoSo> danhSachCoSo) {
    final list = [...danhSachCoSo];

    switch (sapXepDangChon) {
      case 'gia_tang':
        list.sort((a, b) {
          final giaA = a.giaThapNhat <= 0 ? double.maxFinite : a.giaThapNhat;
          final giaB = b.giaThapNhat <= 0 ? double.maxFinite : b.giaThapNhat;

          return giaA.compareTo(giaB);
        });
        break;

      case 'gia_giam':
        list.sort((a, b) {
          return b.giaThapNhat.compareTo(a.giaThapNhat);
        });
        break;

      case 'nhieu_san':
        list.sort((a, b) {
          final sanA = a.soLuongSan > 0 ? a.soLuongSan : a.danhSachSan.length;
          final sanB = b.soLuongSan > 0 ? b.soLuongSan : b.danhSachSan.length;

          return sanB.compareTo(sanA);
        });
        break;

      case 'ten_az':
        list.sort((a, b) {
          return a.tenCoSo.toLowerCase().compareTo(
                b.tenCoSo.toLowerCase(),
              );
        });
        break;

      case 'mac_dinh':
      default:
        break;
    }

    return list;
  }

  List<CoSo> layDanhSachHienThi(List<CoSo> danhSachCoSo) {
    if (!gioNamTrongKhungHoatDong()) {
      return [];
    }

    if (gioDaQua()) {
      return [];
    }

    final theoTuKhoa = locTheoTuKhoa(danhSachCoSo);
    final theoTinh = locCoSoTheoTinh(theoTuKhoa);
    final theoLoc = locTheoBoLoc(theoTinh);
    final daSapXep = sapXepDanhSach(theoLoc);

    return daSapXep;
  }


  List<dynamic> layMang(dynamic data, List<String> keys) {
    if (data is List) return data;

    if (data is Map) {
      for (final key in keys) {
        final value = data[key];

        if (value is List) return value;
      }

      if (data['data'] is Map) {
        return layMang(data['data'], keys);
      }
    }

    return [];
  }

  String layTextMap(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value == null) continue;

      final text = '$value'.trim();

      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return '';
  }

  int layIntMap(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value == null) continue;

      if (value is num) return value.toInt();

      final text = '$value'.trim();
      final so = int.tryParse(text) ?? double.tryParse(text)?.toInt();

      if (so != null) return so;
    }

    return 0;
  }

  double layDoubleMap(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value == null) continue;

      if (value is num) return value.toDouble();

      final text = '$value'
          .replaceAll('đ', '')
          .replaceAll('%', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll(' ', '')
          .trim();

      final so = double.tryParse(text);

      if (so != null) return so;
    }

    return 0;
  }

  DateTime? layNgayMap(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value == null) continue;

      final text = '$value'.trim();

      if (text.isEmpty || text.toLowerCase() == 'null') continue;

      final ngay = DateTime.tryParse(text);

      if (ngay != null) return ngay;
    }

    return null;
  }

  Future<void> taiDanhSachAnhBanner() async {
    final fallback = [
      DuongDanAnh.banner1,
      DuongDanAnh.banner2,
      DuongDanAnh.banner3,
      DuongDanAnh.banner4,
      DuongDanAnh.banner5,
      'assets/images/Banner1.png',
      'assets/images/Banner2.png',
      'assets/images/Banner3.png',
      'assets/images/Banner4.png',
      'assets/images/Banner5.png',
    ];

    try {
      List<String> assets = [];

      try {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        assets = manifest.listAssets();
      } catch (_) {
        final raw = await rootBundle.loadString('AssetManifest.json');
        final map = jsonDecode(raw) as Map<String, dynamic>;
        assets = map.keys.toList();
      }

      final danhSach = assets.where((path) {
        final lower = path.toLowerCase();

        return lower.startsWith('assets/images/') &&
            lower.contains('banner') &&
            (lower.endsWith('.png') ||
                lower.endsWith('.jpg') ||
                lower.endsWith('.jpeg') ||
                lower.endsWith('.webp'));
      }).toList();

      danhSach.sort((a, b) {
        return soThuTuBanner(a).compareTo(soThuTuBanner(b));
      });

      if (!mounted) return;

      setState(() {
        danhSachAnhBannerDaCo = danhSach.isEmpty ? fallback.take(5).toList() : danhSach;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        danhSachAnhBannerDaCo = fallback.take(5).toList();
      });
    }
  }

  int soThuTuBanner(String path) {
    final match = RegExp(r'banner[^0-9]*([0-9]+)').firstMatch(
      path.toLowerCase(),
    );

    return int.tryParse(match?.group(1) ?? '') ?? 999;
  }

  int laySoBannerTuTenAnh(String anhNen) {
    final match = RegExp(r'banner[^0-9]*([0-9]+)').firstMatch(
      anhNen.toLowerCase(),
    );

    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  Color mauTheoBanner(String anhNen) {
    final soBanner = laySoBannerTuTenAnh(anhNen);

    switch (soBanner) {
      case 1:
        return const Color(0xff7c3aed);
      case 2:
        return const Color(0xffff9800);
      case 3:
        return const Color(0xff16a34a);
      case 4:
        return const Color(0xff0284c7);
      case 5:
        return const Color(0xff2563eb);
      default:
        return const Color(0xff2454ff);
    }
  }

  Color mauChuPhuTheoBanner(String anhNen) {
    final soBanner = laySoBannerTuTenAnh(anhNen);

    switch (soBanner) {
      case 1:
        return const Color(0xff3b0764);
      case 2:
        return const Color(0xff78350f);
      case 3:
        return const Color(0xff14532d);
      case 4:
        return const Color(0xff075985);
      case 5:
        return const Color(0xff1e3a8a);
      default:
        return const Color(0xff0f235c);
    }
  }

  Color mauNenNheTheoBanner(String anhNen) {
    final soBanner = laySoBannerTuTenAnh(anhNen);

    switch (soBanner) {
      case 1:
        return const Color(0xfff3e8ff);
      case 2:
        return const Color(0xfffff3d6);
      case 3:
        return const Color(0xffecfdf5);
      case 4:
        return const Color(0xffe0f2fe);
      case 5:
        return const Color(0xffeff6ff);
      default:
        return const Color(0xffeaf3ff);
    }
  }

  List<String> layDanhSachAnhBannerNgauNhien() {
    final fallback = [
      DuongDanAnh.banner1,
      DuongDanAnh.banner2,
      DuongDanAnh.banner3,
      DuongDanAnh.banner4,
      DuongDanAnh.banner5,
    ];

    final banners = danhSachAnhBannerDaCo.isNotEmpty
        ? [...danhSachAnhBannerDaCo]
        : [...fallback];

    final ketQua = <String>[];

    for (int i = 1; i <= 5; i++) {
      final index = banners.indexWhere((path) {
        return laySoBannerTuTenAnh(path) == i;
      });

      if (index >= 0) {
        ketQua.add(banners[index]);
      } else {
        ketQua.add(fallback[i - 1]);
      }
    }

    return ketQua;
  }

  String layAnhNenBanner(List<String> danhSachAnh, int index) {
    if (danhSachAnh.isEmpty) {
      return DuongDanAnh.banner1;
    }

    return danhSachAnh[index % danhSachAnh.length];
  }


  CoSo? timCoSoTheoKhuyenMai(
    Map<String, dynamic> item,
    List<CoSo> danhSachCoSo,
  ) {
    final coSoId = layIntMap(
      item,
      const [
        'co_so_id',
        'coSoId',
        'coso_id',
        'cosoId',
        'id_co_so',
        'idCoSo',
        'san_id',
        'sanId',
      ],
    );

    if (coSoId > 0) {
      for (final coSo in danhSachCoSo) {
        if (coSo.id == coSoId) {
          return coSo;
        }
      }
    }

    final coSoRaw = item['co_so'] ??
        item['coSo'] ??
        item['coso'] ??
        item['facility'] ??
        item['san'];

    if (coSoRaw is Map) {
      try {
        return CoSo.fromJson(
          Map<String, dynamic>.from(coSoRaw),
        );
      } catch (_) {}
    }

    return null;
  }

  bool khuyenMaiSapHetHan(Map<String, dynamic> item) {
    final ngayKetThuc = layNgayMap(
      item,
      const [
        'ngay_ket_thuc',
        'ngayKetThuc',
        'han_su_dung',
        'hanSuDung',
        'end_date',
        'endDate',
        'expired_at',
        'expiredAt',
      ],
    );

    if (ngayKetThuc == null) return false;

    final homNay = DateTime.now();
    final ngayHomNay = DateTime(homNay.year, homNay.month, homNay.day);
    final ngayHetHan = DateTime(
      ngayKetThuc.year,
      ngayKetThuc.month,
      ngayKetThuc.day,
    );

    final soNgayConLai = ngayHetHan.difference(ngayHomNay).inDays;

    return soNgayConLai >= 0 && soNgayConLai <= 3;
  }

  String layBadgeKhuyenMai(Map<String, dynamic> item) {
    if (khuyenMaiSapHetHan(item)) {
      return 'SẮP HẾT HẠN';
    }

    final loai = layTextMap(
      item,
      const [
        'loai_giam_gia',
        'loaiGiamGia',
        'loai_giam',
        'loaiGiam',
        'kieu_giam',
        'kieuGiam',
        'type',
      ],
    ).toLowerCase();

    if (loai.contains('phan') ||
        loai.contains('%') ||
        loai.contains('percent')) {
      return 'ƯU ĐÃI';
    }

    if (loai.contains('tien') ||
        loai.contains('money') ||
        loai.contains('fixed')) {
      return 'VOUCHER';
    }

    return 'KHUYẾN MÃI';
  }

  String layGiaTriKhuyenMai(Map<String, dynamic> item) {
    final loai = layTextMap(
      item,
      const [
        'loai_giam_gia',
        'loaiGiamGia',
        'loai_giam',
        'loaiGiam',
        'kieu_giam',
        'kieuGiam',
        'type',
      ],
    ).toLowerCase();

    final giaTri = layDoubleMap(
      item,
      const [
        'gia_tri_giam',
        'giaTriGiam',
        'gia_tri',
        'giaTri',
        'value',
        'discount',
        'discount_value',
        'discountValue',
        'so_tien_giam',
        'soTienGiam',
        'phan_tram_giam',
        'phanTramGiam',
      ],
    );

    if (giaTri <= 0) {
      return 'Ưu đãi hấp dẫn';
    }

    if (loai.contains('phan') ||
        loai.contains('%') ||
        loai.contains('percent')) {
      return 'Giảm ${giaTri.toStringAsFixed(0)}%';
    }

    return 'Giảm ${dinhDangGia(giaTri)}';
  }

  String layTenKhuyenMai(Map<String, dynamic> item) {
    final ten = layTextMap(
      item,
      const [
        'ten_khuyen_mai',
        'tenKhuyenMai',
        'ten',
        'name',
        'title',
        'tieu_de',
        'tieuDe',
      ],
    );

    if (ten.isNotEmpty) return ten;

    return 'Ưu đãi đặt sân';
  }

  String layMoTaKhuyenMai(Map<String, dynamic> item, CoSo coSo) {
    final moTa = layTextMap(
      item,
      const [
        'mo_ta',
        'moTa',
        'description',
        'noi_dung',
        'noiDung',
        'ghi_chu',
        'ghiChu',
      ],
    );

    if (moTa.isNotEmpty) return moTa;

    if (coSo.giaThapNhat > 0) {
      return 'Chỉ từ ${dinhDangGia(coSo.giaThapNhat)}/giờ tại ${coSo.tenCoSo}';
    }

    return 'Ưu đãi dành cho ${coSo.tenCoSo}';
  }

  String layHanDungKhuyenMai(Map<String, dynamic> item) {
    final ngayKetThuc = layNgayMap(
      item,
      const [
        'ngay_ket_thuc',
        'ngayKetThuc',
        'han_su_dung',
        'hanSuDung',
        'end_date',
        'endDate',
        'expired_at',
        'expiredAt',
      ],
    );

    if (ngayKetThuc == null) {
      return 'Đang áp dụng';
    }

    return 'Hạn dùng: ${dinhDangNgayDayDu(ngayKetThuc)}';
  }

  

  Future<void> taiBannerKhuyenMai(List<CoSo> danhSachCoSo) async {
    // Không gọi API khuyến mãi để tránh lỗi /api/api và lỗi cơ sở không hợp lệ.
    // Banner lấy 5 ảnh trong assets/images/banner1.png -> banner5.png.
    // Cứ 5 giây timer sẽ nhảy ngẫu nhiên sang 1 banner khác trong 5 banner.
    if (!mounted) return;

    final danhSachAnh = layDanhSachAnhBannerNgauNhien();
    final danhSach = danhSachCoSo
        .where((coSo) => coSo.id > 0)
        .toList();

    danhSach.shuffle();

    final banners = <_BannerKhuyenMai>[];

    if (danhSach.isEmpty) {
      for (int i = 0; i < danhSachAnh.length; i++) {
        banners.add(
          _BannerKhuyenMai(
            id: i,
            coSo: CoSo(
              id: 0,
              ten: 'Badminton Booking',
              diaChi: '',
              moTa: '',
            ),
            tenKhuyenMai: 'Đặt sân nhanh chóng',
            giaTriHienThi: i == 0
                ? 'Tìm sân gần bạn'
                : i == 1
                    ? 'Chọn giờ linh hoạt'
                    : i == 2
                        ? 'Sân đẹp dễ đặt'
                        : i == 3
                            ? 'Đặt sân tiện lợi'
                            : 'Sẵn sàng ra sân',
            moTa: 'Tìm sân • Chọn giờ • Xác nhận đặt sân',
            hanDung: 'Khám phá sân cầu lông gần bạn',
            badge: 'BADMINTON',
            nutBam: 'Khám phá',
            anhNen: layAnhNenBanner(danhSachAnh, i),
          ),
        );
      }
    } else {
      for (int i = 0; i < danhSachAnh.length; i++) {
        final coSo = danhSach[i % danhSach.length];

        banners.add(
          taoBannerTuCoSo(
            coSo,
            danhSachAnh,
            i,
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      danhSachBannerKhuyenMai = banners.take(5).toList();
      bannerDangChon = 0;
      dangTaiBannerKhuyenMai = false;
    });

    if (bannerController.hasClients) {
      bannerController.jumpToPage(0);
    }
  }

  _BannerKhuyenMai taoBannerTuCoSo(
    CoSo coSo,
    List<String> danhSachAnh,
    int index,
  ) {
    final gia = coSo.giaThapNhat > 0
        ? 'Từ ${dinhDangGia(coSo.giaThapNhat)}/giờ'
        : 'Đặt sân nhanh';

    return _BannerKhuyenMai(
      id: coSo.id,
      coSo: coSo,
      tenKhuyenMai: 'Sân cầu lông nổi bật',
      giaTriHienThi: gia,
      moTa: coSo.tenCoSo,
      hanDung:
          '${hienThiSoSan(coSo)} • ${coSo.tinhThanh.isEmpty ? 'Sẵn sàng đặt sân' : coSo.tinhThanh}',
      badge: 'GỢI Ý',
      nutBam: 'Xem sân',
      anhNen: layAnhNenBanner(danhSachAnh, index),
    );
  }


  List<_BannerKhuyenMai> taoBannerMacDinh(List<CoSo> danhSachCoSo) {
    final danhSachAnh = layDanhSachAnhBannerNgauNhien();

    final danhSach = danhSachCoSo
        .where((coSo) => coSo.id > 0)
        .toList();

    danhSach.shuffle();

    if (danhSach.isEmpty) {
      return List.generate(danhSachAnh.length, (index) {
        return _BannerKhuyenMai(
          id: index,
          coSo: CoSo(
            id: 0,
            ten: 'Badminton Booking',
            diaChi: '',
            moTa: '',
          ),
          tenKhuyenMai: 'Đặt sân nhanh chóng',
          giaTriHienThi: index == 0
              ? 'Tìm sân gần bạn'
              : index == 1
                  ? 'Chọn giờ linh hoạt'
                  : index == 2
                      ? 'Sân đẹp dễ đặt'
                      : index == 3
                          ? 'Đặt sân tiện lợi'
                          : 'Sẵn sàng ra sân',
          moTa: 'Tìm sân • Chọn giờ • Xác nhận đặt sân',
          hanDung: 'Khám phá sân cầu lông gần bạn',
          badge: 'BADMINTON',
          nutBam: 'Khám phá',
          anhNen: layAnhNenBanner(danhSachAnh, index),
        );
      });
    }

    return List.generate(danhSachAnh.length, (index) {
      return taoBannerTuCoSo(
        danhSach[index % danhSach.length],
        danhSachAnh,
        index,
      );
    });
  }

  void xoaBoLocTrongNutLoc() {
    setState(() {
      chiHienConSan = false;
      chiHienCoGia = false;
      loaiSanDangChon = 'tat_ca';
      giaTuDangChon = null;
      giaDenDangChon = null;
    });
  }

  void xoaNgayDangChon() {
    setState(() {
      ngayDangChon = null;
    });
  }

  void xoaGioDangChon() {
    setState(() {
      gioDangChon = null;
    });
  }

  void xoaTuKhoaTimKiem() {
    timKiemController.clear();

    setState(() {
      tuKhoaTimKiem = '';
    });
  }

  Future<void> chonNgay() async {
    final homNay = DateTime.now();

    final ngay = await showDatePicker(
      context: context,
      initialDate: ngayDangChon ?? homNay,
      firstDate: homNay,
      lastDate: homNay.add(
        const Duration(days: 60),
      ),
      helpText: 'Chọn ngày đặt sân',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (ngay == null) return;
    if (!mounted) return;

    setState(() {
      ngayDangChon = ngay;
    });
  }

  Future<void> chonGio() async {
    final gio = await showTimePicker(
      context: context,
      initialTime: gioDangChon ?? TimeOfDay.now(),
      helpText: 'Chọn giờ chơi',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (gio == null) return;
    if (!mounted) return;

    setState(() {
      gioDangChon = gio;
    });
  }

  void moBoLoc() {
    String tamLoaiSan = loaiSanDangChon;
    bool tamConSan = chiHienConSan;
    bool tamCoGia = chiHienCoGia;

    final giaTuController = TextEditingController(
      text: giaTuDangChon == null ? '' : giaTuDangChon!.toStringAsFixed(0),
    );

    final giaDenController = TextEditingController(
      text: giaDenDangChon == null ? '' : giaDenDangChon!.toStringAsFixed(0),
    );

    Widget nutLoaiSan({
      required String value,
      required String text,
      required String tamValue,
      required void Function(String value) onChanged,
    }) {
      final dangChon = tamValue == value;

      return Expanded(
        child: InkWell(
          onTap: () {
            onChanged(value);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 39,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dangChon ? const Color(0xffeef4ff) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    dangChon ? const Color(0xff2454ff) : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: dangChon ? const Color(0xff2454ff) : Colors.black87,
                fontWeight: dangChon ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    Widget oNhapGia({
      required String label,
      required TextEditingController controller,
      required String hint,
    }) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 42,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(
                      color: Color(0xff2454ff),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget dongCongTac({
      required String title,
      required bool value,
      required void Function(bool value) onChanged,
    }) {
      return InkWell(
        onTap: () {
          onChanged(!value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: value ? const Color(0xffeef4ff) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? const Color(0xff2454ff) : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.4,
                    color: value ? const Color(0xff2454ff) : Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 22,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: value ? const Color(0xff2454ff) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final rongManHinh = MediaQuery.of(dialogContext).size.width;
        final caoManHinh = MediaQuery.of(dialogContext).size.height;
        final rongHop = rongManHinh > 520 ? 420.0 : rongManHinh - 32;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                width: rongHop,
                constraints: BoxConstraints(
                  maxHeight: caoManHinh * 0.78,
                ),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Bộ lọc',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(dialogContext);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 21,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      Text(
                        'LOẠI SÂN',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          nutLoaiSan(
                            value: 'tat_ca',
                            text: 'Tất cả',
                            tamValue: tamLoaiSan,
                            onChanged: (value) {
                              setDialogState(() {
                                tamLoaiSan = value;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          nutLoaiSan(
                            value: 'thuong',
                            text: 'Sân thường',
                            tamValue: tamLoaiSan,
                            onChanged: (value) {
                              setDialogState(() {
                                tamLoaiSan = value;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          nutLoaiSan(
                            value: 'vip',
                            text: 'Sân VIP',
                            tamValue: tamLoaiSan,
                            onChanged: (value) {
                              setDialogState(() {
                                tamLoaiSan = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          oNhapGia(
                            label: 'GIÁ TỪ',
                            controller: giaTuController,
                            hint: '0',
                          ),
                          const SizedBox(width: 12),
                          oNhapGia(
                            label: 'GIÁ ĐẾN',
                            controller: giaDenController,
                            hint: '200000',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      dongCongTac(
                        title: 'Chỉ hiện sân còn sân',
                        value: tamConSan,
                        onChanged: (value) {
                          setDialogState(() {
                            tamConSan = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      dongCongTac(
                        title: 'Chỉ hiện sân có giá',
                        value: tamCoGia,
                        onChanged: (value) {
                          setDialogState(() {
                            tamCoGia = value;
                          });
                        },
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    loaiSanDangChon = 'tat_ca';
                                    giaTuDangChon = null;
                                    giaDenDangChon = null;
                                    chiHienConSan = false;
                                    chiHienCoGia = false;
                                  });

                                  Navigator.pop(dialogContext);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  backgroundColor: Colors.grey.shade100,
                                  side: BorderSide(
                                    color: Colors.grey.shade100,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: const Text(
                                  'Xóa lọc',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    loaiSanDangChon = tamLoaiSan;
                                    giaTuDangChon =
                                        docGiaTien(giaTuController.text);
                                    giaDenDangChon =
                                        docGiaTien(giaDenController.text);
                                    chiHienConSan = tamConSan;
                                    chiHienCoGia = tamCoGia;
                                  });

                                  Navigator.pop(dialogContext);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2454ff),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: const Text(
                                  'Áp dụng',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      giaTuController.dispose();
      giaDenController.dispose();
    });
  }

  void moSapXep() {
    Widget itemSapXep({
      required String value,
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      final dangChon = sapXepDangChon == value;

      return ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 0,
        ),
        leading: Icon(
          dangChon ? Icons.radio_button_checked : Icons.radio_button_off,
          color: const Color(0xff2454ff),
          size: 19,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.8,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.4,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          icon,
          color: Colors.black54,
          size: 18,
        ),
        onTap: () {
          setState(() {
            sapXepDangChon = value;
          });
          Navigator.pop(context);
        },
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.50,
          minChildSize: 0.35,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 14),
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Sắp xếp sân',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    itemSapXep(
                      value: 'mac_dinh',
                      icon: Icons.restart_alt_rounded,
                      title: 'Mặc định',
                      subtitle: 'Giữ thứ tự ban đầu',
                    ),
                    itemSapXep(
                      value: 'gia_tang',
                      icon: Icons.arrow_upward_rounded,
                      title: 'Giá thấp đến cao',
                      subtitle: 'Ưu tiên sân rẻ hơn',
                    ),
                    itemSapXep(
                      value: 'gia_giam',
                      icon: Icons.arrow_downward_rounded,
                      title: 'Giá cao đến thấp',
                      subtitle: 'Sắp xếp giá cao trước',
                    ),
                    itemSapXep(
                      value: 'nhieu_san',
                      icon: Icons.stadium_outlined,
                      title: 'Nhiều sân nhất',
                      subtitle: 'Ưu tiên cơ sở có nhiều sân',
                    ),
                    itemSapXep(
                      value: 'ten_az',
                      icon: Icons.sort_by_alpha_rounded,
                      title: 'Tên A-Z',
                      subtitle: 'Sắp xếp theo tên cơ sở',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void chuyenChiTietCoSo(CoSo coSo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhChiTietSan(
          coSo: coSo,
        ),
      ),
    );
  }

  void chuyenTatCaCoSo({
    bool focusTimKiem = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhTatCaSan(
          tuDongFocusTimKiem: focusTimKiem,
        ),
      ),
    );
  }

  Future<void> doiYeuThich(CoSo coSo) async {
    await context.read<XuLiYeuThich>().doiYeuThich(coSo.id);
  }

  Widget avatarTrangChu({
    required String hoTen,
    required String avatar,
    required bool daDangNhap,
  }) {
    if (!daDangNhap) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: 29,
          color: Colors.black,
        ),
      );
    }

    Widget noiDungAvatar;

    if (avatar.isNotEmpty) {
      if (File(avatar).existsSync()) {
        noiDungAvatar = ClipOval(
          child: Image.file(
            File(avatar),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return avatarChuCaiNho(hoTen);
            },
          ),
        );
      } else {
        noiDungAvatar = ClipOval(
          child: Image.network(
            DuongDanApi.linkAnh(avatar),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return avatarChuCaiNho(hoTen);
            },
          ),
        );
      }
    } else {
      noiDungAvatar = avatarChuCaiNho(hoTen);
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xff2454ff),
            Color(0xff60a5fa),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: noiDungAvatar,
    );
  }

  Widget avatarChuCaiNho(String hoTen) {
    return Center(
      child: Text(
        layChuCaiDau(hoTen),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget oTimKiemTrangChu() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(1, 2.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: timKiemController,
              onChanged: (value) {
                setState(() {
                  tuKhoaTimKiem = value;
                });
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm sân cầu lông',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 1),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (tuKhoaTimKiem.isNotEmpty)
            InkWell(
              onTap: xoaTuKhoaTimKiem,
              borderRadius: BorderRadius.circular(20),
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade600,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget nutLoc({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onXoa,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 34,
            padding: const EdgeInsets.only(left: 8, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xffe7f1ff).withOpacity(0.96),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.10),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 13,
                    color: const Color(0xff2454ff),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 10.8,
                    color: Color(0xff1d3f91),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onXoa != null)
          Positioned(
            top: -7,
            right: -6,
            child: InkWell(
              onTap: onXoa,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xff2454ff),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Color(0xff2454ff),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget nutChonTinhThanh(List<CoSo> danhSachCoSo) {
    final danhSachTinh = layDanhSachTinhThanh(danhSachCoSo);
    final danhSachHienThi = ['Tất cả', ...danhSachTinh];
    final ten = tenTinhHienThi(tinhThanhDangChon);

    return PopupMenuButton<String>(
      tooltip: 'Chọn tỉnh/thành',
      color: Colors.white,
      elevation: 8,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      constraints: const BoxConstraints(
        minWidth: 170,
        maxWidth: 220,
        maxHeight: 310,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        setState(() {
          tinhThanhDangChon = value;
        });
      },
      itemBuilder: (context) {
        return danhSachHienThi.map((tinh) {
          final dangChon = tinhThanhDangChon == tinh;
          final tenHienThi = tinh == 'Tất cả' ? 'Tất cả khu vực' : tinh;

          return PopupMenuItem<String>(
            value: tinh,
            height: 36,
            child: Row(
              children: [
                Icon(
                  dangChon
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xff2454ff),
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tenHienThi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: dangChon ? FontWeight.w900 : FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 32,
        constraints: const BoxConstraints(
          maxWidth: 165,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Colors.black87,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                ten,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 1),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 17,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }


  Widget bannerVoucher() {
    final xuLiCoSo = context.watch<XuLiCoSo>();

    final bannersGoc = danhSachBannerKhuyenMai.isNotEmpty
        ? danhSachBannerKhuyenMai
        : taoBannerMacDinh(xuLiCoSo.danhSachCoSo);

    final banners = bannersGoc.take(5).toList();

    if (banners.isEmpty) {
      return const SizedBox(height: 145);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chieuRongManHinh = constraints.maxWidth;
        final laManHinhRong = chieuRongManHinh >= 650;

        // Màn Fold/tablet rộng quá thì không kéo banner full ngang,
        // nếu kéo full ngang ảnh sẽ dẹt và chữ nhìn bị nhỏ.
        final chieuRongBanner = laManHinhRong
            ? chieuRongManHinh.clamp(620.0, 820.0).toDouble()
            : chieuRongManHinh;

        final chieuCao = laManHinhRong
            ? ((chieuRongBanner / 3.05).clamp(220.0, 270.0)).toDouble()
            : ((chieuRongBanner / 2.38).clamp(155.0, 182.0)).toDouble();

        final dpr = MediaQuery.of(context).devicePixelRatio;
        final cacheWidth = (chieuRongBanner * dpr).round();
        final cacheHeight = (chieuCao * dpr).round();

        final rongText = laManHinhRong
            ? chieuRongBanner * 0.47
            : chieuRongBanner * 0.46;

        final leftText = laManHinhRong ? 28.0 : 15.0;
        final topText = laManHinhRong ? 28.0 : 18.0;
        final bottomText = laManHinhRong ? 18.0 : 10.0;

        final caoKhungChu = laManHinhRong ? 210.0 : 154.0;

        final sizeIconTron = laManHinhRong ? 28.0 : 21.0;
        final sizeIconVot = laManHinhRong ? 15.0 : 11.0;
        final caoBadge = laManHinhRong ? 27.0 : 21.0;
        final fontBadge = laManHinhRong ? 10.5 : 8.0;

        final paddingKhungChu = laManHinhRong
            ? const EdgeInsets.fromLTRB(15, 15, 15, 12)
            : const EdgeInsets.fromLTRB(10, 11, 10, 7);

        final radiusKhungChu = laManHinhRong ? 17.0 : 13.0;

        final fontTieuDe = laManHinhRong ? 12.5 : 9.5;
        final fontGia = laManHinhRong ? 25.0 : 18.0;
        final caoGia = laManHinhRong ? 30.0 : 20.0;
        final fontMoTa = laManHinhRong ? 10.5 : 8.2;
        final fontHanDung = laManHinhRong ? 9.4 : 7.3;

        final caoNut = laManHinhRong ? 32.0 : 24.0;
        final fontNut = laManHinhRong ? 12.0 : 9.3;
        final iconNut = laManHinhRong ? 22.0 : 18.0;
        final iconNutSize = laManHinhRong ? 18.0 : 15.0;

        return Center(
          child: SizedBox(
            width: chieuRongBanner,
            height: chieuCao,
            child: Stack(
              children: [
                PageView.builder(
                  controller: bannerController,
                  itemCount: banners.length,
                  allowImplicitScrolling: false,
                  onPageChanged: (index) {
                    if (!mounted) return;

                    setState(() {
                      bannerDangChon = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    final mauChinh = mauTheoBanner(banner.anhNen);
                    final mauNenNhe = mauNenNheTheoBanner(banner.anhNen);

                    return InkWell(
                      onTap: () {
                        if (banner.coSo.id > 0) {
                          chuyenChiTietCoSo(banner.coSo);
                        } else {
                          chuyenTatCaCoSo();
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: mauChinh.withOpacity(0.14),
                              blurRadius: 9,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  banner.anhNen,
                                  fit: BoxFit.fill,
                                  cacheWidth: cacheWidth,
                                  cacheHeight: cacheHeight,
                                  filterQuality: FilterQuality.low,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      'LOI TAI BANNER: ${banner.anhNen} - $error',
                                    );

                                    return Container(
                                      color: mauNenNhe,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Lỗi ảnh banner\n${banner.anhNen}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: mauChinh,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withOpacity(0.08),
                                        Colors.white.withOpacity(0.015),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: leftText,
                                top: topText,
                                bottom: bottomText,
                                width: rongText,
                                child: ClipRect(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: rongText,
                                      height: caoKhungChu,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: sizeIconTron,
                                                height: sizeIconTron,
                                                decoration: BoxDecoration(
                                                  color:
                                                      mauChinh.withOpacity(0.95),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: mauChinh
                                                          .withOpacity(0.22),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.sports_tennis_rounded,
                                                  color: Colors.white,
                                                  size: sizeIconVot,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                height: caoBadge,
                                                constraints: BoxConstraints(
                                                  maxWidth: rongText * 0.68,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.72),
                                                  borderRadius:
                                                      BorderRadius.circular(99),
                                                  border: Border.all(
                                                    color: mauChinh
                                                        .withOpacity(0.16),
                                                    width: 0.7,
                                                  ),
                                                ),
                                                child: Text(
                                                  banner.badge.toUpperCase(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: mauChinh,
                                                    fontSize: fontBadge,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: laManHinhRong ? 10 : 7,
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: paddingKhungChu,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.44),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                radiusKhungChu,
                                              ),
                                              border: Border.all(
                                                color:
                                                    mauChinh.withOpacity(0.12),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  banner.tenKhuyenMai,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: mauChuPhuTheoBanner(
                                                      banner.anhNen,
                                                    ),
                                                    fontSize: fontTieuDe,
                                                    fontWeight: FontWeight.w900,
                                                    height: 1,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      laManHinhRong ? 5 : 3,
                                                ),
                                                SizedBox(
                                                  height: caoGia,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      banner.giaTriHienThi,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: mauChinh,
                                                        fontSize: fontGia,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      laManHinhRong ? 5 : 3,
                                                ),
                                                Text(
                                                  banner.moTa,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade800,
                                                    fontSize: fontMoTa,
                                                    fontWeight: FontWeight.w800,
                                                    height: 1.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  banner.hanDung,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: fontHanDung,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: laManHinhRong ? 10 : 7,
                                          ),
                                          SizedBox(
                                            height: caoNut,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    mauChinh,
                                                    mauChinh.withOpacity(0.78),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: mauChinh
                                                        .withOpacity(0.18),
                                                    blurRadius: 5,
                                                    offset:
                                                        const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left:
                                                      laManHinhRong ? 15 : 12,
                                                  right: 5,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      banner.nutBam,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: fontNut,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: laManHinhRong
                                                          ? 8
                                                          : 6,
                                                    ),
                                                    Container(
                                                      width: iconNut,
                                                      height: iconNut,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.22),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .chevron_right_rounded,
                                                        color: Colors.white,
                                                        size: iconNutSize,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(banners.length, (index) {
                      final dangChon = bannerDangChon == index;
                      final mauCham = mauTheoBanner(banners[index].anhNen);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: dangChon ? 14 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: dangChon
                              ? mauCham
                              : mauCham.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget anhMacDinh() {
    return Container(
      width: 108,
      height: 108,
      color: Colors.blue.shade50,
      child: const Icon(
        Icons.sports_tennis,
        size: 28,
        color: Color(0xff2454ff),
      ),
    );
  }

  Widget theCoSo(CoSo coSo) {
    final daYeuThich = context.watch<XuLiYeuThich>().kiemTraYeuThich(coSo.id);

    return InkWell(
      onTap: () {
        chuyenChiTietCoSo(coSo);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        height: 108,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                    child: coSo.hinhAnh.isNotEmpty
                        ? Image.network(
                            DuongDanApi.linkAnh(coSo.hinhAnh),
                            width: 108,
                            height: 108,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return anhMacDinh();
                            },
                          )
                        : anhMacDinh(),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () {
                        doiYeuThich(coSo);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          daYeuThich ? Icons.favorite : Icons.favorite_border,
                          color: daYeuThich ? Colors.red : Colors.black87,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hienThiSoSan(coSo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coSo.tenCoSo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            coSo.tinhThanh.isEmpty
                                ? 'Cơ sở cầu lông'
                                : coSo.tinhThanh,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.6,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xff2454ff),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '4,9 (297 đánh giá)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey.shade600,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  coSo.diaChi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffe8ecff),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Còn sân',
                              style: TextStyle(
                                color: Color(0xff2454ff),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Chỉ từ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${dinhDangGia(coSo.giaThapNhat)}/giờ',
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff2454ff),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.08,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 65,
                            height: 29,
                            child: ElevatedButton(
                              onPressed: () {
                                chuyenChiTietCoSo(coSo);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2454ff),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text(
                                'Đặt Sân',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget noiDungDanhSachCoSo(XuLiCoSo xuLiCoSo) {
    if (xuLiCoSo.dangTai) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: HieuUngTai(
          text: 'Đang tải sân...',
        ),
      );
    }

    if (xuLiCoSo.thongBaoLoi != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 35),
        child: Center(
          child: Text(
            xuLiCoSo.thongBaoLoi!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (xuLiCoSo.danhSachCoSo.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 35),
        child: Center(
          child: Text(
            'Chưa có cơ sở',
            style: TextStyle(fontSize: 15),
          ),
        ),
      );
    }

    final danhSachHienThi = layDanhSachHienThi(xuLiCoSo.danhSachCoSo);

    if (danhSachHienThi.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 35),
        child: Center(
          child: Text(
            !gioNamTrongKhungHoatDong()
                ? 'Khung giờ này sân chưa mở hoặc đã đóng'
                : gioDaQua()
                    ? 'Khung giờ này đã qua, vui lòng chọn giờ khác'
                    : tuKhoaTimKiem.trim().isNotEmpty
                        ? 'Không tìm thấy sân phù hợp'
                        : tinhThanhDangChon == 'Tất cả'
                            ? 'Không có sân phù hợp'
                            : 'Không có sân ở ${tenTinhHienThi(tinhThanhDangChon)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: danhSachHienThi.length,
      itemBuilder: (context, index) {
        return theCoSo(danhSachHienThi[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLiCoSo = context.watch<XuLiCoSo>();
    final taiKhoanXuLy = context.watch<XuLiTaiKhoan>();
    final nguoiDung = taiKhoanXuLy.nguoiDung;

    final hoTen = nguoiDung?.hoTen ?? 'Người dùng';
    final avatar = nguoiDung?.avatar ?? '';

    final tenHienThi = taiKhoanXuLy.daDangNhap ? '$hoTen 👋' : 'Khách 👋';

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ThanhDuoi(
        viTriDangChon: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              DuongDanAnh.Nen2,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 9, 14, 88),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: taiKhoanXuLy.daDangNhap
                                  ? null
                                  : moDangNhapNeuLaKhach,
                              borderRadius: BorderRadius.circular(24),
                              child: avatarTrangChu(
                                hoTen: hoTen,
                                avatar: avatar,
                                daDangNhap: taiKhoanXuLy.daDangNhap,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: InkWell(
                                onTap: taiKhoanXuLy.daDangNhap
                                    ? null
                                    : moDangNhapNeuLaKhach,
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Xin chào,',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      tenHienThi,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            nutChonTinhThanh(xuLiCoSo.danhSachCoSo),
                          ],
                        ),
                        const SizedBox(height: 10),
                        oTimKiemTrangChu(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            nutLoc(
                              text: tenNutLoc(),
                              icon: Icons.tune_rounded,
                              onTap: moBoLoc,
                            ),
                            nutLoc(
                              text: tenNutNgay(),
                              icon: Icons.calendar_month_rounded,
                              onTap: chonNgay,
                              onXoa: ngayDangChon == null
                                  ? null
                                  : xoaNgayDangChon,
                            ),
                            nutLoc(
                              text: tenNutGio(),
                              icon: Icons.access_time_rounded,
                              onTap: chonGio,
                              onXoa: gioDangChon == null
                                  ? null
                                  : xoaGioDangChon,
                            ),
                            nutLoc(
                              text: tenNutSapXep(),
                              icon: Icons.swap_vert_rounded,
                              onTap: moSapXep,
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        bannerVoucher(),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tieuDeDanhSach(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                chuyenTatCaCoSo();
                              },
                              child: Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        noiDungDanhSachCoSo(xuLiCoSo),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}