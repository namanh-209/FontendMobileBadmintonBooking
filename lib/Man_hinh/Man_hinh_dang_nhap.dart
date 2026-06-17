import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/O_nhap.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_dang_ki.dart';
import 'Man_hinh_quen_mk.dart';
import 'Man_hinh_trang_chu.dart';

class ManHinhDangNhap extends StatefulWidget {
  final bool quayLaiTrangTruoc;

  const ManHinhDangNhap({
    super.key,
    this.quayLaiTrangTruoc = false,
  });

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  final taiKhoanController = TextEditingController();
  final matKhauController = TextEditingController();

  @override
  void dispose() {
    taiKhoanController.dispose();
    matKhauController.dispose();
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

  void xuLyDangNhap() async {
    if (taiKhoanController.text.trim().isEmpty ||
        matKhauController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final xuLy = context.read<XuLiTaiKhoan>();

    final thanhCong = await xuLy.dangNhap(
      taiKhoan: taiKhoanController.text.trim(),
      matKhau: matKhauController.text.trim(),
    );

    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công')),
      );

      if (widget.quayLaiTrangTruoc) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ManHinhTrangChu(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(xuLy.thongBaoLoi ?? 'Đăng nhập thất bại'),
        ),
      );
    }
  }

  void chuyenSangQuenMatKhau() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhQuenMk(),
      ),
    );
  }

  void chuyenSangDangKy() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ManHinhDangKi(),
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
                  const SizedBox(height: 28),

                  Image.asset(
                    DuongDanAnh.logo,
                    width: 150,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Chào mừng trở lại!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff004fa3),
                      fontSize: 25,
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
                    'Đăng nhập để tiếp tục đặt sân',
                    style: TextStyle(
                      color: Color(0xff004fa3),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
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
                          controller: taiKhoanController,
                          goiY: 'Email/Số điện thoại',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 14),

                        ONhap(
                          controller: matKhauController,
                          goiY: 'Mật khẩu',
                          icon: Icons.visibility_outlined,
                          anChu: true,
                        ),

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: chuyenSangQuenMatKhau,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                color: Color(0xff2454ff),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: xuLy.dangTai ? null : xuLyDangNhap,
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
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

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

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: chuyenSangDangKy,
                        child: const Text(
                          'Đăng ký',
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