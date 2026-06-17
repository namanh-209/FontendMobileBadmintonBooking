class LichKhungGio {
  final int khungGioMauId;
  final String gioBatDau;
  final String gioKetThuc;
  final int loaiGioId;
  final double gia;
  final bool conTrong;
  final String trangThaiSlot;

  LichKhungGio({
    required this.khungGioMauId,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.loaiGioId,
    required this.gia,
    required this.conTrong,
    required this.trangThaiSlot,
  });

  factory LichKhungGio.fromJson(Map<String, dynamic> json) {
    final trangThai = (json['trang_thai_slot'] ?? json['trang_thai'] ?? json['status'] ?? '').toString();
    final giaValue = json['gia'];

    return LichKhungGio(
      khungGioMauId: int.tryParse((json['khung_gio_mau_id'] ?? json['id'] ?? 0).toString()) ?? 0,
      gioBatDau: _catGio(json['gio_bat_dau'] ?? json['gioBatDau']),
      gioKetThuc: _catGio(json['gio_ket_thuc'] ?? json['gioKetThuc']),
      loaiGioId: int.tryParse((json['loai_gio_id'] ?? json['loaiGioId'] ?? 0).toString()) ?? 0,
      gia: double.tryParse((giaValue ?? 0).toString()) ?? 0,
      conTrong: _laConTrong(json['con_trong'], trangThai, giaValue),
      trangThaiSlot: trangThai,
    );
  }

  static String _catGio(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 5) return text.substring(0, 5);
    return text;
  }

  static bool _laConTrong(dynamic conTrongValue, String trangThai, dynamic giaValue) {
    final text = conTrongValue?.toString().toLowerCase() ?? '';

    if (text == '1' || text == 'true') return true;
    if (text == '0' || text == 'false') return false;

    if (trangThai.isEmpty) return true;

    return trangThai == 'trong' && giaValue != null;
  }
}

class LichSanCon {
  final int sanId;
  final String tenSan;
  final List<LichKhungGio> lich;

  LichSanCon({
    required this.sanId,
    required this.tenSan,
    required this.lich,
  });

  factory LichSanCon.fromJson(Map<String, dynamic> json) {
    final lichJson = json['lich'] ?? json['slots'] ?? json['khung_gio'];

    List<LichKhungGio> danhSachLich = [];

    if (lichJson is List) {
      danhSachLich = lichJson
          .whereType<Map>()
          .map((e) => LichKhungGio.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return LichSanCon(
      sanId: int.tryParse((json['san_id'] ?? json['id'] ?? 0).toString()) ?? 0,
      tenSan: (json['ten_san'] ?? json['ten'] ?? json['name'] ?? '').toString(),
      lich: danhSachLich,
    );
  }
}
