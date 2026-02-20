// // ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

// import 'dart:html' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:restart_app/restart_app.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:typing_speed_master/features/profile/widget/profile_login_widget.dart';
// import 'package:typing_speed_master/features/profile/widget/profile_register_widget.dart';
// import 'package:typing_speed_master/features/profile/widget/profile_tab_widget.dart';
// import 'package:typing_speed_master/models/user_activity_month_label_model.dart';
// import 'package:typing_speed_master/models/user_model.dart';
// import 'package:typing_speed_master/features/profile/provider/user_activity_provider.dart';
// import 'package:typing_speed_master/theme/provider/theme_provider.dart';
// import 'package:typing_speed_master/features/typing_test/provider/typing_test_provider.dart';
// import 'package:typing_speed_master/widgets/custom_dialogs.dart';
// import 'package:typing_speed_master/features/profile/widget/profile_placeholder_avatar.dart';
// import 'package:typing_speed_master/widgets/custom_stats_card.dart';
// import '../../providers/auth_provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:typing_speed_master/providers/router_provider.dart'; // Added RouterProvider
// import 'package:typing_speed_master/widgets/custom_textformfield.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => ProfileScreenState();
// }

// class ProfileScreenState extends State<ProfileScreen>
//     with WidgetsBindingObserver {
//   bool isFirstLoad = true;
//   bool isRefreshing = false;
//   List<List<DateTime?>> heatmapWeeks = [];
//   int currentHeatmapYear = DateTime.now().year;
//   Map<DateTime, int> activityData = {};
//   List<UserActivityMonthLabelModel> monthLabels = [];
//   String? profileImageUrl;
//   List<int> availableYears = [];

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);
//     loadProfileData();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         generateHeatmapData();
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _initializeProfile();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);

//       if (authProvider.isLoggedIn && authProvider.user != null) {
//         generateHeatmapData();
//       }
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       refreshProfileData();
//     }
//   }

//   Future<void> _initializeProfile() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.isLoggedIn && authProvider.user != null) {
//       await authProvider.fetchUserProfile(authProvider.user!.id);
//       generateHeatmapData();
//     }
//     if (mounted) {
//       setState(() {
//         isFirstLoad = false;
//       });
//     }
//   }

//   Future<void> loadProfileData() async {
//     if (!mounted) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.isLoggedIn && authProvider.user != null) {
//       await authProvider.fetchUserProfile(authProvider.user!.id);
//     }
//     if (mounted) {
//       setState(() {
//         isFirstLoad = false;
//       });
//     }
//   }

//   Future<void> refreshProfileData() async {
//     if (!mounted || isRefreshing) return;

//     setState(() {
//       isRefreshing = true;
//     });

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       if (authProvider.isLoggedIn && authProvider.user != null) {
//         await authProvider.fetchUserProfile(authProvider.user!.id);
//         if (mounted) {
//           generateHeatmapData();
//         }
//       }
//     } catch (e) {
//       print('Error refreshing profile: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isRefreshing = false;
//         });
//       }
//     }
//   }

//   void generateHeatmapData() async {
//     if (!mounted) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final activityProvider = Provider.of<UserActivityProvider>(
//       context,
//       listen: false,
//     );

//     if (authProvider.user != null) {
//       try {
//         await activityProvider.fetchActivityData(
//           authProvider.user!.id,
//           currentHeatmapYear,
//         );
//         await activityProvider.forceRefreshActivity(
//           authProvider.user!.id,
//           currentHeatmapYear,
//         );

//         final userCreatedYear =
//             authProvider.user!.createdAt?.year ?? DateTime.now().year;
//         final currentYear = DateTime.now().year;

//         availableYears = List.generate(
//           currentYear - userCreatedYear + 1,
//           (index) => userCreatedYear + index,
//         );

//         if (mounted) {
//           setState(() {
//             activityData = Map.from(activityProvider.activityData);
//             generateHeatmapWeeks();
//             calculateMonthLabels();
//           });
//         }
//       } catch (e) {
//         if (mounted) {
//           setState(() {
//             activityData = {};
//             generateHeatmapWeeks();
//             calculateMonthLabels();
//           });
//         }
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           activityData = {};
//           generateHeatmapWeeks();
//           calculateMonthLabels();
//         });
//       }
//     }
//   }

//   void generateHeatmapWeeks() {
//     heatmapWeeks = [];

//     DateTime currentDate = DateTime(currentHeatmapYear, 1, 1);

//     while (currentDate.weekday != DateTime.monday) {
//       currentDate = currentDate.subtract(const Duration(days: 1));
//     }

//     for (int week = 0; week < 53; week++) {
//       List<DateTime?> weekDays = [];

//       for (int day = 0; day < 7; day++) {
//         final date = currentDate.add(Duration(days: (week * 7) + day));
//         weekDays.add(date);
//       }

//       heatmapWeeks.add(weekDays);
//     }
//   }

//   void calculateMonthLabels() {
//     monthLabels = [];

//     Map<int, List<int>> monthWeeks = {};

//     for (int weekIndex = 0; weekIndex < heatmapWeeks.length; weekIndex++) {
//       final week = heatmapWeeks[weekIndex];

//       final monthCount = <int, int>{};
//       for (final date in week) {
//         if (date != null && date.year == currentHeatmapYear) {
//           monthCount[date.month] = (monthCount[date.month] ?? 0) + 1;
//         }
//       }

//       if (monthCount.isNotEmpty) {
//         final dominantMonth =
//             monthCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

//         if (!monthWeeks.containsKey(dominantMonth)) {
//           monthWeeks[dominantMonth] = [];
//         }
//         monthWeeks[dominantMonth]!.add(weekIndex);
//       }
//     }

//     final sortedMonths = monthWeeks.keys.toList()..sort();
//     for (final month in sortedMonths) {
//       final weeks = monthWeeks[month]!;
//       if (weeks.isNotEmpty) {
//         final startWeek = weeks.first;
//         final weekCount = weeks.length;
//         final monthName = getMonthAbbreviation(month);
//         monthLabels.add(
//           UserActivityMonthLabelModel(monthName, startWeek, weekCount),
//         );
//       }
//     }
//   }

//   String getMonthAbbreviation(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   Widget customHeatmap(bool isDark, bool isMobile, bool isTablet) {
//     final double squareSize = isMobile ? 10 : 12;
//     final double spacing = isMobile ? 1.5 : 2;
//     final double containerHeight = isMobile ? 110 : 130;
//     final double weekWidth = squareSize + spacing * 2;
//     final double dayLabelWidth = 30;

//     final bool shouldScroll = isMobile || isTablet;

//     Widget heatmapContent = customHeatmapContent(
//       isDark,
//       isMobile,
//       squareSize,
//       spacing,
//       containerHeight,
//       weekWidth,
//       dayLabelWidth,
//     );

//     if (shouldScroll) {
//       return ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: double.infinity, minWidth: 0),
//         child: heatmapContent,
//       );
//     } else {
//       return Center(child: heatmapContent);
//     }
//   }

//   Widget customHeatmapContent(
//     bool isDark,
//     bool isMobile,
//     double squareSize,
//     double spacing,
//     double containerHeight,
//     double weekWidth,
//     double dayLabelWidth,
//   ) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       physics: const BouncingScrollPhysics(),
//       child: IntrinsicWidth(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: 20,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(width: dayLabelWidth),
//                   SizedBox(
//                     width: heatmapWeeks.length * weekWidth,
//                     child: Stack(
//                       children:
//                           monthLabels.map((monthLabel) {
//                             return Positioned(
//                               left:
//                                   monthLabel.startWeek * weekWidth +
//                                   (monthLabel.weekCount * weekWidth) / 2 -
//                                   (monthLabel.name.length *
//                                           (isMobile ? 4.5 : 5)) /
//                                       3,
//                               child: SizedBox(
//                                 width: monthLabel.weekCount * weekWidth,
//                                 child: Text(
//                                   monthLabel.name,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color:
//                                         isDark
//                                             ? Colors.grey[400]
//                                             : Colors.grey[600],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: dayLabelWidth,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: squareSize * 0.3 + spacing),
//                       Text('Mon', style: dayLabelStyle(isDark)),
//                       SizedBox(height: squareSize * 1.4 + spacing),
//                       Text('Wed', style: dayLabelStyle(isDark)),
//                       SizedBox(height: squareSize * 1.4 + spacing),
//                       Text('Fri', style: dayLabelStyle(isDark)),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 8),

//                 SizedBox(
//                   height: containerHeight,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: List.generate(heatmapWeeks.length, (weekIndex) {
//                       return Container(
//                         margin: EdgeInsets.symmetric(horizontal: spacing),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: List.generate(7, (dayIndex) {
//                             return Container(
//                               margin: EdgeInsets.symmetric(vertical: spacing),
//                               child: customHeatmapBoxes(
//                                 weekIndex,
//                                 dayIndex,
//                                 isDark,
//                                 squareSize,
//                               ),
//                             );
//                           }),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color getActivityColor(int level, bool isDark) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     switch (level) {
//       case 0:
//         return isDark ? Colors.white12 : Colors.black12.withOpacity(0.07);
//       case 1:
//         return themeProvider.primaryColor.shade100;
//       case 2:
//         return themeProvider.primaryColor.shade300;
//       case 3:
//         return themeProvider.primaryColor.shade500;
//       case 4:
//         return themeProvider.primaryColor.shade700;
//       default:
//         return isDark ? Colors.white12 : Colors.black12.withOpacity(0.07);
//     }
//   }

//   void changeHeatmapYear(int year) {
//     if (availableYears.contains(year)) {
//       currentHeatmapYear = year;
//       generateHeatmapData();
//     }
//   }

//   Future<void> updateProfilePicture() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final currentUser = authProvider.user;
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

//     final isDarkTheme = themeProvider.isDarkMode;

//     if (currentUser == null) return;

//     String? newImageDataUrl = await CustomDialog.showProfilePictureDialog(
//       context: context,
//       currentImageUrl: currentUser.avatarUrl ?? '',
//     );

//     if (newImageDataUrl != null && mounted) {
//       try {
//         setState(() {
//           profileImageUrl = newImageDataUrl;
//         });

//         await uploadProfilePictureToServer(newImageDataUrl);

//         Fluttertoast.showToast(
//           msg: "Profile picture updated successfully!",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 2,
//           textColor: isDarkTheme ? Colors.white : Colors.black,
//           fontSize: 14.0,
//           webPosition: "center",
//           webBgColor:
//               isDarkTheme
//                   ? "linear-gradient(to right, #000000, #000000)"
//                   : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
//         );
//       } catch (e) {
//         Fluttertoast.showToast(
//           msg: "Failed to update profile picture",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 2,
//           textColor: isDarkTheme ? Colors.white : Colors.black,
//           fontSize: 14.0,
//           webPosition: "center",
//           webBgColor:
//               isDarkTheme
//                   ? "linear-gradient(to right, #000000, #000000)"
//                   : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
//         );

//         setState(() {
//           profileImageUrl = null;
//         });
//       }
//     }
//   }

//   Future<void> uploadProfilePictureToServer(String imageDataUrl) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     if (authProvider.user != null) {
//       await authProvider.updateProfile(avatarUrl: imageDataUrl);
//       await authProvider.fetchUserProfile(authProvider.user!.id);
//     }
//   }

//   Widget profileAvatar(
//     UserModel? user,
//     bool isDark,
//     double size,
//     void Function()? onTap,
//   ) {
//     final currentImageUrl = profileImageUrl ?? user?.avatarUrl;
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return InkWell(
//       onTap: updateProfilePicture,
//       borderRadius: BorderRadius.circular(size / 2),
//       child: Stack(
//         children: [
//           Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
//                 width: 2,
//               ),
//             ),
//             child: ClipOval(
//               child:
//                   currentImageUrl != null && currentImageUrl.isNotEmpty
//                       ? showProfileImage(
//                         currentImageUrl,
//                         isDark,
//                         size,
//                         themeProvider,
//                       )
//                       : ProfilePlaceHolderAvatar(
//                         isDark: isDark,
//                         size: size * 0.8,
//                       ),
//             ),
//           ),

//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Container(
//               width: size * 0.3,
//               height: size * 0.3,
//               decoration: BoxDecoration(
//                 color: themeProvider.primaryColor,
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isDark ? Colors.grey[900]! : Colors.white,
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Icon(Icons.edit, color: Colors.white, size: size * 0.15),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget showProfileImage(
//     String imageUrl,
//     bool isDark,
//     double size,
//     ThemeProvider themeProvider,
//   ) {
//     if (imageUrl.startsWith('data:image')) {
//       return profileDataUrlImage(imageUrl, isDark, size);
//     } else {
//       return profileNetworkImage(imageUrl, isDark, size, themeProvider);
//     }
//   }

//   Widget profileDataUrlImage(String dataUrl, bool isDark, double size) {
//     return Image.network(
//       dataUrl,
//       fit: BoxFit.cover,
//       width: size,
//       height: size,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;

//         final double progress =
//             loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded /
//                     loadingProgress.expectedTotalBytes!
//                 : 0.0;

//         return Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             color: isDark ? Colors.grey[800] : Colors.grey[200],
//             shape: BoxShape.circle,
//           ),
//           child: Stack(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 500),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                       isDark ? Colors.grey[800]! : Colors.grey[200]!,
//                     ],
//                   ),
//                 ),
//               ),

//               Center(
//                 child: CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     isDark ? Colors.white : Colors.grey[600]!,
//                   ),
//                   backgroundColor: isDark ? Colors.grey[600] : Colors.grey[400],
//                 ),
//               ),

//               if (size > 80)
//                 Center(
//                   child: Text(
//                     '${(progress * 100).toInt()}%',
//                     style: TextStyle(
//                       fontSize: size * 0.1,
//                       color: isDark ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//       errorBuilder: (context, error, stackTrace) {
//         return profileErrorState(isDark, size, error.toString());
//       },
//       frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
//         if (wasSynchronouslyLoaded) {
//           return child;
//         }
//         return AnimatedOpacity(
//           opacity: frame == null ? 0 : 1,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           child: child,
//         );
//       },
//     );
//   }

//   Widget profileNetworkImage(
//     String imageUrl,
//     bool isDark,
//     double size,
//     ThemeProvider themeProvider,
//   ) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       fit: BoxFit.cover,
//       width: size,
//       height: size,
//       placeholder: (context, url) => profileLoadingState(isDark, size),
//       errorWidget:
//           (context, url, error) =>
//               profileErrorState(isDark, size, error.toString()),
//       imageBuilder: (context, imageProvider) {
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 500),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
//               ),
//             ),
//           ),
//         );
//       },
//       fadeInDuration: const Duration(milliseconds: 300),
//       fadeInCurve: Curves.easeInOut,
//       fadeOutDuration: const Duration(milliseconds: 200),
//       fadeOutCurve: Curves.easeOut,
//     );
//   }

//   Widget profileLoadingState(bool isDark, double size) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey[800] : Colors.grey[200],
//         shape: BoxShape.circle,
//       ),
//       child: Stack(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 1000),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                   isDark ? Colors.grey[800]! : Colors.grey[200]!,
//                   isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                 ],
//               ),
//             ),
//           ),

//           Center(
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.3, end: 0.8),
//               duration: const Duration(milliseconds: 1000),
//               curve: Curves.easeInOut,
//               builder: (context, value, child) {
//                 return Opacity(
//                   opacity: value,
//                   child: Icon(
//                     Icons.person,
//                     size: size * 0.5,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget profileErrorState(bool isDark, double size, String error) {
//     return CachedNetworkImage(
//       imageUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=male",
//       fit: BoxFit.cover,
//       width: size,
//       height: size,
//       placeholder: (context, url) => profileLoadingState(isDark, size),
//       imageBuilder: (context, imageProvider) {
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 500),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
//               ),
//             ),
//           ),
//         );
//       },
//       fadeInDuration: const Duration(milliseconds: 300),
//       fadeInCurve: Curves.easeInOut,
//       fadeOutDuration: const Duration(milliseconds: 200),
//       fadeOutCurve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = themeProvider.isDarkMode;

//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         if (authProvider.isLoading && !authProvider.isInitialized) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildProfileUI(context, authProvider, isDark),
//               // authProvider.isLoggedIn
//               //     ? FooterWidget(themeProvider: themeProvider)
//               //     : SizedBox.shrink(),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Widget _buildProfileUI(
//   //   BuildContext context,
//   //   AuthProvider authProvider,
//   //   bool isDark,
//   // ) {
//   //   final user = authProvider.user;

//   //   if (authProvider.isLoading && isFirstLoad) {
//   //     return const Center(child: CircularProgressIndicator());
//   //   }

//   //   if (authProvider.isLoggedIn && user != null && !isFirstLoad) {
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       refreshProfileData();
//   //     });
//   //   }

//   //   return profileUI(
//   //     context,
//   //     authProvider,
//   //     isDark,
//   //     user ??
//   //         UserModel(
//   //           id: 'UserID',
//   //           email: 'example@gmail.com',
//   //           fullName: "Guest User",
//   //           avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=male",
//   //           createdAt: DateTime.now().toUtc(),
//   //           updatedAt: DateTime.now().toUtc(),
//   //           totalTests: 0,
//   //           totalWords: 0,
//   //           averageWpm: 0.0,
//   //           averageAccuracy: 0.0,
//   //         ),
//   //   );
//   // }

//   Widget _buildProfileUI(
//     BuildContext context,
//     AuthProvider authProvider,
//     bool isDark,
//   ) {
//     final user = authProvider.user;

//     if (authProvider.isLoading && isFirstLoad) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     // REMOVE THIS COMPLETELY - it's causing infinite reloads
//     // if (authProvider.isLoggedIn && user != null && !isFirstLoad) {
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     refreshProfileData();
//     //   });
//     // }

//     // Show guest profile if not logged in
//     if (!authProvider.isLoggedIn || user == null) {
//       return profileUI(
//         context,
//         authProvider,
//         isDark,
//         UserModel(
//           id: 'Guest',
//           email: '',
//           fullName: "Guest User",
//           avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=guest",
//           createdAt: DateTime.now().toUtc(),
//           updatedAt: DateTime.now().toUtc(),
//           totalTests: 0,
//           totalWords: 0,
//           averageWpm: 0.0,
//           averageAccuracy: 0.0,
//         ),
//       );
//     }

//     return profileUI(context, authProvider, isDark, user);
//   }

//   Widget profileUI(
//     BuildContext context,
//     AuthProvider authProvider,
//     bool isDark,
//     UserModel user,
//   ) {
//     final cardColor = isDark ? Colors.grey[850] : Colors.white;
//     final borderColor =
//         isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);
//     final width = MediaQuery.of(context).size.width;

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isMobile = constraints.maxWidth < 768;
//         final isTablet = constraints.maxWidth < 1024;
//         final themeProvider = Provider.of<ThemeProvider>(
//           context,
//           listen: false,
//         );
//         final routerProvider = Provider.of<RouterProvider>(context);

//         return RefreshIndicator(
//           onRefresh: () async {
//             await refreshProfileData();
//           },
//           child: SingleChildScrollView(
//             padding:
//                 width > 1200
//                     ? EdgeInsets.symmetric(
//                       vertical: 50,
//                       horizontal: MediaQuery.of(context).size.width / 5,
//                     )
//                     : EdgeInsets.all(40),
//             child: Column(
//               children: [
//                 profileHeader(context, isMobile, isTablet),
//                 const SizedBox(height: 40),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 24 : 48,
//                     vertical: isMobile ? 20 : 24,
//                   ),
//                   decoration: BoxDecoration(
//                     color: cardColor,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: borderColor),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
//                         blurRadius: 15,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: profileContent(
//                     context,
//                     authProvider,
//                     isDark,
//                     isMobile,
//                     isTablet,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 if (!authProvider.isLoggedIn)
//                   Row(
//                     children: [
//                       Expanded(child: Divider(endIndent: 50)),
//                       Text("OR", style: TextStyle(fontSize: 16)),
//                       Expanded(child: Divider(indent: 50)),
//                     ],
//                   ),
//                 if (!authProvider.isLoggedIn) const SizedBox(height: 32),

//                 if (!authProvider.isLoggedIn)
//                   Container(
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[800] : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.all(4),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: _buildAuthTabButton(
//                             title: 'Login',
//                             isSelected: routerProvider.authViewMode == 'login',
//                             onTap:
//                                 () => routerProvider.setAuthViewMode('login'),
//                             isDark: isDark,
//                             themeProvider: themeProvider,
//                             isLeft: true,
//                           ),
//                         ),
//                         Expanded(
//                           child: _buildAuthTabButton(
//                             title: 'Register',
//                             isSelected:
//                                 routerProvider.authViewMode == 'register',
//                             onTap:
//                                 () =>
//                                     routerProvider.setAuthViewMode('register'),
//                             isDark: isDark,
//                             themeProvider: themeProvider,
//                             isLeft: false,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 if (!authProvider.isLoggedIn)
//                   _buildAuthSection(
//                     context,
//                     isMobile,
//                     isDark,
//                     routerProvider,
//                     authProvider,
//                   ),

//                 if (authProvider.isLoggedIn) ...[
//                   profileStatsSection(user, isDark, isMobile, isTablet),
//                   const SizedBox(height: 32),
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 20 : 32,
//                       vertical: isMobile ? 16 : 20,
//                     ),
//                     decoration: BoxDecoration(
//                       color: cardColor,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: borderColor),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
//                           blurRadius: 15,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Theme Preferences',
//                           style: TextStyle(
//                             fontSize: isMobile ? 18 : 20,
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? Colors.white : Colors.black,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Choose your primary color',
//                           style: TextStyle(
//                             fontSize: isMobile ? 14 : 16,
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         Wrap(
//                           spacing: 16,
//                           runSpacing: 16,
//                           children: [
//                             themePreferenceColorOption(
//                               color: Colors.red,
//                               colorName: 'red',
//                               isSelected:
//                                   themeProvider.currentColorName == 'red',
//                               onTap: () => themeProvider.setPrimaryColor('red'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.pink,
//                               colorName: 'pink',
//                               isSelected:
//                                   themeProvider.currentColorName == 'pink',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('pink'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.purple,
//                               colorName: 'purple',
//                               isSelected:
//                                   themeProvider.currentColorName == 'purple',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('purple'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.deepPurple,
//                               colorName: 'deepPurple',
//                               isSelected:
//                                   themeProvider.currentColorName ==
//                                   'deepPurple',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor(
//                                     'deepPurple',
//                                   ),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.indigo,
//                               colorName: 'indigo',
//                               isSelected:
//                                   themeProvider.currentColorName == 'indigo',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('indigo'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.blue,
//                               colorName: 'blue',
//                               isSelected:
//                                   themeProvider.currentColorName == 'blue',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('blue'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.lightBlue,
//                               colorName: 'lightBlue',
//                               isSelected:
//                                   themeProvider.currentColorName == 'lightBlue',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor(
//                                     'lightBlue',
//                                   ),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.cyan,
//                               colorName: 'cyan',
//                               isSelected:
//                                   themeProvider.currentColorName == 'cyan',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('cyan'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.teal,
//                               colorName: 'teal',
//                               isSelected:
//                                   themeProvider.currentColorName == 'teal',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('teal'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.green,
//                               colorName: 'green',
//                               isSelected:
//                                   themeProvider.currentColorName == 'green',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('green'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.lightGreen,
//                               colorName: 'lightGreen',
//                               isSelected:
//                                   themeProvider.currentColorName ==
//                                   'lightGreen',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor(
//                                     'lightGreen',
//                                   ),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.lime,
//                               colorName: 'lime',
//                               isSelected:
//                                   themeProvider.currentColorName == 'lime',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('lime'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.yellow,
//                               colorName: 'yellow',
//                               isSelected:
//                                   themeProvider.currentColorName == 'yellow',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('yellow'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.amber,
//                               colorName: 'amber',
//                               isSelected:
//                                   themeProvider.currentColorName == 'amber',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('amber'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.orange,
//                               colorName: 'orange',
//                               isSelected:
//                                   themeProvider.currentColorName == 'orange',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('orange'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.deepOrange,
//                               colorName: 'deepOrange',
//                               isSelected:
//                                   themeProvider.currentColorName ==
//                                   'deepOrange',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor(
//                                     'deepOrange',
//                                   ),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.brown,
//                               colorName: 'brown',
//                               isSelected:
//                                   themeProvider.currentColorName == 'brown',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('brown'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.grey,
//                               colorName: 'grey',
//                               isSelected:
//                                   themeProvider.currentColorName == 'grey',
//                               onTap:
//                                   () => themeProvider.setPrimaryColor('grey'),
//                               isDark: isDark,
//                             ),

//                             themePreferenceColorOption(
//                               color: Colors.blueGrey,
//                               colorName: 'blueGrey',
//                               isSelected:
//                                   themeProvider.currentColorName == 'blueGrey',
//                               onTap:
//                                   () =>
//                                       themeProvider.setPrimaryColor('blueGrey'),
//                               isDark: isDark,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 32),
//                   profileDangerZone(
//                     context,
//                     authProvider,
//                     isDark,
//                     isMobile,
//                     isTablet,
//                   ),
//                 ],
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAuthSection(
//     BuildContext context,
//     bool isMobile,
//     bool isDark,
//     RouterProvider routerProvider,
//     AuthProvider authProvider,
//   ) {
//     return Column(
//       children: [
//         SizedBox(height: 24),

//         // Selected Form
//         AnimatedSwitcher(
//           duration: Duration(milliseconds: 300),
//           child:
//               routerProvider.authViewMode == 'login'
//                   ? ProfileLoginWidget(key: ValueKey('login'))
//                   : ProfileRegisterWidget(key: ValueKey('register')),
//         ),

//         // SizedBox(height: 32),

//         // Google Sign In (Below Form)
//       ],
//     );
//   }

//   Widget _buildAuthTabButton({
//     required String title,
//     required bool isSelected,
//     required bool isLeft,
//     required VoidCallback onTap,
//     required bool isDark,
//     required ThemeProvider themeProvider,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color:
//               isSelected
//                   ? themeProvider.primaryColor.withOpacity(0.2)
//                   : Colors.black12,
//           // border: Border.all(
//           //   color: isSelected ? themeProvider.primaryColor : Colors.black12,
//           // ),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(isLeft ? 8 : 0),
//             bottomLeft: Radius.circular(isLeft ? 8 : 0),
//             topRight: Radius.circular(isLeft ? 0 : 8),
//             bottomRight: Radius.circular(isLeft ? 0 : 8),
//           ),

//           boxShadow:
//               isSelected
//                   ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ]
//                   : [],
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color:
//                 isSelected
//                     ? (isDark ? Colors.white : Colors.black)
//                     : (isDark ? Colors.grey[400] : Colors.grey[600]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget themePreferenceColorOption({
//     required MaterialColor color,
//     required String colorName,
//     required bool isSelected,
//     required VoidCallback onTap,
//     required bool isDark,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 40,
//         width: 40,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           border: Border.all(
//             color:
//                 isSelected
//                     ? isDark
//                         ? Colors.white
//                         : Colors.black
//                     : Colors.transparent,
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child:
//             isSelected
//                 ? Icon(
//                   Icons.check,
//                   color: isDark ? Colors.white : Colors.black,
//                   size: 20,
//                 )
//                 : null,
//       ),
//     );
//   }

//   Widget profileHeader(BuildContext context, bool isMobile, bool isTablet) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Profile',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color:
//                       themeProvider.isDarkMode
//                           ? Colors.white
//                           : Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Manage your account and preferences',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   color:
//                       themeProvider.isDarkMode
//                           ? Colors.grey[400]
//                           : Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget profileContent(
//     BuildContext context,
//     AuthProvider authProvider,
//     bool isDark,
//     bool isMobile,
//     bool isTablet,
//   ) {
//     final textColor = isDark ? Colors.white : Colors.black;
//     final user = authProvider.user;

//     return Column(
//       children: [
//         if (isMobile)
//           profileMobileLayout(authProvider, isDark, isMobile, textColor, user)
//         else
//           profileDesktopLayout(
//             authProvider,
//             isDark,
//             isMobile,
//             isTablet,
//             textColor,
//             user,
//           ),
//       ],
//     );
//   }

//   // Widget profileMobileLayout(
//   //   AuthProvider authProvider,
//   //   bool isDark,
//   //   bool isMobile,
//   //   Color textColor,
//   //   UserModel? user,
//   // ) {
//   //   return Column(
//   //     children: [
//   //       profileAvatar(user, isDark, isMobile ? 80.0 : 100.0, () {}),
//   //       const SizedBox(height: 20),

//   //       profileUserInfo(authProvider, user, textColor, isMobile, true, isDark),
//   //       const SizedBox(height: 24),

//   //       profileActionButton(authProvider, isDark, isMobile),
//   //     ],
//   //   );
//   // }
//   Widget profileMobileLayout(
//     AuthProvider authProvider,
//     bool isDark,
//     bool isMobile,
//     Color textColor,
//     UserModel? user,
//   ) {
//     return Column(
//       children: [
//         profileAvatar(user, isDark, isMobile ? 80.0 : 100.0, () {}),
//         const SizedBox(height: 20),

//         profileUserInfo(authProvider, user, textColor, isMobile, true, isDark),
//         const SizedBox(height: 24),

//         // For mobile, show a simpler layout
//         profileActionButton(authProvider, isDark, isMobile),
//       ],
//     );
//   }

//   Widget profileDesktopLayout(
//     AuthProvider authProvider,
//     bool isDark,
//     bool isMobile,
//     bool isTablet,
//     Color textColor,
//     UserModel? user,
//   ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             profileAvatar(user, isDark, isTablet ? 100.0 : 120.0, () {}),
//             const SizedBox(width: 24),

//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 profileUserInfo(
//                   authProvider,
//                   user,
//                   textColor,
//                   isMobile,
//                   false,
//                   isDark,
//                 ),
//                 const SizedBox(height: 20),

//                 if (authProvider.isLoggedIn && user != null)
//                   profileUserTags(user, isDark, isMobile),
//               ],
//             ),
//           ],
//         ),

//         profileActionButton(authProvider, isDark, isMobile),
//       ],
//     );
//   }

//   Widget profileUserTags(UserModel user, bool isDark, bool isMobile) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: [
//         profileTags('ID: ${user.id.substring(0, 8)}...', isDark, () {
//           Clipboard.setData(ClipboardData(text: user.id));
//           Fluttertoast.showToast(
//             msg: "User ID copied successfully.",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 2,
//             textColor: isDark ? Colors.white : Colors.black,
//             fontSize: 14.0,
//             webPosition: "center",
//             webBgColor:
//                 isDark
//                     ? "linear-gradient(to right, #000000, #000000)"
//                     : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
//           );
//         }),
//         profileTags('🔥 ${user.level}', isDark, () {}),
//       ],
//     );
//   }

//   // Widget profileUserInfo(
//   //   AuthProvider authProvider,
//   //   UserModel? user,
//   //   Color textColor,
//   //   bool isMobile,
//   //   bool isCentered,
//   //   bool isDark,
//   // ) {
//   //   final themeProvider = Provider.of<ThemeProvider>(context);
//   //   final routerProvider = Provider.of<RouterProvider>(context);

//   //   if (!authProvider.isLoggedIn) {
//   //     return Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       crossAxisAlignment:
//   //           isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
//   //       children: [
//   //         Text(
//   //           'Welcome!',
//   //           style: TextStyle(
//   //             fontSize: isMobile ? 20 : 24,
//   //             fontWeight: FontWeight.bold,
//   //             color: textColor,
//   //           ),
//   //           textAlign: isCentered ? TextAlign.center : TextAlign.left,
//   //         ),
//   //         const SizedBox(height: 8),
//   //         Text(
//   //           'Sign in to access your account',
//   //           style: TextStyle(
//   //             fontSize: isMobile ? 14 : 16,
//   //             color: textColor.withOpacity(0.8),
//   //           ),
//   //           textAlign: isCentered ? TextAlign.center : TextAlign.left,
//   //         ),

//   //         // const SizedBox(height: 24),
//   //         // Toggle Buttons

//   //         // const SizedBox(height: 24),
//   //       ],
//   //     );
//   //   }

//   //   return Column(
//   //     crossAxisAlignment:
//   //         isCentered ? CrossAxisAlignment.start : CrossAxisAlignment.start,
//   //     children: [
//   //       CommonTextField(
//   //         controller: TextEditingController(text: user?.fullName ?? ''),
//   //         labelText: 'Full Name',
//   //         hintText: '',
//   //         readOnly: true,
//   //         prefixIcon: Icon(
//   //           Icons.person_outline_rounded,
//   //           color: themeProvider.primaryColor,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),

//   //       CommonTextField(
//   //         controller: TextEditingController(text: user?.username ?? ''),
//   //         labelText: 'Username',
//   //         hintText: '',
//   //         readOnly: true,
//   //         prefixIcon: Icon(
//   //           Icons.alternate_email_rounded,
//   //           color: themeProvider.primaryColor,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),

//   //       CommonTextField(
//   //         controller: TextEditingController(text: user?.email ?? ''),
//   //         labelText: 'Email Address',
//   //         hintText: '',
//   //         readOnly: true,
//   //         prefixIcon: Icon(
//   //           Icons.email_outlined,
//   //           color: themeProvider.primaryColor,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),

//   //       CommonTextField(
//   //         controller: TextEditingController(text: user?.mobileNumber ?? ''),
//   //         labelText: 'Mobile Number',
//   //         hintText: '',
//   //         readOnly: true,
//   //         prefixIcon: Icon(
//   //           Icons.phone_outlined,
//   //           color: themeProvider.primaryColor,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),

//   //       CommonTextField(
//   //         controller: TextEditingController(text: user?.userBio ?? ''),
//   //         labelText: 'Bio',
//   //         hintText: '',
//   //         readOnly: true,
//   //         maxLines: 3,
//   //         prefixIcon: Padding(
//   //           padding: const EdgeInsets.only(bottom: 30),
//   //           child: Icon(
//   //             Icons.info_outline_rounded,
//   //             color: themeProvider.primaryColor,
//   //           ),
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),

//   //       CommonTextField(
//   //         controller: TextEditingController(
//   //           text:
//   //               user?.createdAt != null
//   //                   ? DateFormat('MMM yyyy').format(user!.createdAt!)
//   //                   : '',
//   //         ),
//   //         labelText: 'Joined Date',
//   //         hintText: '',
//   //         readOnly: true,
//   //         prefixIcon: Icon(
//   //           Icons.calendar_today_rounded,
//   //           color: themeProvider.primaryColor,
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   Widget profileUserInfo(
//     AuthProvider authProvider,
//     UserModel? user,
//     Color textColor,
//     bool isMobile,
//     bool isCentered,
//     bool isDark,
//   ) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final routerProvider = Provider.of<RouterProvider>(context, listen: false);

//     if (!authProvider.isLoggedIn || user == null) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment:
//             isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Welcome!',
//             style: TextStyle(
//               fontSize: isMobile ? 20 : 24,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//             textAlign: isCentered ? TextAlign.center : TextAlign.left,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Sign in to access your account',
//             style: TextStyle(
//               fontSize: isMobile ? 14 : 16,
//               color: textColor.withOpacity(0.8),
//             ),
//             textAlign: isCentered ? TextAlign.center : TextAlign.left,
//           ),
//         ],
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Display name with proper null safety
//         // Text(
//         //   "${user.fullName ?? 'No Name'} ${user.username != null && user.username!.isNotEmpty ? '@${user.username}' : ''}",
//         //   style: TextStyle(
//         //     fontSize: isMobile ? 20 : 24,
//         //     fontWeight: FontWeight.bold,
//         //     color: textColor,
//         //   ),
//         // ),

//         // // Display username if available
//         // if (user.username != null && user.username!.isNotEmpty) ...[
//         //   Text(
//         //     '@${user.username}',
//         //     style: TextStyle(
//         //       fontSize: isMobile ? 14 : 16,
//         //       color: themeProvider.primaryColor,
//         //     ),
//         //   ),
//         //   const SizedBox(height: 8),
//         // ],
//         Text.rich(
//           TextSpan(
//             children: [
//               TextSpan(
//                 text: user.fullName ?? 'No Name',
//                 style: TextStyle(
//                   fontSize: isMobile ? 20 : 24,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//               if (user.username != null && user.username!.isNotEmpty) ...[
//                 const TextSpan(text: ' '),
//                 TextSpan(
//                   text: ' (@${user.username}) ',
//                   style: TextStyle(
//                     fontSize: isMobile ? 14 : 16,
//                     fontWeight: FontWeight.normal,
//                     color: themeProvider.primaryColor,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),

//         // Display email with proper null safety
//         Text(
//           user.email ?? 'No email',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             color: textColor.withOpacity(0.7),
//           ),
//         ),
//         const SizedBox(height: 8),

//         // Display bio if available
//         if (user.userBio != null && user.userBio!.isNotEmpty) ...[
//           SizedBox(
//             width: 500,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey[800] : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 user.userBio!,
//                 style: TextStyle(
//                   fontSize: isMobile ? 14 : 15,
//                   color: textColor,
//                 ),
//               ),
//             ),
//           ),
//         ],

//         // Display join date
//         if (user.createdAt != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   size: 14,
//                   color: isDark ? Colors.grey[400] : Colors.grey[600],
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Joined ${DateFormat('MMMM yyyy').format(user.createdAt!)}',
//                   style: TextStyle(
//                     fontSize: isMobile ? 13 : 14,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   // Widget profileActionButton(
//   //   AuthProvider authProvider,
//   //   bool isDark,
//   //   bool isMobile,
//   // ) {
//   //   final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//   //   if (authProvider.isLoggedIn) {
//   //     return SizedBox(
//   //       width: isMobile ? double.infinity : null,
//   //       child: TextButton(
//   //         onPressed: () {
//   //           showEditProfileDialog(context, authProvider);
//   //         },
//   //         style: TextButton.styleFrom(
//   //           backgroundColor: themeProvider.primaryColor,
//   //           padding: EdgeInsets.symmetric(
//   //             horizontal: isMobile ? 16 : 20,
//   //             vertical: isMobile ? 12 : 14,
//   //           ),
//   //         ),
//   //         child: Text(
//   //           'Edit Profile',
//   //           style: TextStyle(
//   //             fontSize: isMobile ? 14 : 16,
//   //             fontWeight: FontWeight.bold,
//   //             color:
//   //                 themeProvider.primaryColor == Colors.amber ||
//   //                         themeProvider.primaryColor == Colors.yellow ||
//   //                         themeProvider.primaryColor == Colors.lime
//   //                     ? Colors.black
//   //                     : Colors.white,
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   } else {
//   //     return Container(
//   //       padding: EdgeInsets.all(12),
//   //       decoration: BoxDecoration(
//   //         borderRadius: BorderRadius.circular(8),
//   //         color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
//   //       ),
//   //       child: Column(
//   //         mainAxisSize: MainAxisSize.max,
//   //         children: [
//   //           Row(
//   //             mainAxisAlignment: MainAxisAlignment.center,
//   //             children: [
//   //               ElevatedButton(
//   //                 onPressed: () {},
//   //                 // authProvider.isLoading
//   //                 //     ? null
//   //                 //     : () {
//   //                 //       authProvider.signInWithGoogle();
//   //                 //     },
//   //                 style: ElevatedButton.styleFrom(
//   //                   backgroundColor: isDark ? Colors.grey[850] : Colors.white,
//   //                   foregroundColor: isDark ? Colors.white : Colors.grey[800],
//   //                   elevation: 2,
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(8),
//   //                     side: BorderSide(
//   //                       color:
//   //                           isDark
//   //                               ? Colors.grey.shade700
//   //                               : Colors.grey.shade300,
//   //                     ),
//   //                   ),
//   //                   padding: EdgeInsets.symmetric(
//   //                     horizontal: isMobile ? 16 : 24,
//   //                     vertical: isMobile ? 14 : 16,
//   //                   ),
//   //                 ),
//   //                 child: Row(
//   //                   mainAxisAlignment: MainAxisAlignment.center,
//   //                   mainAxisSize:
//   //                       isMobile ? MainAxisSize.max : MainAxisSize.min,
//   //                   children: [
//   //                     const Icon(FontAwesomeIcons.google, size: 16),
//   //                     const SizedBox(width: 12),
//   //                     Text(
//   //                       'Login',
//   //                       style: TextStyle(
//   //                         fontSize: isMobile ? 14 : 16,
//   //                         fontWeight: FontWeight.w500,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //               ElevatedButton(
//   //                 onPressed: () {},
//   //                 // authProvider.isLoading
//   //                 //     ? null
//   //                 //     : () {
//   //                 //       authProvider.signInWithGoogle();
//   //                 //     },
//   //                 style: ElevatedButton.styleFrom(
//   //                   backgroundColor: isDark ? Colors.grey[850] : Colors.white,
//   //                   foregroundColor: isDark ? Colors.white : Colors.grey[800],
//   //                   elevation: 2,
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(8),
//   //                     side: BorderSide(
//   //                       color:
//   //                           isDark
//   //                               ? Colors.grey.shade700
//   //                               : Colors.grey.shade300,
//   //                     ),
//   //                   ),
//   //                   padding: EdgeInsets.symmetric(
//   //                     horizontal: isMobile ? 16 : 24,
//   //                     vertical: isMobile ? 14 : 16,
//   //                   ),
//   //                 ),
//   //                 child: Row(
//   //                   mainAxisAlignment: MainAxisAlignment.center,
//   //                   mainAxisSize:
//   //                       isMobile ? MainAxisSize.max : MainAxisSize.min,
//   //                   children: [
//   //                     const Icon(FontAwesomeIcons.google, size: 16),
//   //                     const SizedBox(width: 12),
//   //                     Text(
//   //                       'Register',
//   //                       style: TextStyle(
//   //                         fontSize: isMobile ? 14 : 16,
//   //                         fontWeight: FontWeight.w500,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //           SizedBox(height: 16),
//   //           ElevatedButton(
//   //             onPressed:
//   //                 authProvider.isLoading
//   //                     ? null
//   //                     : () {
//   //                       authProvider.signInWithGoogle();
//   //                     },
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: isDark ? Colors.grey[850] : Colors.white,
//   //               foregroundColor: isDark ? Colors.white : Colors.grey[800],
//   //               elevation: 2,
//   //               shape: RoundedRectangleBorder(
//   //                 borderRadius: BorderRadius.circular(8),
//   //                 side: BorderSide(
//   //                   color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//   //                 ),
//   //               ),
//   //               padding: EdgeInsets.symmetric(
//   //                 horizontal: isMobile ? 16 : 24,
//   //                 vertical: isMobile ? 14 : 16,
//   //               ),
//   //             ),
//   //             child: Row(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
//   //               children: [
//   //                 const Icon(FontAwesomeIcons.google, size: 16),
//   //                 const SizedBox(width: 12),
//   //                 Text(
//   //                   'Continue with Google',
//   //                   style: TextStyle(
//   //                     fontSize: isMobile ? 14 : 16,
//   //                     fontWeight: FontWeight.w500,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   }
//   // }
//   // Widget profileActionButton(
//   //   AuthProvider authProvider,
//   //   bool isDark,
//   //   bool isMobile,
//   // ) {
//   //   final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

//   //   if (authProvider.isLoggedIn) {
//   //     return SizedBox(
//   //       width: isMobile ? double.infinity : null,
//   //       child: TextButton(
//   //         onPressed: () {
//   //           showEditProfileDialog(context, authProvider);
//   //         },
//   //         style: TextButton.styleFrom(
//   //           backgroundColor: themeProvider.primaryColor,
//   //           padding: EdgeInsets.symmetric(
//   //             horizontal: isMobile ? 16 : 20,
//   //             vertical: isMobile ? 12 : 14,
//   //           ),
//   //         ),
//   //         child: Text(
//   //           'Edit Profile',
//   //           style: TextStyle(
//   //             fontSize: isMobile ? 14 : 16,
//   //             fontWeight: FontWeight.bold,
//   //             color:
//   //                 themeProvider.primaryColor == Colors.amber ||
//   //                         themeProvider.primaryColor == Colors.yellow ||
//   //                         themeProvider.primaryColor == Colors.lime
//   //                     ? Colors.black
//   //                     : Colors.white,
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   } else {
//   //     final routerProvider = Provider.of<RouterProvider>(context);

//   //     return Column(
//   //       children: [
//   //         ElevatedButton.icon(
//   //           onPressed:
//   //               authProvider.isLoading
//   //                   ? null
//   //                   : () {
//   //                     authProvider.signInWithGoogle();
//   //                   },

//   //           icon: Icon(FontAwesomeIcons.google, size: 18),
//   //           label: Text(
//   //             'Continue with Google',
//   //             style: TextStyle(fontWeight: FontWeight.bold),
//   //           ),
//   //           style: ElevatedButton.styleFrom(
//   //             backgroundColor: isDark ? Colors.white : Colors.black,
//   //             foregroundColor: isDark ? Colors.black : Colors.white,
//   //             padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//   //             shape: RoundedRectangleBorder(
//   //               borderRadius: BorderRadius.circular(8),
//   //             ),
//   //             elevation: 0,
//   //           ),
//   //         ),
//   //         SizedBox(height: 16),
//   //         Container(
//   //           width: isMobile ? double.infinity : 400,
//   //           decoration: BoxDecoration(
//   //             color: isDark ? Colors.grey[800] : Colors.grey[200],
//   //             borderRadius: BorderRadius.circular(12),
//   //           ),
//   //           padding: EdgeInsets.all(4),
//   //           child: Row(
//   //             children: [
//   //               Expanded(
//   //                 child: _buildAuthTabButton(
//   //                   title: 'Login',
//   //                   isSelected: routerProvider.authViewMode == 'login',
//   //                   onTap: () => routerProvider.setAuthViewMode('login'),
//   //                   isDark: isDark,
//   //                 ),
//   //               ),
//   //               Expanded(
//   //                 child: _buildAuthTabButton(
//   //                   title: 'Register',
//   //                   isSelected: routerProvider.authViewMode == 'register',
//   //                   onTap: () => routerProvider.setAuthViewMode('register'),
//   //                   isDark: isDark,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     );
//   //   }
//   // }
//   Widget profileActionButton(
//     AuthProvider authProvider,
//     bool isDark,
//     bool isMobile,
//   ) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

//     if (authProvider.isLoggedIn) {
//       return SizedBox(
//         width: isMobile ? double.infinity : 200,
//         child: ElevatedButton.icon(
//           onPressed: () => showEditProfileDialog(context, authProvider),
//           icon: const Icon(Icons.edit, size: 18),
//           label: const Text('Edit Profile'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: themeProvider.primaryColor,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//       );
//     } else {
//       // return Column(
//       //   children: [
//       //     SizedBox(
//       //       width: isMobile ? double.infinity : 300,
//       //       child: ElevatedButton.icon(
//       //         onPressed:
//       //             authProvider.isLoading
//       //                 ? null
//       //                 : () => authProvider.signInWithGoogle(),
//       //         icon: const Icon(FontAwesomeIcons.google),
//       //         label: const Text('Continue with Google'),
//       //         style: ElevatedButton.styleFrom(
//       //           backgroundColor: isDark ? Colors.white : Colors.black,
//       //           foregroundColor: isDark ? Colors.black : Colors.white,
//       //           padding: const EdgeInsets.symmetric(vertical: 16),
//       //           shape: RoundedRectangleBorder(
//       //             borderRadius: BorderRadius.circular(8),
//       //           ),
//       //         ),
//       //       ),
//       //     ),
//       //   ],
//       // );
//       final routerProvider = Provider.of<RouterProvider>(context);

//       return Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: themeProvider.primaryColor.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: themeProvider.primaryColor.withOpacity(0.1),
//           ),
//         ),
//         child: Column(
//           children: [
//             ElevatedButton.icon(
//               onPressed:
//                   authProvider.isLoading
//                       ? null
//                       : () {
//                         authProvider.signInWithGoogle();
//                       },

//               icon: Icon(FontAwesomeIcons.google, size: 18),
//               label: Text(
//                 'Continue with Google',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isDark ? Colors.white : Colors.black,
//                 foregroundColor: isDark ? Colors.black : Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 elevation: 0,
//               ),
//             ),
//             // SizedBox(height: 16),
//             // Container(
//             //   width: isMobile ? double.infinity : 400,
//             //   decoration: BoxDecoration(
//             //     color: isDark ? Colors.grey[800] : Colors.grey[200],
//             //     borderRadius: BorderRadius.circular(12),
//             //   ),
//             //   padding: EdgeInsets.all(4),
//             //   child: Row(
//             //     children: [
//             //       Expanded(
//             //         child: _buildAuthTabButton(
//             //           title: 'Login',
//             //           isSelected: routerProvider.authViewMode == 'login',
//             //           onTap: () => routerProvider.setAuthViewMode('login'),
//             //           isDark: isDark,
//             //           themeProvider: themeProvider,
//             //           isLeft: true,
//             //         ),
//             //       ),
//             //       Expanded(
//             //         child: _buildAuthTabButton(
//             //           title: 'Register',
//             //           isSelected: routerProvider.authViewMode == 'register',
//             //           onTap: () => routerProvider.setAuthViewMode('register'),
//             //           isDark: isDark,
//             //           themeProvider: themeProvider,
//             //           isLeft: false,
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget profileDangerZone(
//     BuildContext context,
//     AuthProvider authProvider,
//     bool isDark,
//     bool isMobile,
//     bool isTablet,
//   ) {
//     final textColor = isDark ? Colors.white : Colors.black;

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 20 : 32,
//         vertical: isMobile ? 16 : 20,
//       ),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey[850] : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.redAccent,
//                 size: isMobile ? 20 : 24,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Danger Zone',
//                 style: TextStyle(
//                   fontSize: isMobile ? 18 : 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.redAccent,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 16 : 24,
//               vertical: isMobile ? 16 : 20,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Sign Out',
//                         style: TextStyle(
//                           fontSize: isMobile ? 16 : 18,
//                           fontWeight: FontWeight.w600,
//                           color: textColor,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'Sign out from your account',
//                         style: TextStyle(
//                           fontSize: isMobile ? 14 : 15,
//                           color: isDark ? Colors.grey[400] : Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 TextButton(
//                   onPressed: () {
//                     CustomDialog.showSignOutDialog(
//                       context: context,
//                       onConfirm: () async {
//                         await authProvider.signOut();
//                         await Future.delayed(Duration(milliseconds: 500));
//                         if (kIsWeb) {
//                           html.window.location.assign(
//                             html.window.location.href,
//                           );
//                         } else {
//                           Restart.restartApp();
//                         }
//                       },
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                   child: Text(
//                     'Sign Out',
//                     style: TextStyle(
//                       fontSize: isMobile ? 14 : 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget profileTags(String text, bool isDark, void Function()? onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color:
//               isDark
//                   ? Colors.white.withOpacity(0.1)
//                   : Colors.black.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: isDark ? Colors.white : Colors.black,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   void showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
//     final user = authProvider.user;
//     final nameController = TextEditingController(text: user?.fullName ?? '');

//     showDialog(
//       context: context,
//       builder: (context) {
//         final themeProvider = Provider.of<ThemeProvider>(context);
//         final isDark = themeProvider.isDarkMode;
//         return AlertDialog(
//           backgroundColor: isDark ? Colors.grey[900] : Colors.white,
//           title: Text(
//             'Edit Profile',
//             style: TextStyle(color: isDark ? Colors.white : Colors.black),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   labelStyle: TextStyle(
//                     color: isDark ? Colors.grey[400] : Colors.grey,
//                   ),
//                   border: const OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: isDark ? Colors.amberAccent : Colors.blueAccent,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: isDark ? Colors.grey[400] : Colors.grey[800],
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (nameController.text.trim().isNotEmpty) {
//                   authProvider.updateProfile(
//                     fullName: nameController.text.trim(),
//                   );
//                 }
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isDark ? Colors.amberAccent.shade400 : Colors.amber,
//               ),
//               child: const Text('Save', style: TextStyle(color: Colors.black)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget profileStatsSection(
//     UserModel user,
//     bool isDark,
//     bool isMobile,
//     bool isTablet,
//   ) {
//     final cardColor = isDark ? Colors.grey[850] : Colors.white;
//     final borderColor =
//         isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);
//     final typingProvider = Provider.of<TypingProvider>(context, listen: false);

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 20 : 32,
//         vertical: isMobile ? 16 : 20,
//       ),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 'Statistics',
//                 style: TextStyle(
//                   fontSize: isMobile ? 18 : 20,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 18),
//           Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             children: [
//               CustomStatsCard(
//                 width: 200,
//                 title: 'Total Tests',
//                 value: '${user.totalTests}',
//                 unit: '',
//                 color: Colors.grey,
//                 icon: Icons.assignment,
//                 isDarkMode: isDark,
//                 isProfile: true,
//               ),
//               CustomStatsCard(
//                 width: 200,
//                 title: 'Average WPM',
//                 value: '${user.averageWpm.round()}',
//                 unit: '',
//                 color: Colors.grey,
//                 icon: Icons.speed,
//                 isDarkMode: isDark,
//                 isProfile: true,
//               ),
//               CustomStatsCard(
//                 width: 200,
//                 title: 'Total Words',
//                 value: '${user.totalWords}',
//                 unit: '',
//                 color: Colors.grey,
//                 icon: Icons.text_fields,
//                 isDarkMode: isDark,
//                 isProfile: true,
//               ),

//               CustomStatsCard(
//                 width: 200,
//                 title: 'Accuracy',
//                 value: '${typingProvider.averageAccuracy.round()}%',
//                 unit: '',
//                 color: Colors.grey,
//                 icon: Icons.flag,
//                 isDarkMode: isDark,
//                 isProfile: true,
//               ),
//               CustomStatsCard(
//                 width: 200,
//                 title: 'Current Streak',
//                 value: '${user.currentStreak} days',
//                 unit: '',
//                 color: Colors.grey,
//                 icon: Icons.local_fire_department,
//                 isDarkMode: isDark,
//                 isProfile: true,
//               ),
//               CustomStatsCard(
//                 width: 200,
//                 title: 'Longest Streak',
//                 value: '${user.longestStreak} days',
//                 unit: '',
//                 color: Colors.grey,
//                 icon: Icons.emoji_events,
//                 isDarkMode: isDark,
//                 isProfile: true,
//               ),
//             ],
//           ),
//           SizedBox(height: 24),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(isMobile ? 12 : 16),
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey[900] : Colors.grey.withOpacity(0.03),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Typing Activity',
//                       style: TextStyle(
//                         fontSize: isMobile ? 16 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             Icons.chevron_left,
//                             size: isMobile ? 18 : 20,
//                           ),
//                           onPressed:
//                               availableYears.contains(currentHeatmapYear - 1)
//                                   ? () =>
//                                       changeHeatmapYear(currentHeatmapYear - 1)
//                                   : null,
//                           padding: EdgeInsets.zero,
//                           constraints: BoxConstraints(minWidth: 36),
//                         ),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isMobile ? 10 : 12,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isDark ? Colors.grey[700] : Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             '$currentHeatmapYear',
//                             style: TextStyle(
//                               fontSize: isMobile ? 12 : 14,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             Icons.chevron_right,
//                             size: isMobile ? 18 : 20,
//                           ),
//                           onPressed:
//                               availableYears.contains(currentHeatmapYear + 1)
//                                   ? () =>
//                                       changeHeatmapYear(currentHeatmapYear + 1)
//                                   : null,
//                           padding: EdgeInsets.zero,
//                           constraints: BoxConstraints(minWidth: 36),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: isMobile ? 12 : 20),

//                 customHeatmap(isDark, isMobile, isTablet),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       'Less',
//                       style: TextStyle(
//                         fontSize: isMobile ? 9 : 10,
//                         color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     profileColorIndicator(0, isDark),
//                     SizedBox(width: 2),
//                     profileColorIndicator(1, isDark),
//                     SizedBox(width: 2),
//                     profileColorIndicator(2, isDark),
//                     SizedBox(width: 2),
//                     profileColorIndicator(3, isDark),
//                     SizedBox(width: 2),
//                     profileColorIndicator(4, isDark),
//                     SizedBox(width: 8),
//                     Text(
//                       'More',
//                       style: TextStyle(
//                         fontSize: isMobile ? 9 : 10,
//                         color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget customHeatmapBoxes(
//     int weekIndex,
//     int dayIndex,
//     bool isDark,
//     double squareSize,
//   ) {
//     final date = heatmapWeeks[weekIndex][dayIndex];

//     if (date == null || date.year != currentHeatmapYear) {
//       return SizedBox(width: squareSize, height: squareSize);
//     }

//     final normalizedDate = DateTime(date.year, date.month, date.day);

//     final activityEntry = activityData.entries.firstWhere(
//       (entry) =>
//           entry.key.year == normalizedDate.year &&
//           entry.key.month == normalizedDate.month &&
//           entry.key.day == normalizedDate.day,
//       orElse: () => MapEntry(normalizedDate, 0),
//     );

//     final testCount = activityEntry.value;

//     int activityLevel = getActivityLevel(testCount);

//     final color = getActivityColor(activityLevel, isDark);

//     return Container(
//       width: squareSize,
//       height: squareSize,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(2),
//       ),
//       child: Tooltip(
//         message:
//             testCount > 0
//                 ? '${DateFormat('MMM dd, yyyy').format(date)}\n$testCount typing test${testCount == 1 ? '' : 's'}'
//                 : '${DateFormat('MMM dd, yyyy').format(date)}\nNo tests',
//         textStyle: TextStyle(
//           fontSize: 12,
//           color: isDark ? Colors.white : Colors.black,
//         ),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey[800]! : Colors.white,
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(
//             color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
//           ),
//         ),
//         child: MouseRegion(
//           cursor: SystemMouseCursors.click,
//           child: Container(),
//         ),
//       ),
//     );
//   }

//   int getActivityLevel(int testCount) {
//     if (testCount == 0) return 0;
//     if (testCount <= 2) return 1;
//     if (testCount <= 5) return 2;
//     if (testCount <= 10) return 3;
//     return 4;
//   }

//   TextStyle dayLabelStyle(bool isDark) {
//     return TextStyle(
//       fontSize: 12,
//       color: isDark ? Colors.grey[400] : Colors.grey[600],
//       fontWeight: FontWeight.w500,
//     );
//   }

//   Widget profileColorIndicator(int intensity, bool isDark) {
//     return Container(
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(
//         color: getActivityColor(intensity, isDark),
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }

//   Widget heatmapShimmer(bool isDark, bool isMobile, bool isTablet) {
//     final double squareSize = isMobile ? 10 : 12;
//     final double spacing = isMobile ? 1.5 : 2;
//     final double containerHeight = isMobile ? 110 : 130;
//     final double weekWidth = squareSize + spacing * 2;
//     final double dayLabelWidth = 30;

//     return Shimmer.fromColors(
//       baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
//       highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: IntrinsicWidth(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 height: 20,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(width: dayLabelWidth),
//                     Container(
//                       width: heatmapWeeks.length * weekWidth,
//                       height: 15,
//                       color: Colors.white,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 4),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(
//                     width: dayLabelWidth,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: squareSize * 0.3 + spacing),
//                         Container(width: 25, height: 12, color: Colors.white),
//                         SizedBox(height: squareSize * 1.4 + spacing),
//                         Container(width: 25, height: 12, color: Colors.white),
//                         SizedBox(height: squareSize * 1.4 + spacing),
//                         Container(width: 25, height: 12, color: Colors.white),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   SizedBox(
//                     height: containerHeight,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: List.generate(heatmapWeeks.length, (weekIndex) {
//                         return Container(
//                           margin: EdgeInsets.symmetric(horizontal: spacing),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: List.generate(7, (dayIndex) {
//                               return Container(
//                                 margin: EdgeInsets.symmetric(vertical: spacing),
//                                 width: squareSize,
//                                 height: squareSize,
//                                 color: Colors.white,
//                               );
//                             }),
//                           ),
//                         );
//                       }),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shimmer/shimmer.dart';
import 'package:typing_speed_master/features/profile/widget/profile_login_widget.dart';
import 'package:typing_speed_master/features/profile/widget/profile_register_widget.dart';
import 'package:typing_speed_master/models/user_activity_month_label_model.dart';
import 'package:typing_speed_master/models/user_model.dart';
import 'package:typing_speed_master/features/profile/provider/user_activity_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/typing_test/provider/typing_test_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/features/profile/widget/profile_placeholder_avatar.dart';
import 'package:typing_speed_master/widgets/custom_stats_card.dart';
import '../../providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:typing_speed_master/providers/router_provider.dart';
import 'package:typing_speed_master/widgets/custom_textformfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  bool isFirstLoad = true;
  bool isRefreshing = false;
  List<List<DateTime?>> heatmapWeeks = [];
  int currentHeatmapYear = DateTime.now().year;
  Map<DateTime, int> activityData = {};
  List<UserActivityMonthLabelModel> monthLabels = [];
  String? profileImageUrl;
  List<int> availableYears = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  // Tab management - short words only
  String _selectedProfileTab = 'Overview'; // 'Overview' or 'Settings'

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    loadProfileData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        generateHeatmapData();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeProfile();
      }
    });
    nameController.addListener(() {
      setState(() {});
    });
    emailController.addListener(() {
      setState(() {});
    });
    userNameController.addListener(() {
      setState(() {});
    });
    mobileNoController.addListener(() {
      setState(() {});
    });
    bioController.addListener(() {
      setState(() {});
    });
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
        generateHeatmapData();
        _populateUserData(authProvider.user);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshProfileData();
    }
  }

  Future<void> _initializeProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await authProvider.fetchUserProfile(authProvider.user!.id);
      generateHeatmapData();

      // Populate text controllers with user data
      _populateUserData(authProvider.user);
    }
    if (mounted) {
      setState(() {
        isFirstLoad = false;
      });
    }
  }

  void _populateUserData(UserModel? user) {
    if (user == null) return;

    nameController.text = user.fullName ?? '';
    emailController.text = user.email;
    userNameController.text = user.username ?? '';
    mobileNoController.text = user.mobileNumber ?? '';
    bioController.text = user.userBio ?? '';
  }

  Future<void> _saveAccountSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkTheme = themeProvider.isDarkMode;

    if (!authProvider.isLoggedIn || authProvider.user == null) {
      Fluttertoast.showToast(
        msg: "Please login to update your profile",
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
      return;
    }

    try {
      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        Fluttertoast.showToast(
          msg: "Full name cannot be empty",
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
        return;
      }

      // Update profile (username and email are read-only, so we don't update them)
      await authProvider.updateProfile(
        fullName: nameController.text.trim(),
        mobile: mobileNoController.text.trim(),
        bio: bioController.text.trim(),
      );

      // Refresh profile data
      await authProvider.fetchUserProfile(authProvider.user!.id);
      _populateUserData(authProvider.user);

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Profile updated successfully!",
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
      }
    } catch (e) {
      debugPrint('Error saving account settings: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Failed to update profile: ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: isDarkTheme ? Colors.white : Colors.black,
          fontSize: 14.0,
          webPosition: "center",
          webBgColor:
              isDarkTheme
                  ? "linear-gradient(to right, #FF0000, #FF0000)"
                  : "linear-gradient(to right, #FF0000, #FF0000)",
        );
      }
    }
  }

  Future<void> loadProfileData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await authProvider.fetchUserProfile(authProvider.user!.id);
      _populateUserData(authProvider.user);
    }
    if (mounted) {
      setState(() {
        isFirstLoad = false;
      });
    }
  }

  Future<void> refreshProfileData() async {
    if (!mounted || isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.user != null) {
        await authProvider.fetchUserProfile(authProvider.user!.id);
        if (mounted) {
          generateHeatmapData();
          _populateUserData(authProvider.user);
        }
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  void generateHeatmapData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<UserActivityProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      try {
        await activityProvider.fetchActivityData(
          authProvider.user!.id,
          currentHeatmapYear,
        );
        await activityProvider.forceRefreshActivity(
          authProvider.user!.id,
          currentHeatmapYear,
        );

        final userCreatedYear =
            authProvider.user!.createdAt?.year ?? DateTime.now().year;
        final currentYear = DateTime.now().year;

        availableYears = List.generate(
          currentYear - userCreatedYear + 1,
          (index) => userCreatedYear + index,
        );

        if (mounted) {
          setState(() {
            activityData = Map.from(activityProvider.activityData);
            generateHeatmapWeeks();
            calculateMonthLabels();
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            activityData = {};
            generateHeatmapWeeks();
            calculateMonthLabels();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          activityData = {};
          generateHeatmapWeeks();
          calculateMonthLabels();
        });
      }
    }
  }

  void generateHeatmapWeeks() {
    heatmapWeeks = [];

    DateTime currentDate = DateTime(currentHeatmapYear, 1, 1);

    while (currentDate.weekday != DateTime.monday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    for (int week = 0; week < 53; week++) {
      List<DateTime?> weekDays = [];

      for (int day = 0; day < 7; day++) {
        final date = currentDate.add(Duration(days: (week * 7) + day));
        weekDays.add(date);
      }

      heatmapWeeks.add(weekDays);
    }
  }

  void calculateMonthLabels() {
    monthLabels = [];

    Map<int, List<int>> monthWeeks = {};

    for (int weekIndex = 0; weekIndex < heatmapWeeks.length; weekIndex++) {
      final week = heatmapWeeks[weekIndex];

      final monthCount = <int, int>{};
      for (final date in week) {
        if (date != null && date.year == currentHeatmapYear) {
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
        final monthName = getMonthAbbreviation(month);
        monthLabels.add(
          UserActivityMonthLabelModel(monthName, startWeek, weekCount),
        );
      }
    }
  }

  String getMonthAbbreviation(int month) {
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

  Widget customHeatmap(bool isDark, bool isMobile, bool isTablet) {
    final double squareSize = isMobile ? 10 : 12;
    final double spacing = isMobile ? 1.5 : 2;
    final double containerHeight = isMobile ? 110 : 130;
    final double weekWidth = squareSize + spacing * 2;
    final double dayLabelWidth = 30;

    final bool shouldScroll = isMobile || isTablet;

    Widget heatmapContent = customHeatmapContent(
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

  Widget customHeatmapContent(
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
                    width: heatmapWeeks.length * weekWidth,
                    child: Stack(
                      children:
                          monthLabels.map((monthLabel) {
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
                      Text('Mon', style: dayLabelStyle(isDark)),
                      SizedBox(height: squareSize * 1.4 + spacing),
                      Text('Wed', style: dayLabelStyle(isDark)),
                      SizedBox(height: squareSize * 1.4 + spacing),
                      Text('Fri', style: dayLabelStyle(isDark)),
                    ],
                  ),
                ),
                SizedBox(width: 8),

                SizedBox(
                  height: containerHeight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(heatmapWeeks.length, (weekIndex) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: spacing),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(7, (dayIndex) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: spacing),
                              child: customHeatmapBoxes(
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

  Color getActivityColor(int level, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    switch (level) {
      case 0:
        return isDark ? Colors.white12 : Colors.black12.withOpacity(0.07);
      case 1:
        return themeProvider.primaryColor.shade100;
      case 2:
        return themeProvider.primaryColor.shade300;
      case 3:
        return themeProvider.primaryColor.shade500;
      case 4:
        return themeProvider.primaryColor.shade700;
      default:
        return isDark ? Colors.white12 : Colors.black12.withOpacity(0.07);
    }
  }

  void changeHeatmapYear(int year) {
    if (availableYears.contains(year)) {
      currentHeatmapYear = year;
      generateHeatmapData();
    }
  }

  Future<void> updateProfilePicture() async {
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
        setState(() {
          profileImageUrl = newImageDataUrl;
        });

        await uploadProfilePictureToServer(newImageDataUrl);

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

        setState(() {
          profileImageUrl = null;
        });
      }
    }
  }

  Future<void> uploadProfilePictureToServer(String imageDataUrl) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user != null) {
      await authProvider.updateProfile(avatarUrl: imageDataUrl);
      await authProvider.fetchUserProfile(authProvider.user!.id);
    }
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
      onTap: updateProfilePicture,
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading && !authProvider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [_buildProfileUI(context, authProvider, isDark)],
          ),
        );
      },
    );
  }

  Widget _buildProfileUI(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
  ) {
    final user = authProvider.user;

    if (authProvider.isLoading && isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show guest profile if not logged in
    if (!authProvider.isLoggedIn || user == null) {
      return profileUI(
        context,
        authProvider,
        isDark,
        UserModel(
          id: 'Guest',
          email: '',
          fullName: "Guest User",
          avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=guest",
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          totalTests: 0,
          totalWords: 0,
          averageWpm: 0.0,
          averageAccuracy: 0.0,
        ),
      );
    }

    return profileUI(context, authProvider, isDark, user);
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
        final routerProvider = Provider.of<RouterProvider>(context);

        return RefreshIndicator(
          onRefresh: () async {
            await refreshProfileData();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER - at top, before tabs
                profileHeader(context, isMobile, isTablet),
                const SizedBox(height: 40),

                authProvider.isLoggedIn
                    ? _buildProfileTabs(isDark, themeProvider, isMobile)
                    : SizedBox.shrink(),
                SizedBox(height: authProvider.isLoggedIn ? 28 : 0),

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

                const SizedBox(height: 28),

                // TAB CONTENT
                if (authProvider.isLoggedIn) ...[
                  if (_selectedProfileTab == 'Overview') ...[
                    profileStatsSection(user, isDark, isMobile, isTablet),
                    // _buildThemePreferencesSection(
                    //   isDark,
                    //   isMobile,
                    //   themeProvider,
                    // ),
                    // const SizedBox(height: 32),
                    // profileDangerZone(
                    //   context,
                    //   authProvider,
                    //   isDark,
                    //   isMobile,
                    //   isTablet,
                    // ),
                  ] else if (_selectedProfileTab == 'Settings') ...[
                    // SETTINGS TAB - Only ONE container for edit profile
                    // User will add their own UI design here
                    _buildSettingsContainer(
                      isDark,
                      isMobile,
                      themeProvider,
                      authProvider,
                      user,
                    ),
                    const SizedBox(height: 32),
                    _buildThemePreferencesSection(
                      isDark,
                      isMobile,
                      themeProvider,
                    ),
                    const SizedBox(height: 32),
                    profileDangerZone(
                      context,
                      authProvider,
                      isDark,
                      isMobile,
                      isTablet,
                    ),
                  ],
                ],

                // NON-LOGGED IN STATE
                if (!authProvider.isLoggedIn) ...[
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(endIndent: 50)),
                      Text("OR", style: TextStyle(fontSize: 16)),
                      Expanded(child: Divider(indent: 50)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildAuthTabs(
                    isDark,
                    themeProvider,
                    routerProvider,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildAuthSection(
                    context,
                    isMobile,
                    isDark,
                    routerProvider,
                    authProvider,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Profile Tabs Widget - short words only
  Widget _buildProfileTabs(
    bool isDark,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildProfileTabButton(
              title: 'Overview', // Short word
              isSelected: _selectedProfileTab == 'Overview',
              onTap: () {
                setState(() {
                  _selectedProfileTab = 'Overview';
                });
              },
              isDark: isDark,
              themeProvider: themeProvider,
              isLeft: true,
            ),
          ),
          Expanded(
            child: _buildProfileTabButton(
              title: 'Settings', // Short word
              isSelected: _selectedProfileTab == 'Settings',
              onTap: () {
                setState(() {
                  _selectedProfileTab = 'Settings';
                });
              },
              isDark: isDark,
              themeProvider: themeProvider,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTabButton({
    required String title,
    required bool isSelected,
    required bool isLeft,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // color: isSelected ? themeProvider.primaryColor : Colors.transparent,
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(isLeft ? 4 : 0),
          //   bottomLeft: Radius.circular(isLeft ? 4 : 0),
          //   topRight: Radius.circular(isLeft ? 0 : 4),
          //   bottomRight: Radius.circular(isLeft ? 0 : 4),
          // ),
          border: Border(
            right:
                isLeft
                    ? BorderSide(
                      color:
                          isSelected
                              ? isDark
                                  ? Colors.white
                                  : Colors.black
                              : isDark
                              ? Colors.white
                              : Colors.black,
                      width: 0.3,
                    )
                    : BorderSide.none,
            left:
                !isLeft
                    ? BorderSide(
                      color:
                          isSelected
                              ? isDark
                                  ? Colors.white
                                  : Colors.black
                              : isDark
                              ? Colors.white
                              : Colors.black,
                      width: 0.3,
                    )
                    : BorderSide.none,
          ),

          // boxShadow:
          //     isSelected
          //         ? [
          //           BoxShadow(
          //             color: themeProvider.primaryColor.withOpacity(0.3),
          //             blurRadius: 8,
          //             offset: Offset(0, 2),
          //           ),
          //         ]
          //         : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color:
                isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  // SETTINGS CONTAINER - Only ONE container for user to add their own UI design
  Widget _buildSettingsContainer(
    bool isDark,
    bool isMobile,
    ThemeProvider themeProvider,
    AuthProvider authProvider,
    UserModel user,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
        ),
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
          // Settings Header
          Row(
            children: [
              Icon(
                Icons.person,
                color: themeProvider.primaryColor,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _saveAccountSettings,
                child: Text(
                  "Save Changes",
                  style: TextStyle(
                    color:
                        themeProvider.primaryColor == Colors.amber ||
                                themeProvider.primaryColor == Colors.yellow ||
                                themeProvider.primaryColor == Colors.lime
                            ? Colors.black
                            : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // EMPTY CONTAINER - User will add their own UI design here
          Row(
            children: [
              Expanded(
                child: CommonTextField(
                  controller: nameController,
                  labelText: "Full Name",
                  hintText: "Enter your name",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CommonTextField(
                  controller: userNameController,
                  labelText: "User Name",
                  hintText: "Enter your name",
                  readOnly: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CommonTextField(
                  controller: emailController,
                  labelText: "Email",
                  hintText: "Enter your name",
                  readOnly: true,
                ),
              ),
              SizedBox(width: 12),

              Expanded(
                child: CommonTextField(
                  controller: mobileNoController,
                  labelText: "Mobile Number",
                  hintText: "Enter your mobile number",
                  readOnly: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          CommonTextField(
            controller: bioController,
            labelText: "Bio",
            hintText: "Enter your bio",
            maxLines: 4,
            readOnly: false,
          ),
        ],
      ),
    );
  }

  // Theme Preferences Section
  Widget _buildThemePreferencesSection(
    bool isDark,
    bool isMobile,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
        ),
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
                isSelected: themeProvider.currentColorName == 'red',
                onTap: () => themeProvider.setPrimaryColor('red'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.pink,
                colorName: 'pink',
                isSelected: themeProvider.currentColorName == 'pink',
                onTap: () => themeProvider.setPrimaryColor('pink'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.purple,
                colorName: 'purple',
                isSelected: themeProvider.currentColorName == 'purple',
                onTap: () => themeProvider.setPrimaryColor('purple'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.deepPurple,
                colorName: 'deepPurple',
                isSelected: themeProvider.currentColorName == 'deepPurple',
                onTap: () => themeProvider.setPrimaryColor('deepPurple'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.indigo,
                colorName: 'indigo',
                isSelected: themeProvider.currentColorName == 'indigo',
                onTap: () => themeProvider.setPrimaryColor('indigo'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.blue,
                colorName: 'blue',
                isSelected: themeProvider.currentColorName == 'blue',
                onTap: () => themeProvider.setPrimaryColor('blue'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.lightBlue,
                colorName: 'lightBlue',
                isSelected: themeProvider.currentColorName == 'lightBlue',
                onTap: () => themeProvider.setPrimaryColor('lightBlue'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.cyan,
                colorName: 'cyan',
                isSelected: themeProvider.currentColorName == 'cyan',
                onTap: () => themeProvider.setPrimaryColor('cyan'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.teal,
                colorName: 'teal',
                isSelected: themeProvider.currentColorName == 'teal',
                onTap: () => themeProvider.setPrimaryColor('teal'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.green,
                colorName: 'green',
                isSelected: themeProvider.currentColorName == 'green',
                onTap: () => themeProvider.setPrimaryColor('green'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.lightGreen,
                colorName: 'lightGreen',
                isSelected: themeProvider.currentColorName == 'lightGreen',
                onTap: () => themeProvider.setPrimaryColor('lightGreen'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.lime,
                colorName: 'lime',
                isSelected: themeProvider.currentColorName == 'lime',
                onTap: () => themeProvider.setPrimaryColor('lime'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.yellow,
                colorName: 'yellow',
                isSelected: themeProvider.currentColorName == 'yellow',
                onTap: () => themeProvider.setPrimaryColor('yellow'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.amber,
                colorName: 'amber',
                isSelected: themeProvider.currentColorName == 'amber',
                onTap: () => themeProvider.setPrimaryColor('amber'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.orange,
                colorName: 'orange',
                isSelected: themeProvider.currentColorName == 'orange',
                onTap: () => themeProvider.setPrimaryColor('orange'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.deepOrange,
                colorName: 'deepOrange',
                isSelected: themeProvider.currentColorName == 'deepOrange',
                onTap: () => themeProvider.setPrimaryColor('deepOrange'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.brown,
                colorName: 'brown',
                isSelected: themeProvider.currentColorName == 'brown',
                onTap: () => themeProvider.setPrimaryColor('brown'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.grey,
                colorName: 'grey',
                isSelected: themeProvider.currentColorName == 'grey',
                onTap: () => themeProvider.setPrimaryColor('grey'),
                isDark: isDark,
              ),
              themePreferenceColorOption(
                color: Colors.blueGrey,
                colorName: 'blueGrey',
                isSelected: themeProvider.currentColorName == 'blueGrey',
                onTap: () => themeProvider.setPrimaryColor('blueGrey'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthTabs(
    bool isDark,
    ThemeProvider themeProvider,
    RouterProvider routerProvider,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : 400,
      decoration: BoxDecoration(
        // color: isDark ? Colors.grey[800] : Colors.grey[200],
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildAuthTabButton(
              title: 'Login',
              isSelected: routerProvider.authViewMode == 'login',
              onTap: () => routerProvider.setAuthViewMode('login'),
              isDark: isDark,
              themeProvider: themeProvider,
              isLeft: true,
            ),
          ),
          Expanded(
            child: _buildAuthTabButton(
              title: 'Register',
              isSelected: routerProvider.authViewMode == 'register',
              onTap: () => routerProvider.setAuthViewMode('register'),
              isDark: isDark,
              themeProvider: themeProvider,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection(
    BuildContext context,
    bool isMobile,
    bool isDark,
    RouterProvider routerProvider,
    AuthProvider authProvider,
  ) {
    return Column(
      children: [
        SizedBox(height: 24),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child:
              routerProvider.authViewMode == 'login'
                  ? ProfileLoginWidget(key: ValueKey('login'))
                  : ProfileRegisterWidget(key: ValueKey('register')),
        ),
      ],
    );
  }

  Widget _buildAuthTabButton({
    required String title,
    required bool isSelected,
    required bool isLeft,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? themeProvider.primaryColor.withOpacity(0.5)
                  : Colors.black12,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 8 : 0),
            bottomLeft: Radius.circular(isLeft ? 8 : 0),
            topRight: Radius.circular(isLeft ? 0 : 8),
            bottomRight: Radius.circular(isLeft ? 0 : 8),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
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

      child: Tooltip(
        message: colorName,
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
        profileAvatar(
          user,
          isDark,
          isMobile ? 80.0 : 100.0,
          updateProfilePicture,
        ),
        const SizedBox(height: 20),

        profileUserInfo(authProvider, user, textColor, isMobile, true, isDark),

        if (authProvider.isLoggedIn && user != null) ...[
          const SizedBox(height: 20),
          profileUserTags(user, isDark, isMobile),
        ],

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
    if (!authProvider.isLoggedIn || user == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              profileAvatar(user, isDark, isMobile ? 80.0 : 100.0, () {}),
              SizedBox(width: 16),
              profileUserInfo(
                authProvider,
                user,
                textColor,
                isMobile,
                false,
                isDark,
              ),
            ],
          ),
          Spacer(),
          profileActionButton(authProvider, isDark, isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  profileAvatar(
                    user,
                    isDark,
                    isTablet ? 100.0 : 120.0,
                    updateProfilePicture,
                  ),
                  const SizedBox(width: 24),
                  profileUserInfo(
                    authProvider,
                    user,
                    textColor,
                    isMobile,
                    false,
                    isDark,
                    showFullInfo: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (user.userBio != null && user.userBio!.isNotEmpty)
                _buildBioSection(user.userBio!, isDark, isMobile, textColor),
              // if (user.createdAt != null)
              //   _buildJoinedDateBadge(user.createdAt!, isDark),
              // const SizedBox(height: 12),
              // profileUserTags(user, isDark, isMobile),
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
      runSpacing: 0,
      children: [
        profileTags('ID: ${user.id.substring(0, 16)}...', isDark, () {
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

  Widget profileUserInfo(
    AuthProvider authProvider,
    UserModel? user,
    Color textColor,
    bool isMobile,
    bool isCentered,
    bool isDark, {
    bool showFullInfo = true,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!authProvider.isLoggedIn || user == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your account and save your progress',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: textColor.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Name and Username
        Row(
          crossAxisAlignment:
              isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.end,
          children: [
            Text(
              user.fullName ?? 'No Name',
              style: TextStyle(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.8,
              ),
            ),
            if (user.username != null && user.username!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.primaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Contact Info Row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildInfoItem(
              Icons.alternate_email_rounded,
              user.email,
              textColor,
              isDark,
            ),
            if (user.createdAt != null)
              _buildJoinedDateBadge(user.createdAt!, isDark),
            // if (user.mobileNumber != null && user.mobileNumber!.isNotEmpty)
            //   _buildInfoItem(
            //     Icons.phone_iphone_rounded,
            //     user.mobileNumber!,
            //     textColor,
            //     isDark,
            //   ),
          ],
        ),
        if (showFullInfo) ...[
          const SizedBox(height: 24),

          // Bio Section
          if (user.userBio != null && user.userBio!.isNotEmpty)
            _buildBioSection(user.userBio!, isDark, isMobile, textColor),

          // Joined Date Badge
          // if (user.createdAt != null)
          //   _buildJoinedDateBadge(user.createdAt!, isDark),
        ],
      ],
    );
  }

  Widget _buildBioSection(
    String bio,
    bool isDark,
    bool isMobile,
    Color textColor,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Column(
      children: [
        Container(
          width: isMobile ? double.infinity : 520,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: themeProvider.primaryColor.withOpacity(0.4),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  bio,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: textColor.withOpacity(0.85),
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildJoinedDateBadge(DateTime createdAt, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 8),
          Text(
            'Joined at ${DateFormat('MMMM yyyy').format(createdAt)}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String value,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget profileActionButton(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      return SizedBox.shrink();
      // Center(
      //   child: Image.asset("assets/images/profile_details.png", height: 300),
      // );
      //  SizedBox(
      //   width: isMobile ? double.infinity : 200,
      //   child: ElevatedButton.icon(
      //     onPressed: () {
      //       // Switch to settings tab
      //       setState(() {
      //         _selectedProfileTab = 'Settings';
      //       });
      //     },
      //     icon: const Icon(Icons.edit, size: 18),
      //     label: const Text('Edit Profile'),
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: themeProvider.primaryColor,
      //       foregroundColor: Colors.white,
      //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //     ),
      //   ),
      // );
    } else {
      // final routerProvider = Provider.of<RouterProvider>(context);

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: themeProvider.primaryColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed:
                  authProvider.isLoading
                      ? null
                      : () {
                        authProvider.signInWithGoogle();
                      },
              icon: Icon(FontAwesomeIcons.google, size: 18),
              label: Text(
                'Continue with Google',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                // backgroundColor: isDark ? Colors.white : Colors.black,
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
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
                        await authProvider.signOut();
                        await Future.delayed(Duration(milliseconds: 500));
                        if (kIsWeb) {
                          html.window.location.assign(
                            html.window.location.href,
                          );
                        } else {
                          Restart.restartApp();
                        }
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

  Widget profileStatsSection(
    UserModel user,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final borderColor =
        isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);
    final typingProvider = Provider.of<TypingProvider>(context, listen: false);

    return Column(
      children: [
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
                  CustomStatsCard(
                    width: 200,
                    title: 'Total Tests',
                    value: '${user.totalTests}',
                    unit: '',
                    color: Colors.grey,
                    icon: Icons.assignment,
                    isDarkMode: isDark,
                    isProfile: true,
                  ),
                  CustomStatsCard(
                    width: 200,
                    title: 'Average WPM',
                    value: '${user.averageWpm.round()}',
                    unit: '',
                    color: Colors.grey,
                    icon: Icons.speed,
                    isDarkMode: isDark,
                    isProfile: true,
                  ),
                  CustomStatsCard(
                    width: 200,
                    title: 'Total Words',
                    value: '${user.totalWords}',
                    unit: '',
                    color: Colors.grey,
                    icon: Icons.text_fields,
                    isDarkMode: isDark,
                    isProfile: true,
                  ),

                  CustomStatsCard(
                    width: 200,
                    title: 'Accuracy',
                    value: '${typingProvider.averageAccuracy.round()}%',
                    unit: '',
                    color: Colors.grey,
                    icon: Icons.flag,
                    isDarkMode: isDark,
                    isProfile: true,
                  ),
                  CustomStatsCard(
                    width: 200,
                    title: 'Current Streak',
                    value: '${user.currentStreak} days',
                    unit: '',
                    color: Colors.grey,
                    icon: Icons.local_fire_department,
                    isDarkMode: isDark,
                    isProfile: true,
                  ),
                  CustomStatsCard(
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
            ],
          ),
        ),
        SizedBox(height: 24),
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
                'Typing Activity',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.grey[900] : Colors.grey.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                size: isMobile ? 18 : 20,
                              ),
                              onPressed:
                                  availableYears.contains(
                                        currentHeatmapYear - 1,
                                      )
                                      ? () => changeHeatmapYear(
                                        currentHeatmapYear - 1,
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
                                color:
                                    isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$currentHeatmapYear',
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
                                  availableYears.contains(
                                        currentHeatmapYear + 1,
                                      )
                                      ? () => changeHeatmapYear(
                                        currentHeatmapYear + 1,
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

                    customHeatmap(isDark, isMobile, isTablet),
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
                        profileColorIndicator(0, isDark),
                        SizedBox(width: 2),
                        profileColorIndicator(1, isDark),
                        SizedBox(width: 2),
                        profileColorIndicator(2, isDark),
                        SizedBox(width: 2),
                        profileColorIndicator(3, isDark),
                        SizedBox(width: 2),
                        profileColorIndicator(4, isDark),
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
        ),
      ],
    );
  }

  Widget customHeatmapBoxes(
    int weekIndex,
    int dayIndex,
    bool isDark,
    double squareSize,
  ) {
    final date = heatmapWeeks[weekIndex][dayIndex];

    if (date == null || date.year != currentHeatmapYear) {
      return SizedBox(width: squareSize, height: squareSize);
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);

    final activityEntry = activityData.entries.firstWhere(
      (entry) =>
          entry.key.year == normalizedDate.year &&
          entry.key.month == normalizedDate.month &&
          entry.key.day == normalizedDate.day,
      orElse: () => MapEntry(normalizedDate, 0),
    );

    final testCount = activityEntry.value;

    int activityLevel = getActivityLevel(testCount);

    final color = getActivityColor(activityLevel, isDark);

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

  TextStyle dayLabelStyle(bool isDark) {
    return TextStyle(
      fontSize: 12,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  Widget profileColorIndicator(int intensity, bool isDark) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: getActivityColor(intensity, isDark),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget heatmapShimmer(bool isDark, bool isMobile, bool isTablet) {
    final double squareSize = isMobile ? 10 : 12;
    final double spacing = isMobile ? 1.5 : 2;
    final double containerHeight = isMobile ? 110 : 130;
    final double weekWidth = squareSize + spacing * 2;
    final double dayLabelWidth = 30;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
                    Container(
                      width: heatmapWeeks.length * weekWidth,
                      height: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
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
                        Container(width: 25, height: 12, color: Colors.white),
                        SizedBox(height: squareSize * 1.4 + spacing),
                        Container(width: 25, height: 12, color: Colors.white),
                        SizedBox(height: squareSize * 1.4 + spacing),
                        Container(width: 25, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    height: containerHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(heatmapWeeks.length, (weekIndex) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: spacing),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(7, (dayIndex) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: spacing),
                                width: squareSize,
                                height: squareSize,
                                color: Colors.white,
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
      ),
    );
  }
}
