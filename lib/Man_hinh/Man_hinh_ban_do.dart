import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../Dung_lai/Hieu_ung_chuyen_trang.dart';
import '../Dung_lai/Thanh_duoi.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li/Xu_li_co_so.dart';
import 'Man_hinh_chi_tiet_san.dart';
import 'Man_hinh_xem_lich_dat_san.dart';

class ManHinhBanDo extends StatefulWidget {
  const ManHinhBanDo({super.key});

  @override
  State<ManHinhBanDo> createState() => _ManHinhBanDoState();
}

class _ManHinhBanDoState extends State<ManHinhBanDo> {
  final MapController mapController = MapController();
  final TextEditingController oTimKiemController = TextEditingController();
  final FocusNode focusTimKiem = FocusNode();

  static const LatLng viTriMacDinh = LatLng(10.762622, 106.660172);

  LatLng? viTriCuaToi;
  CoSo? coSoDangChon;

  bool dangLayViTri = false;
  String tuKhoa = '';
  String kieuSapXep = 'mac_dinh';

  @override
  void initState() {
    super.initState();

    focusTimKiem.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    Future.microtask(() async {
      final xuLyCoSo = context.read<XuLiCoSo>();

      if (xuLyCoSo.danhSachCoSo.isEmpty) {
        await xuLyCoSo.layDanhSachCoSo();
      }

      if (!mounted) return;

      final danhSach = danhSachCoToaDo(xuLyCoSo.danhSachCoSo);

      if (danhSach.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;

          diChuyenMap(
            tinhTamDanhSach(danhSach),
            zoom: 12.2,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    oTimKiemController.dispose();
    focusTimKiem.dispose();
    super.dispose();
  }

  String boDauTiengViet(String text) {
    var result = text.toLowerCase();

    const bangDau = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
    };

    bangDau.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  bool coToaDo(CoSo coSo) {
    return coSo.viDo != 0 && coSo.kinhDo != 0;
  }

  List<CoSo> danhSachCoToaDo(List<CoSo> danhSachGoc) {
    return danhSachGoc.where((coSo) => coToaDo(coSo)).toList();
  }

  LatLng tinhTamDanhSach(List<CoSo> danhSach) {
    if (danhSach.isEmpty) return viTriMacDinh;

    double tongViDo = 0;
    double tongKinhDo = 0;

    for (final coSo in danhSach) {
      tongViDo += coSo.viDo;
      tongKinhDo += coSo.kinhDo;
    }

    return LatLng(
      tongViDo / danhSach.length,
      tongKinhDo / danhSach.length,
    );
  }

  String dinhDangGia(double gia) {
    if (gia <= 0) return 'Chưa có giá';

    return '${gia.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ/giờ';
  }

  double khoangCachKm(CoSo coSo) {
    final viTri = viTriCuaToi;

    if (viTri == null || !coToaDo(coSo)) return 0;

    final met = Geolocator.distanceBetween(
      viTri.latitude,
      viTri.longitude,
      coSo.viDo,
      coSo.kinhDo,
    );

    return met / 1000;
  }

  String dinhDangKhoangCach(CoSo coSo) {
    final km = khoangCachKm(coSo);

    if (km <= 0) return '... km';

    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }

    return '${km.toStringAsFixed(1)} km';
  }

  List<CoSo> danhSachSauKhiLoc(List<CoSo> danhSachGoc) {
    final keyword = boDauTiengViet(tuKhoa.trim());

    final danhSach = danhSachGoc.where((coSo) {
      if (!coToaDo(coSo)) return false;

      if (keyword.isEmpty) return true;

      final noiDungTim = boDauTiengViet(
        [
          coSo.tenCoSo,
          coSo.ten,
          coSo.diaChi,
          coSo.phuongXa,
          coSo.tinhThanh,
        ].join(' '),
      );

      return noiDungTim.contains(keyword);
    }).toList();

    if (kieuSapXep == 'gia_thap') {
      danhSach.sort((a, b) {
        final giaA = a.giaThapNhat <= 0 ? 999999999 : a.giaThapNhat;
        final giaB = b.giaThapNhat <= 0 ? 999999999 : b.giaThapNhat;
        return giaA.compareTo(giaB);
      });
    } else if (kieuSapXep == 'danh_gia') {
      danhSach.sort((a, b) => b.danhGia.compareTo(a.danhGia));
    } else if (kieuSapXep == 'gan_ban' && viTriCuaToi != null) {
      danhSach.sort((a, b) => khoangCachKm(a).compareTo(khoangCachKm(b)));
    }

    return danhSach;
  }

  List<CoSo> danhSachGoiY(List<CoSo> danhSachGoc) {
    if (tuKhoa.trim().isEmpty) return [];

    final danhSach = danhSachSauKhiLoc(danhSachGoc);

    if (viTriCuaToi != null) {
      danhSach.sort((a, b) => khoangCachKm(a).compareTo(khoangCachKm(b)));
    }

    if (danhSach.length > 6) {
      return danhSach.sublist(0, 6);
    }

    return danhSach;
  }

  CoSo? coSoDangHienThi(List<CoSo> danhSach) {
    final coSo = coSoDangChon;

    if (coSo != null && danhSach.any((item) => item.id == coSo.id)) {
      return coSo;
    }

    return null;
  }

  LatLng tamBanDoDauTien(List<CoSo> danhSachCoSo) {
    final danhSach = danhSachCoToaDo(danhSachCoSo);

    if (danhSach.isNotEmpty) {
      return tinhTamDanhSach(danhSach);
    }

    return viTriMacDinh;
  }

  void diChuyenMap(
    LatLng target, {
    double zoom = 15,
  }) {
    mapController.move(target, zoom);
  }

  void chonCoSo(CoSo coSo) {
    setState(() {
      coSoDangChon = coSo;
    });

    diChuyenMap(
      LatLng(coSo.viDo, coSo.kinhDo),
      zoom: 15.5,
    );
  }

  void chonGoiY(CoSo coSo) {
    oTimKiemController.text = coSo.tenCoSo;

    setState(() {
      tuKhoa = coSo.tenCoSo;
      coSoDangChon = coSo;
    });

    focusTimKiem.unfocus();

    diChuyenMap(
      LatLng(coSo.viDo, coSo.kinhDo),
      zoom: 15.5,
    );
  }

  void timVaDiChuyen() {
    final danhSachGoc = context.read<XuLiCoSo>().danhSachCoSo;
    final danhSach = danhSachSauKhiLoc(danhSachGoc);

    if (danhSach.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy sân phù hợp'),
        ),
      );
      return;
    }

    chonGoiY(danhSach.first);
  }

  Future<bool> xinQuyenViTri() async {
    final batDinhVi = await Geolocator.isLocationServiceEnabled();

    if (!batDinhVi) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần bật định vị trên điện thoại'),
        ),
      );

      return false;
    }

    LocationPermission quyen = await Geolocator.checkPermission();

    if (quyen == LocationPermission.denied) {
      quyen = await Geolocator.requestPermission();
    }

    if (quyen == LocationPermission.denied ||
        quyen == LocationPermission.deniedForever) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa cấp quyền vị trí'),
        ),
      );

      return false;
    }

    return true;
  }

  Future<void> layViTriCuaToi() async {
    if (dangLayViTri) return;

    setState(() {
      dangLayViTri = true;
    });

    try {
      final duocCapQuyen = await xinQuyenViTri();
      if (!duocCapQuyen) return;

      final viTri = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final latLng = LatLng(viTri.latitude, viTri.longitude);

      setState(() {
        viTriCuaToi = latLng;
        kieuSapXep = 'gan_ban';
      });

      diChuyenMap(latLng, zoom: 14.5);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Không lấy được vị trí: ${e.toString().replaceAll('Exception: ', '')}",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          dangLayViTri = false;
        });
      }
    }
  }

  void moChiTiet(CoSo coSo) {
    Navigator.push(
      context,
      HieuUngChuyenTrang(
        manHinh: ManHinhChiTietSan(
          coSo: coSo,
        ),
      ),
    );
  }

  void moDatSan(CoSo coSo) {
    Navigator.push(
      context,
      HieuUngChuyenTrang(
        manHinh: ManHinhXemLichSan(
          coSo: coSo,
        ),
      ),
    );
  }

  List<CircleMarker> taoVongTronViTri() {
    if (viTriCuaToi == null) return [];

    return [
      CircleMarker(
        point: viTriCuaToi!,
        radius: 130,
        useRadiusInMeter: true,
        color: const Color(0xff2454ff).withOpacity(0.10),
        borderColor: const Color(0xff2454ff).withOpacity(0.28),
        borderStrokeWidth: 2,
      ),
    ];
  }

  List<Marker> taoMarker(
    List<CoSo> danhSachCoSo,
    CoSo? coSoDangHienThi,
  ) {
    final markers = <Marker>[];

    for (final coSo in danhSachCoSo) {
      final dangChon = coSoDangHienThi?.id == coSo.id;

      markers.add(
        Marker(
          width: dangChon ? 50 : 42,
          height: dangChon ? 50 : 42,
          point: LatLng(coSo.viDo, coSo.kinhDo),
          child: GestureDetector(
            onTap: () {
              focusTimKiem.unfocus();
              chonCoSo(coSo);
            },
            child: Icon(
              Icons.location_on_rounded,
              color: dangChon ? const Color(0xff16a34a) : Colors.black87,
              size: dangChon ? 44 : 35,
            ),
          ),
        ),
      );
    }

    if (viTriCuaToi != null) {
      markers.add(
        Marker(
          width: 48,
          height: 48,
          point: viTriCuaToi!,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff2454ff).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: const Color(0xff2454ff),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget oTimKiem() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: TextField(
        controller: oTimKiemController,
        focusNode: focusTimKiem,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          setState(() {
            tuKhoa = value;
            coSoDangChon = null;
          });
        },
        onSubmitted: (_) {
          timVaDiChuyen();
        },
        decoration: InputDecoration(
          hintText: 'Tìm sân cầu lông',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 21,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 42,
          ),
          suffixIcon: tuKhoa.trim().isEmpty
              ? null
              : IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    oTimKiemController.clear();

                    setState(() {
                      tuKhoa = '';
                      coSoDangChon = null;
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.only(
            top: 12,
            right: 10,
          ),
        ),
      ),
    );
  }

  Widget nutLoc() {
    return InkWell(
      onTap: moBangLoc,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 42,
        width: 68,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 7,
              offset: Offset(1, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              color: Color(0xff2454ff),
              size: 18,
            ),
            SizedBox(width: 4),
            Text(
              'Lọc',
              style: TextStyle(
                color: Color(0xff2454ff),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nutGanBan() {
    return InkWell(
      onTap: layViTriCuaToi,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xff2454ff),
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2454ff).withOpacity(0.24),
              blurRadius: 7,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dangLayViTri
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.near_me_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
            const SizedBox(width: 5),
            const Text(
              'Gần bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemGoiY(CoSo coSo) {
    return InkWell(
      onTap: () {
        chonGoiY(coSo);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xffeef4ff),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xff2454ff),
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coSo.tenCoSo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff172554),
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    coSo.diaChi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dinhDangKhoangCach(coSo),
                  style: const TextStyle(
                    color: Color(0xff2454ff),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.north_west_rounded,
                  color: Colors.black54,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget hopGoiY(List<CoSo> danhSach) {
    if (!focusTimKiem.hasFocus || tuKhoa.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final goiY = danhSachGoiY(danhSach);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: goiY.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Không tìm thấy sân phù hợp',
                style: TextStyle(
                  color: Color(0xff172554),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 5),
              shrinkWrap: true,
              itemCount: goiY.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  thickness: 0.7,
                  color: Colors.grey.shade200,
                  indent: 58,
                );
              },
              itemBuilder: (context, index) {
                return itemGoiY(goiY[index]);
              },
            ),
    );
  }

  Widget lopTimKiemVaLoc(List<CoSo> danhSachGoc) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: oTimKiem(),
                ),
                const SizedBox(width: 8),
                nutLoc(),
              ],
            ),
            hopGoiY(danhSachGoc),
            const SizedBox(height: 10),
            nutGanBan(),
          ],
        ),
      ),
    );
  }

  Widget anhMacDinh() {
    return Container(
      width: 92,
      height: 100,
      color: const Color(0xffe7f1ff),
      child: const Icon(
        Icons.sports_tennis_rounded,
        color: Color(0xff2454ff),
        size: 36,
      ),
    );
  }

  Widget cardCoSoDangChon(CoSo coSo) {
    final danhGiaText =
        coSo.danhGia <= 0 ? '4.9' : coSo.danhGia.toStringAsFixed(1);

    final diaChi =
        coSo.diaChi.trim().isEmpty ? 'Chưa có địa chỉ' : coSo.diaChi.trim();

    return GestureDetector(
      onTap: () {
        moChiTiet(coSo);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 9,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                bottomLeft: Radius.circular(17),
              ),
              child: coSo.hinhAnh.isNotEmpty
                  ? Image.network(
                      coSo.hinhAnh,
                      width: 92,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          anhMacDinh(),
                    )
                  : anhMacDinh(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coSo.tenCoSo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff172554),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: Color(0xffffc107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          danhGiaText,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.location_on_rounded,
                          size: 10,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            dinhDangKhoangCach(coSo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
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
                          Icons.place_rounded,
                          size: 10,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            diaChi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
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
                          Icons.access_time_rounded,
                          size: 10,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '5:00 - 22:00',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          height: 21,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xffdcfce7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xff16a34a),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Còn trống',
                                style: TextStyle(
                                  color: Color(0xff16a34a),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dinhDangGia(coSo.giaThapNhat),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xff2454ff),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 25,
                          child: ElevatedButton(
                            onPressed: () {
                              moDatSan(coSo);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2454ff),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Đặt',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget nutLuaChonLoc({
    required String text,
    required String value,
    required IconData icon,
  }) {
    final dangChon = kieuSapXep == value;

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: dangChon ? const Color(0xff2454ff) : Colors.grey.shade700,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: dangChon ? FontWeight.bold : FontWeight.w500,
          color: dangChon ? const Color(0xff2454ff) : Colors.black87,
        ),
      ),
      trailing: dangChon
          ? const Icon(
              Icons.check_circle_rounded,
              color: Color(0xff2454ff),
            )
          : null,
      onTap: () async {
        Navigator.pop(context);

        if (value == 'gan_ban' && viTriCuaToi == null) {
          await layViTriCuaToi();
        }

        if (!mounted) return;

        setState(() {
          kieuSapXep = value;
        });

        final danhSachGoc = context.read<XuLiCoSo>().danhSachCoSo;
        final danhSach = danhSachSauKhiLoc(danhSachGoc);

        if (danhSach.isNotEmpty) {
          diChuyenMap(
            tinhTamDanhSach(danhSach),
            zoom: 12.5,
          );
        }
      },
    );
  }

  void moBangLoc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Lọc sân trên bản đồ',
                  style: TextStyle(
                    color: Color(0xff172554),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                nutLuaChonLoc(
                  text: 'Mặc định',
                  value: 'mac_dinh',
                  icon: Icons.map_rounded,
                ),
                nutLuaChonLoc(
                  text: 'Gần bạn nhất',
                  value: 'gan_ban',
                  icon: Icons.near_me_rounded,
                ),
                nutLuaChonLoc(
                  text: 'Giá thấp nhất',
                  value: 'gia_thap',
                  icon: Icons.sell_rounded,
                ),
                nutLuaChonLoc(
                  text: 'Đánh giá cao',
                  value: 'danh_gia',
                  icon: Icons.star_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget chuThichOsm() {
    return Positioned(
      right: 12,
      bottom: 224,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '© OpenStreetMap',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLyCoSo = context.watch<XuLiCoSo>();

    final danhSachHienThi = danhSachSauKhiLoc(xuLyCoSo.danhSachCoSo);
    final coSoHienTai = coSoDangHienThi(danhSachHienThi);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const ThanhDuoi(
        viTriDangChon: 1,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: tamBanDoDauTien(xuLyCoSo.danhSachCoSo),
                initialZoom: 12.2,
                minZoom: 5,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  focusTimKiem.unfocus();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.do_an',
                ),
                CircleLayer(
                  circles: taoVongTronViTri(),
                ),
                MarkerLayer(
                  markers: taoMarker(danhSachHienThi, coSoHienTai),
                ),
              ],
            ),
          ),
          lopTimKiemVaLoc(xuLyCoSo.danhSachCoSo),
          chuThichOsm(),
          if (xuLyCoSo.dangTai)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xff2454ff),
              ),
            ),
          if (xuLyCoSo.thongBaoLoi != null && xuLyCoSo.danhSachCoSo.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.all(22),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  xuLyCoSo.thongBaoLoi!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (coSoHienTai != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 104,
              child: cardCoSoDangChon(coSoHienTai),
            ),
        ],
      ),
    );
  }
}