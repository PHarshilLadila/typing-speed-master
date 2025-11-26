// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:developer' as dev;
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restart_app/restart_app.dart';
import 'package:typing_speed_master/models/test_text.dart';
import 'package:typing_speed_master/models/user_model.dart';
import 'package:typing_speed_master/providers/activity_provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/profile_placeholder_avatar.dart';
import 'package:typing_speed_master/widgets/stats_card.dart';
import '../providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  bool _isFirstLoad = true;
  List<List<DateTime?>> _heatmapWeeks = [];
  int _currentHeatmapYear = DateTime.now().year;
  Map<DateTime, int> _activityData = {};
  List<MonthLabel> _monthLabels = [];
  String? _profileImageUrl;
  List<int> _availableYears = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileData();
    _generateHeatmapData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn && authProvider.user != null) {
        _generateHeatmapData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await authProvider.fetchUserProfile(authProvider.user!.id);
    }
    _isFirstLoad = false;
  }

  Future<void> _refreshProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await authProvider.fetchUserProfile(authProvider.user!.id);
    }
  }

  void _generateHeatmapData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      dev.log('🔄 Generating heatmap data for user: ${authProvider.user!.id}');

      if (mounted) {
        setState(() {
          _activityData = {};
        });
      }

      try {
        await activityProvider.fetchActivityData(
          authProvider.user!.id,
          _currentHeatmapYear,
        );

        // Calculate available years based on user's account creation
        final userCreatedYear =
            authProvider.user!.createdAt?.year ?? DateTime.now().year;
        final currentYear = DateTime.now().year;

        // Generate list of years from user creation to current year
        _availableYears = List.generate(
          currentYear - userCreatedYear + 1,
          (index) => userCreatedYear + index,
        );

        if (mounted) {
          setState(() {
            _activityData = Map.from(activityProvider.activityData);
            _generateHeatmapWeeks();
            _calculateMonthLabels();
          });

          dev.log('✅ Heatmap data generated: ${_activityData.length} days');
          if (_activityData.isNotEmpty) {
            dev.log(
              '📊 Sample activity: ${_activityData.entries.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}',
            );
          }
        }
      } catch (e) {
        dev.log('❌ Error generating heatmap data: $e');
        if (mounted) {
          setState(() {
            _activityData = {};
            _generateHeatmapWeeks();
            _calculateMonthLabels();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _activityData = {};
          _generateHeatmapWeeks();
          _calculateMonthLabels();
        });
      }
    }
  }

  void _generateHeatmapWeeks() {
    _heatmapWeeks = [];

    DateTime currentDate = DateTime(_currentHeatmapYear, 1, 1);

    while (currentDate.weekday != DateTime.monday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    for (int week = 0; week < 53; week++) {
      List<DateTime?> weekDays = [];

      for (int day = 0; day < 7; day++) {
        final date = currentDate.add(Duration(days: (week * 7) + day));
        weekDays.add(date);
      }

      _heatmapWeeks.add(weekDays);
    }
  }

  void _calculateMonthLabels() {
    _monthLabels = [];

    Map<int, List<int>> monthWeeks = {};

    for (int weekIndex = 0; weekIndex < _heatmapWeeks.length; weekIndex++) {
      final week = _heatmapWeeks[weekIndex];

      final monthCount = <int, int>{};
      for (final date in week) {
        if (date != null && date.year == _currentHeatmapYear) {
          monthCount[date.month] = (monthCount[date.month] ?? 0) + 1;
        }
      }

      if (monthCount.isNotEmpty) {
        final dominantMonth =
            monthCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        if (!monthWeeks.containsKey(dominantMonth)) {
          monthWeeks[dominantMonth] = [];
        }
        monthWeeks[dominantMonth]!.add(weekIndex);
      }
    }

    final sortedMonths = monthWeeks.keys.toList()..sort();
    for (final month in sortedMonths) {
      final weeks = monthWeeks[month]!;
      if (weeks.isNotEmpty) {
        final startWeek = weeks.first;
        final weekCount = weeks.length;
        final monthName = _getMonthAbbreviation(month);
        _monthLabels.add(MonthLabel(monthName, startWeek, weekCount));
      }
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildCustomHeatmap(bool isDark, bool isMobile, bool isTablet) {
    final double squareSize = isMobile ? 10 : 12;
    final double spacing = isMobile ? 1.5 : 2;
    final double containerHeight = isMobile ? 110 : 130;
    final double weekWidth = squareSize + spacing * 2;
    final double dayLabelWidth = 30;

    final bool shouldScroll = isMobile || isTablet;

    Widget heatmapContent = _buildHeatmapContent(
      isDark,
      isMobile,
      squareSize,
      spacing,
      containerHeight,
      weekWidth,
      dayLabelWidth,
    );

    if (shouldScroll) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: double.infinity, minWidth: 0),
        child: heatmapContent,
      );
    } else {
      return Center(child: heatmapContent);
    }
  }

  Widget _buildHeatmapContent(
    bool isDark,
    bool isMobile,
    double squareSize,
    double spacing,
    double containerHeight,
    double weekWidth,
    double dayLabelWidth,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: dayLabelWidth),
                  SizedBox(
                    width: _heatmapWeeks.length * weekWidth,
                    child: Stack(
                      children:
                          _monthLabels.map((monthLabel) {
                            return Positioned(
                              left:
                                  monthLabel.startWeek * weekWidth +
                                  (monthLabel.weekCount * weekWidth) / 2 -
                                  (monthLabel.name.length *
                                          (isMobile ? 4.5 : 5)) /
                                      3,
                              child: SizedBox(
                                width: monthLabel.weekCount * weekWidth,
                                child: Text(
                                  monthLabel.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: dayLabelWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: squareSize * 0.3 + spacing),
                      Text('Mon', style: _dayLabelStyle(isDark)),
                      SizedBox(height: squareSize * 1.4 + spacing),
                      Text('Wed', style: _dayLabelStyle(isDark)),
                      SizedBox(height: squareSize * 1.4 + spacing),
                      Text('Fri', style: _dayLabelStyle(isDark)),
                    ],
                  ),
                ),
                SizedBox(width: 8),

                SizedBox(
                  height: containerHeight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_heatmapWeeks.length, (weekIndex) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: spacing),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(7, (dayIndex) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: spacing),
                              child: _buildHeatmapSquare(
                                weekIndex,
                                dayIndex,
                                isDark,
                                squareSize,
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(int level, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    switch (level) {
      case 0:
        return isDark ? Colors.white12 : Colors.black12.withOpacity(0.02);
      case 1:
        return themeProvider.primaryColor.shade100;
      case 2:
        return themeProvider.primaryColor.shade300;
      case 3:
        return themeProvider.primaryColor.shade500;
      case 4:
        return themeProvider.primaryColor.shade700;
      default:
        return isDark ? Colors.white12 : Colors.black12.withOpacity(0.02);
    }
  }

  void _changeHeatmapYear(int year) {
    if (_availableYears.contains(year)) {
      _currentHeatmapYear = year;
      _generateHeatmapData();
    }
  }

  Future<void> _updateProfilePicture() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final isDarkTheme = themeProvider.isDarkMode;

    if (currentUser == null) return;

    String? newImageDataUrl = await CustomDialog.showProfilePictureDialog(
      context: context,
      currentImageUrl: currentUser.avatarUrl ?? '',
    );

    if (newImageDataUrl != null && mounted) {
      try {
        // Show loading state
        setState(() {
          _profileImageUrl = newImageDataUrl;
        });

        // Update in backend
        await _uploadProfilePictureToServer(newImageDataUrl);

        // Show success message
        Fluttertoast.showToast(
          msg: "Profile picture updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: isDarkTheme ? Colors.white : Colors.black,
          fontSize: 14.0,
          webPosition: "center",
          webBgColor:
              isDarkTheme
                  ? "linear-gradient(to right, #000000, #000000)"
                  : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
        );
      } catch (e) {
        // Show error message
        Fluttertoast.showToast(
          msg: "Failed to update profile picture",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: isDarkTheme ? Colors.white : Colors.black,
          fontSize: 14.0,
          webPosition: "center",
          webBgColor:
              isDarkTheme
                  ? "linear-gradient(to right, #000000, #000000)"
                  : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
        );

        // Revert to original image
        setState(() {
          _profileImageUrl = null;
        });
      }
    }
  }

  // Add this method to handle server upload
  Future<void> _uploadProfilePictureToServer(String imageDataUrl) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Here you would typically upload the image to your backend
    // For now, we'll just update the local user data
    if (authProvider.user != null) {
      // Convert data URL to a format your backend expects
      // This might involve uploading to cloud storage and getting a URL back

      // For demo purposes, we'll use the data URL directly
      // In production, you should upload to your server and get a proper URL
      await authProvider.updateProfile(avatarUrl: imageDataUrl);

      // Refresh user data
      await authProvider.fetchUserProfile(authProvider.user!.id);
    }
  }

  // Update the profileAvatar method to use the new image URL
  // Widget profileAvatar(
  //   UserModel? user,
  //   bool isDark,
  //   double size,
  //   void Function()? onTap,
  // ) {
  //   final currentImageUrl = _profileImageUrl ?? user?.avatarUrl;

  //   return InkWell(
  //     onTap: _updateProfilePicture, // Update this line to use the new method
  //     borderRadius: BorderRadius.circular(size / 2),
  //     child: Stack(
  //       children: [
  //         Container(
  //           width: size,
  //           height: size,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             border: Border.all(
  //               color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
  //               width: 2,
  //             ),
  //           ),
  //           child: ClipOval(
  //             child:
  //                 currentImageUrl != null && currentImageUrl.isNotEmpty
  //                     ? _buildProfileImage(currentImageUrl, isDark, size)
  //                     : ProfilePlaceHolderAvatar(
  //                       isDark: isDark,
  //                       size: size * 0.8,
  //                     ),
  //           ),
  //         ),
  //         // Add edit icon overlay
  //         Positioned(
  //           bottom: 0,
  //           right: 0,
  //           child: Container(
  //             width: size * 0.3,
  //             height: size * 0.3,
  //             decoration: BoxDecoration(
  //               color: Colors.blue,
  //               shape: BoxShape.circle,
  //               border: Border.all(
  //                 color: isDark ? Colors.grey[900]! : Colors.white,
  //                 width: 2,
  //               ),
  //             ),
  //             child: Icon(Icons.edit, color: Colors.white, size: size * 0.15),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget profileAvatar(
    UserModel? user,
    bool isDark,
    double size,
    void Function()? onTap,
  ) {
    final currentImageUrl = _profileImageUrl ?? user?.avatarUrl;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: _updateProfilePicture,
      borderRadius: BorderRadius.circular(size / 2),
      child: Stack(
        children: [
          // Profile Image Container
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
                      ? _buildEnhancedProfileImage(
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

          // Edit Icon Overlay
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

  // Enhanced profile image builder with smooth loading and better error handling
  Widget _buildEnhancedProfileImage(
    String imageUrl,
    bool isDark,
    double size,
    ThemeProvider themeProvider,
  ) {
    if (imageUrl.startsWith('data:image')) {
      // Handle data URL (base64 image from camera/gallery)
      return _buildDataUrlImage(imageUrl, isDark, size);
    } else {
      // Handle regular network image with cached_network_image
      return _buildNetworkImage(imageUrl, isDark, size, themeProvider);
    }
  }

  // Build image from data URL (base64)
  Widget _buildDataUrlImage(String dataUrl, bool isDark, double size) {
    return Image.network(
      dataUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        // Smooth loading animation
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
              // Background shimmer effect
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

              // Progress indicator
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

              // Percentage text for larger images
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
        // Fallback to placeholder with error animation
        return _buildErrorState(isDark, size, error.toString());
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // Smooth fade-in animation when image loads
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

  // Build network image with cached_network_image for better performance
  Widget _buildNetworkImage(
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
      placeholder: (context, url) => _buildLoadingState(isDark, size),
      errorWidget:
          (context, url, error) =>
              _buildErrorState(isDark, size, error.toString()),
      imageBuilder: (context, imageProvider) {
        // Smooth image rendering with fade-in effect
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

  // Loading state widget
  Widget _buildLoadingState(bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          // Shimmer effect
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

          // Pulsing animation
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

  // Error state widget
  Widget _buildErrorState(bool isDark, double size, String error) {
    dev.log('❌ Profile image loading error: $error');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: size * 0.3,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          if (size > 60)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Error',
                style: TextStyle(
                  fontSize: size * 0.1,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build profile image with better error handling
  // Widget _buildProfileImage(String imageUrl, bool isDark, double size) {
  //   if (imageUrl.startsWith('data:image')) {
  //     // Handle data URL (base64 image)
  //     return Image.network(
  //       imageUrl,
  //       fit: BoxFit.cover,
  //       width: size,
  //       height: size,
  //       loadingBuilder: (context, child, loadingProgress) {
  //         if (loadingProgress == null) return child;
  //         return Center(
  //           child: CircularProgressIndicator(
  //             value:
  //                 loadingProgress.expectedTotalBytes != null
  //                     ? loadingProgress.cumulativeBytesLoaded /
  //                         loadingProgress.expectedTotalBytes!
  //                     : null,
  //           ),
  //         );
  //       },
  //       errorBuilder: (context, error, stackTrace) {
  //         return ProfilePlaceHolderAvatar(isDark: isDark, size: size * 0.8);
  //       },
  //     );
  //   } else {
  //     // Handle regular network image
  //     return CachedNetworkImage(
  //       imageUrl: imageUrl,
  //       fit: BoxFit.cover,
  //       placeholder:
  //           (context, url) =>
  //               Center(child: CircularProgressIndicator(strokeWidth: 2)),
  //       errorWidget: (context, url, error) {
  //         return ProfilePlaceHolderAvatar(isDark: isDark, size: size * 0.8);
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoggedIn &&
            authProvider.user != null &&
            !_isFirstLoad) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshProfileData();
          });
        }

        if (authProvider.isLoading && !authProvider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return profileUI(
          context,
          authProvider,
          isDark,
          authProvider.user ??
              UserModel(
                id: 'UserID',
                email: 'example@gmail.com',
                fullName: "Guest User",
                avatarUrl: "https://avatar.iran.liara.run/public/42",
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
                totalTests: 0,
                totalWords: 0,
                averageWpm: 0.0,
                averageAccuracy: 0.0,
              ),
        );
      },
    );
  }

  Widget profileUI(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
    UserModel user,
  ) {
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final borderColor =
        isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);
    final width = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth < 1024;
        final themeProvider = Provider.of<ThemeProvider>(
          context,
          listen: false,
        );

        return RefreshIndicator(
          onRefresh: () async {
            if (authProvider.isLoggedIn) {
              final user = authProvider.user;
              if (user != null) {
                await authProvider.fetchUserProfile(user.id);
              }
            }
          },
          child: SingleChildScrollView(
            padding:
                width > 1200
                    ? EdgeInsets.symmetric(
                      vertical: 50,
                      horizontal: MediaQuery.of(context).size.width / 5,
                    )
                    : EdgeInsets.all(40),
            child: Column(
              children: [
                profileHeader(context, isMobile, isTablet),
                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 48,
                    vertical: isMobile ? 20 : 24,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: profileContent(
                    context,
                    authProvider,
                    isDark,
                    isMobile,
                    isTablet,
                  ),
                ),

                const SizedBox(height: 32),
                if (authProvider.isLoggedIn) ...[
                  profileStatsSection(user, isDark, isMobile, isTablet),
                ],
                const SizedBox(height: 32),

                if (authProvider.isLoggedIn)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: isMobile ? 16 : 20,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Preferences',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose your primary color',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            themePreferenceColorOption(
                              color: Colors.red,
                              colorName: 'red',
                              isSelected:
                                  themeProvider.currentColorName == 'red',
                              onTap: () => themeProvider.setPrimaryColor('red'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.pink,
                              colorName: 'pink',
                              isSelected:
                                  themeProvider.currentColorName == 'pink',
                              onTap:
                                  () => themeProvider.setPrimaryColor('pink'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.purple,
                              colorName: 'purple',
                              isSelected:
                                  themeProvider.currentColorName == 'purple',
                              onTap:
                                  () => themeProvider.setPrimaryColor('purple'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.deepPurple,
                              colorName: 'deepPurple',
                              isSelected:
                                  themeProvider.currentColorName ==
                                  'deepPurple',
                              onTap:
                                  () => themeProvider.setPrimaryColor(
                                    'deepPurple',
                                  ),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.indigo,
                              colorName: 'indigo',
                              isSelected:
                                  themeProvider.currentColorName == 'indigo',
                              onTap:
                                  () => themeProvider.setPrimaryColor('indigo'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.blue,
                              colorName: 'blue',
                              isSelected:
                                  themeProvider.currentColorName == 'blue',
                              onTap:
                                  () => themeProvider.setPrimaryColor('blue'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.lightBlue,
                              colorName: 'lightBlue',
                              isSelected:
                                  themeProvider.currentColorName == 'lightBlue',
                              onTap:
                                  () => themeProvider.setPrimaryColor(
                                    'lightBlue',
                                  ),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.cyan,
                              colorName: 'cyan',
                              isSelected:
                                  themeProvider.currentColorName == 'cyan',
                              onTap:
                                  () => themeProvider.setPrimaryColor('cyan'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.teal,
                              colorName: 'teal',
                              isSelected:
                                  themeProvider.currentColorName == 'teal',
                              onTap:
                                  () => themeProvider.setPrimaryColor('teal'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.green,
                              colorName: 'green',
                              isSelected:
                                  themeProvider.currentColorName == 'green',
                              onTap:
                                  () => themeProvider.setPrimaryColor('green'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.lightGreen,
                              colorName: 'lightGreen',
                              isSelected:
                                  themeProvider.currentColorName ==
                                  'lightGreen',
                              onTap:
                                  () => themeProvider.setPrimaryColor(
                                    'lightGreen',
                                  ),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.lime,
                              colorName: 'lime',
                              isSelected:
                                  themeProvider.currentColorName == 'lime',
                              onTap:
                                  () => themeProvider.setPrimaryColor('lime'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.yellow,
                              colorName: 'yellow',
                              isSelected:
                                  themeProvider.currentColorName == 'yellow',
                              onTap:
                                  () => themeProvider.setPrimaryColor('yellow'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.amber,
                              colorName: 'amber',
                              isSelected:
                                  themeProvider.currentColorName == 'amber',
                              onTap:
                                  () => themeProvider.setPrimaryColor('amber'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.orange,
                              colorName: 'orange',
                              isSelected:
                                  themeProvider.currentColorName == 'orange',
                              onTap:
                                  () => themeProvider.setPrimaryColor('orange'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.deepOrange,
                              colorName: 'deepOrange',
                              isSelected:
                                  themeProvider.currentColorName ==
                                  'deepOrange',
                              onTap:
                                  () => themeProvider.setPrimaryColor(
                                    'deepOrange',
                                  ),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.brown,
                              colorName: 'brown',
                              isSelected:
                                  themeProvider.currentColorName == 'brown',
                              onTap:
                                  () => themeProvider.setPrimaryColor('brown'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.grey,
                              colorName: 'grey',
                              isSelected:
                                  themeProvider.currentColorName == 'grey',
                              onTap:
                                  () => themeProvider.setPrimaryColor('grey'),
                              isDark: isDark,
                            ),

                            themePreferenceColorOption(
                              color: Colors.blueGrey,
                              colorName: 'blueGrey',
                              isSelected:
                                  themeProvider.currentColorName == 'blueGrey',
                              onTap:
                                  () =>
                                      themeProvider.setPrimaryColor('blueGrey'),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (authProvider.isLoggedIn) SizedBox(height: 32),
                if (authProvider.isLoggedIn)
                  profileDangerZone(
                    context,
                    authProvider,
                    isDark,
                    isMobile,
                    isTablet,
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget themePreferenceColorOption({
    required MaterialColor color,
    required String colorName,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isSelected
                    ? isDark
                        ? Colors.white
                        : Colors.black
                    : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child:
            isSelected
                ? Icon(
                  Icons.check,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                )
                : null,
      ),
    );
  }

  Widget profileHeader(BuildContext context, bool isMobile, bool isTablet) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget profileContent(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final textColor = isDark ? Colors.white : Colors.black;
    final user = authProvider.user;

    return Column(
      children: [
        if (isMobile)
          profileMobileLayout(authProvider, isDark, isMobile, textColor, user)
        else
          profileDesktopLayout(
            authProvider,
            isDark,
            isMobile,
            isTablet,
            textColor,
            user,
          ),
      ],
    );
  }

  Widget profileMobileLayout(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    Color textColor,
    UserModel? user,
  ) {
    return Column(
      children: [
        profileAvatar(user, isDark, isMobile ? 80.0 : 100.0, () {}),
        const SizedBox(height: 20),

        profileUserInfo(authProvider, user, textColor, isMobile, true, isDark),
        const SizedBox(height: 24),

        profileActionButton(authProvider, isDark, isMobile),
      ],
    );
  }

  Widget profileDesktopLayout(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    bool isTablet,
    Color textColor,
    UserModel? user,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        profileAvatar(user, isDark, isTablet ? 100.0 : 120.0, () {
          dev.log("onTap = This is the profile Image");
        }),
        const SizedBox(width: 24),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileUserInfo(
                authProvider,
                user,
                textColor,
                isMobile,
                false,
                isDark,
              ),
              const SizedBox(height: 20),

              if (authProvider.isLoggedIn && user != null)
                profileUserTags(user, isDark, isMobile),
            ],
          ),
        ),

        profileActionButton(authProvider, isDark, isMobile),
      ],
    );
  }

  Widget profileUserTags(UserModel user, bool isDark, bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        profileTags('ID: ${user.id.substring(0, 8)}...', isDark, () {
          Clipboard.setData(ClipboardData(text: user.id));
          Fluttertoast.showToast(
            msg: "User ID copied successfully.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: isDark ? Colors.white : Colors.black,
            fontSize: 14.0,
            webPosition: "center",
            webBgColor:
                isDark
                    ? "linear-gradient(to right, #000000, #000000)"
                    : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
          );
        }),
        profileTags('🔥 ${user.level}', isDark, () {}),
      ],
    );
  }

  // Widget profileAvatar(
  //   UserModel? user,
  //   bool isDark,
  //   double size,
  //   void Function()? onTap,
  // ) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       width: size,
  //       height: size,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         border: Border.all(
  //           color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
  //           width: 1,
  //         ),
  //       ),
  //       child: ClipOval(
  //         child:
  //             user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
  //                 ? CachedNetworkImage(
  //                   imageUrl:
  //                       user.avatarUrl ??
  //                       "https://api.dicebear.com/7.x/avataaars/svg?seed=profile",
  //                   fit: BoxFit.cover,
  //                   placeholder: (context, url) {
  //                     return ProfilePlaceHolderAvatar(isDark: isDark, size: 80);
  //                   },
  //                   errorWidget: (context, url, error) {
  //                     return ProfilePlaceHolderAvatar(isDark: isDark, size: 80);
  //                   },
  //                 )
  //                 : ProfilePlaceHolderAvatar(isDark: isDark, size: 80),
  //       ),
  //     ),
  //   );
  // }

  Widget profileUserInfo(
    AuthProvider authProvider,
    UserModel? user,
    Color textColor,
    bool isMobile,
    bool isCentered,
    bool isDark,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          authProvider.isLoggedIn ? (user?.fullName ?? 'User') : 'Welcome!',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment:
              isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.envelope,
              size: isMobile ? 14 : 16,
              color: themeProvider.primaryColor,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                authProvider.isLoggedIn
                    ? (user?.email ?? 'No email')
                    : 'Sign in to access your account',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: textColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        if (authProvider.isLoggedIn && user?.createdAt != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment:
                isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.calendar,
                size: isMobile ? 12 : 14,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Joined ${DateFormat('MMM yyyy').format(user!.createdAt!)}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget profileActionButton(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      return SizedBox(
        width: isMobile ? double.infinity : null,
        child: TextButton(
          onPressed: () {
            showEditProfileDialog(context, authProvider);
          },
          style: TextButton.styleFrom(
            backgroundColor: themeProvider.primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 12 : 14,
            ),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color:
                  themeProvider.primaryColor == Colors.amber ||
                          themeProvider.primaryColor == Colors.yellow ||
                          themeProvider.primaryColor == Colors.lime
                      ? Colors.black
                      : Colors.white,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: isMobile ? double.infinity : null,
        child: ElevatedButton(
          onPressed:
              authProvider.isLoading
                  ? null
                  : () {
                    authProvider.signInWithGoogle();
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.grey[800],
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 14 : 16,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.google, size: 16),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget profileDangerZone(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign out from your account',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    CustomDialog.showSignOutDialog(
                      context: context,
                      onConfirm: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        await authProvider.signOut();
                        await Future.delayed(Duration(milliseconds: 500));
                        if (kIsWeb) {
                          html.window.location.assign(
                            html.window.location.href,
                          );
                        } else {
                          Restart.restartApp();
                        }
                        debugPrint(
                          "✅ User Sign Out Successful and App Restarted",
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileTags(String text, bool isDark, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final nameController = TextEditingController(text: user?.fullName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            'Edit Profile',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.amberAccent : Colors.blueAccent,
                    ),
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
                  color: isDark ? Colors.grey[400] : Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  authProvider.updateProfile(
                    fullName: nameController.text.trim(),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.amberAccent.shade400 : Colors.amber,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Widget profileStatsSection(
    UserModel user,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final borderColor =
        isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatsCard(
                width: 200,
                title: 'Total Tests',
                value: '${user.totalTests}',
                unit: '',
                color: Colors.grey,
                icon: Icons.assignment,
                isDarkMode: isDark,
                isProfile: true,
              ),
              StatsCard(
                width: 200,
                title: 'Average WPM',
                value: '${user.averageWpm.round()}',
                unit: '',
                color: Colors.grey,
                icon: Icons.speed,
                isDarkMode: isDark,
                isProfile: true,
              ),
              StatsCard(
                width: 200,
                title: 'Total Words',
                value: '${user.totalWords}',
                unit: '',
                color: Colors.grey,
                icon: Icons.text_fields,
                isDarkMode: isDark,
                isProfile: true,
              ),

              StatsCard(
                width: 200,
                title: 'Accuracy',
                value: '${user.averageAccuracy.round()}%',
                unit: '',
                color: Colors.grey,
                icon: Icons.flag,
                isDarkMode: isDark,
                isProfile: true,
              ),
              StatsCard(
                width: 200,
                title: 'Current Streak',
                value: '${user.currentStreak} days',
                unit: '',
                color: Colors.grey,
                icon: Icons.local_fire_department,
                isDarkMode: isDark,
                isProfile: true,
              ),
              StatsCard(
                width: 200,
                title: 'Longest Streak',
                value: '${user.longestStreak} days',
                unit: '',
                color: Colors.grey,
                icon: Icons.emoji_events,
                isDarkMode: isDark,
                isProfile: true,
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Typing Activity',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: isMobile ? 18 : 20,
                          ),
                          onPressed:
                              () =>
                                  _availableYears.contains(
                                        _currentHeatmapYear - 1,
                                      )
                                      ? () => _changeHeatmapYear(
                                        _currentHeatmapYear - 1,
                                      )
                                      : null,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 36),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_currentHeatmapYear',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            size: isMobile ? 18 : 20,
                          ),
                          onPressed:
                              () =>
                                  _availableYears.contains(
                                        _currentHeatmapYear + 1,
                                      )
                                      ? () => _changeHeatmapYear(
                                        _currentHeatmapYear + 1,
                                      )
                                      : null,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 36),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 20),

                _buildCustomHeatmap(isDark, isMobile, isTablet),
                SizedBox(height: isMobile ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Less',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildColorIndicator(0, isDark),
                    SizedBox(width: 2),
                    _buildColorIndicator(1, isDark),
                    SizedBox(width: 2),
                    _buildColorIndicator(2, isDark),
                    SizedBox(width: 2),
                    _buildColorIndicator(3, isDark),
                    SizedBox(width: 2),
                    _buildColorIndicator(4, isDark),
                    SizedBox(width: 8),
                    Text(
                      'More',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapSquare(
    int weekIndex,
    int dayIndex,
    bool isDark,
    double squareSize,
  ) {
    final date = _heatmapWeeks[weekIndex][dayIndex];

    if (date == null || date.year != _currentHeatmapYear) {
      return SizedBox(width: squareSize, height: squareSize);
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);

    final activityEntry = _activityData.entries.firstWhere(
      (entry) =>
          entry.key.year == normalizedDate.year &&
          entry.key.month == normalizedDate.month &&
          entry.key.day == normalizedDate.day,
      orElse: () => MapEntry(normalizedDate, 0),
    );

    final testCount = activityEntry.value;

    int activityLevel = getActivityLevel(testCount);

    final color = _getActivityColor(activityLevel, isDark);

    return Container(
      width: squareSize,
      height: squareSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Tooltip(
        message:
            testCount > 0
                ? '${DateFormat('MMM dd, yyyy').format(date)}\n$testCount typing test${testCount == 1 ? '' : 's'}'
                : '${DateFormat('MMM dd, yyyy').format(date)}\nNo tests',
        textStyle: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800]! : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(),
        ),
      ),
    );
  }

  int getActivityLevel(int testCount) {
    if (testCount == 0) return 0;
    if (testCount <= 2) return 1;
    if (testCount <= 5) return 2;
    if (testCount <= 10) return 3;
    return 4;
  }

  TextStyle _dayLabelStyle(bool isDark) {
    return TextStyle(
      fontSize: 12,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildColorIndicator(int intensity, bool isDark) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _getActivityColor(intensity, isDark),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
