import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_anh.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li/Xu_li_co_so.dart';
import '../Xu_li/Xu_li_yeu_thich.dart';
import 'Man_hinh_chi_tiet_san.dart';

class ManHinhYeuThich extends StatefulWidget {
  const ManHinhYeuThich({
    super.key,
  });

  @override
  State<ManHinhYeuThich> createState() => _ManHinhYeuThichState();
}

class _ManHinhYeuThichState extends State<ManHinhYeuThich> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<XuLiYeuThich>().taiYeuThichDaLuu();

      if (!mounted) return;

      final xuLiCoSo = context.read<XuLiCoSo>();

      if (xuLiCoSo.danhSachCoSo.isEmpty) {
        await xuLiCoSo.layDanhSachCoSo();
      }
    });
  }

  String dinhDangGia(double gia) {
    return '${gia.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  void chuyenChiTietCoSo(CoSo coSo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManHinhChiTietSan(
          coSo: coSo,
        ),
      ),
    );
  }

  Widget anhMacDinh() {
    return Container(
      width: 108,
      height: 108,
      color: Colors.blue.shade50,
      child: const Icon(
        Icons.sports_tennis,
        size: 28,
        color: Color(0xff2454ff),
      ),
    );
  }

  Widget theCoSoYeuThich(CoSo coSo) {
    return InkWell(
      onTap: () {
        chuyenChiTietCoSo(coSo);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        height: 108,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                    child: coSo.hinhAnh.isNotEmpty
                        ? Image.network(
                            coSo.hinhAnh,
                            width: 108,
                            height: 108,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return anhMacDinh();
                            },
                          )
                        : anhMacDinh(),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${coSo.soLuongSan} sân',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () {
                        context.read<XuLiYeuThich>().doiYeuThich(coSo.id);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coSo.tenCoSo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            coSo.tinhThanh.isEmpty
                                ? 'Cơ sở cầu lông'
                                : coSo.tinhThanh,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.6,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xff2454ff),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '4,9 (297 đánh giá)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey.shade600,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  coSo.diaChi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffe8ecff),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Còn sân',
                              style: TextStyle(
                                color: Color(0xff2454ff),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 66,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Chỉ từ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${dinhDangGia(coSo.giaThapNhat)}/giờ',
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff2454ff),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.08,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 65,
                            height: 29,
                            child: ElevatedButton(
                              onPressed: () {
                                chuyenChiTietCoSo(coSo);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2454ff),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text(
                                'Đặt Sân',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget manHinhTrong() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xffe7f1ff),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xff2454ff),
                size: 38,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Chưa có cơ sở yêu thích',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bấm vào biểu tượng trái tim ở trang chủ để lưu cơ sở bạn thích.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLiCoSo = context.watch<XuLiCoSo>();
    final xuLiYeuThich = context.watch<XuLiYeuThich>();

    final danhSachYeuThich = xuLiCoSo.danhSachCoSo.where((coSo) {
      return xuLiYeuThich.kiemTraYeuThich(coSo.id);
    }).toList();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ThanhDuoi(
        viTriDangChon: 2,
      ),
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
                const SizedBox(height: 12),
                const Text(
                  'Yêu thích',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: xuLiCoSo.dangTai
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff2454ff),
                          ),
                        )
                      : danhSachYeuThich.isEmpty
                          ? manHinhTrong()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                4,
                                14,
                                18,
                              ),
                              itemCount: danhSachYeuThich.length,
                              itemBuilder: (context, index) {
                                return theCoSoYeuThich(
                                  danhSachYeuThich[index],
                                );
                              },
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