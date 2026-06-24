class NguoiDung {
  final int id;
  final String hoTen;
  final String email;
  final String avatar;
  final String soDienThoai;
  final String diaChi;
  final String vaiTro;
  final String trangThai;
  final String gioiTinh;
  final String ngaySinh;

  const NguoiDung({
    this.id = 0,
    this.hoTen = '',
    this.email = '',
    this.avatar = '',
    this.soDienThoai = '',
    this.diaChi = '',
    this.vaiTro = '',
    this.trangThai = '',
    this.gioiTinh = '',
    this.ngaySinh = '',
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    final data = _layMapNguoiDung(json);

    return NguoiDung(
      id: _intTuJson(
        data['id'] ??
            data['nguoi_dung_id'] ??
            data['nguoiDungId'] ??
            data['user_id'],
      ),
      hoTen:
          '${data['ho_ten'] ?? data['hoTen'] ?? data['ten'] ?? data['name'] ?? data['full_name'] ?? data['fullName'] ?? ''}',
      email: '${data['email'] ?? data['email_nguoi_dung'] ?? ''}',
      avatar:
          '${data['avatar'] ?? data['anh_dai_dien'] ?? data['anhDaiDien'] ?? data['hinh_anh'] ?? data['hinhAnh'] ?? ''}',
      soDienThoai:
          '${data['so_dien_thoai'] ?? data['soDienThoai'] ?? data['sdt'] ?? data['dien_thoai'] ?? data['dienThoai'] ?? data['phone'] ?? data['phone_number'] ?? data['phoneNumber'] ?? data['mobile'] ?? ''}',
      diaChi:
          '${data['dia_chi'] ?? data['diaChi'] ?? data['address'] ?? ''}',
      vaiTro:
          '${data['vai_tro'] ?? data['vaiTro'] ?? data['role'] ?? ''}',
      trangThai:
          '${data['trang_thai'] ?? data['trangThai'] ?? data['status'] ?? ''}',
      gioiTinh:
          '${data['gioi_tinh'] ?? data['gioiTinh'] ?? data['gender'] ?? ''}',
      ngaySinh:
          '${data['ngay_sinh'] ?? data['ngaySinh'] ?? data['birthday'] ?? data['date_of_birth'] ?? data['dateOfBirth'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ho_ten': hoTen,
      'email': email,
      'avatar': avatar,
      'so_dien_thoai': soDienThoai,
      'dia_chi': diaChi,
      'vai_tro': vaiTro,
      'trang_thai': trangThai,
      'gioi_tinh': gioiTinh,
      'ngay_sinh': ngaySinh,
    };
  }

  NguoiDung copyWith({
    int? id,
    String? hoTen,
    String? email,
    String? avatar,
    String? soDienThoai,
    String? diaChi,
    String? vaiTro,
    String? trangThai,
    String? gioiTinh,
    String? ngaySinh,
  }) {
    return NguoiDung(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      diaChi: diaChi ?? this.diaChi,
      vaiTro: vaiTro ?? this.vaiTro,
      trangThai: trangThai ?? this.trangThai,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      ngaySinh: ngaySinh ?? this.ngaySinh,
    );
  }
}

Map<String, dynamic> _layMapNguoiDung(Map<String, dynamic> json) {
  if (json['nguoi_dung'] is Map) {
    return Map<String, dynamic>.from(json['nguoi_dung']);
  }

  if (json['nguoiDung'] is Map) {
    return Map<String, dynamic>.from(json['nguoiDung']);
  }

  if (json['user'] is Map) {
    return Map<String, dynamic>.from(json['user']);
  }

  if (json['tai_khoan'] is Map) {
    return Map<String, dynamic>.from(json['tai_khoan']);
  }

  if (json['taiKhoan'] is Map) {
    return Map<String, dynamic>.from(json['taiKhoan']);
  }

  if (json['data'] is Map) {
    final data = Map<String, dynamic>.from(json['data']);

    if (data['nguoi_dung'] is Map) {
      return Map<String, dynamic>.from(data['nguoi_dung']);
    }

    if (data['nguoiDung'] is Map) {
      return Map<String, dynamic>.from(data['nguoiDung']);
    }

    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user']);
    }

    if (data['tai_khoan'] is Map) {
      return Map<String, dynamic>.from(data['tai_khoan']);
    }

    if (data['taiKhoan'] is Map) {
      return Map<String, dynamic>.from(data['taiKhoan']);
    }

    return data;
  }

  return json;
}

int _intTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}