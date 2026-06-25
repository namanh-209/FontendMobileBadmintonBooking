import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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

class ManHinhTrangChu extends StatefulWidget {
  const ManHinhTrangChu({
    super.key,
  });

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuState();
}

class _ManHinhTrangChuState extends State<ManHinhTrangChu> {
  int bannerDangChon = 0;

  String tinhThanhDangChon = 'Tất cả';
  String sapXepDangChon = 'mac_dinh';
  String tuKhoaTimKiem = '';

  DateTime? ngayDangChon;
  TimeOfDay? gioDangChon;

  bool chiHienConSan = false;
  bool chiHienCoGia = false;

  final PageController bannerController = PageController();
  final TextEditingController timKiemController = TextEditingController();

  Timer? timerBanner;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<XuLiYeuThich>().taiYeuThichDaLuu();

      if (!mounted) return;

      await context.read<XuLiCoSo>().layDanhSachCoSo();
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

  void batDauTuChayBanner() {
    timerBanner?.cancel();

    timerBanner = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        if (!mounted || !bannerController.hasClients) return;

        final trangTiepTheo = bannerDangChon == 2 ? 0 : bannerDangChon + 1;

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

  String dinhDangGio(TimeOfDay gio) {
    final gioText = gio.hour.toString().padLeft(2, '0');
    final phutText = gio.minute.toString().padLeft(2, '0');

    return '$gioText:$phutText';
  }

  String hienThiSoSan(CoSo coSo) {
    final soSan = coSo.soLuongSan > 0
        ? coSo.soLuongSan
        : coSo.danhSachSan.length;

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
    if (chiHienConSan && chiHienCoGia) return 'Đã lọc';
    if (chiHienConSan) return 'Còn sân';
    if (chiHienCoGia) return 'Có giá';

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

  void xoaBoLocTrongNutLoc() {
    setState(() {
      chiHienConSan = false;
      chiHienCoGia = false;
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
    bool tamConSan = chiHienConSan;
    bool tamCoGia = chiHienCoGia;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Bộ lọc sân',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: tamConSan,
                        activeColor: const Color(0xff2454ff),
                        title: const Text(
                          'Chỉ hiện sân còn sân',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: const Text(
                          'Ẩn các cơ sở không có số sân',
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            tamConSan = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: tamCoGia,
                        activeColor: const Color(0xff2454ff),
                        title: const Text(
                          'Chỉ hiện sân có giá',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: const Text(
                          'Ẩn các cơ sở chưa có giá',
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            tamCoGia = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                xoaBoLocTrongNutLoc();
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Xóa lọc',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  chiHienConSan = tamConSan;
                                  chiHienCoGia = tamCoGia;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2454ff),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Áp dụng',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 0,
        ),
        leading: Icon(
          dangChon ? Icons.radio_button_checked : Icons.radio_button_off,
          color: const Color(0xff2454ff),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          icon,
          color: Colors.black54,
          size: 21,
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
          initialChildSize: 0.58,
          minChildSize: 0.38,
          maxChildSize: 0.82,
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
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'Sắp xếp sân',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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

  void moChonTinhThanh(List<CoSo> danhSachCoSo) {
    final danhSachTinh = layDanhSachTinhThanh(danhSachCoSo);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Chọn tỉnh/thành',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(
                    tinhThanhDangChon == 'Tất cả'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color(0xff2454ff),
                  ),
                  title: const Text(
                    'Tất cả khu vực',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      tinhThanhDangChon = 'Tất cả';
                    });
                    Navigator.pop(context);
                  },
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: danhSachTinh.length,
                    itemBuilder: (context, index) {
                      final tinh = danhSachTinh[index];
                      final dangChon = tinhThanhDangChon == tinh;

                      return ListTile(
                        leading: Icon(
                          dangChon
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: const Color(0xff2454ff),
                        ),
                        title: Text(
                          tinh,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            tinhThanhDangChon = tinh;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
    final coTinh = layDanhSachTinhThanh(danhSachCoSo).isNotEmpty;
    final ten = tenTinhHienThi(tinhThanhDangChon);

    return InkWell(
      onTap: coTinh
          ? () {
              moChonTinhThanh(danhSachCoSo);
            }
          : null,
      borderRadius: BorderRadius.circular(17),
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
    final List<String> banners = [
      DuongDanAnh.banner1,
      DuongDanAnh.banner2,
      DuongDanAnh.banner3,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final chieuRong = constraints.maxWidth;
        final chieuCao = chieuRong / 2.55;

        return SizedBox(
          height: chieuCao,
          child: Stack(
            children: [
              PageView.builder(
                controller: bannerController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    bannerDangChon = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        banners[index],
                        width: double.infinity,
                        height: chieuCao,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 7,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) {
                        final dangChon = index == bannerDangChon;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: dangChon ? 12 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: dangChon
                                ? Colors.white
                                : Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
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
        padding: EdgeInsets.only(top: 50),
        child: Center(
          child: CircularProgressIndicator(),
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