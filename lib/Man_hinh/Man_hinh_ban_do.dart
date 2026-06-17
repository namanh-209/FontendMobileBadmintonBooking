// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';

// import '../Chung/Duong_dan_anh.dart';
// import '../Dung_lai/Thanh_duoi.dart';
// import '../Mau_du_lieu/San.dart';
// import '../Xu_li/Xu_li_san.dart';
// import '../Xu_li/Xu_li_tai_khoan.dart';

// class ManHinhBanDo extends StatefulWidget {
//   const ManHinhBanDo({super.key});

//   @override
//   State<ManHinhBanDo> createState() => _ManHinhBanDoState();
// }

// class _ManHinhBanDoState extends State<ManHinhBanDo> {
//   final MapController mapController = MapController();

//   final LatLng viTriMacDinh = const LatLng(10.762622, 106.660172);

//   LatLng? viTriCuaToi;
//   bool dangLayViTri = false;

//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       final xuLySan = context.read<SanXuLy>();

//       if (xuLySan.danhSachSan.isEmpty) {
//         xuLySan.layDanhSachSan();
//       }
//     });
//   }

//   String dinhDangGia(double gia) {
//     return '${gia.toStringAsFixed(0).replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//         )}đ';
//   }

//   LatLng layToaDoSan(San san) {
//     if (san.viDo != 0 && san.kinhDo != 0) {
//       return LatLng(san.viDo, san.kinhDo);
//     }

//     return viTriMacDinh;
//   }

//   Future<void> layViTriCuaToi() async {
//     if (dangLayViTri) return;

//     setState(() {
//       dangLayViTri = true;
//     });

//     try {
//       final dichVuBat = await Geolocator.isLocationServiceEnabled();

//       if (!dichVuBat) {
//         if (!mounted) return;

//         setState(() {
//           dangLayViTri = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Bạn chưa bật vị trí/GPS trên máy ảo'),
//           ),
//         );

//         return;
//       }

//       LocationPermission quyen = await Geolocator.checkPermission();

//       if (quyen == LocationPermission.denied) {
//         quyen = await Geolocator.requestPermission();
//       }

//       if (quyen == LocationPermission.denied) {
//         if (!mounted) return;

//         setState(() {
//           dangLayViTri = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Bạn chưa cấp quyền vị trí'),
//           ),
//         );

//         return;
//       }

//       if (quyen == LocationPermission.deniedForever) {
//         if (!mounted) return;

//         setState(() {
//           dangLayViTri = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Quyền vị trí đã bị từ chối vĩnh viễn'),
//           ),
//         );

//         return;
//       }

//       final viTri = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.low,
//         timeLimit: const Duration(seconds: 5),
//       );

//       final toaDo = LatLng(
//         viTri.latitude,
//         viTri.longitude,
//       );

//       if (!mounted) return;

//       setState(() {
//         viTriCuaToi = toaDo;
//         dangLayViTri = false;
//       });

//       mapController.move(
//         toaDo,
//         16,
//       );
//     } on TimeoutException {
//       if (!mounted) return;

//       setState(() {
//         dangLayViTri = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Lấy vị trí quá lâu, hãy set Location trong Emulator'),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         dangLayViTri = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Không lấy được vị trí: $e'),
//         ),
//       );
//     }
//   }

//   void xuLyDatSan(San san) {
//     final taiKhoanXuLy = context.read<XuLiTaiKhoan>();

//     if (taiKhoanXuLy.daDangNhap == false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng đăng nhập để đặt sân'),
//         ),
//       );
//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Bạn đang đặt sân: ${san.tenSan}'),
//       ),
//     );
//   }

//   Widget anhLoi() {
//     return Container(
//       width: 92,
//       height: 92,
//       color: const Color(0xffe7f1ff),
//       child: const Icon(
//         Icons.sports_tennis_rounded,
//         color: Color(0xff2454ff),
//         size: 34,
//       ),
//     );
//   }

//   void hienThongTinSan(San san, LatLng toaDo) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           margin: const EdgeInsets.all(14),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(22),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 12,
//                 offset: Offset(2, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: san.hinhAnh.isNotEmpty
//                     ? Image.network(
//                         san.hinhAnh,
//                         width: 92,
//                         height: 92,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return anhLoi();
//                         },
//                       )
//                     : anhLoi(),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       san.tenSan,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 15.5,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       san.tenCoSo,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on_rounded,
//                           size: 15,
//                           color: Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             san.diaChi,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 11.5,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       '${dinhDangGia(san.giaThapNhat)}/giờ',
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xff2454ff),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 9),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: SizedBox(
//                             height: 34,
//                             child: OutlinedButton(
//                               onPressed: () {
//                                 Navigator.pop(context);

//                                 mapController.move(
//                                   toaDo,
//                                   16,
//                                 );
//                               },
//                               style: OutlinedButton.styleFrom(
//                                 side: const BorderSide(
//                                   color: Color(0xff2454ff),
//                                   width: 1,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(11),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'Xem vị trí',
//                                 style: TextStyle(
//                                   color: Color(0xff2454ff),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: SizedBox(
//                             height: 34,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 xuLyDatSan(san);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xff2454ff),
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(11),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'Đặt sân',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Marker markerSan({
//     required San san,
//     required LatLng toaDo,
//   }) {
//     return Marker(
//       point: toaDo,
//       width: 48,
//       height: 58,
//       child: GestureDetector(
//         onTap: () {
//           hienThongTinSan(san, toaDo);
//         },
//         child: Column(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: const Color(0xff2454ff),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 3,
//                 ),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 6,
//                     offset: Offset(1, 3),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.sports_tennis_rounded,
//                 color: Colors.white,
//                 size: 22,
//               ),
//             ),
//             Container(
//               width: 3,
//               height: 10,
//               color: const Color(0xff2454ff),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Marker markerViTriCuaToi() {
//     return Marker(
//       point: viTriCuaToi!,
//       width: 54,
//       height: 54,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.22),
//           shape: BoxShape.circle,
//         ),
//         child: Center(
//           child: Container(
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//               color: const Color(0xff2454ff),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white,
//                 width: 4,
//               ),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 6,
//                   offset: Offset(1, 3),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget thanhTimKiem() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//       height: 44,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.96),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8,
//             offset: Offset(2, 4),
//           ),
//         ],
//       ),
//       child: const Row(
//         children: [
//           Icon(
//             Icons.search_rounded,
//             size: 22,
//             color: Colors.black54,
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'Tìm sân gần bạn',
//               style: TextStyle(
//                 fontSize: 13.5,
//                 color: Colors.black45,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Icon(
//             Icons.tune_rounded,
//             size: 20,
//             color: Color(0xff2454ff),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget nutVeViTriCuaToi() {
//     return Positioned(
//       right: 14,
//       bottom: 82,
//       child: InkWell(
//         onTap: layViTriCuaToi,
//         borderRadius: BorderRadius.circular(18),
//         child: Container(
//           width: 46,
//           height: 46,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.96),
//             shape: BoxShape.circle,
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(2, 4),
//               ),
//             ],
//           ),
//           child: dangLayViTri
//               ? const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2.2,
//                     color: Color(0xff2454ff),
//                   ),
//                 )
//               : const Icon(
//                   Icons.my_location_rounded,
//                   color: Color(0xff2454ff),
//                   size: 22,
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget hienThiDangTai() {
//     return Container(
//       color: Colors.white.withOpacity(0.85),
//       child: const Center(
//         child: CircularProgressIndicator(
//           color: Color(0xff2454ff),
//         ),
//       ),
//     );
//   }

//   Widget hienThiLoi(String text) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.95),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final xuLySan = context.watch<SanXuLy>();
//     final danhSachSan = xuLySan.danhSachSan;

//     final List<Marker> markers = [];

//     for (final san in danhSachSan) {
//       if (san.viDo != 0 && san.kinhDo != 0) {
//         final toaDo = layToaDoSan(san);

//         markers.add(
//           markerSan(
//             san: san,
//             toaDo: toaDo,
//           ),
//         );
//       }
//     }S

//     if (viTriCuaToi != null) {
//       markers.add(markerViTriCuaToi());
//     }

//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               DuongDanAnh.Nen2,
//               fit: BoxFit.cover,
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       FlutterMap(
//                         mapController: mapController,
//                         options: MapOptions(
//                           initialCenter: viTriMacDinh,
//                           initialZoom: 12.5,
//                           minZoom: 5,
//                           maxZoom: 18,
//                         ),
//                         children: [
//                           TileLayer(
//                             urlTemplate:
//                                 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                             userAgentPackageName: 'com.example.do_an',
//                           ),
//                           MarkerLayer(
//                             markers: markers,
//                           ),
//                         ],
//                       ),
//                       thanhTimKiem(),
//                       if (xuLySan.dangTai) hienThiDangTai(),
//                       if (!xuLySan.dangTai && danhSachSan.isEmpty)
//                         hienThiLoi(
//                           xuLySan.thongBaoLoi ?? 'Chưa có sân để hiển thị',
//                         ),
//                       if (!xuLySan.dangTai &&
//                           danhSachSan.isNotEmpty &&
//                           markers.isEmpty)
//                         hienThiLoi(
//                           'Danh sách sân chưa có tọa độ vi_do, kinh_do',
//                         ),
//                       nutVeViTriCuaToi(),
//                     ],
//                   ),
//                 ),
//                 const ThanhDuoi(
//                   viTriDangChon: 1,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }