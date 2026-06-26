import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../Chung/Duong_dan_api.dart';
import '../Chung/Duong_dan_anh.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li/Xu_li_co_so.dart';
import '../Xu_li/Xu_li_yeu_thich.dart';
import 'Man_hinh_chi_tiet_san.dart';

class ManHinhTatCaSan extends StatefulWidget {
  final bool tuDongFocusTimKiem;

  const ManHinhTatCaSan({
    super.key,
    this.tuDongFocusTimKiem = false,
  });

  @override
  State<ManHinhTatCaSan> createState() => _ManHinhTatCaSanState();
}

class _ManHinhTatCaSanState extends State<ManHinhTatCaSan> {
  final TextEditingController timKiemController = TextEditingController();
  final FocusNode timKiemFocusNode = FocusNode();

  String tuKhoa = '';
  String sapXepDangChon = 'Mặc định';

  double? viDoNguoiDung;
  double? kinhDoNguoiDung;

  bool dangLayViTri = false;

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

      if (widget.tuDongFocusTimKiem) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            timKiemFocusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timKiemController.dispose();
    timKiemFocusNode.dispose();
    super.dispose();
  }

  void hienThongBao(String noiDung) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung),
      ),
    );
  }

  String dinhDangGia(double gia) {
    return '${gia.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String hienThiSoSan(CoSo coSo) {
    final soSan =
        coSo.soLuongSan > 0 ? coSo.soLuongSan : coSo.danhSachSan.length;

    return '$soSan sân';
  }

  double? tinhKhoangCachKm(CoSo coSo) {
    if (viDoNguoiDung == null || kinhDoNguoiDung == null) {
      return null;
    }

    final viDoCoSo = coSo.viDo;
    final kinhDoCoSo = coSo.kinhDo;

    if (viDoCoSo == null || kinhDoCoSo == null) {
      return null;
    }

    if (viDoCoSo == 0 || kinhDoCoSo == 0) {
      return null;
    }

    final met = Geolocator.distanceBetween(
      viDoNguoiDung!,
      kinhDoNguoiDung!,
      viDoCoSo,
      kinhDoCoSo,
    );

    return met / 1000;
  }

  String dinhDangKhoangCach(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }

    if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    }

    return '${km.toStringAsFixed(0)} km';
  }

  String hienThiTinhVaKhoangCach(CoSo coSo) {
    final tinh = coSo.tinhThanh.isEmpty ? 'Cơ sở cầu lông' : coSo.tinhThanh;
    final khoangCach = tinhKhoangCachKm(coSo);

    if (khoangCach == null) {
      return tinh;
    }

    return '$tinh • ${dinhDangKhoangCach(khoangCach)}';
  }

  String tenNutLocSapXep() {
    if (dangLayViTri) return 'Đang lấy';

    if (sapXepDangChon == 'Gần bạn') return 'Gần nhất';
    if (sapXepDangChon == 'Giá thấp đến cao') return 'Giá thấp';
    if (sapXepDangChon == 'Giá cao đến thấp') return 'Giá cao';
    if (sapXepDangChon == 'Nhiều sân nhất') return 'Nhiều sân';

    return 'Lọc và sắp xếp';
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

  Future<void> doiYeuThich(CoSo coSo) async {
    await context.read<XuLiYeuThich>().doiYeuThich(coSo.id);
  }

  Future<void> sapXepTheoGanBan() async {
    if (dangLayViTri) return;

    setState(() {
      dangLayViTri = true;
    });

    try {
      final daBatDichVuViTri = await Geolocator.isLocationServiceEnabled();

      if (!daBatDichVuViTri) {
        hienThongBao('Bạn cần bật vị trí để tìm sân gần bạn');
        await Geolocator.openLocationSettings();
        return;
      }

      var quyen = await Geolocator.checkPermission();

      if (quyen == LocationPermission.denied) {
        quyen = await Geolocator.requestPermission();
      }

      if (quyen == LocationPermission.denied) {
        hienThongBao('Bạn chưa cấp quyền vị trí');
        return;
      }

      if (quyen == LocationPermission.deniedForever) {
        hienThongBao('Bạn đã chặn quyền vị trí, hãy mở cài đặt để cấp lại');
        await Geolocator.openAppSettings();
        return;
      }

      final caiDatViTri = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      final viTri = await Geolocator.getCurrentPosition(
        locationSettings: caiDatViTri,
      );

      if (!mounted) return;

      setState(() {
        viDoNguoiDung = viTri.latitude;
        kinhDoNguoiDung = viTri.longitude;
        sapXepDangChon = 'Gần bạn';
      });
    } catch (_) {
      hienThongBao('Không lấy được vị trí hiện tại');
    } finally {
      if (mounted) {
        setState(() {
          dangLayViTri = false;
        });
      }
    }
  }

  List<CoSo> locDanhSach(List<CoSo> danhSach) {
    List<CoSo> ketQua = List<CoSo>.from(danhSach);

    if (tuKhoa.trim().isNotEmpty) {
      final key = tuKhoa.toLowerCase().trim();

      ketQua = ketQua.where((coSo) {
        return coSo.tenCoSo.toLowerCase().contains(key) ||
            coSo.diaChi.toLowerCase().contains(key) ||
            coSo.phuongXa.toLowerCase().contains(key) ||
            coSo.tinhThanh.toLowerCase().contains(key);
      }).toList();
    }

    if (sapXepDangChon == 'Gần bạn' &&
        viDoNguoiDung != null &&
        kinhDoNguoiDung != null) {
      ketQua.sort((a, b) {
        final khoangCachA = tinhKhoangCachKm(a) ?? double.maxFinite;
        final khoangCachB = tinhKhoangCachKm(b) ?? double.maxFinite;

        return khoangCachA.compareTo(khoangCachB);
      });
    } else if (sapXepDangChon == 'Giá thấp đến cao') {
      ketQua.sort((a, b) {
        final giaA = a.giaThapNhat <= 0 ? double.maxFinite : a.giaThapNhat;
        final giaB = b.giaThapNhat <= 0 ? double.maxFinite : b.giaThapNhat;

        return giaA.compareTo(giaB);
      });
    } else if (sapXepDangChon == 'Giá cao đến thấp') {
      ketQua.sort((a, b) => b.giaThapNhat.compareTo(a.giaThapNhat));
    } else if (sapXepDangChon == 'Nhiều sân nhất') {
      ketQua.sort((a, b) {
        final sanA = a.soLuongSan > 0 ? a.soLuongSan : a.danhSachSan.length;
        final sanB = b.soLuongSan > 0 ? b.soLuongSan : b.danhSachSan.length;

        return sanB.compareTo(sanA);
      });
    }

    return ketQua;
  }

  Widget oTimKiem() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(1, 2.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: timKiemController,
              focusNode: timKiemFocusNode,
              onChanged: (value) {
                setState(() {
                  tuKhoa = value;
                });
              },
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Tìm sân cầu lông',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 1),
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (tuKhoa.isNotEmpty)
            InkWell(
              onTap: () {
                timKiemController.clear();

                setState(() {
                  tuKhoa = '';
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade500,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget nutLoc(
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 34,
        padding: const EdgeInsets.only(left: 8, right: 10),
        decoration: BoxDecoration(
          color: const Color(0xffe7f1ff).withOpacity(0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 13,
                color: const Color(0xff2454ff),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 10.8,
                color: Color(0xff1d3f91),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData iconSapXep(String item) {
    if (item == 'Mặc định') return Icons.restart_alt_rounded;
    if (item == 'Gần bạn') return Icons.location_on_rounded;
    if (item == 'Giá thấp đến cao') return Icons.arrow_upward_rounded;
    if (item == 'Giá cao đến thấp') return Icons.arrow_downward_rounded;
    if (item == 'Nhiều sân nhất') return Icons.stadium_outlined;

    return Icons.sort_rounded;
  }

  void moSapXep() {
    final List<String> danhSach = [
      'Mặc định',
      'Gần bạn',
      'Giá thấp đến cao',
      'Giá cao đến thấp',
      'Nhiều sân nhất',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final chieuCaoToiDa = MediaQuery.of(context).size.height * 0.76;

        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            constraints: BoxConstraints(
              maxHeight: chieuCaoToiDa,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Lọc và sắp xếp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: danhSach.map((item) {
                      final bool dangChon = item == sapXepDangChon;

                      return InkWell(
                        onTap: () async {
                          if (item == 'Gần bạn') {
                            Navigator.pop(context);
                            await sapXepTheoGanBan();
                            return;
                          }

                          setState(() {
                            sapXepDangChon = item;
                          });

                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: dangChon
                                ? const Color(0xffeef4ff)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dangChon
                                  ? const Color(0xff2454ff)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                dangChon
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 17,
                                color: dangChon
                                    ? const Color(0xff2454ff)
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 9),
                              Icon(
                                iconSapXep(item),
                                size: 17,
                                color: dangChon
                                    ? const Color(0xff2454ff)
                                    : Colors.black54,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  item,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: dangChon
                                        ? const Color(0xff2454ff)
                                        : Colors.black87,
                                    fontWeight: dangChon
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget theCoSo(CoSo coSo) {
    final daYeuThich = context.watch<XuLiYeuThich>().kiemTraYeuThich(coSo.id);

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
                            DuongDanApi.linkAnh(coSo.hinhAnh),
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
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () {
                        doiYeuThich(coSo);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          daYeuThich ? Icons.favorite : Icons.favorite_border,
                          color: daYeuThich ? Colors.red : Colors.black87,
                          size: 17,
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
                        hienThiSoSan(coSo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
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
                            hienThiTinhVaKhoangCach(coSo),
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
                      width: 65,
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

  Widget noiDungDanhSach(List<CoSo> danhSachDaLoc) {
    final xuLiCoSo = context.watch<XuLiCoSo>();

    if (xuLiCoSo.dangTai) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (xuLiCoSo.thongBaoLoi != null) {
      return Expanded(
        child: Center(
          child: Text(
            xuLiCoSo.thongBaoLoi!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (danhSachDaLoc.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            tuKhoa.isEmpty ? 'Chưa có cơ sở' : 'Không tìm thấy cơ sở phù hợp',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 18),
        itemCount: danhSachDaLoc.length,
        itemBuilder: (context, index) {
          return theCoSo(danhSachDaLoc[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLiCoSo = context.watch<XuLiCoSo>();
    final danhSachDaLoc = locDanhSach(xuLiCoSo.danhSachCoSo);
    final tongSoCoSo = danhSachDaLoc.length;

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Column(
                children: [
                  Row(
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
                          'Tất cả sân',
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
                  const SizedBox(height: 10),
                  oTimKiem(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      nutLoc(
                        '$tongSoCoSo cơ sở',
                        Icons.manage_search_rounded,
                        () {},
                      ),
                      const SizedBox(width: 8),
                      nutLoc(
                        tenNutLocSapXep(),
                        Icons.tune_rounded,
                        moSapXep,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  noiDungDanhSach(danhSachDaLoc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}