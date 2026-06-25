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

  final PageController bannerController = PageController();
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

  List<CoSo> locCoSoTheoTinh(List<CoSo> danhSachCoSo) {
    if (tinhThanhDangChon == 'Tất cả') {
      return danhSachCoSo;
    }

    return danhSachCoSo.where((coSo) {
      return coSo.tinhThanh.trim() == tinhThanhDangChon;
    }).toList();
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
    return InkWell(
      onTap: () {
        chuyenTatCaCoSo(
          focusTimKiem: true,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Text(
              'Tìm sân cầu lông',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nutLoc(String text, IconData icon) {
    return Container(
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
            style: const TextStyle(
              fontSize: 10.8,
              color: Color(0xff1d3f91),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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

    final danhSachHienThi = locCoSoTheoTinh(xuLiCoSo.danhSachCoSo);

    if (danhSachHienThi.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 35),
        child: Center(
          child: Text(
            'Không có sân ở ${tenTinhHienThi(tinhThanhDangChon)}',
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
                            avatarTrangChu(
                              hoTen: hoTen,
                              avatar: avatar,
                              daDangNhap: taiKhoanXuLy.daDangNhap,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
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
                            nutChonTinhThanh(xuLiCoSo.danhSachCoSo),
                          ],
                        ),
                        const SizedBox(height: 10),
                        oTimKiemTrangChu(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            nutLoc('Lọc', Icons.tune_rounded),
                            nutLoc('Ngày', Icons.calendar_month_rounded),
                            nutLoc('Giờ', Icons.access_time_rounded),
                            nutLoc('Sắp xếp', Icons.swap_vert_rounded),
                          ],
                        ),
                        const SizedBox(height: 13),
                        bannerVoucher(),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tinhThanhDangChon == 'Tất cả'
                                  ? 'Gợi ý cho bạn'
                                  : 'Sân ở ${tenTinhHienThi(tinhThanhDangChon)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black,
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