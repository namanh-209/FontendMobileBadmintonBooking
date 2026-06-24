import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Chung/Duong_dan_api.dart';
import '../Server/Goi_api.dart';

class ManHinhVnpayWebView extends StatefulWidget {
  final String paymentUrl;

  const ManHinhVnpayWebView({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<ManHinhVnpayWebView> createState() => _ManHinhVnpayWebViewState();
}

class _ManHinhVnpayWebViewState extends State<ManHinhVnpayWebView> {
  late final WebViewController controller;

  bool dangTai = true;
  bool dangXacMinh = false;
  bool daCoKetQua = false;

  bool? thanhCong;
  int tienTrinh = 0;

  String thongBao = '';
  Map<String, dynamic>? duLieuKetQua;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;

            setState(() {
              tienTrinh = progress;
            });
          },
          onPageStarted: (url) {
            if (_laUrlKetQua(url)) {
              _xuLyUrlKetQua(url);
              return;
            }

            if (_laUrlKhongHoTroTrongWebView(url)) {
              _xuLyUrlKhongHoTro(url);
              return;
            }

            if (!mounted) return;

            setState(() {
              dangTai = true;
            });
          },
          onPageFinished: (url) {
            if (_laUrlKetQua(url)) {
              _xuLyUrlKetQua(url);
              return;
            }

            if (!mounted) return;

            setState(() {
              dangTai = false;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (_laUrlKetQua(url)) {
              _xuLyUrlKetQua(url);
              return NavigationDecision.prevent;
            }

            if (_laUrlKhongHoTroTrongWebView(url)) {
              _xuLyUrlKhongHoTro(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;

            setState(() {
              dangTai = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.paymentUrl),
      );
  }

  bool _laUrlKetQua(String url) {
    final value = url.toLowerCase();

    return value.contains('/thanh-toan/ket-qua') ||
        value.contains('/thanh-toan/vnpay/return') ||
        value.contains('vnp_responsecode=');
  }

  bool _laUrlKhongHoTroTrongWebView(String url) {
    final uri = Uri.tryParse(url);
    final scheme = uri?.scheme.toLowerCase();

    if (scheme == null || scheme.isEmpty) return false;

    return scheme != 'http' &&
        scheme != 'https' &&
        scheme != 'about' &&
        scheme != 'data';
  }

  String? _layFallbackUrlTuIntent(String url) {
    const key = 'S.browser_fallback_url=';
    final index = url.indexOf(key);

    if (index == -1) return null;

    var fallback = url.substring(index + key.length);
    final endIndex = fallback.indexOf(';');

    if (endIndex != -1) {
      fallback = fallback.substring(0, endIndex);
    }

    fallback = Uri.decodeComponent(fallback);

    if (fallback.startsWith('http://') || fallback.startsWith('https://')) {
      return fallback;
    }

    return null;
  }

  Future<void> _xuLyUrlKhongHoTro(String url) async {
    if (url.startsWith('intent://')) {
      final fallbackUrl = _layFallbackUrlTuIntent(url);

      if (fallbackUrl != null) {
        await controller.loadRequest(
          Uri.parse(fallbackUrl),
        );
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không mở được app thanh toán trên giả lập. Hãy chọn thanh toán bằng thẻ hoặc QR trong VNPay.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link này không hỗ trợ mở trong app'),
      ),
    );
  }

  Future<void> _xuLyUrlKetQua(String url) async {
    if (dangXacMinh || daCoKetQua) return;

    final uri = Uri.tryParse(url);

    if (uri == null) {
      if (!mounted) return;

      setState(() {
        daCoKetQua = true;
        thanhCong = false;
        thongBao = 'Link kết quả thanh toán không hợp lệ';
      });
      return;
    }

    setState(() {
      dangTai = false;
      dangXacMinh = true;
    });

    try {
      final params = Map<String, dynamic>.from(uri.queryParameters);

      final data = await GoiApi().get(
        DuongDanApi.vnpayReturn,
        query: params,
      );

      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      final ok = mapData['thanh_cong'] == true ||
          mapData['success'] == true ||
          mapData['status'] == 'success' ||
          '${mapData['vnp_ResponseCode'] ?? mapData['vnp_response_code'] ?? ''}' ==
              '00';

      if (!mounted) return;

      setState(() {
        dangXacMinh = false;
        daCoKetQua = true;
        thanhCong = ok;
        duLieuKetQua = mapData;
        thongBao =
            '${mapData['message'] ?? mapData['thong_bao'] ?? (ok ? 'Thanh toán thành công' : 'Thanh toán thất bại')}';
      });
    } catch (e) {
      if (!mounted) return;

      final responseCode = uri.queryParameters['vnp_ResponseCode'] ??
          uri.queryParameters['vnp_response_code'];

      final ok = responseCode == '00';

      setState(() {
        dangXacMinh = false;
        daCoKetQua = true;
        thanhCong = ok;
        thongBao = ok ? 'Thanh toán thành công' : 'Thanh toán thất bại';
      });
    }
  }

  Future<bool> _bamQuayLai() async {
    if (daCoKetQua || dangXacMinh) {
      Navigator.pop(context, thanhCong == true);
      return false;
    }

    final coTheLui = await controller.canGoBack();

    if (coTheLui) {
      await controller.goBack();
      return false;
    }

    Navigator.pop(context, false);
    return false;
  }

  Widget manHinhDangXacMinh() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text(
              'Đang xác minh thanh toán...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Vui lòng chờ trong giây lát',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget manHinhKetQua() {
    final ok = thanhCong == true;
    final hoaDon = duLieuKetQua?['hoa_don'];

    String maDatSan = '';

    if (hoaDon is Map) {
      maDatSan = '${hoaDon['ma_dat_san'] ?? hoaDon['dat_san_id'] ?? ''}';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ok
                      ? const Color(0xffdcfce7)
                      : const Color(0xffffe4e6),
                ),
                child: Icon(
                  ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: ok
                      ? const Color(0xff16a34a)
                      : const Color(0xffe11d48),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ok ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                thongBao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              if (maDatSan.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffeef4ff),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Mã đặt sân: $maDatSan',
                    style: const TextStyle(
                      color: Color(0xff2454ff),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, ok);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2454ff),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    ok ? 'Hoàn tất' : 'Quay lại',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (!ok) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        dangTai = true;
                        dangXacMinh = false;
                        daCoKetQua = false;
                        thanhCong = null;
                        thongBao = '';
                        duLieuKetQua = null;
                      });

                      controller.loadRequest(
                        Uri.parse(widget.paymentUrl),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff2454ff),
                      side: const BorderSide(
                        color: Color(0xff2454ff),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Thử thanh toán lại',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget noiDung() {
    if (dangXacMinh) {
      return manHinhDangXacMinh();
    }

    if (daCoKetQua) {
      return manHinhKetQua();
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: controller,
        ),
        if (dangTai || tienTrinh < 100)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: tienTrinh <= 0 ? null : tienTrinh / 100,
              minHeight: 3,
              color: const Color(0xff2454ff),
              backgroundColor: const Color(0xffdbeafe),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _bamQuayLai,
      child: Scaffold(
        backgroundColor: const Color(0xfff5f9ff),
        appBar: AppBar(
          title: const Text(
            'Thanh toán VNPay',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xfff5f9ff),
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              await _bamQuayLai();
            },
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
          ),
        ),
        body: noiDung(),
      ),
    );
  }
}