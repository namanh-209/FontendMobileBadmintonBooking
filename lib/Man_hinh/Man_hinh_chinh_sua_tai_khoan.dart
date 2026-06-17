import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';

class ManHinhChinhSuaTaiKhoan extends StatefulWidget {
  const ManHinhChinhSuaTaiKhoan({super.key});

  @override
  State<ManHinhChinhSuaTaiKhoan> createState() =>
      _ManHinhChinhSuaTaiKhoanState();
}

class _ManHinhChinhSuaTaiKhoanState extends State<ManHinhChinhSuaTaiKhoan> {
  final hoTenController = TextEditingController();
  final emailController = TextEditingController();
  final soDienThoaiController = TextEditingController();
  final ngaySinhController = TextEditingController();

  String gioiTinhDangChon = '';
  String avatarDangChon = '';

  final ImagePicker imagePicker = ImagePicker();

  String chuyenGioiTinhHienThi(String gioiTinh) {
    if (gioiTinh == '1') return 'Nam';
    if (gioiTinh == '0') return 'Nữ';
    if (gioiTinh == '2') return 'Khác';
    if (gioiTinh == '3') return 'Khác';
    return gioiTinh;
  }

  @override
  void initState() {
    super.initState();

    final nguoiDung = context.read<XuLiTaiKhoan>().nguoiDung;

    hoTenController.text = nguoiDung?.hoTen ?? '';
    emailController.text = nguoiDung?.email ?? '';
    soDienThoaiController.text = nguoiDung?.soDienThoai ?? '';
    ngaySinhController.text = nguoiDung?.ngaySinh ?? '';

    gioiTinhDangChon = chuyenGioiTinhHienThi(nguoiDung?.gioiTinh ?? '');
    avatarDangChon = nguoiDung?.avatar ?? '';
  }

  @override
  void dispose() {
    hoTenController.dispose();
    emailController.dispose();
    soDienThoaiController.dispose();
    ngaySinhController.dispose();
    super.dispose();
  }

  Future<void> chonAnh() async {
    final XFile? anh = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (anh == null) return;

    setState(() {
      avatarDangChon = anh.path;
    });
  }

  Future<void> chonNgaySinh() async {
    final DateTime? ngay = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ngaySinhController.text) ??
          DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (ngay == null) return;

    final thang = ngay.month.toString().padLeft(2, '0');
    final ngayTrongThang = ngay.day.toString().padLeft(2, '0');

    setState(() {
      ngaySinhController.text = '${ngay.year}-$thang-$ngayTrongThang';
    });
  }

  Future<void> luuThayDoi() async {
    final hoTen = hoTenController.text.trim();
    final soDienThoai = soDienThoaiController.text.trim();
    final ngaySinh = ngaySinhController.text.trim();

    if (hoTen.isEmpty || soDienThoai.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập họ tên và số điện thoại'),
        ),
      );
      return;
    }

    final thanhCong = await context.read<XuLiTaiKhoan>().capNhatThongTin(
          hoTen: hoTen,
          soDienThoai: soDienThoai,
          gioiTinh: gioiTinhDangChon,
          ngaySinh: ngaySinh,
          avatar: avatarDangChon,
        );

    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thông tin'),
        ),
      );

      Navigator.pop(context);
    } else {
      final loi = context.read<XuLiTaiKhoan>().thongBaoLoi;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loi ?? 'Cập nhật thất bại'),
        ),
      );
    }
  }

  Widget avatar() {
    Widget noiDung;

    if (avatarDangChon.isNotEmpty) {
      if (avatarDangChon.startsWith('http')) {
        noiDung = Image.network(
          avatarDangChon,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return iconAvatarMacDinh();
          },
        );
      } else if (File(avatarDangChon).existsSync()) {
        noiDung = Image.file(
          File(avatarDangChon),
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return iconAvatarMacDinh();
          },
        );
      } else {
        noiDung = iconAvatarMacDinh();
      }
    } else {
      noiDung = iconAvatarMacDinh();
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 104,
            height: 104,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: noiDung,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 4,
            child: InkWell(
              onTap: chonAnh,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xff2454ff),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconAvatarMacDinh() {
    return Container(
      color: const Color(0xffe7f1ff),
      child: const Icon(
        Icons.person,
        size: 48,
        color: Color(0xff2454ff),
      ),
    );
  }

  Widget oNhap({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: const Color(0xff2454ff),
                  size: 20,
                ),
          suffixIcon: onTap == null
              ? null
              : const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xff2454ff),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget chonGioiTinh() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wc_rounded,
            color: Color(0xff2454ff),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: gioiTinhDangChon.isEmpty ? null : gioiTinhDangChon,
                hint: const Text(
                  'Chọn giới tính',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Nam',
                    child: Text('Nam'),
                  ),
                  DropdownMenuItem(
                    value: 'Nữ',
                    child: Text('Nữ'),
                  ),
                  DropdownMenuItem(
                    value: 'Khác',
                    child: Text('Khác'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    gioiTinhDangChon = value ?? '';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nutLuu() {
    final taiKhoanXuLy = context.watch<XuLiTaiKhoan>();

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: taiKhoanXuLy.dangTai ? null : luuThayDoi,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2454ff),
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: taiKhoanXuLy.dangTai
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Lưu thay đổi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Chỉnh sửa tài khoản',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 38),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      children: [
                        avatar(),
                        const SizedBox(height: 24),
                        oNhap(
                          label: 'Họ tên',
                          controller: hoTenController,
                          icon: Icons.person_outline_rounded,
                        ),
                        oNhap(
                          label: 'Email',
                          controller: emailController,
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                        oNhap(
                          label: 'Số điện thoại',
                          controller: soDienThoaiController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        chonGioiTinh(),
                        oNhap(
                          label: 'Ngày sinh',
                          controller: ngaySinhController,
                          icon: Icons.calendar_month_rounded,
                          readOnly: true,
                          onTap: chonNgaySinh,
                        ),
                        const SizedBox(height: 8),
                        nutLuu(),
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