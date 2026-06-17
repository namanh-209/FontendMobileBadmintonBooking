import 'package:flutter/material.dart';

const mauChinh = Color(0xFF2D9CDB);
const mauNen = Color(0xFFF6FBFF);
const mauChu = Color(0xFF17324D);

String dinhDangTien(num tien) {
  final s = tien.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final viTriTuCuoi = s.length - i;
    b.write(s[i]);
    if (viTriTuCuoi > 1 && viTriTuCuoi % 3 == 1) b.write('.');
  }
  return '${b.toString()}đ';
}

void baoLoi(BuildContext context, Object loi) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(loi.toString().replaceFirst('Exception: ', ''))),
  );
}

void baoThanhCong(BuildContext context, String noiDung) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(noiDung), backgroundColor: Colors.green),
  );
}

Widget trangThaiRong({required IconData icon, required String tieuDe, String? moTa}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.blueGrey.shade200),
          const SizedBox(height: 14),
          Text(tieuDe, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (moTa != null) ...[
            const SizedBox(height: 8),
            Text(moTa, textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade600)),
          ],
        ],
      ),
    ),
  );
}
