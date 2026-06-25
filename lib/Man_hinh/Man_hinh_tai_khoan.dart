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

  Widget tieuDeTrang() {
    return const Text(
      'Tài khoản',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
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
            DuongDanApi.linkAnh(avatarText),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
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
                      fontSize: giaTri == null ? 13.4 : 11.5,
                      color:
                          giaTri == null ? Colors.black87 : Colors.grey[600],
                      fontWeight:
                          giaTri == null ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (giaTri != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      giaTri,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.3,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (coMuiTen)
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Colors.black38,
              ),
          ],
        ),
      ),
    );
  }

  Widget gachNgang() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 60,
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

  Widget manHinhChuaDangNhap(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 105),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeTrang(),
          const SizedBox(height: 16),
          Container(
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
                const Icon(
                  Icons.account_circle_rounded,
                  size: 86,
                  color: Color(0xff2454ff),
                ),
                const SizedBox(height: 12),
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
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
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
              ],
            ),
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 105),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeTrang(),
          const SizedBox(height: 16),
          Container(
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
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
                icon: Icons.calendar_month_rounded,
                tieuDe: 'Lịch đặt sân',
                coMuiTen: true,
                onTap: () {
                  chuyenLichDatSan(context);
                },
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.history_rounded,
                tieuDe: 'Lịch sử đặt sân',
                coMuiTen: true,
                onTap: () {
                  chuyenLichSuDatSan(context);
                },
              ),
              gachNgang(),
              dongThongTin(
                icon: Icons.notifications_none_rounded,
                tieuDe: 'Thông báo',
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
            height: 44,
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