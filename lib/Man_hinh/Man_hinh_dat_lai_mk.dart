import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/O_nhap.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_dang_nhap.dart';

class ManHinhDatLaiMatKhau extends StatefulWidget {
  final String taiKhoan;

  const ManHinhDatLaiMatKhau({
    super.key,
    required this.taiKhoan,
  });

  @override
  State<ManHinhDatLaiMatKhau> createState() => _ManHinhDatLaiMatKhauState();
}

class _ManHinhDatLaiMatKhauState extends State<ManHinhDatLaiMatKhau> {
  final matKhauCuController = TextEditingController();
  final matKhauMoiController = TextEditingController();
  final xacNhanMatKhauController = TextEditingController();

  @override
  void dispose() {
    matKhauCuController.dispose();
    matKhauMoiController.dispose();
    xacNhanMatKhauController.dispose();
    super.dispose();
  }

  bool matKhauHopLe(String matKhau) {
    if (matKhau.length < 6) return false;
    if (matKhau.contains(' ')) return false;
    return true;
  }

  void xuLyMatKhau() async {
    final xuLy = context.read<XuLiTaiKhoan>();
    final dangDangNhap = xuLy.daDangNhap;

    final matKhauCu = matKhauCuController.text.trim();
    final matKhauMoi = matKhauMoiController.text.trim();
    final xacNhanMatKhau = xacNhanMatKhauController.text.trim();

    if (dangDangNhap && matKhauCu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mật khẩu cũ')),
      );
      return;
    }

    if (matKhauMoi.isEmpty || xacNhanMatKhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ mật khẩu')),
      );
      return;
    }

    if (matKhauMoi != xacNhanMatKhau) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    if (!matKhauHopLe(matKhauMoi)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mật khẩu phải ít nhất 6 ký tự và không có khoảng trắng',
          ),
        ),
      );
      return;
    }

    bool thanhCong = false;

    if (dangDangNhap) {
      thanhCong = await xuLy.doiMatKhau(
        matKhauCu: matKhauCu,
        matKhauMoi: matKhauMoi,
        xacNhanMatKhauMoi: xacNhanMatKhau,
      );
    } else {
      thanhCong = await xuLy.datLaiMatKhau(
        taiKhoan: widget.taiKhoan,
        matKhauMoi: matKhauMoi,
        xacNhanMatKhau: xacNhanMatKhau,
      );
    }

    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dangDangNhap
                ? 'Đổi mật khẩu thành công'
                : 'Đặt lại mật khẩu thành công',
          ),
        ),
      );

      if (dangDangNhap) {
        Navigator.pop(context);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const ManHinhDangNhap(),
          ),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            xuLy.thongBaoLoi ??
                (dangDangNhap
                    ? 'Đổi mật khẩu thất bại'
                    : 'Đặt lại mật khẩu thất bại'),
          ),
        ),
      );
    }
  }

  Widget dongDieuKien(String noiDung) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xff2196f3),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            noiDung,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLy = context.watch<XuLiTaiKhoan>();
    final dangDangNhap = xuLy.daDangNhap;

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
                  const SizedBox(height: 35),

                  Image.asset(
                    DuongDanAnh.logo,
                    width: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  Text(
                    dangDangNhap ? 'Đổi mật khẩu' : 'Đặt lại mật khẩu',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dangDangNhap) ...[
                          const Text(
                            'Mật khẩu cũ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ONhap(
                            controller: matKhauCuController,
                            goiY: 'Nhập mật khẩu cũ',
                            icon: Icons.lock_open_outlined,
                            anChu: true,
                          ),
                          const SizedBox(height: 25),
                        ],

                        const Text(
                          'Mật khẩu mới',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        ONhap(
                          controller: matKhauMoiController,
                          goiY: 'Nhập mật khẩu mới',
                          icon: Icons.lock_outline,
                          anChu: true,
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Xác nhận mật khẩu',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        ONhap(
                          controller: xacNhanMatKhauController,
                          goiY: 'Nhập lại mật khẩu mới',
                          icon: Icons.lock_outline,
                          anChu: true,
                        ),

                        const SizedBox(height: 25),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffe3f2fd),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              dongDieuKien('Tối thiểu 6 kí tự'),
                              const SizedBox(height: 8),
                              dongDieuKien('Không chứa khoảng trắng'),
                              const SizedBox(height: 8),
                              dongDieuKien('Nên có chữ và số'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: xuLy.dangTai ? null : xuLyMatKhau,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2454ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: xuLy.dangTai
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              dangDangNhap ? 'Đổi mật khẩu' : 'Xác nhận',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'Quay lại',
                      style: TextStyle(fontSize: 18),
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