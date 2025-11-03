import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';

class CustomDialog {
  // Sign Out Dialog
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

  // Generic Confirmation Dialog
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

  // Success Dialog
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

  // Error Dialog
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

  // Loading Dialog
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

  // Dismiss Loading Dialog
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Custom Input Dialog
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
}

// Confirmation Dialog Widget
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
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.grey[400] : Colors.grey[800],
                    ),
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 12),

                  // Confirm Button
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

// Info Dialog Widget (Success/Error)
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
            // Icon
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            // OK Button
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

// Loading Dialog Widget
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

// Input Dialog Widget
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
            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Text Field
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

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.grey[400] : Colors.grey[800],
                  ),
                  child: Text(widget.cancelText),
                ),
                const SizedBox(width: 12),

                // Confirm Button
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

/*

Success Dialog
CustomDialog.showSuccessDialog(
  context: context,
  title: 'Success!',
  content: 'Your profile has been updated successfully.',
  onPressed: () {
    // Optional callback
  },
);

2. Generic Confirmation Dialog
CustomDialog.showConfirmationDialog(
  context: context,
  title: 'Delete Account',
  content: 'Are you sure you want to delete your account? This action cannot be undone.',
  confirmText: 'Delete',
  confirmButtonColor: Colors.red,
  isDestructive: true,
  onConfirm: () {
    // Delete account logic
  },
);

 */
