import 'package:flutter/material.dart';

class ThanhTimKiem extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String goiY;
  final bool chiDoc;
  final String tuKhoa;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const ThanhTimKiem({
    super.key,
    this.controller,
    this.focusNode,
    this.goiY = 'Tìm sân cầu lông',
    this.chiDoc = false,
    this.tuKhoa = '',
    this.onChanged,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3.5,
              offset: Offset(1, 1.8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Colors.black45,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: chiDoc,
                onTap: onTap,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: goiY,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 4),
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (tuKhoa.isNotEmpty && onClear != null)
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.black38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}