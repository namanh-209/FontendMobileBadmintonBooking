import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Chung/Duong_dan_api.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_chinh_sua_tai_khoan.dart';
import 'Man_hinh_dang_ki.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_lich_dat_san.dart';
import 'Man_hinh_lich_su_dat_san.dart';

class ManHinhTaiKhoan extends StatelessWidget {
  const ManHinhTaiKhoan({super.key});

  void chuyenDangNhap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhDangNhap(
          quayLaiTrangTruoc: true,
        ),
      ),
    );
  }

  void chuyenDangKy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhDangKi(),
      ),
    );
  }

  void chuyenChinhSua(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhChinhSuaTaiKhoan(),
      ),
    );
  }

  void chuyenLichDatSan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhLichDatSan(),
      ),
    );
  }

  void chuyenLichSuDatSan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhLichSuDatSan(),
      ),
    );
  }

  String layChuCaiDau(String ten) {
    final text = ten.trim();

    if (text.isEmpty) return 'U';

    final tach = text.split(' ');

    return tach.last[0].toUpperCase();
  }

  String hienThiGioiTinh(String value) {
    final text = value.trim().toLowerCase();

    if (text == '1' || text == 'nam' || text == 'male') {
      return 'Nam';
    }

    if (text == '0' ||
        text == '2' ||
        text == 'nữ' ||
        text == 'nu' ||
        text == 'female') {
      return 'Nữ';
    }

    if (text == '3' ||
        text == 'khác' ||
        text == 'khac' ||
        text == 'other') {
      return 'Khác';
    }

    return 'Chưa chọn';
  }

  String hienThiNgaySinh(String ngaySinh) {
    final text = ngaySinh.trim();

    if (text.isEmpty) return 'Chưa chọn';

    try {
      final date = DateTime.parse(text).toLocal();

      final d = date.day.toString().padLeft(2, '0');
      final m = date.month.toString().padLeft(2, '0');
      final y = date.year.toString();

      return '$d/$m/$y';
    } catch (_) {
      if (text.contains('T')) {
        final ngay = text.split('T').first;
        final tach = ngay.split('-');

        if (tach.length == 3) {
          return '${tach[2]}/${tach[1]}/${tach[0]}';
        }
      }

      if (text.contains('-')) {
        final tach = text.split('-');

        if (tach.length == 3) {
          return '${tach[2]}/${tach[1]}/${tach[0]}';
        }
      }

      return text;
    }
  }

  String layLinkAvatar(String avatar) {
    final text = avatar.trim();

    if (text.isEmpty) return '';

    if (text.startsWith('http://') || text.startsWith('https://')) {
      return text;
    }

    return DuongDanApi.linkAnh(text);
  }

  Widget tieuDeTrang({
    required String tieuDe,
    required String moTa,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tieuDe,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                moTa,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 9,
                offset: const Offset(1, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 21,
            color: Color(0xff2454ff),
          ),
        ),
      ],
    );
  }

  Widget avatarChuCai(String hoTen) {
    return Center(
      child: Text(
        layChuCaiDau(hoTen),
        style: const TextStyle(
          fontSize: 34,
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget avatarNguoiDung({
    required BuildContext context,
    required String hoTen,
    required String avatar,
  }) {
    Widget noiDungAvatar;

    final avatarText = avatar.trim();

    if (avatarText.isNotEmpty) {
      if (File(avatarText).existsSync()) {
        noiDungAvatar = ClipOval(
          child: Image.file(
            File(avatarText),
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return avatarChuCai(hoTen);
            },
          ),
        );
      } else {
        noiDungAvatar = ClipOval(
          child: Image.network(
            layLinkAvatar(avatarText),
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return avatarChuCai(hoTen);
            },
          ),
        );
      }
    } else {
      noiDungAvatar = avatarChuCai(hoTen);
    }

    return Stack(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff2454ff),
                Color(0xff60a5fa),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff2454ff).withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: noiDungAvatar,
        ),
        Positioned(
          right: 0,
          bottom: 4,
          child: InkWell(
            onTap: () {
              chuyenChinhSua(context);
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xffdbeafe),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 7,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 15,
                color: Color(0xff2454ff),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget nutNhanh({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xffdbeafe),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xff2454ff),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.8,
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dongThongTin({
    required IconData icon,
    required String tieuDe,
    String? giaTri,
    bool coMuiTen = false,
    Color mauIcon = const Color(0xff2454ff),
    Color mauNenIcon = const Color(0xffe7f1ff),
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: mauNenIcon,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 19,
                color: mauIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: giaTri == null
                  ? Text(
                      tieuDe,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 13.8,
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tieuDe,
                          style: TextStyle(
                            fontSize: 11.2,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          giaTri,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 13.6,
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
            ),
            if (coMuiTen)
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget gachNgang() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 66,
        right: 14,
      ),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget nhomThongTin({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 12,
            offset: const Offset(2, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget theChuaDangNhap(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffffffff),
            Color(0xffedf5ff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 16,
            offset: const Offset(2, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xffe7f1ff),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
            ),
            child: const Icon(
              Icons.account_circle_rounded,
              size: 72,
              color: Color(0xff2454ff),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Bạn chưa đăng nhập',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để xem hồ sơ, lịch đặt sân,\nthông báo và ưu đãi dành riêng cho bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.7,
              height: 1.42,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                chuyenDangNhap(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2454ff),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                chuyenDangKy(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xff2454ff),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  color: Color(0xff2454ff),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget manHinhChuaDangNhap(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeTrang(
            tieuDe: 'Tài khoản',
            moTa: 'Đăng nhập để quản lý hồ sơ của bạn',
          ),
          const SizedBox(height: 18),
          theChuaDangNhap(context),
          const SizedBox(height: 16),
          nhomThongTin(
            children: [
              dongThongTin(
                icon: Icons.help_outline_rounded,
                tieuDe: 'Trợ giúp',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.settings_rounded,
                tieuDe: 'Cài đặt',
                coMuiTen: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget theHoSoNguoiDung({
    required BuildContext context,
    required String hoTen,
    required String email,
    required String avatar,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffffffff),
            Color(0xffeef6ff),
            Color(0xffdbeafe),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2454ff).withOpacity(0.13),
            blurRadius: 18,
            offset: const Offset(2, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          avatarNguoiDung(
            context: context,
            hoTen: hoTen,
            avatar: avatar,
          ),
          const SizedBox(height: 12),
          Text(
            hoTen,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 285,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.email_rounded,
                  size: 14,
                  color: Color(0xff2454ff),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              nutNhanh(
                icon: Icons.calendar_month_rounded,
                text: 'Lịch đặt',
                onTap: () {
                  chuyenLichDatSan(context);
                },
              ),
              const SizedBox(width: 8),
              nutNhanh(
                icon: Icons.history_rounded,
                text: 'Lịch sử',
                onTap: () {
                  chuyenLichSuDatSan(context);
                },
              ),
              const SizedBox(width: 8),
              nutNhanh(
                icon: Icons.edit_rounded,
                text: 'Sửa hồ sơ',
                onTap: () {
                  chuyenChinhSua(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget manHinhDaDangNhap(BuildContext context) {
    final xuLyTaiKhoan = context.read<XuLiTaiKhoan>();
    final dynamic nguoiDung = context.watch<XuLiTaiKhoan>().nguoiDung;

    final hoTen = '${nguoiDung?.hoTen ?? 'Người dùng'}';

    final email = '${nguoiDung?.email ?? ''}'.trim().isNotEmpty
        ? '${nguoiDung?.email}'
        : 'Chưa có email';

    final soDienThoai = '${nguoiDung?.soDienThoai ?? ''}'.trim().isNotEmpty
        ? '${nguoiDung?.soDienThoai}'
        : 'Chưa có số điện thoại';

    final gioiTinh = '${nguoiDung?.gioiTinh ?? ''}'.trim().isNotEmpty
        ? hienThiGioiTinh('${nguoiDung?.gioiTinh}')
        : 'Chưa chọn';

    final ngaySinh = '${nguoiDung?.ngaySinh ?? ''}'.trim().isNotEmpty
        ? hienThiNgaySinh('${nguoiDung?.ngaySinh}')
        : 'Chưa chọn';

    final avatar = '${nguoiDung?.avatar ?? ''}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeTrang(
            tieuDe: 'Tài khoản',
            moTa: 'Quản lý hồ sơ và lịch đặt sân',
          ),
          const SizedBox(height: 15),
          theHoSoNguoiDung(
            context: context,
            hoTen: hoTen,
            email: email,
            avatar: avatar,
          ),
          const SizedBox(height: 15),
          nhomThongTin(
            children: [
              dongThongTin(
                icon: Icons.person_outline_rounded,
                tieuDe: 'Họ tên',
                giaTri: hoTen,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.phone_rounded,
                tieuDe: 'Số điện thoại',
                giaTri: soDienThoai,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.wc_rounded,
                tieuDe: 'Giới tính',
                giaTri: gioiTinh,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.cake_outlined,
                tieuDe: 'Ngày sinh',
                giaTri: ngaySinh,
              ),
            ],
          ),
          const SizedBox(height: 14),
          nhomThongTin(
            children: [
              dongThongTin(
                icon: Icons.lock_outline_rounded,
                tieuDe: 'Đổi mật khẩu',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.help_outline_rounded,
                tieuDe: 'Trợ giúp',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.settings_rounded,
                tieuDe: 'Cài đặt',
                coMuiTen: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () async {
                await xuLyTaiKhoan.dangXuat();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đăng xuất'),
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: Colors.red,
              ),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                side: const BorderSide(
                  color: Colors.red,
                  width: 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taiKhoanXuLy = context.watch<XuLiTaiKhoan>();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ThanhDuoi(
        viTriDangChon: 4,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              DuongDanAnh.Nen2,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          SafeArea(
            bottom: false,
            child: taiKhoanXuLy.daDangNhap
                ? manHinhDaDangNhap(context)
                : manHinhChuaDangNhap(context),
          ),
        ],
      ),
    );
  }
}