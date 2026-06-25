class DuongDanApi {
  DuongDanApi._();

  // Host đang dùng giống web/deploy.
  // Nếu muốn chạy backend local trên Android Emulator thì đổi hostDangDung = hostAndroidEmulator.
  static const String hostOnline = 'https://badminton-booking-backend-g45o.onrender.com';
  static const String hostWebLocal = 'http://localhost:3000';
  static const String hostAndroidEmulator = 'http://10.0.2.2:3000';
  static const String hostDienThoaiThat = 'http://192.168.1.10:3000';

  static const String hostDangDung = hostOnline;

  static const String gocServer = hostDangDung;
  static const String gocApi = '$hostDangDung/api';

  // Alias để không lỗi các file cũ.
  static const String goc = gocApi;
  static const String api = gocApi;
  static const String baseUrl = gocApi;
  static const String baseUrlApi = gocApi;
  static const String duongDanApi = gocApi;
  static const String serverBaseUrl = gocServer;

  static String noiApi(String path) {
    final value = path.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('/api/')) return '$hostDangDung$value';
    if (value == '/api') return gocApi;
    if (value.startsWith('/')) return '$gocApi$value';
    return '$gocApi/$value';
  }

  static String _xoaDauNgoacNeuCo(String value) {
    var text = value.trim();

    while ((text.startsWith('\"') && text.endsWith('\"')) ||
        (text.startsWith("'") && text.endsWith("'"))) {
      text = text.substring(1, text.length - 1).trim();
    }

    return text;
  }

  static String _doiLocalhostTheoHostDangDung(String value) {
    final uri = Uri.tryParse(value);
    final hostUri = Uri.tryParse(gocServer);

    if (uri == null || hostUri == null) return value;

    final host = uri.host.toLowerCase();
    final laLocalhost = host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';

    if (!laLocalhost) return value;

    return uri
        .replace(
          scheme: hostUri.scheme,
          host: hostUri.host,
          port: hostUri.hasPort ? hostUri.port : null,
        )
        .toString();
  }

  static String noiServer(String path) {
    var value = path.trim();

    if (value.isEmpty || value.toLowerCase() == 'null') return '';

    value = _xoaDauNgoacNeuCo(value);
    value = value.replaceAll('\\', '/');

    if (value.startsWith('//')) {
      return 'https:$value';
    }

    if (value.startsWith('res.cloudinary.com/')) {
      return 'https://$value';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return _doiLocalhostTheoHostDangDung(value);
    }

    if (value.startsWith('/')) {
      return '$gocServer$value';
    }

    if (value.startsWith('uploads/') ||
        value.startsWith('upload/') ||
        value.startsWith('storage/') ||
        value.startsWith('public/')) {
      return '$gocServer/$value';
    }

    if (value.contains('/')) {
      return '$gocServer/$value';
    }

    return '$gocServer/uploads/$value';
  }

  static String anh(String? duongDanAnh) {
    final value = (duongDanAnh ?? '').trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    return noiServer(value);
  }

  static String linkAnh(String? duongDanAnh) => anh(duongDanAnh);

  static String taoQuery(Map<String, dynamic> params) {
    final query = <String, String>{};
    params.forEach((key, value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isEmpty) return;
      query[key] = text;
    });

    if (query.isEmpty) return '';
    return '?${Uri(queryParameters: query).query}';
  }

  // Auth
  static const String dangKy = '/auth/register';
  static const String dangNhap = '/auth/login';
  static const String quenMatKhau = '/auth/quen-mat-khau';
  static const String xacThucOtp = '/auth/xac-thuc-otp';
  static const String datLaiMatKhau = '/auth/dat-lai-mat-khau';

  // User
  static const String hoSo = '/user/me';
  static const String capNhatHoSo = '/user/profile';
  static const String doiMatKhau = '/user/change-password';

  // Cơ sở / sân
  static const String danhSachCoSo = '/co-so';
  static const String danhSachSan = '/san';

  static String danhSachCoSoLoc({
    String? tuKhoa,
    String? tinhThanh,
    String? phuongXa,
    String? loaiSan,
    num? giaTu,
    num? giaDen,
    String? ngay,
    String? gio,
    String? sapXep,
  }) {
    return '$danhSachCoSo${taoQuery({
      'tu_khoa': tuKhoa,
      'tinh_thanh': tinhThanh,
      'phuong_xa': phuongXa,
      'loai_san': loaiSan,
      'gia_tu': giaTu,
      'gia_den': giaDen,
      'ngay': ngay,
      'gio': gio,
      'sap_xep': sapXep,
    })}';
  }

  static String chiTietCoSo(dynamic id) => '/co-so/$id';

  static String danhSachSanTheoCoSo(dynamic coSoId) {
    return '/san?co_so_id=$coSoId';
  }

  static String chiTietSan(dynamic id) => '/san/$id';

  static String lichTheoCoSo(dynamic coSoId, {String? ngay}) {
    final query = taoQuery({
      'co_so_id': coSoId,
      'ngay': ngay,
    });
    return '/dat-san/lich$query';
  }

  static String lichSan(dynamic sanId, {String? ngay}) {
    final query = taoQuery({'ngay': ngay});
    return '/san/$sanId/lich$query';
  }

  // Giá / khuyến mãi công khai giống web
  static const String bangGiaCongKhai = '/bang-gia/cong-khai';
  static const String khuyenMaiCongKhai = '/khuyen-mai/cong-khai';

  // Đặt sân giống web
  static const String lichDatSanCongKhai = '/dat-san/lich';
  static const String giuChoDatSan = '/dat-san/giu-cho';
  static const String lichSuDatSanCuaToi = '/dat-san/lich-su-cua-toi';

  static String huyGiuCho(dynamic datSanId) => '/dat-san/$datSanId/huy-giu-cho';
  static String capNhatGhiChuDatSan(dynamic datSanId) => '/dat-san/$datSanId/ghi-chu';
  static String apDungKhuyenMai(dynamic datSanId) => '/dat-san/$datSanId/khuyen-mai';
  static String huyDatSan(dynamic datSanId) => '/huy-dat-san/$datSanId';

  // Thanh toán giống web: VNPay tạo URL
  static const String taoUrlThanhToanVnpay = '/thanh-toan/vnpay/tao-url';
  static const String vnpayReturn = '/thanh-toan/vnpay/return';

  // Yêu thích
  static const String danhSachYeuThich = '/yeu-thich';
  static String themYeuThich(dynamic coSoId) => '/yeu-thich/$coSoId';
  static String xoaYeuThich(dynamic coSoId) => '/yeu-thich/$coSoId';
  static String kiemTraYeuThich(dynamic coSoId) => '/yeu-thich/check/$coSoId';
}
