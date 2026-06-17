import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_chinh_sua_tai_khoan.dart';
import 'Man_hinh_dang_ki.dart';
import 'Man_hinh_dang_nhap.dart';

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

  String layChuCaiDau(String ten) {
    if (ten.trim().isEmpty) return 'U';

    final tachTen = ten.trim().split(' ');
    final chuCuoi = tachTen.last;

    if (chuCuoi.isEmpty) return 'U';

    return chuCuoi[0].toUpperCase();
  }

  String hienThiGioiTinh(String gioiTinh) {
    if (gioiTinh == '1') return 'Nam';
    if (gioiTinh == '0') return 'Nữ';
    if (gioiTinh == '2') return 'Khác';
    if (gioiTinh == '3') return 'Khác';

    if (gioiTinh.toLowerCase() == 'nam') return 'Nam';

    if (gioiTinh.toLowerCase() == 'nữ' || gioiTinh.toLowerCase() == 'nu') {
      return 'Nữ';
    }

    if (gioiTinh.toLowerCase() == 'khác' || gioiTinh.toLowerCase() == 'khac') {
      return 'Khác';
    }

    return 'Chưa chọn';
  }

  Widget tieuDeTrang({
    required String tieuDe,
    String moTa = '',
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (moTa.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  moTa,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(1, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings_rounded,
            size: 20,
            color: Color(0xff2454ff),
          ),
        ),
      ],
    );
  }

  Widget dongLoiIch({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: const Color(0xff2454ff),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.3,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget dongThongTin({
    required IconData icon,
    required String tieuDe,
    String? giaTri,
    bool coMuiTen = false,
    Color mauIcon = const Color(0xff2454ff),
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xffe7f1ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: mauIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: giaTri == null ? 13.2 : 11.4,
                      color: giaTri == null
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontWeight:
                          giaTri == null ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (giaTri != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      giaTri,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.2,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (coMuiTen)
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black38,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget gachNgang() {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 14),
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
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 5),
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
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(2, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xffdbeafe),
                  Color(0xfff4f8ff),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(2, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_circle_rounded,
              size: 72,
              color: Color(0xff2454ff),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa đăng nhập',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để xem hồ sơ, lịch đặt sân,\nthông báo và ưu đãi dành riêng cho bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                chuyenDangNhap(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2454ff),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                chuyenDangKy(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xff2454ff),
                  width: 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  color: Color(0xff2454ff),
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xfff3f8ff),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                dongLoiIch(
                  icon: Icons.calendar_month_rounded,
                  text: 'Theo dõi lịch sân đã đặt',
                ),
                const SizedBox(height: 10),
                dongLoiIch(
                  icon: Icons.local_offer_rounded,
                  text: 'Nhận voucher và ưu đãi mới',
                ),
                const SizedBox(height: 10),
                dongLoiIch(
                  icon: Icons.notifications_rounded,
                  text: 'Nhận thông báo đặt sân',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget manHinhChuaDangNhap(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeTrang(
            tieuDe: 'Tài khoản',
            moTa: 'Quản lý hồ sơ và lịch đặt sân',
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

  Widget avatarNguoiDung({
    required BuildContext context,
    required String hoTen,
    required String avatar,
  }) {
    Widget noiDungAvatar;

    if (avatar.isNotEmpty) {
      if (avatar.startsWith('http')) {
        noiDungAvatar = ClipOval(
          child: Image.network(
            avatar,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return avatarChuCai(hoTen);
            },
          ),
        );
      } else if (File(avatar).existsSync()) {
        noiDungAvatar = ClipOval(
          child: Image.file(
            File(avatar),
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return avatarChuCai(hoTen);
            },
          ),
        );
      } else {
        noiDungAvatar = avatarChuCai(hoTen);
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(2, 5),
              ),
            ],
          ),
          child: noiDungAvatar,
        ),
        Positioned(
          right: 2,
          bottom: 4,
          child: InkWell(
            onTap: () {
              chuyenChinhSua(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xffdbeafe),
                  width: 2,
                ),
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

  Widget avatarChuCai(String hoTen) {
    return Center(
      child: Text(
        layChuCaiDau(hoTen),
        style: const TextStyle(
          fontSize: 34,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget theHoSoDaDangNhap({
    required BuildContext context,
    required String hoTen,
    required String email,
    required String avatar,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xfffafdff),
            Color(0xffe8f2ff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(2, 7),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
                      fontSize: 12.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () {
                chuyenChinhSua(context);
              },
              icon: const Icon(
                Icons.edit_rounded,
                size: 16,
                color: Color(0xff2454ff),
              ),
              label: const Text(
                'Chỉnh sửa thông tin',
                style: TextStyle(
                  color: Color(0xff2454ff),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                side: const BorderSide(
                  color: Color(0xff2454ff),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget manHinhDaDangNhap(BuildContext context) {
    final xuLyTaiKhoan = context.read<XuLiTaiKhoan>();
    final nguoiDung = context.watch<XuLiTaiKhoan>().nguoiDung;

    final hoTen = nguoiDung?.hoTen ?? 'Người dùng';

    final email = nguoiDung?.email.isNotEmpty == true
        ? nguoiDung!.email
        : 'Chưa có email';

    final soDienThoai = nguoiDung?.soDienThoai.isNotEmpty == true
        ? nguoiDung!.soDienThoai
        : 'Chưa có số điện thoại';

    final gioiTinh = nguoiDung?.gioiTinh.isNotEmpty == true
        ? hienThiGioiTinh(nguoiDung!.gioiTinh)
        : 'Chưa chọn';

    final ngaySinh = nguoiDung?.ngaySinh.isNotEmpty == true
        ? nguoiDung!.ngaySinh
        : 'Chưa chọn';

    final avatar = nguoiDung?.avatar ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeTrang(
            tieuDe: 'Tài khoản',
            moTa: 'Thông tin cá nhân của bạn',
          ),
          const SizedBox(height: 14),
          theHoSoDaDangNhap(
            context: context,
            hoTen: hoTen,
            email: email,
            avatar: avatar,
          ),
          const SizedBox(height: 16),
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
                icon: Icons.history_rounded,
                tieuDe: 'Lịch sử đặt sân',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.notifications_none_rounded,
                tieuDe: 'Thông báo',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.calendar_month_rounded,
                tieuDe: 'Lịch đã đặt',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.settings_rounded,
                tieuDe: 'Cài đặt',
                coMuiTen: true,
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.lock_outline_rounded,
                tieuDe: 'Đổi mật khẩu',
                coMuiTen: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () async {
                await xuLyTaiKhoan.dangXuat();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng xuất'),
                  ),
                );
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.85),
                side: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
            child: Column(
              children: [
                Expanded(
                  child: taiKhoanXuLy.daDangNhap
                      ? manHinhDaDangNhap(context)
                      : manHinhChuaDangNhap(context),
                ),
                const ThanhDuoi(
                  viTriDangChon: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}