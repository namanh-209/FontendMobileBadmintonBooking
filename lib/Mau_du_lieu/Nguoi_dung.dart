import '../Chung/Duong_dan_api.dart';

class NguoiDung {
  final int id;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String ngaySinh;
  final String gioiTinh;
  final String avatar;
  final String username;
  final int isAdmin;

  NguoiDung({
    this.id = 0,
    this.hoTen = '',
    this.email = '',
    this.soDienThoai = '',
    this.ngaySinh = '',
    this.gioiTinh = '',
    this.avatar = '',
    this.username = '',
    this.isAdmin = 0,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user;

    if (json['user'] is Map) {
      user = Map<String, dynamic>.from(json['user']);
    } else if (json['data'] is Map) {
      user = Map<String, dynamic>.from(json['data']);
    } else if (json['nguoiDung'] is Map) {
      user = Map<String, dynamic>.from(json['nguoiDung']);
    } else {
      user = json;
    }

    final tenDangNhap = (user['username'] ??
            user['ten_dang_nhap'] ??
            user['tai_khoan'] ??
            '')
        .toString();

    final tenHienThi = (user['hoTen'] ??
            user['ho_ten'] ??
            user['hoten'] ??
            user['name'] ??
            user['ten'] ??
            user['username'] ??
            user['ten_dang_nhap'] ??
            '')
        .toString();

    return NguoiDung(
      id: _toInt(
            user['id'] ??
                user['nguoi_dung_id'] ??
                user['user_id'] ??
                user['id_nguoi_dung'],
          ) ??
          0,
      hoTen: tenHienThi,
      username: tenDangNhap.isNotEmpty ? tenDangNhap : tenHienThi,
      email: (user['email'] ?? '').toString(),
      soDienThoai: (user['soDienThoai'] ??
              user['so_dien_thoai'] ??
              user['sdt'] ??
              user['phone'] ??
              user['dien_thoai'] ??
              '')
          .toString(),
      ngaySinh: _catNgay(
        user['ngaySinh'] ?? user['ngay_sinh'] ?? user['birthday'] ?? user['date_of_birth'],
      ),
      gioiTinh: (user['gioiTinh'] ??
              user['gioi_tinh'] ??
              user['gender'] ??
              '')
          .toString(),
      avatar: _chuanHoaAvatar(
        user['avatar'] ?? user['anh_dai_dien'] ?? user['hinh_anh'] ?? user['image'] ?? '',
      ),
      isAdmin: _toInt(user['is_admin'] ?? user['isAdmin'] ?? user['vai_tro_id'] ?? user['role'] ?? 0) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ho_ten': hoTen,
      'username': username,
      'email': email,
      'so_dien_thoai': soDienThoai,
      'ngay_sinh': ngaySinh,
      'gioi_tinh': gioiTinh,
      'avatar': avatar,
      'is_admin': isAdmin,
    };
  }

  NguoiDung copyWith({
    int? id,
    String? hoTen,
    String? email,
    String? soDienThoai,
    String? ngaySinh,
    String? gioiTinh,
    String? avatar,
    String? username,
    int? isAdmin,
  }) {
    return NguoiDung(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  static String _catNgay(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 10) return text.substring(0, 10);
    return text;
  }

  static String _chuanHoaAvatar(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '';
    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    if (text.startsWith('/uploads/') || text.startsWith('uploads/')) {
      return DuongDanApi.linkAnh(text);
    }
    return text;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
