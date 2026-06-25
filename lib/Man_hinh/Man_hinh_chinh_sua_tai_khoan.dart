import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Chung/Duong_dan_api.dart';
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

  final ImagePicker imagePicker = ImagePicker();

  String gioiTinhDangChon = '';
  String avatarDangChon = '';

  bool dangChonAnh = false;

  String chuyenGioiTinhHienThi(String gioiTinh) {
    final text = gioiTinh.trim().toLowerCase();

    if (text == '1' || text == 'nam' || text == 'male') return 'Nam';

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

    return gioiTinh;
  }

  bool laAnhHopLe(String path) {
    final lower = path.toLowerCase();

    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  String linkAnhHienThi(String avatar) {
    final value = avatar.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return DuongDanApi.linkAnh(value);
  }

  Future<String> doiWebpSangJpgNeuCan(String path) async {
    final lower = path.toLowerCase();

    if (!lower.endsWith('.webp')) {
      return path;
    }

    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Không tìm thấy ảnh WEBP');
    }

    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Không đọc được ảnh WEBP');
    }

    final jpgBytes = img.encodeJpg(
      image,
      quality: 90,
    );

    final jpgPath = '${path.substring(0, path.length - 5)}.jpg';
    final jpgFile = File(jpgPath);

    await jpgFile.writeAsBytes(jpgBytes);

    return jpgPath;
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
    if (dangChonAnh) return;

    setState(() {
      dangChonAnh = true;
    });

    try {
      final XFile? anh = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (!mounted) return;
      if (anh == null) return;

      if (!laAnhHopLe(anh.path)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chỉ hỗ trợ ảnh JPG, PNG hoặc WEBP'),
          ),
        );
        return;
      }

      final pathSauKhiXuLy = await doiWebpSangJpgNeuCan(anh.path);

      if (!mounted) return;

      setState(() {
        avatarDangChon = pathSauKhiXuLy;
      });
    } on PlatformException catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');

      if (!mounted) return;

      String thongBao = 'Không chọn được ảnh';

      if (e.code == 'already_active') {
        thongBao = 'Bộ chọn ảnh đang mở, vui lòng đợi một chút';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(thongBao),
        ),
      );
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          dangChonAnh = false;
        });
      } else {
        dangChonAnh = false;
      }
    }
  }

  Future<void> chonNgaySinh() async {
    final DateTime? ngay = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(ngaySinhController.text) ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (ngay == null) return;
    if (!mounted) return;

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

    final avatar = avatarDangChon.trim();

    if (avatar.isEmpty) {
      noiDung = iconAvatarMacDinh();
    } else if (File(avatar).existsSync()) {
      noiDung = Image.file(
        File(avatar),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return iconAvatarMacDinh();
        },
      );
    } else {
      noiDung = Image.network(
        linkAnhHienThi(avatar),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return iconAvatarMacDinh();
        },
      );
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
              onTap: dangChonAnh ? null : chonAnh,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: dangChonAnh
                      ? Colors.grey.shade500
                      : const Color(0xff2454ff),
                  shape: BoxShape.circle,
                ),
                child: dangChonAnh
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
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