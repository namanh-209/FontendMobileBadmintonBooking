import 'package:flutter/material.dart';

class HieuUngChuyenTrang extends PageRouteBuilder {
  final Widget manHinh;

  HieuUngChuyenTrang({
    required this.manHinh,
  }) : super(
          transitionDuration: const Duration(milliseconds: 430),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return manHinh;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final animationCong = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final hieuUngTruot = Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animationCong);

            final hieuUngMo = Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animationCong);

            return FadeTransition(
              opacity: hieuUngMo,
              child: SlideTransition(
                position: hieuUngTruot,
                child: child,
              ),
            );
          },
        );
}