// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePlaceHolderAvatar extends StatelessWidget {
  final bool isDark;
  final double size;
  final String? imageUrl;
  final String seedName;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxShape shape;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final Widget? customChild;
  final bool useInitials;
  final String? userName;

  const ProfilePlaceHolderAvatar({
    super.key,
    required this.isDark,
    required this.size,
    this.imageUrl,
    this.seedName = 'User',
    this.backgroundColor,
    this.iconColor,
    this.shape = BoxShape.circle,
    this.onTap,
    this.onLongPress,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.customChild,
    this.useInitials = false,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? Colors.grey[800] : Colors.blue.shade100),
          shape: shape,
          borderRadius:
              shape == BoxShape.circle ? null : BorderRadius.circular(12.0),
          border:
              showBorder
                  ? Border.all(
                    color:
                        borderColor ??
                        (isDark ? Colors.amberAccent : Colors.blue.shade600),
                    width: borderWidth,
                  )
                  : null,
          boxShadow: [
            if (showBorder)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: customChild ?? profileImageAvatarContent(),
      ),
    );
  }

  Widget profileImageAvatarContent() {
    if (useInitials && userName != null && userName!.isNotEmpty) {
      return profileImageInitialsAvatar();
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipPath(
        clipper:
            shape == BoxShape.circle
                ? CircleClipperShape()
                : RectangleClipperShape(),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => prfoleImagePlaceholder(),
          errorWidget: (context, url, error) => profileImageFallbackAvatar(),
        ),
      );
    }

    return profileImageDiceBearAvatar();
  }

  Widget profileImageInitialsAvatar() {
    final initials = _getInitials(userName!);
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color:
              iconColor ?? (isDark ? Colors.amberAccent : Colors.blue.shade600),
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  Widget profileImageDiceBearAvatar() {
    final diceBearUrl = "https://api.dicebear.com/7.x/avataaars/svg?seed=amber";

    return ClipPath(
      clipper:
          shape == BoxShape.circle
              ? CircleClipperShape()
              : RectangleClipperShape(),
      child: CachedNetworkImage(
        imageUrl: diceBearUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => prfoleImagePlaceholder(),
        errorWidget: (context, url, error) => profileImageFallbackAvatar(),
      ),
    );
  }

  Widget prfoleImagePlaceholder() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          iconColor ?? (isDark ? Colors.amberAccent : Colors.blue.shade600),
        ),
      ),
    );
  }

  Widget profileImageFallbackAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: size * 0.4,
        color:
            iconColor ?? (isDark ? Colors.amberAccent : Colors.blue.shade600),
      ),
    );
  }
}

class CircleClipperShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RectangleClipperShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
