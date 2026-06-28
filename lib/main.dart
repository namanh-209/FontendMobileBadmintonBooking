import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Man_hinh/Man_hinh_trang_chu.dart';
import 'Xu_li/Xu_li_co_so.dart';
import 'Xu_li/Xu_li_dat_san.dart';
import 'Xu_li/Xu_li_san.dart';
import 'Xu_li/Xu_li_tai_khoan.dart';
import 'Xu_li/Xu_li_thanh_toan.dart';
import 'Xu_li/Xu_li_yeu_thich.dart';
import 'Dung_lai/Hieu_ung_tai.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<XuLiTaiKhoan>(
          create: (_) => XuLiTaiKhoan(),
        ),
        ChangeNotifierProvider<SanXuLy>(
          create: (_) => SanXuLy(),
        ),
        ChangeNotifierProvider<XuLiYeuThich>(
          create: (_) => XuLiYeuThich(),
        ),
        ChangeNotifierProvider<XuLiCoSo>(
          create: (_) => XuLiCoSo(),
        ),
        ChangeNotifierProvider<XuLiDatSan>(
          create: (_) => XuLiDatSan(),
        ),
        ChangeNotifierProvider<XuLiThanhToan>(
          create: (_) => XuLiThanhToan(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Badminton Booking',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff2454ff),
          ),
          scaffoldBackgroundColor: const Color(0xffeef6ff),
        ),
        home: const ManHinhKhoiDong(),
      ),
    );
  }
}

class ManHinhKhoiDong extends StatefulWidget {
  const ManHinhKhoiDong({
    super.key,
  });

  @override
  State<ManHinhKhoiDong> createState() => _ManHinhKhoiDongState();
}

class _ManHinhKhoiDongState extends State<ManHinhKhoiDong> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<XuLiTaiKhoan>().taiDangNhapDaLuu();

      if (!mounted) return;

      await context.read<XuLiYeuThich>().taiYeuThichDaLuu();

      if (!mounted) return;

      await context.read<XuLiCoSo>().layDanhSachCoSo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taiKhoanXuLy = context.watch<XuLiTaiKhoan>();

    if (taiKhoanXuLy.daKiemTraDangNhap == false) {
      return Scaffold(
        backgroundColor: const Color(0xffeef6ff),
        body: Center(
          child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: const HieuUngTai(
              text: 'Đang khởi động...',
            ),
          ),
        ),
      );
    }

    return const ManHinhTrangChu();
  }
}