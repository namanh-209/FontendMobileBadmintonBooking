import 'package:flutter/material.dart';

import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li_api/Co_so_api.dart';
import 'Man_hinh_xem_lich_dat_san.dart';

class ManHinhChiTietSan extends StatefulWidget {
  final CoSo? coSo;
  final CoSo? coSoHienTai;

  const ManHinhChiTietSan({
    super.key,
    this.coSo,
    this.coSoHienTai,
  });

  @override
  State<ManHinhChiTietSan> createState() => _ManHinhChiTietSanState();
}

class _ManHinhChiTietSanState extends State<ManHinhChiTietSan> {
  late CoSo coSoHienTai;

  @override
  void initState() {
    super.initState();

    coSoHienTai = widget.coSoHienTai ??
        widget.coSo ??
        CoSo(
          id: 0,
          ten: 'Sân cầu lông',
          diaChi: 'Chưa cập nhật địa chỉ',
          moTa: 'Sân cầu lông sạch sẽ, thoáng mát, phù hợp để đặt lịch tập luyện và thi đấu.',
          hinhAnh: '',
          danhGia: 0,
        );

    Future.microtask(taiChiTietCoSo);
  }

  Future<void> taiChiTietCoSo() async {
    if (coSoHienTai.id <= 0) return;

    try {
      final chiTiet = await CoSoApi().layChiTietCoSo(coSoHienTai.id);

      if (!mounted) return;

      setState(() {
        coSoHienTai = chiTiet;
      });
    } catch (_) {
      // Giữ dữ liệu cũ nếu API chi tiết chưa sẵn sàng.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFF),
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF1D3557),
        title: const Text(
          'Chi tiết sân',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _anhSan(),
            const SizedBox(height: 18),
            _thongTinChinh(),
            const SizedBox(height: 16),
            _theThongTinNhanh(),
            const SizedBox(height: 18),
            _tieuDe('Mô tả'),
            const SizedBox(height: 8),
            Text(
              coSoHienTai.moTa.isNotEmpty
                  ? coSoHienTai.moTa
                  : 'Sân cầu lông sạch sẽ, thoáng mát, phù hợp để đặt lịch tập luyện và thi đấu.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF425466),
              ),
            ),
            const SizedBox(height: 18),
            _tieuDe('Tiện ích'),
            const SizedBox(height: 10),
            _tienIch(),
            const SizedBox(height: 24),
            _nutDatSan(),
          ],
        ),
      ),
    );
  }

  Widget _anhSan() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 190,
            child: coSoHienTai.hinhAnh.isNotEmpty
                ? Image.network(
                    coSoHienTai.hinhAnh,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _anhMacDinh();
                    },
                  )
                : _anhMacDinh(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Color(0xFF3BA9E4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _anhMacDinh() {
    return Container(
      width: double.infinity,
      height: 190,
      color: const Color(0xFFEAF6FF),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 54,
            color: Color(0xFF4DA3D9),
          ),
          SizedBox(height: 8),
          Text(
            'Chưa có hình ảnh',
            style: TextStyle(
              color: Color(0xFF4DA3D9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _thongTinChinh() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coSoHienTai.ten,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Color(0xFF3BA9E4),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  coSoHienTai.diaChi.isNotEmpty
                      ? coSoHienTai.diaChi
                      : 'Chưa cập nhật địa chỉ',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF425466),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC107),
                size: 22,
              ),
              const SizedBox(width: 5),
              Text(
                coSoHienTai.danhGia > 0
                    ? coSoHienTai.danhGia.toStringAsFixed(1)
                    : 'Chưa có đánh giá',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _theThongTinNhanh() {
    return Row(
      children: [
        Expanded(
          child: _oThongTinNhanh(
            icon: Icons.access_time,
            title: 'Giờ mở cửa',
            value: '06:00 - 22:00',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _oThongTinNhanh(
            icon: Icons.attach_money,
            title: 'Giá sân',
            value: 'Từ 50k',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _oThongTinNhanh(
            icon: Icons.sports_tennis,
            title: 'Loại sân',
            value: 'Cầu lông',
          ),
        ),
      ],
    );
  }

  Widget _oThongTinNhanh({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE1F0FA),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3BA9E4),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1D3557),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tieuDe(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1D3557),
      ),
    );
  }

  Widget _tienIch() {
    final items = [
      {
        'icon': Icons.local_parking_outlined,
        'text': 'Bãi xe',
      },
      {
        'icon': Icons.wifi,
        'text': 'Wifi',
      },
      {
        'icon': Icons.local_drink_outlined,
        'text': 'Nước uống',
      },
      {
        'icon': Icons.wc_outlined,
        'text': 'Nhà vệ sinh',
      },
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 18,
                color: const Color(0xFF3BA9E4),
              ),
              const SizedBox(width: 6),
              Text(
                item['text'].toString(),
                style: const TextStyle(
                  color: Color(0xFF1D3557),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _nutDatSan() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManHinhXemLichSan(
                coSo: coSoHienTai,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3BA9E4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Đặt sân ngay',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}