import 'dart:math' as math;

import 'package:flutter/material.dart';

class HieuUngTai extends StatefulWidget {
  final String text;
  final double kichThuocLogo;
  final double kichThuocChu;
  final IconData icon;

  const HieuUngTai({
    super.key,
    this.text = 'Đang tải...',
    this.kichThuocLogo = 58,
    this.kichThuocChu = 14,
    this.icon = Icons.sports_tennis_rounded,
  });

  @override
  State<HieuUngTai> createState() => _HieuUngTaiState();
}

class _HieuUngTaiState extends State<HieuUngTai>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.kichThuocLogo;

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = controller.value;
          final doNay = math.sin(t * math.pi);

          final diLen = -size * 0.16 * doNay;
          final xoayNhe = math.sin(t * math.pi * 2) * 0.08;

          final bongRong = size * (0.55 + (1 - doNay) * 0.18);
          final bongMo = 0.08 + (1 - doNay) * 0.12;

          return SizedBox(
            width: size * 1.4,
            height: size * 1.35,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: bongRong,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xff2454ff).withOpacity(bongMo),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: Offset(0, diLen),
                  child: Transform.rotate(
                    angle: xoayNhe,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: const Color(0xffeef4ff),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff2454ff).withOpacity(0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: size * 0.58,
                        color: const Color(0xff2454ff),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}