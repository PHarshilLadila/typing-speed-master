// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/profile/widget/profile_placeholder_avatar.dart';
import 'package:typing_speed_master/models/user_model.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_textformfield.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/providers/router_provider.dart';

class ProfileRegisterWidget extends StatefulWidget {
  const ProfileRegisterWidget({super.key});

  @override
  State<ProfileRegisterWidget> createState() => _ProfileRegisterWidgetState();
}

class _ProfileRegisterWidgetState extends State<ProfileRegisterWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedCountryCode = '+91';
  bool _termsAccepted = false;
  bool _newsletterSubscription = true;

  String? profileImageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _countryCodes = ['+91', '+44', '+1', '+61', '+86', '+81'];
  final Map<String, int> _countryMaxLengths = {
    '+91': 10, // India
    '+44': 10, // UK (commonly 10 without leading 0)
    '+1': 10, // USA/Canada
    '+61': 9, // Australia (without leading 0)
    '+86': 11, // China
    '+81': 10, // Japan
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      // Show options dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Image Source'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
      );

      if (source == null) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Validate image format
      final String fileName = pickedFile.name.toLowerCase();
      final List<String> supportedFormats = ['.jpg', '.jpeg', '.png', '.webp'];
      final bool isSupported = supportedFormats.any(
        (format) => fileName.endsWith(format),
      );

      if (!isSupported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please use supported image formats: JPEG, PNG, or WebP',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Read the image bytes
        final bytes = await pickedFile.readAsBytes();

        // During registration, user is not authenticated yet
        // So we store as base64 data URL instead of uploading to Storage
        // The image will be saved in user metadata and profile table
        final base64Image = base64Encode(bytes);
        final mimeType = pickedFile.name.endsWith('.png') ? 'png' : 'jpeg';

        setState(() {
          profileImageUrl = 'data:image/$mimeType;base64,$base64Image';
          _isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture selected successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        debugPrint('Error processing image: $e');
        setState(() => _isLoading = false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          username: _usernameController.text.trim(),
          mobile: '$_selectedCountryCode ${_mobileController.text.trim()}',
          bio: _bioController.text.trim(),
          avatarUrl: profileImageUrl,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful!'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('AuthException: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Must contain special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
    final user = Provider.of<UserModel?>(context);

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            //  isMobile ? 500 : 600
          ),
          child: Container(
            width: double.infinity,
            // margin: EdgeInsets.all(isMobile ? 16 : 24),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 32,
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
                  // Header
                  _buildHeader(isMobile, isDarkTheme),
                  const SizedBox(height: 42),

                  // Profile Image Upload
                  _buildProfileImageUpload(
                    isMobile,
                    isDarkTheme,
                    isTablet,
                    user,
                    themeProvider,
                  ),
                  const SizedBox(height: 32),

                  // Two column layout for desktop/tablet
                  if (isMobile)
                    _buildMobileForm(themeProvider, isDarkTheme, isMobile)
                  else
                    _buildDesktopForm(themeProvider, isDarkTheme, isMobile),

                  const SizedBox(height: 32),

                  // Bio
                  CommonTextField(
                    controller: _bioController,
                    labelText: 'Bio (Optional)',
                    hintText: 'Tell us about yourself...',
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    // prefixIcon: Icon(
                    //   Icons.description_rounded,
                    //   color: themeProvider.primaryColor,
                    // ),
                  ),
                  const SizedBox(height: 24),

                  // Terms and Newsletter
                  _buildTermsAndNewsletter(isDarkTheme, themeProvider),
                  const SizedBox(height: 32),

                  // Register Button
                  _buildRegisterButton(isMobile, isDarkTheme, themeProvider),
                  const SizedBox(height: 24),

                  // Login Link
                  _buildLoginLink(isMobile, isDarkTheme, themeProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profileAvatar(
    UserModel? user,
    bool isDark,
    double size,
    void Function()? onTap,
  ) {
    final currentImageUrl = profileImageUrl ?? user?.avatarUrl;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipOval(
              child:
                  currentImageUrl != null && currentImageUrl.isNotEmpty
                      ? showProfileImage(
                        currentImageUrl,
                        isDark,
                        size,
                        themeProvider,
                      )
                      : ProfilePlaceHolderAvatar(
                        isDark: isDark,
                        size: size * 0.8,
                      ),
            ),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey[900]! : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.edit, color: Colors.white, size: size * 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isDarkTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 32,
                    fontWeight: FontWeight.w800,
                    color: isDarkTheme ? Colors.white : Colors.grey[900],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join our typing community and improve your skills",
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
            //       "assets/images/light/r_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/e_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/g_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/i_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/s_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/t_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/e_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     Image.asset(
            //       "assets/images/light/r_light.png",
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //   ],
            // ),
          ],
        ),
      ],
    );
  }

  Widget showProfileImage(
    String imageUrl,
    bool isDark,
    double size,
    ThemeProvider themeProvider,
  ) {
    if (imageUrl.startsWith('data:image')) {
      return profileDataUrlImage(imageUrl, isDark, size);
    } else {
      return profileNetworkImage(imageUrl, isDark, size, themeProvider);
    }
  }

  Widget profileDataUrlImage(String dataUrl, bool isDark, double size) {
    return Image.network(
      dataUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        final double progress =
            loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : 0.0;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ],
                  ),
                ),
              ),

              Center(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : Colors.grey[600]!,
                  ),
                  backgroundColor: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),

              if (size > 80)
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: size * 0.1,
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return profileErrorState(isDark, size, error.toString());
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child,
        );
      },
    );
  }

  Widget profileNetworkImage(
    String imageUrl,
    bool isDark,
    double size,
    ThemeProvider themeProvider,
  ) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      placeholder: (context, url) => profileLoadingState(isDark, size),
      errorWidget:
          (context, url, error) =>
              profileErrorState(isDark, size, error.toString()),
      imageBuilder: (context, imageProvider) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
              ),
            ),
          ),
        );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeInOut,
      fadeOutDuration: const Duration(milliseconds: 200),
      fadeOutCurve: Curves.easeOut,
    );
  }

  Widget profileLoadingState(bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ],
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 0.8),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Icon(
                    Icons.person,
                    size: size * 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget profileErrorState(bool isDark, double size, String error) {
    return CachedNetworkImage(
      imageUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=male",
      fit: BoxFit.cover,
      width: size,
      height: size,
      placeholder: (context, url) => profileLoadingState(isDark, size),
      imageBuilder: (context, imageProvider) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
              ),
            ),
          ),
        );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeInOut,
      fadeOutDuration: const Duration(milliseconds: 200),
      fadeOutCurve: Curves.easeOut,
    );
  }

  Widget _buildProfileImageUpload(
    bool isMobile,
    bool isDarkTheme,
    bool isTablet,
    UserModel? user,
    ThemeProvider themeProvider,
  ) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // Show the profile avatar with selected image
              profileAvatar(
                user,
                isDarkTheme,
                isTablet ? 100.0 : 120.0,
                _pickProfileImage,
              ),

              // Camera icon button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isDarkTheme
                                ? Colors.grey[900] ??
                                    Colors.grey.withOpacity(0.9)
                                : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Upload Profile Picture',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileForm(
    ThemeProvider themeProvider,
    bool isDarkTheme,
    bool isMobile,
  ) {
    return Column(
      children: [
        // Full Name
        CommonTextField(
          controller: _fullNameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          isRequired: true,
          prefixIcon: Icon(
            Icons.person_rounded,
            color: themeProvider.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Full name is required';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Email
        CommonTextField(
          controller: _emailController,
          labelText: 'Email Address',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          prefixIcon: Icon(
            Icons.email_rounded,
            color: themeProvider.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Username
        CommonTextField(
          controller: _usernameController,
          labelText: 'Username',
          hintText: 'Choose a username',
          isRequired: true,
          prefixIcon: Icon(
            Icons.alternate_email_rounded,
            color: themeProvider.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Only letters, numbers and underscore allowed';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Mobile with Country Code
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Mobile Number',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: isDarkTheme ? Colors.white : Colors.grey[800],
                ),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Country Code Dropdown
                Container(
                  height: isMobile ? 50 : 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[850] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 0.5,
                      color:
                          isDarkTheme
                              ? Colors.grey[800] ?? Colors.grey.withOpacity(0.8)
                              : Colors.grey[300] ??
                                  Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color:
                            isDarkTheme ? Colors.grey[500] : Colors.grey[600],
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 17,
                        color: isDarkTheme ? Colors.white : Colors.grey[900],
                      ),
                      dropdownColor:
                          isDarkTheme ? Colors.grey[900] : Colors.white,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value!;
                          _mobileController
                              .clear(); // optional: clear when country changes
                        });
                      },
                      items:
                          _countryCodes.map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Mobile Number Field
                Flexible(
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 17,
                      color: isDarkTheme ? Colors.white : Colors.grey[900],
                    ),
                    maxLength: _countryMaxLengths[_selectedCountryCode] ?? 10,
                    maxLines: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Allows only digits (0-9)
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      hintStyle: TextStyle(
                        color:
                            isDarkTheme ? Colors.grey[500] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.phone_rounded,
                        color: themeProvider.primaryColor,
                      ),
                      filled: true,
                      fillColor:
                          isDarkTheme ? Colors.grey[850] : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          width: 0.5,
                          color:
                              isDarkTheme
                                  ? Colors.grey[800] ??
                                      Colors.grey.withOpacity(0.8)
                                  : Colors.grey[300] ??
                                      Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: themeProvider.primaryColor,
                          width: 0.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isMobile ? 14 : 16,
                      ),
                    ),
                    validator: (value) {
                      final maxLength =
                          _countryMaxLengths[_selectedCountryCode] ?? 10;

                      if (value == null || value.isEmpty) {
                        return 'Mobile number is required';
                      }

                      if (value.length != maxLength) {
                        return 'Enter valid $maxLength-digit number';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Password
        CommonTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'Create a strong password',
          obscureText: !_isPasswordVisible,
          isRequired: true,
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: themeProvider.primaryColor,
          ),
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
          validator: _validatePassword,
        ),
        const SizedBox(height: 20),

        // Confirm Password
        CommonTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          obscureText: !_isConfirmPasswordVisible,
          isRequired: true,
          prefixIcon: Icon(
            Icons.lock_reset_rounded,
            color: themeProvider.primaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: isDarkTheme ? Colors.grey[500] : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: _validateConfirmPassword,
        ),
      ],
    );
  }

  Widget _buildDesktopForm(
    ThemeProvider themeProvider,
    bool isDarkTheme,
    bool isMobile,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  // Full Name
                  CommonTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    isRequired: true,
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: themeProvider.primaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Full name is required';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Email
                  CommonTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    prefixIcon: Icon(
                      Icons.email_rounded,
                      color: themeProvider.primaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Username
                  CommonTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    hintText: 'Choose a username',
                    isRequired: true,
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      color: themeProvider.primaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'Only letters, numbers and underscore allowed';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  // Mobile Number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Mobile Number',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkTheme ? Colors.white : Colors.grey[800],
                          ),
                          children: const [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Country Code Dropdown
                          Container(
                            height: isMobile ? 50 : 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color:
                                  isDarkTheme
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 0.5,
                                color:
                                    isDarkTheme
                                        ? Colors.grey[800] ??
                                            Colors.grey.withOpacity(0.8)
                                        : Colors.grey[300] ??
                                            Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCountryCode,
                                icon: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color:
                                      isDarkTheme
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                ),
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 17,
                                  color:
                                      isDarkTheme
                                          ? Colors.white
                                          : Colors.grey[900],
                                ),
                                dropdownColor:
                                    isDarkTheme
                                        ? Colors.grey[900]
                                        : Colors.white,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountryCode = value!;
                                    _mobileController.clear();
                                  });
                                },
                                items:
                                    _countryCodes.map((code) {
                                      return DropdownMenuItem(
                                        value: code,
                                        child: Text(code),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 17,
                                color:
                                    isDarkTheme
                                        ? Colors.white
                                        : Colors.grey[900],
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your mobile number',
                                hintStyle: TextStyle(
                                  color:
                                      isDarkTheme
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                ),
                                prefixIcon: Icon(
                                  Icons.phone_rounded,
                                  color: themeProvider.primaryColor,
                                ),
                                filled: true,
                                fillColor:
                                    isDarkTheme
                                        ? Colors.grey[850]
                                        : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 0.5,
                                    color:
                                        isDarkTheme
                                            ? Colors.grey[800] ??
                                                Colors.grey.withOpacity(0.8)
                                            : Colors.grey[300] ??
                                                Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: themeProvider.primaryColor,
                                    width: 0.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isMobile ? 14 : 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mobile number is required';
                                }
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                  return 'Enter valid 10-digit number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Password
                  CommonTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Create a strong password',
                    obscureText: !_isPasswordVisible,
                    isRequired: true,
                    prefixIcon: Icon(
                      Icons.lock_rounded,
                      color: themeProvider.primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            isDarkTheme ? Colors.grey[500] : Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 32),

                  // Confirm Password
                  CommonTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    obscureText: !_isConfirmPasswordVisible,
                    isRequired: true,
                    prefixIcon: Icon(
                      Icons.lock_reset_rounded,
                      color: themeProvider.primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            isDarkTheme ? Colors.grey[500] : Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: _validateConfirmPassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsAndNewsletter(
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Terms and Conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _termsAccepted,
              onChanged: (value) {
                setState(() {
                  _termsAccepted = value ?? false;
                });
              },
              activeColor: themeProvider.primaryColor,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(
                        color: themeProvider.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: themeProvider.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Newsletter Subscription
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _newsletterSubscription,
              onChanged: (value) {
                setState(() {
                  _newsletterSubscription = value ?? false;
                });
              },
              activeColor: themeProvider.primaryColor,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text(
                'Subscribe to newsletter for typing tips and updates',
                style: TextStyle(
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
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
            _isLoading
                ? SizedBox(
                  height: isMobile ? 20 : 24,
                  width: isMobile ? 20 : 24,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Text(
                  'Create Account',
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

  Widget _buildLoginLink(
    bool isMobile,
    bool isDarkTheme,
    ThemeProvider themeProvider,
  ) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Provider.of<RouterProvider>(
                context,
                listen: false,
              ).setAuthViewMode('login');
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.w700,
                color: themeProvider.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
