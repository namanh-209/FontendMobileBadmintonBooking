import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/O_nhap.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_trang_chu.dart';

class ManHinhDangKi extends StatefulWidget {
  const ManHinhDangKi({super.key});

  @override
  State<ManHinhDangKi> createState() => _ManHinhDangKiState();
}

class _ManHinhDangKiState extends State<ManHinhDangKi> {
  final hoTenController = TextEditingController();
  final emailController = TextEditingController();
  final soDienThoaiController = TextEditingController();
  final matKhauController = TextEditingController();
  final xacNhanMatKhauController = TextEditingController();

  @override
  void dispose() {
    hoTenController.dispose();
    emailController.dispose();
    soDienThoaiController.dispose();
    matKhauController.dispose();
    xacNhanMatKhauController.dispose();
    super.dispose();
  }

  void quayLai() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhTrangChu(),
      ),
    );
  }

  void xuLyDangKy() async {
    final hoTen = hoTenController.text.trim();
    final email = emailController.text.trim();
    final soDienThoai = soDienThoaiController.text.trim();
    final matKhau = matKhauController.text.trim();
    final xacNhanMatKhau = xacNhanMatKhauController.text.trim();

    if (hoTen.isEmpty ||
        email.isEmpty ||
        soDienThoai.isEmpty ||
        matKhau.isEmpty ||
        xacNhanMatKhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (matKhau != xacNhanMatKhau) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    final xuLy = context.read<XuLiTaiKhoan>();

    final thanhCong = await xuLy.dangKy(
      hoTen: hoTen,
      email: email,
      soDienThoai: soDienThoai,
      matKhau: matKhau,
    );

    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ManHinhDangNhap(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(xuLy.thongBaoLoi ?? 'Đăng ký thất bại'),
        ),
      );
    }
  }

  void quayLaiDangNhap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhDangNhap(),
      ),
    );
  }

  Widget nutBack() {
    return Positioned(
      top: 12,
      left: 16,
      child: SafeArea(
        child: InkWell(
          onTap: quayLai,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLy = context.watch<XuLiTaiKhoan>();

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
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Image.asset(
                    DuongDanAnh.logo,
                    width: 138,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Tạo tài khoản mới',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff004fa3),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Bắt đầu đặt sân dễ dàng hơn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff004fa3),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 9,
                          offset: Offset(2, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ONhap(
                          controller: hoTenController,
                          goiY: 'Tên tài khoản',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 11),

                        ONhap(
                          controller: emailController,
                          goiY: 'Email',
                          icon: Icons.mail_outline,
                          kieuBanPhim: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 11),

                        ONhap(
                          controller: soDienThoaiController,
                          goiY: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                          kieuBanPhim: TextInputType.phone,
                        ),

                        const SizedBox(height: 11),

                        ONhap(
                          controller: matKhauController,
                          goiY: 'Mật khẩu',
                          icon: Icons.visibility_outlined,
                          anChu: true,
                        ),

                        const SizedBox(height: 11),

                        ONhap(
                          controller: xacNhanMatKhauController,
                          goiY: 'Xác nhận mật khẩu',
                          icon: Icons.visibility_outlined,
                          anChu: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: xuLy.dangTai ? null : xuLyDangKy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2454ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: xuLy.dangTai
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Đăng ký',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'hoặc',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: quayLaiDangNhap,
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Color(0xff2454ff),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          nutBack(),
        ],
      ),
    );
  }
}