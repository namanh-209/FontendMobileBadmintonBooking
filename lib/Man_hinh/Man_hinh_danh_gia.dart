import 'package:flutter/material.dart';

import '../Mau_du_lieu/Danh_gia.dart';
import '../Xu_li_api/Danh_gia_api.dart';

class ManHinhDanhGiaSan extends StatefulWidget {
  final int coSoId;
  final String tenCoSo;
  final int? datSanId;

  const ManHinhDanhGiaSan({
    super.key,
    required this.coSoId,
    required this.tenCoSo,
    this.datSanId,
  });

  @override
  State<ManHinhDanhGiaSan> createState() => _ManHinhDanhGiaSanState();
}

class _ManHinhDanhGiaSanState extends State<ManHinhDanhGiaSan> {
  final TextEditingController noiDungController = TextEditingController();

  int soSao = 5;
  bool dangGui = false;
  late Future<List<DanhGia>> futureDanhGia;

  bool get duocPhepDanhGia => widget.datSanId != null && widget.datSanId! > 0;

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

    if (!duocPhepDanhGia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chỉ có thể đánh giá sau khi đã đặt sân'),
        ),
      );
      return;
    }

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

      await DanhGiaApi.guiDanhGiaSauDatSan(
        datSanId: widget.datSanId!,
        coSoId: widget.coSoId,
        soSao: soSao,
        noiDung: noiDung,
      );

      noiDungController.clear();

      setState(() {
        soSao = 5;
      });

      taiLaiDanhGia();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thành công')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
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
          onPressed: dangGui
              ? null
              : () {
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

  Widget buildFormDanhGia() {
    if (!duocPhepDanhGia) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xfffff7ed),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Bạn chỉ có thể viết đánh giá sau khi đã đặt sân.',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
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
          Text(
            'Đánh giá cho mã đặt sân #${widget.datSanId}',
            style: const TextStyle(
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
            enabled: !dangGui,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/nen2.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Đánh giá sân',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(1, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xffe8f1ff),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.sports_tennis_rounded,
                                  color: Color(0xff2454ff),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.tenCoSo,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      duocPhepDanhGia
                                          ? 'Mã đặt sân #${widget.datSanId}'
                                          : 'Xem đánh giá từ người dùng',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        buildFormDanhGia(),

                        const SizedBox(height: 20),

                        const Text(
                          'Danh sách đánh giá',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 12),

                        buildDanhSachDanhGia(),
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