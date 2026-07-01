import 'package:flutter/material.dart';

import '../Chung/Duong_dan_anh.dart';

class ManHinhTroGiup extends StatefulWidget {
  const ManHinhTroGiup({super.key});

  @override
  State<ManHinhTroGiup> createState() => _ManHinhTroGiupState();
}

class _ManHinhTroGiupState extends State<ManHinhTroGiup> {
  final List<Map<String, String>> cauHoiThuongGap = [
    {
      'hoi': 'Làm sao để đặt sân?',
      'dap':
          'Bạn vào Trang chủ, chọn cơ sở sân cầu lông, chọn ngày và khung giờ còn trống, sau đó bấm Tiếp tục đặt sân để thanh toán.',
    },
    {
      'hoi': 'Tôi có thể hủy lịch đặt sân không?',
      'dap':
          'Bạn có thể hủy lịch trong mục Lịch đặt sân nếu đơn còn trong thời gian được phép hủy và chưa qua giờ chơi.',
    },
    {
      'hoi': 'Thanh toán thành công nhưng chưa thấy lịch?',
      'dap':
          'Bạn hãy kiểm tra mục Lịch sử đặt sân hoặc Lịch đặt sân. Nếu vẫn chưa thấy, vui lòng liên hệ hỗ trợ.',
    },
    {
      'hoi': 'Giữ chỗ hết hạn là gì?',
      'dap':
          'Giữ chỗ hết hạn nghĩa là bạn đã chọn sân nhưng chưa thanh toán trong thời gian quy định, nên hệ thống tự động hủy giữ chỗ.',
    },
    {
      'hoi': 'Làm sao để đánh giá sân?',
      'dap':
          'Sau khi đã đặt sân và hoàn tất lịch chơi, bạn có thể vào Lịch đặt sân hoặc Lịch sử để gửi đánh giá.',
    },
  ];

  Widget tieuDe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(1, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xff2454ff),
                ),
              ),
            ),
          ),
          const Text(
            'Trợ giúp',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget theLienHe() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff2454ff),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(1, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.support_agent_rounded,
              size: 34,
              color: Color(0xff2454ff),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cần hỗ trợ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Liên hệ đội ngũ hỗ trợ Badminton Booking',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dongLienHe({
    required IconData icon,
    required String tieuDe,
    required String noiDung,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xffe8f1ff),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xff2454ff),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieuDe,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  noiDung,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mucCauHoi(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: const CircleAvatar(
          backgroundColor: Color(0xffe8f1ff),
          child: Icon(
            Icons.help_outline_rounded,
            color: Color(0xff2454ff),
          ),
        ),
        title: Text(
          item['hoi'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14.5,
          ),
        ),
        children: [
          Text(
            item['dap'] ?? '',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget noiDung() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          theLienHe(),

          const SizedBox(height: 22),

          const Text(
            'Câu hỏi thường gặp',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          ...cauHoiThuongGap.map(mucCauHoi),

          const SizedBox(height: 18),

          const Text(
            'Liên hệ hỗ trợ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          dongLienHe(
            icon: Icons.email_rounded,
            tieuDe: 'Email',
            noiDung: 'support@badmintonbooking.vn',
          ),

          dongLienHe(
            icon: Icons.phone_rounded,
            tieuDe: 'Hotline',
            noiDung: '1900 8888',
          ),

          dongLienHe(
            icon: Icons.access_time_rounded,
            tieuDe: 'Thời gian hỗ trợ',
            noiDung: '08:00 - 22:00 mỗi ngày',
          ),

          const SizedBox(height: 18),

          const Text(
            'Thông tin ứng dụng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          dongLienHe(
            icon: Icons.info_rounded,
            tieuDe: 'Badminton Booking',
            noiDung: 'Phiên bản 1.0.0',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            bottom: false,
            child: Column(
              children: [
                tieuDe(),
                Expanded(
                  child: noiDung(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}