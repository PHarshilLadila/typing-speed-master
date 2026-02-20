// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/providers/router_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:typing_speed_master/widgets/custom_textformfield.dart';

class ProfileLoginWidget extends StatefulWidget {
  const ProfileLoginWidget({super.key});

  @override
  State<ProfileLoginWidget> createState() => _ProfileLoginWidgetState();
}

class _ProfileLoginWidgetState extends State<ProfileLoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signInWithEmailOrUsername(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString().replaceAll('AuthException: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    // final isTablet = MediaQuery.of(context).size.width < 1000;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          // isMobile
          //     ? 400
          //     : isTablet
          //     ? 500
          //     : double.infinity,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 32,
            vertical: isMobile ? 24 : 32,
          ),
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkTheme ? Colors.white12 : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkTheme ? 0.4 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                _buildHeader(isMobile, isDarkTheme, themeProvider),
                const SizedBox(height: 42),

                // Email Field
                _buildEmailField(isMobile, isDarkTheme, themeProvider),
                const SizedBox(height: 20),

                // Password Field
                _buildPasswordField(isMobile, isDarkTheme, themeProvider),
                const SizedBox(height: 8),

                // Forgot Password
                _buildForgotPassword(isMobile, isDarkTheme, themeProvider),
                const SizedBox(height: 32),

                // Login Button
                _buildLoginButton(isMobile, isDarkTheme, themeProvider),
                const SizedBox(height: 32),

                // Divider
                _buildDivider(isDarkTheme),
                const SizedBox(height: 32),

                // Sign Up Section
                Center(
                  child: _buildSignUpSection(
                    isMobile,
                    isDarkTheme,
                    themeProvider,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 32,
                    fontWeight: FontWeight.w800,
                    color: isDarkTheme ? Colors.white : Colors.grey[900],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login to continue improving your typing skills",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            // Spacer(),

            // Row(
            //   children: [
            //     Image.asset(
            //       "assets/images/dark/l_dark.png",
            //       color: Colors.white,
            //     ),
            //     Image.asset(
            //       "assets/images/dark/o_dark.png",
            //       color: Colors.white,
            //     ),
            //     Image.asset(
            //       "assets/images/dark/g_dark.png",
            //       color: Colors.white,
            //     ),
            //     Image.asset(
            //       "assets/images/dark/i_dark.png",
            //       color: Colors.white,
            //     ),
            //     Image.asset(
            //       "assets/images/dark/n_dark.png",
            //       color: Colors.white,
            //     ),
            //   ],
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: _emailController,
          labelText: 'Username or Email',
          hintText: 'Enter your username or email',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your username or email';
            }
            return null;
          },
        ),
        // TextFormField(
        //   controller: _emailController,
        //   keyboardType: TextInputType.emailAddress,
        //   style: TextStyle(
        //     fontSize: isMobile ? 16 : 17,
        //     color: isDarkTheme ? Colors.white : Colors.grey[900],
        //   ),
        //   decoration: InputDecoration(
        //     hintText: 'Enter your username or email',
        //     hintStyle: TextStyle(
        //       color: isDarkTheme ? Colors.grey[500] : Colors.grey[500],
        //     ),
        //     prefixIcon: Icon(
        //       Icons.person_outline_rounded,
        //       color: themeProvider.primaryColor,
        //     ),
        //     filled: true,
        //     fillColor: isDarkTheme ? Colors.grey[850] : Colors.grey[50],
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide.none,
        //     ),
        //     enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide(
        //         width: 0.5,
        //         color:
        //             isDarkTheme
        //                 ? Colors.grey[800] ?? Colors.grey.withOpacity(0.8)
        //                 : Colors.grey[300] ?? Colors.grey.withOpacity(0.3),
        //       ),
        //     ),
        //     focusedBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide(
        //         color: themeProvider.primaryColor,
        //         width: 0.5,
        //       ),
        //     ),
        //     contentPadding: EdgeInsets.symmetric(
        //       horizontal: 16,
        //       vertical: isMobile ? 14 : 16,
        //     ),
        //   ),
        //   validator: (value) {
        //     if (value == null || value.isEmpty) {
        //       return 'Please enter your username or email';
        //     }
        //     return null;
        //   },
        // ),
      ],
    );
  }

  Widget _buildPasswordField(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: _passwordController,
          labelText: "Password",
          hintText: "Enter your password",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: isDarkTheme ? Colors.grey[500] : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        // TextFormField(
        //   controller: _passwordController,
        //   obscureText: !_isPasswordVisible,
        //   style: TextStyle(
        //     fontSize: isMobile ? 16 : 17,
        //     color: isDarkTheme ? Colors.white : Colors.grey[900],
        //   ),
        //   decoration: InputDecoration(
        //     hintText: 'Enter your password',
        //     hintStyle: TextStyle(
        //       color: isDarkTheme ? Colors.grey[500] : Colors.grey[500],
        //     ),
        //     prefixIcon: Icon(
        //       Icons.lock_rounded,
        //       color: themeProvider.primaryColor,
        //     ),
        //     suffixIcon: IconButton(
        //       icon: Icon(
        //         _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        //         color: isDarkTheme ? Colors.grey[500] : Colors.grey[600],
        //       ),
        //       onPressed: () {
        //         setState(() {
        //           _isPasswordVisible = !_isPasswordVisible;
        //         });
        //       },
        //     ),
        //     filled: true,
        //     fillColor: isDarkTheme ? Colors.grey[850] : Colors.grey[50],
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide.none,
        //     ),
        //     enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide(
        //         width: 0.5,

        //         color:
        //             isDarkTheme
        //                 ? Colors.grey[800] ?? Colors.grey.withOpacity(0.8)
        //                 : Colors.grey[300] ?? Colors.grey.withOpacity(0.3),
        //       ),
        //     ),
        //     focusedBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide(
        //         color: themeProvider.primaryColor,
        //         width: 0.5,
        //       ),
        //     ),
        //     contentPadding: EdgeInsets.symmetric(
        //       horizontal: 16,
        //       vertical: isMobile ? 14 : 16,
        //     ),
        //   ),
        //   validator: (value) {
        //     if (value == null || value.isEmpty) {
        //       return 'Please enter your password';
        //     }
        //     if (value.length < 6) {
        //       return 'Password must be at least 6 characters';
        //     }
        //     return null;
        //   },
        // ),
      ],
    );
  }

  Widget _buildForgotPassword(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _showForgotPasswordDialog(isMobile, isDarkTheme);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? Colors.white : Colors.black,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isMobile ? 16 : 18,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: themeProvider.primaryColor.withOpacity(0.5),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: isMobile ? 20 : 24,
                  width: isMobile ? 20 : 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color:
                        themeProvider.primaryColor == Colors.amber ||
                                themeProvider.primaryColor == Colors.lime ||
                                themeProvider.primaryColor == Colors.brown
                            ? Colors.black
                            : Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkTheme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDarkTheme ? Colors.grey[800] : Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDarkTheme ? Colors.grey[800] : Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpSection(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Provider.of<RouterProvider>(
              context,
              listen: false,
            ).setAuthViewMode('register');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: themeProvider.primaryColor,
            side: BorderSide(color: themeProvider.primaryColor, width: 0.5),
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: isMobile ? 14 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Create New Account',
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showForgotPasswordDialog(bool isMobile, bool isDarkTheme) {
    final emailController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          backgroundColor: isDarkTheme ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Reset Password',
            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email address to receive a password reset link.',
                style: TextStyle(
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(
                    color: isDarkTheme ? Colors.grey[600] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDarkTheme ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  Fluttertoast.showToast(msg: 'Please enter your email');
                  return;
                }
                try {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).resetPassword(email);
                  if (context.mounted) Navigator.pop(context);
                  Fluttertoast.showToast(msg: 'Password reset email sent');
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: e.toString().replaceAll('AuthException: ', ''),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Send Link'),
            ),
          ],
        );
      },
    );
  }
}
