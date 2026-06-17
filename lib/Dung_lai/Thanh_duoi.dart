import 'package:flutter/material.dart';

import '../Man_hinh/Man_hinh_trang_chu.dart';
import '../Man_hinh/Man_hinh_tai_khoan.dart';
import '../Man_hinh/Man_hinh_yeu_thich.dart';
import 'Hieu_ung_chuyen_trang.dart';

class ThanhDuoi extends StatelessWidget {
  final int viTriDangChon;

  const ThanhDuoi({
    super.key,
    required this.viTriDangChon,
  });

  void chuyenTrang(BuildContext context, int viTri) {
    if (viTri == viTriDangChon) return;

    Widget manHinh;

    if (viTri == 0) {
      manHinh = const ManHinhTrangChu();
    } else if (viTri == 1) {
      manHinh = const ManHinhTam(
        tieuDe: 'Bản đồ',
        noiDung: 'Chức năng bản đồ đang phát triển',
        viTriDangChon: 1,
      );
    } else if (viTri == 2) {
      manHinh = const ManHinhYeuThich();
    } else if (viTri == 3) {
      manHinh = const ManHinhTam(
        tieuDe: 'Thông báo',
        noiDung: 'Chức năng thông báo đang phát triển',
        viTriDangChon: 3,
      );
    } else {
      manHinh = const ManHinhTaiKhoan();
    }

    Navigator.pushReplacement(
      context,
      HieuUngChuyenTrang(
        manHinh: manHinh,
      ),
    );
  }

  Widget nutDuoi({
    required BuildContext context,
    required int viTri,
    required IconData icon,
    required String text,
  }) {
    final dangChon = viTri == viTriDangChon;

    return Expanded(
      child: InkWell(
        onTap: () {
          chuyenTrang(context, viTri);
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: dangChon ? 42 : 36,
              height: 30,
              decoration: BoxDecoration(
                color: dangChon
                    ? const Color(0xffdbeafe)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: dangChon ? const Color(0xff2454ff) : Colors.grey,
                size: dangChon ? 23 : 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: dangChon ? const Color(0xff2454ff) : Colors.grey,
                fontSize: 9.6,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          nutDuoi(
            context: context,
            viTri: 0,
            icon: Icons.home_rounded,
            text: 'Trang chủ',
          ),
          nutDuoi(
            context: context,
            viTri: 1,
            icon: Icons.map_rounded,
            text: 'Bản đồ',
          ),
          nutDuoi(
            context: context,
            viTri: 2,
            icon: Icons.favorite_rounded,
            text: 'Yêu thích',
          ),
          nutDuoi(
            context: context,
            viTri: 3,
            icon: Icons.notifications_rounded,
            text: 'Thông báo',
          ),
          nutDuoi(
            context: context,
            viTri: 4,
            icon: Icons.account_circle_rounded,
            text: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

class ManHinhTam extends StatelessWidget {
  final String tieuDe;
  final String noiDung;
  final int viTriDangChon;

  const ManHinhTam({
    super.key,
    required this.tieuDe,
    required this.noiDung,
    required this.viTriDangChon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xffeef6ff),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(2, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.construction_rounded,
                              size: 56,
                              color: Color(0xff2454ff),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              tieuDe,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              noiDung,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ThanhDuoi(
                  viTriDangChon: viTriDangChon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}