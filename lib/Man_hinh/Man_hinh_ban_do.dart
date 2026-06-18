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

  static const LatLng viTriMacDinh = LatLng(10.762622, 106.660172);

  LatLng? viTriCuaToi;
  CoSo? coSoDangChon;

  bool dangLayViTri = false;
  String tuKhoa = '';
  String kieuSapXep = 'mac_dinh';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final xuLyCoSo = context.read<XuLiCoSo>();

      if (xuLyCoSo.danhSachCoSo.isEmpty) {
        await xuLyCoSo.layDanhSachCoSo();
      }

      if (!mounted) return;

      final danhSach = danhSachSauKhiLoc(xuLyCoSo.danhSachCoSo);

      if (danhSach.isNotEmpty) {
        setState(() {
          coSoDangChon = danhSach.first;
        });

        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;

          diChuyenMap(
            LatLng(danhSach.first.viDo, danhSach.first.kinhDo),
            zoom: 14,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    oTimKiemController.dispose();
    super.dispose();
  }

  bool coToaDo(CoSo coSo) {
    return coSo.viDo != 0 && coSo.kinhDo != 0;
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
    final keyword = tuKhoa.trim().toLowerCase();

    final danhSach = danhSachGoc.where((coSo) {
      if (!coToaDo(coSo)) return false;

      if (keyword.isEmpty) return true;

      final noiDungTim = [
        coSo.tenCoSo,
        coSo.ten,
        coSo.diaChi,
        coSo.phuongXa,
        coSo.tinhThanh,
      ].join(' ').toLowerCase();

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

  CoSo? coSoDangHienThi(List<CoSo> danhSach) {
    final coSo = coSoDangChon;

    if (coSo != null && danhSach.any((item) => item.id == coSo.id)) {
      return coSo;
    }

    if (danhSach.isNotEmpty) return danhSach.first;

    return null;
  }

  LatLng tamBanDoDauTien(List<CoSo> danhSachCoSo) {
    final danhSach = danhSachSauKhiLoc(danhSachCoSo);
    final coSo = coSoDangHienThi(danhSach);

    if (coSo != null) {
      return LatLng(coSo.viDo, coSo.kinhDo);
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
      zoom: 15,
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

    chonCoSo(danhSach.first);
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
          width: dangChon ? 48 : 40,
          height: dangChon ? 48 : 40,
          point: LatLng(coSo.viDo, coSo.kinhDo),
          child: GestureDetector(
            onTap: () {
              chonCoSo(coSo);
            },
            child: Icon(
              Icons.location_on_rounded,
              color: dangChon ? const Color(0xff16a34a) : Colors.black87,
              size: dangChon ? 42 : 34,
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: TextField(
        controller: oTimKiemController,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          setState(() {
            tuKhoa = value;
          });
        },
        onSubmitted: (_) {
          timVaDiChuyen();
        },
        decoration: InputDecoration(
          hintText: 'Tìm sân cầu lông',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 23,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 50,
          ),
          suffixIcon: tuKhoa.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    oTimKiemController.clear();

                    setState(() {
                      tuKhoa = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                  ),
                ),
          border: InputBorder.none,
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 0,
          ),
        ),
      ),
    );
  }

  Widget nutLoc() {
    return InkWell(
      onTap: moBangLoc,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 50,
        width: 78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
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
              size: 19,
            ),
            SizedBox(width: 5),
            Text(
              'Lọc',
              style: TextStyle(
                color: Color(0xff2454ff),
                fontSize: 13,
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

  Widget lopTimKiemVaLoc() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: oTimKiem(),
                ),
                const SizedBox(width: 10),
                nutLoc(),
              ],
            ),
            const SizedBox(height: 12),
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

    return Container(
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
          GestureDetector(
            onTap: () {
              moChiTiet(coSo);
            },
            child: ClipRRect(
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      moChiTiet(coSo);
                    },
                    child: Text(
                      coSo.tenCoSo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff172554),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 9),
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
    );
  }

  Widget cardKhongCoSan() {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Chưa có sân có tọa độ để hiển thị trên bản đồ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xff172554),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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

        timVaDiChuyen();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final xuLyCoSo = context.watch<XuLiCoSo>();

    final danhSach = danhSachSauKhiLoc(xuLyCoSo.danhSachCoSo);
    final coSoHienTai = coSoDangHienThi(danhSach);

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
                initialZoom: 13,
                minZoom: 5,
                maxZoom: 18,
                onTap: (tapPosition, point) {
                  FocusScope.of(context).unfocus();
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
                  markers: taoMarker(danhSach, coSoHienTai),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          lopTimKiemVaLoc(),
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
          Positioned(
            left: 14,
            right: 14,
            bottom: 104,
            child: coSoHienTai == null
                ? cardKhongCoSan()
                : cardCoSoDangChon(coSoHienTai),
          ),
        ],
      ),
    );
  }
}