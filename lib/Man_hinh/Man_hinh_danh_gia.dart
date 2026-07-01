import 'package:flutter/material.dart';

import '../Mau_du_lieu/Danh_gia.dart';
import '../Xu_li_api/Danh_gia_api.dart';

class ManHinhDanhGiaSan extends StatefulWidget {
  final int coSoId;
  final String tenCoSo;

  const ManHinhDanhGiaSan({
    super.key,
    required this.coSoId,
    required this.tenCoSo,
  });

  @override
  State<ManHinhDanhGiaSan> createState() => _ManHinhDanhGiaSanState();
}

class _ManHinhDanhGiaSanState extends State<ManHinhDanhGiaSan> {
  final TextEditingController noiDungController = TextEditingController();

  int soSao = 5;
  bool dangGui = false;
  late Future<List<DanhGia>> futureDanhGia;

  @override
  void initState() {
    super.initState();
    futureDanhGia = DanhGiaApi.layDanhSachDanhGia(widget.coSoId);
  }

  @override
  void dispose() {
    noiDungController.dispose();
    super.dispose();
  }

  void taiLaiDanhGia() {
    setState(() {
      futureDanhGia = DanhGiaApi.layDanhSachDanhGia(widget.coSoId);
    });
  }

  Future<void> guiDanhGia() async {
    final noiDung = noiDungController.text.trim();

    if (noiDung.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
      );
      return;
    }

    try {
      setState(() {
        dangGui = true;
      });

      await DanhGiaApi.guiDanhGia(
        coSoId: widget.coSoId,
        soSao: soSao,
        noiDung: noiDung,
      );

      noiDungController.clear();
      soSao = 5;
      taiLaiDanhGia();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thành công')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          dangGui = false;
        });
      }
    }
  }

  Widget buildChonSao() {
    return Row(
      children: List.generate(5, (index) {
        final sao = index + 1;

        return IconButton(
          onPressed: () {
            setState(() {
              soSao = sao;
            });
          },
          icon: Icon(
            sao <= soSao ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget buildItemDanhGia(DanhGia dg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dg.tenNguoiDung,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < dg.soSao
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            dg.noiDung,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            dg.ngayTao,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDanhSachDanhGia() {
    return FutureBuilder<List<DanhGia>>(
      future: futureDanhGia,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Không tải được đánh giá: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final danhSach = snapshot.data ?? [];

        if (danhSach.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Chưa có đánh giá nào.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: danhSach.map(buildItemDanhGia).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef6ff),
      appBar: AppBar(
        title: const Text('Đánh giá sân'),
        backgroundColor: const Color(0xff2454ff),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tenCoSo,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(1, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn đánh giá sân này thế nào?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  buildChonSao(),

                  const SizedBox(height: 10),

                  TextField(
                    controller: noiDungController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung đánh giá...',
                      filled: true,
                      fillColor: const Color(0xfff8fafc),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: dangGui ? null : guiDanhGia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2454ff),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: dangGui
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Gửi đánh giá',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Danh sách đánh giá',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            buildDanhSachDanhGia(),
          ],
        ),
      ),
    );
  }
}