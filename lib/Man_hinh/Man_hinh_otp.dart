import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Xu_li/Xu_li_tai_khoan.dart';
import 'Man_hinh_dat_lai_mk.dart';

class ManHinhOtp extends StatefulWidget {
  final String taiKhoan;

  const ManHinhOtp({
    super.key,
    required this.taiKhoan,
  });

  @override
  State<ManHinhOtp> createState() => _ManHinhOtpState();
}

class _ManHinhOtpState extends State<ManHinhOtp> {
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  Timer? demNguocTimer;
  int soGiayConLai = 300;

  @override
  void initState() {
    super.initState();
    batDauDemNguoc();
  }

  @override
  void dispose() {
    demNguocTimer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void batDauDemNguoc() {
    demNguocTimer?.cancel();

    setState(() {
      soGiayConLai = 300;
    });

    demNguocTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (soGiayConLai == 0) {
          timer.cancel();
        } else {
          setState(() {
            soGiayConLai--;
          });
        }
      },
    );
  }

  String layMaOtp() {
    return otpControllers.map((controller) => controller.text.trim()).join();
  }

  String dinhDangThoiGianGuiLai() {
    final phut = soGiayConLai ~/ 60;
    final giay = soGiayConLai % 60;

    return '$phut:${giay.toString().padLeft(2, '0')}';
  }

  void xoaOtpCu() {
    for (final controller in otpControllers) {
      controller.clear();
    }

    focusNodes.first.requestFocus();
  }

  void xacNhanOtp() async {
    final otp = layMaOtp();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số OTP')),
      );
      return;
    }

    final xuLy = context.read<XuLiTaiKhoan>();

    final thanhCong = await xuLy.xacThucOtp(
      taiKhoan: widget.taiKhoan,
      otp: otp,
    );

    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực OTP thành công')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ManHinhDatLaiMatKhau(
            taiKhoan: widget.taiKhoan,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(xuLy.thongBaoLoi ?? 'OTP không đúng'),
        ),
      );
    }
  }

  void guiLaiOtp() async {
    if (soGiayConLai > 0) {
      return;
    }

    final xuLy = context.read<XuLiTaiKhoan>();

    final thanhCong = await xuLy.quenMatKhau(
      taiKhoan: widget.taiKhoan,
    );

    if (!mounted) return;

    if (thanhCong) {
      xoaOtpCu();
      batDauDemNguoc();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại OTP về Gmail')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(xuLy.thongBaoLoi ?? 'Gửi lại OTP thất bại'),
        ),
      );
    }
  }

  Widget oNhapOtp(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.0,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.black54,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xff2454ff),
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            focusNodes[index + 1].requestFocus();
          }

          if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLy = context.watch<XuLiTaiKhoan>();

    final coTheGuiLai = soGiayConLai == 0 && !xuLy.dangTai;

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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 35),

                  Image.asset(
                    DuongDanAnh.logo,
                    width: 230,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Nhập OTP',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Mã xác thực đã được gửi đến',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black45),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.taiKhoan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => oNhapOtp(index),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    soGiayConLai > 0
                        ? 'Bạn có thể gửi lại mã sau ${dinhDangThoiGianGuiLai()}'
                        : 'Bạn có thể gửi lại mã OTP',
                    style: TextStyle(
                      fontSize: 14,
                      color: soGiayConLai > 0
                          ? Colors.black54
                          : const Color(0xff2454ff),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: 210,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: xuLy.dangTai ? null : xacNhanOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2454ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: xuLy.dangTai
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Xác Nhận',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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

                  const SizedBox(height: 25),

                  SizedBox(
                    width: 180,
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: coTheGuiLai ? guiLaiOtp : null,
                      icon: Icon(
                        Icons.refresh,
                        color: coTheGuiLai
                            ? const Color(0xff2196f3)
                            : Colors.grey,
                      ),
                      label: Text(
                        soGiayConLai > 0
                            ? 'Gửi lại (${dinhDangThoiGianGuiLai()})'
                            : 'Gửi lại mã',
                        style: TextStyle(
                          color: coTheGuiLai
                              ? const Color(0xff2196f3)
                              : Colors.grey,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: coTheGuiLai
                              ? const Color(0xff2196f3)
                              : Colors.grey,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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