// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'dart:html' as html;

class CustomDialog {
  static void showSignOutDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String title = 'Sign Out',
    String content = 'Are you sure you want to sign out?',
    String confirmText = 'Sign Out',
    String cancelText = 'Cancel',
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _ConfirmationDialog(
            title: title,
            content: content,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmButtonColor: Colors.red,
            onConfirm: onConfirm,
          ),
    );
  }

  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmButtonColor = Colors.blue,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _ConfirmationDialog(
            title: title,
            content: content,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmButtonColor: confirmButtonColor,
            isDestructive: isDestructive,
            onConfirm: onConfirm,
          ),
    );
  }

  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _InfoDialog(
            title: title,
            content: content,
            buttonText: buttonText,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            onPressed: onPressed,
          ),
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _InfoDialog(
            title: title,
            content: content,
            buttonText: buttonText,
            icon: Icons.error,
            iconColor: Colors.red,
            onPressed: onPressed,
          ),
    );
  }

  static void showLoadingDialog({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LoadingDialog(message: message),
    );
  }

  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String hintText = 'Enter text',
    String confirmText = 'Save',
    String cancelText = 'Cancel',
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    return showDialog<String?>(
      context: context,
      builder:
          (context) => _InputDialog(
            title: title,
            hintText: hintText,
            confirmText: confirmText,
            cancelText: cancelText,
            controller: controller,
            keyboardType: keyboardType,
          ),
    );
  }

  static Future<String?> showProfilePictureDialog({
    required BuildContext context,
    required String currentImageUrl,
    String title = 'Update Profile Picture',
  }) async {
    return showDialog<String?>(
      context: context,
      builder:
          (context) => _ProfilePictureDialog(
            title: title,
            currentImageUrl: currentImageUrl,
          ),
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color confirmButtonColor;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const _ConfirmationDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.confirmButtonColor,
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.grey[400] : Colors.grey[800],
                    ),
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 12),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDestructive ? Colors.red : confirmButtonColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(confirmText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _InfoDialog({
    required this.title,
    required this.content,
    required this.buttonText,
    required this.icon,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),

            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  final String message;

  const _LoadingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputDialog({
    required this.title,
    required this.hintText,
    required this.confirmText,
    required this.cancelText,
    required this.controller,
    required this.keyboardType,
  });

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.amberAccent : Colors.blueAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.grey[400] : Colors.grey[800],
                  ),
                  child: Text(widget.cancelText),
                ),
                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, widget.controller.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePictureDialog extends StatefulWidget {
  final String title;
  final String currentImageUrl;

  const _ProfilePictureDialog({
    required this.title,
    required this.currentImageUrl,
  });

  @override
  State<_ProfilePictureDialog> createState() => _ProfilePictureDialogState();
}

class _ProfilePictureDialogState extends State<_ProfilePictureDialog> {
  String? _selectedImageDataUrl;
  bool isLoading = false;

  Future<void> _pickImageFromGallery() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    final Completer<String?> completer = Completer<String?>();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          if (reader.result != null) {
            completer.complete(reader.result as String);
          } else {
            completer.complete(null);
          }
        });

        reader.onError.listen((e) {
          completer.completeError('Error reading file');
        });

        reader.readAsDataUrl(file);
      } else {
        completer.complete(null);
      }
    });

    final String? imageDataUrl = await completer.future;

    if (imageDataUrl != null && mounted) {
      setState(() {
        _selectedImageDataUrl = imageDataUrl;
      });
    }
  }

  Future<void> _takePhotoWithCamera() async {
    // For web, we'll use the device camera through file input
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.setAttribute('capture', 'camera');
    input.click();

    final Completer<String?> completer = Completer<String?>();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          if (reader.result != null) {
            completer.complete(reader.result as String);
          } else {
            completer.complete(null);
          }
        });

        reader.onError.listen((e) {
          completer.completeError('Error reading file');
        });

        reader.readAsDataUrl(file);
      } else {
        completer.complete(null);
      }
    });

    final String? imageDataUrl = await completer.future;

    if (imageDataUrl != null && mounted) {
      setState(() {
        _selectedImageDataUrl = imageDataUrl;
      });
    }
  }

  String get _displayImage {
    return _selectedImageDataUrl ?? widget.currentImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Current/Selected Profile Picture
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeProvider.primaryColor,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child:
                      _displayImage.isNotEmpty
                          ? Image.network(
                            _displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderIcon(isDark);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          )
                          : _buildPlaceholderIcon(isDark),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _selectedImageDataUrl != null
                    ? 'New Profile Picture'
                    : 'Current Profile Picture',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Option Buttons
              Column(
                children: [
                  _buildOptionButton(
                    context: context,
                    icon: Icons.photo_library,
                    title: 'Choose from Gallery',
                    subtitle: 'Select image from your device',
                    onTap: _pickImageFromGallery,
                  ),
                  const SizedBox(height: 12),

                  _buildOptionButton(
                    context: context,
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Use your camera to take a photo',
                    onTap: _takePhotoWithCamera,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (_selectedImageDataUrl != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.grey[400] : Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  Navigator.of(
                                    context,
                                  ).pop(_selectedImageDataUrl);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Update Picture'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.grey[400] : Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 60,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeProvider.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
===>  Success Dialog
CustomDialog.showSuccessDialog(
  context: context,
  title: 'Success!',
  content: 'Your profile has been updated successfully.',
  onPressed: () {
  },
);

===>  Generic Confirmation Dialog
CustomDialog.showConfirmationDialog(
  context: context,
  title: 'Delete Account',
  content: 'Are you sure you want to delete your account? This action cannot be undone.',
  confirmText: 'Delete',
  confirmButtonColor: Colors.red,
  isDestructive: true,
  onConfirm: () {
  },
);

 */
