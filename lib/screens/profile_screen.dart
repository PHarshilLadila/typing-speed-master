// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:typing_speed_master/models/user_model.dart';
// import 'package:typing_speed_master/providers/theme_provider.dart';
// import '../providers/auth_provider.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         if (authProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!authProvider.isLoggedIn) {
//           return _buildLoginUI(context, authProvider);
//         }

//         return _buildProfileUI(context, authProvider);
//       },
//     );
//   }

//   Widget _buildLoginUI(BuildContext context, AuthProvider authProvider) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isMobile = constraints.maxWidth < 768;
//         final isTablet = constraints.maxWidth < 1024;

//         return Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.blue.shade600, Colors.purple.shade600],
//             ),
//           ),
//           child: Center(
//             child: Container(
//               width: isMobile ? constraints.maxWidth * 0.9 : 400,
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     blurRadius: 32,
//                     color: Colors.black.withOpacity(0.1),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildHeader(context, 24, 18),

//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.person,
//                       size: 40,
//                       color: Colors.blue.shade600,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   Text(
//                     'Welcome Back',
//                     style: TextStyle(
//                       fontSize: isMobile ? 24 : 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   Text(
//                     'Sign in to access your profile',
//                     style: TextStyle(
//                       fontSize: isMobile ? 14 : 16,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),

//                   const SizedBox(height: 32),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed:
//                           authProvider.isLoading
//                               ? null
//                               : () {
//                                 authProvider.signInWithGoogle();
//                               },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.grey[800],
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(FontAwesomeIcons.google),

//                           const SizedBox(width: 12),
//                           Text(
//                             'Continue with Google',
//                             style: TextStyle(
//                               fontSize: isMobile ? 14 : 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   if (authProvider.error != null) ...[
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.red.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.error_outline,
//                             color: Colors.red.shade600,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               authProvider.error!,
//                               style: TextStyle(
//                                 color: Colors.red.shade700,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfileUI(BuildContext context, AuthProvider authProvider) {
//     final user = authProvider.user!;

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isMobile = constraints.maxWidth < 768;
//         final isTablet = constraints.maxWidth < 1024;

//         return SingleChildScrollView(
//           padding: EdgeInsets.symmetric(
//             horizontal:
//                 isMobile
//                     ? 16
//                     : isTablet
//                     ? 32
//                     : 64,
//             vertical: 32,
//           ),
//           child: Column(
//             children: [
//               _buildHeader(context, 24, 18),
//               SizedBox(height: 38),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 48,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: isMobile ? 80 : 120,
//                           height: isMobile ? 80 : 120,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 4),
//                           ),
//                           child: ClipOval(
//                             child:
//                                 user.avatarUrl != null
//                                     ? CachedNetworkImage(
//                                       imageUrl:
//                                           user.avatarUrl ??
//                                           "https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?semt=ais_hybrid&w=740&q=80",
//                                       fit: BoxFit.cover,
//                                       errorWidget:
//                                           (context, url, error) =>
//                                               _buildPlaceholderAvatar(user),
//                                     )
//                                     : _buildPlaceholderAvatar(user),
//                           ),
//                         ),
//                         const SizedBox(width: 16),

//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               user.fullName ?? 'User',
//                               style: TextStyle(
//                                 fontSize: isMobile ? 18 : 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),

//                             const SizedBox(height: 8),

//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(FontAwesomeIcons.envelope, size: 16),
//                                     const SizedBox(width: 4),

//                                     Text(
//                                       user.email,
//                                       style: TextStyle(
//                                         fontSize: isMobile ? 14 : 16,
//                                         color: Colors.black.withOpacity(0.9),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(width: 18),

//                                 Row(
//                                   children: [
//                                     Icon(FontAwesomeIcons.calendar, size: 16),
//                                     const SizedBox(width: 4),

//                                     Text(
//                                       user.createdAt != null
//                                           ? 'Joined ${DateFormat('MMM yyyy').format(user.createdAt!)}'
//                                           : 'Unknown',
//                                       style: TextStyle(
//                                         fontSize: isMobile ? 14 : 16,
//                                         color: Colors.black.withOpacity(0.9),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 16),

//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     'ID: ${user.id.substring(0, 8)}...',
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),

//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     'Intermediate',
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),

//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     '7 Day Streak 🔥',
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Spacer(),
//                         TextButton(
//                           onPressed: () {
//                             _showEditProfileDialog(context, authProvider);
//                           },
//                           style: const ButtonStyle(
//                             backgroundColor: WidgetStatePropertyAll(
//                               Colors.amber,
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'Edit Profile',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 20,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.red.withOpacity(0.2)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Danger Zone',
//                       style: TextStyle(
//                         fontSize: isMobile ? 18 : 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     SizedBox(height: 28),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 24,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.03),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Delete Account',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 16 : 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Permanently delete your account and all data',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 16 : 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               authProvider.signOut();
//                             },
//                             style: const ButtonStyle(
//                               backgroundColor: WidgetStatePropertyAll(
//                                 Colors.red,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Delete',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader(
//     BuildContext context,
//     double titleFontSize,
//     double subtitleFontSize,
//     // bool isMobile,
//   ) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final titleColor =
//         themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
//     final subtitleColor =
//         themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

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
//                   fontSize: titleFontSize,
//                   fontWeight: FontWeight.bold,
//                   color: titleColor,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Manage your account and preferences',
//                 style: TextStyle(
//                   fontSize: subtitleFontSize,
//                   color: subtitleColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPlaceholderAvatar(UserModel user) {
//     return Container(
//       color: Colors.blue.shade100,
//       child: Center(
//         child: Icon(Icons.person, size: 40, color: Colors.blue.shade600),
//       ),
//     );
//   }

//   void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
//     final user = authProvider.user!;
//     final nameController = TextEditingController(text: user.fullName);

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Edit Profile'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Full Name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   authProvider.updateProfile(
//                     fullName: nameController.text.trim(),
//                   );
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:typing_speed_master/models/user_model.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!authProvider.isLoggedIn) {
          return _buildLoginUI(context, authProvider, isDark);
        }

        return _buildProfileUI(context, authProvider, isDark);
      },
    );
  }

  Widget _buildLoginUI(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final backgroundGradient =
            isDark
                ? [Colors.indigo.shade900, Colors.deepPurple.shade800]
                : [Colors.blue.shade600, Colors.purple.shade600];

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundGradient,
            ),
          ),
          child: Center(
            child: Container(
              width: isMobile ? constraints.maxWidth * 0.9 : 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 32,
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.6)
                            : Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, 24, 18),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: isDark ? Colors.amberAccent : Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your profile',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          authProvider.isLoading
                              ? null
                              : () {
                                authProvider.signInWithGoogle();
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.grey[850] : Colors.white,
                        foregroundColor:
                            isDark ? Colors.white : Colors.grey[800],
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.google),
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
                  ),
                  if (authProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
    final user = authProvider.user!;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final borderColor =
        isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);
    final textColor = isDark ? Colors.white : Colors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth < 1024;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal:
                isMobile
                    ? 16
                    : isTablet
                    ? 32
                    : 64,
            vertical: 32,
          ),
          child: Column(
            children: [
              _buildHeader(context, 24, 18),
              const SizedBox(height: 38),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 80 : 120,
                      height: isMobile ? 80 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            user.avatarUrl != null
                                ? CachedNetworkImage(
                                  imageUrl: user.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (context, url, error) =>
                                          _buildPlaceholderAvatar(user, isDark),
                                )
                                : _buildPlaceholderAvatar(user, isDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName ?? 'User',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.envelope,
                              size: 16,
                              color: isDark ? Colors.amberAccent : Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: textColor.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Icon(
                              FontAwesomeIcons.calendar,
                              size: 16,
                              color: isDark ? Colors.amberAccent : Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.createdAt != null
                                  ? 'Joined ${DateFormat('MMM yyyy').format(user.createdAt!)}'
                                  : 'Unknown',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: textColor.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildTag(
                              'ID: ${user.id.substring(0, 8)}...',
                              isDark,
                            ),
                            const SizedBox(width: 12),
                            _buildTag('Intermediate', isDark),
                            const SizedBox(width: 12),
                            _buildTag('7 Day Streak 🔥', isDark),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _showEditProfileDialog(context, authProvider);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          isDark ? Colors.amberAccent.shade400 : Colors.amber,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Permanently delete your account and all data',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              authProvider.signOut();
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.red,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final titleColor =
        themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

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
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar(UserModel user, bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.blue.shade100,
      child: Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: isDark ? Colors.amberAccent : Colors.blue.shade600,
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;
    final nameController = TextEditingController(text: user.fullName);

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
                authProvider.updateProfile(
                  fullName: nameController.text.trim(),
                );
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
}
