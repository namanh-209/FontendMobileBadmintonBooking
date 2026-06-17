import 'package:flutter/material.dart';

class ONhap extends StatefulWidget {
  final TextEditingController controller;
  final String goiY;
  final IconData icon;
  final bool anChu;
  final TextInputType kieuBanPhim;

  const ONhap({
    super.key,
    required this.controller,
    required this.goiY,
    required this.icon,
    this.anChu = false,
    this.kieuBanPhim = TextInputType.text,
  });

  @override
  State<ONhap> createState() => _ONhapState();
}

class _ONhapState extends State<ONhap> {
  late bool dangAnChu;

  @override
  void initState() {
    super.initState();
    dangAnChu = widget.anChu;
  }

  @override
  Widget build(BuildContext context) {
    final IconData iconBenTrai =
        widget.anChu ? Icons.lock_outline_rounded : widget.icon;

    return TextField(
      controller: widget.controller,
      obscureText: dangAnChu,
      keyboardType: widget.kieuBanPhim,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.goiY,
        hintStyle: TextStyle(
          fontSize: 12.8,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w400,
        ),

        prefixIcon: Icon(
          iconBenTrai,
          size: 19,
          color: const Color(0xff2454ff),
        ),

        prefixIconConstraints: const BoxConstraints(
          minWidth: 38,
          minHeight: 38,
        ),

        suffixIcon: widget.anChu
            ? IconButton(
                onPressed: () {
                  setState(() {
                    dangAnChu = !dangAnChu;
                  });
                },
                icon: Icon(
                  dangAnChu
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19,
                  color: Colors.grey.shade600,
                ),
              )
            : null,

        suffixIconConstraints: const BoxConstraints(
          minWidth: 38,
          minHeight: 38,
        ),

        contentPadding: const EdgeInsets.only(
          top: 12,
          bottom: 10,
        ),

        filled: false,

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),

        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff2454ff),
            width: 1.5,
          ),
        ),

        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}