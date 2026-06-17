import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/O_nhap.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_dang_nhap.dart';
import 'Man_hinh_otp.dart';

class ManHinhQuenMk extends StatefulWidget {
  const ManHinhQuenMk({super.key});

  @override
  State<ManHinhQuenMk> createState() => _ManHinhQuenMkState();
}

class _ManHinhQuenMkState extends State<ManHinhQuenMk> {
  final taiKhoanController = TextEditingController();

  @override
  void dispose() {
    taiKhoanController.dispose();
    super.dispose();
  }

  void guiMaOtp() async {
    final taiKhoan = taiKhoanController.text.trim();

    if (taiKhoan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email hoặc số điện thoại')),
      );
      return;
    }

    final xuLy = context.read<XuLiTaiKhoan>();

    final thanhCong = await xuLy.quenMatKhau(
      taiKhoan: taiKhoan,
    );


    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP đã được gửi về Gmail')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManHinhOtp(
            taiKhoan: taiKhoan,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(xuLy.thongBaoLoi ?? 'Gửi mã OTP thất bại'),
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
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  Image.asset(
                    DuongDanAnh.logo,
                    width: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 65),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(3, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Quên Mật Khẩu',
                          style: TextStyle(
                            color: Color(0xff004fa3),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Nhập email hoặc số điện thoại để nhận mã OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 45),

                        ONhap(
                          controller: taiKhoanController,
                          goiY: 'Nhập Email/Số điện thoại',
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 35),

                        SizedBox(
                          width: 220,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: xuLy.dangTai ? null : guiMaOtp,
                            icon: xuLy.dangTai
                                ? const SizedBox()
                                : const Icon(
                                    Icons.send_outlined,
                                    color: Colors.white,
                                  ),
                            label: xuLy.dangTai
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Gửi mã xác minh',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2454ff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'hoặc',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: 250,
                          height: 45,
                          child: OutlinedButton.icon(
                            onPressed: quayLaiDangNhap,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Quay lại đăng nhập'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
    );
  }
}