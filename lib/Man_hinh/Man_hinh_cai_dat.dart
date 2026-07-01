import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';

import 'Man_hinh_chinh_sua_tai_khoan.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_quen_mk.dart';

class ManHinhCaiDat extends StatefulWidget {
  const ManHinhCaiDat({super.key});

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  bool batThongBao = true;
  bool cheDoToi = false;

  Future<void> dangXuat() async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (xacNhan != true) return;

    if (!mounted) return;

    await context.read<XuLiTaiKhoan>().dangXuat();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhDangNhap(),
      ),
      (route) => false,
    );
  }

  Widget dongCaiDat({
    required IconData icon,
    required String tieuDe,
    required String moTa,
    VoidCallback? onTap,
    Widget? trailing,
    Color iconColor = const Color(0xff2454ff),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
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
              ),
            ),

            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
          ],
        ),
      ),
    );
  }

  Widget thongTinNguoiDung() {
    final taiKhoan = context.watch<XuLiTaiKhoan>();

    final ten = taiKhoan.nguoiDung?.hoTen ?? 'Người dùng';
    final email = taiKhoan.nguoiDung?.email ?? 'Chưa cập nhật email';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff2454ff),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(1, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 31,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.account_circle_rounded,
              size: 48,
              color: Color(0xff2454ff),
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManHinhChinhSuaTaiKhoan(),
                ),
              );
            },
            icon: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget noiDung() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          thongTinNguoiDung(),

          const SizedBox(height: 22),

          const Text(
            'Tài khoản',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          dongCaiDat(
            icon: Icons.person_rounded,
            tieuDe: 'Thông tin cá nhân',
            moTa: 'Xem và chỉnh sửa hồ sơ tài khoản',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManHinhChinhSuaTaiKhoan(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          dongCaiDat(
            icon: Icons.lock_rounded,
            tieuDe: 'Đổi mật khẩu',
            moTa: 'Cập nhật mật khẩu đăng nhập',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManHinhQuenMk(),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'Ứng dụng',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          dongCaiDat(
            icon: Icons.notifications_rounded,
            tieuDe: 'Thông báo',
            moTa: batThongBao
                ? 'Đang bật thông báo từ hệ thống'
                : 'Đang tắt thông báo từ hệ thống',
            trailing: Switch(
              value: batThongBao,
              activeColor: const Color(0xff2454ff),
              onChanged: (value) {
                setState(() {
                  batThongBao = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),


          const SizedBox(height: 12),

          dongCaiDat(
            icon: Icons.language_rounded,
            tieuDe: 'Ngôn ngữ',
            moTa: 'Tiếng Việt',
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        ListTile(
                          leading: Icon(Icons.check),
                          title: Text('Tiếng Việt'),
                        ),
                        ListTile(
                          leading: Icon(Icons.language),
                          title: Text('English'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'Khác',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          dongCaiDat(
            icon: Icons.description_rounded,
            tieuDe: 'Điều khoản sử dụng',
            moTa: 'Xem chính sách và điều khoản ứng dụng',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Điều khoản sử dụng'),
                  content: Text(
                    'Ứng dụng Badminton Booking hỗ trợ người dùng đặt lịch sân cầu lông, quản lý lịch đặt và thanh toán trực tuyến.',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          dongCaiDat(
            icon: Icons.info_rounded,
            tieuDe: 'Phiên bản ứng dụng',
            moTa: 'Badminton Booking v1.0.0',
          ),

          const SizedBox(height: 12),

          dongCaiDat(
            icon: Icons.logout_rounded,
            tieuDe: 'Đăng xuất',
            moTa: 'Thoát khỏi tài khoản hiện tại',
            iconColor: Colors.red,
            onTap: dangXuat,
          ),
        ],
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Nút quay lại
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
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
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xff2454ff),
                            ),
                          ),
                        ),
                      ),

                      // Tiêu đề
                      const Text(
                        'Cài đặt',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: noiDung(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}