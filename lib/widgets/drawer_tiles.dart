// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DrawerTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const DrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              widget.selected
                  ? (widget.isDarkMode
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.amber.shade100)
                  : _isHovered
                  ? (widget.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border:
              widget.selected
                  ? Border.all(
                    color:
                        widget.isDarkMode
                            ? Colors.amber
                            : Colors.amber.shade500,
                    width: 0.5,
                  )
                  : null,
          gradient:
              _isHovered && !widget.selected
                  ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors:
                        widget.isDarkMode
                            ? [
                              Colors.grey.shade800.withOpacity(0.8),
                              Colors.grey.shade800,
                            ]
                            : [Colors.grey.shade50, Colors.grey.shade100],
                  )
                  : null,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  widget.selected
                      ? (widget.isDarkMode
                          ? Colors.amber.shade600
                          : Colors.amber.shade500)
                      : _isHovered
                      ? (widget.isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade200)
                      : Colors.transparent,
              shape: BoxShape.circle,
              gradient:
                  widget.selected
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.amber, Colors.amber],
                      )
                      : null,
            ),
            child: Icon(
              widget.icon,
              color:
                  widget.selected
                      ? Colors.white
                      : (widget.isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade700),
              size: 20,
            ),
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
              color:
                  widget.selected
                      ? (widget.isDarkMode ? Colors.white : Colors.black)
                      : (widget.isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade800),
            ),
          ),
          trailing:
              widget.selected
                  ? Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color:
                        widget.isDarkMode
                            ? Colors.amber.shade400
                            : Colors.amber.shade600,
                  )
                  : null,
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
