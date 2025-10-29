// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:typing_speed_master/models/typing_result.dart';
// import 'package:typing_speed_master/providers/theme_provider.dart';
// import 'package:typing_speed_master/widgets/responsive_layout.dart';
// import '../providers/typing_provider.dart';
// import '../widgets/stats_card.dart';
// import '../widgets/accuracy_chart.dart';
// import 'typing_test_screen.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveLayout(
//       smallMobile: _buildDashboard(
//         context: context,
//         horizontalPadding: 12,
//         titleFontSize: 22,
//         subtitleFontSize: 14,
//       ),
//       bigMobile: _buildDashboard(
//         context: context,
//         horizontalPadding: 24,
//         titleFontSize: 24,
//         subtitleFontSize: 14,
//       ),
//       smallTablet: _buildDashboard(
//         context: context,
//         horizontalPadding: 40,
//         titleFontSize: 26,
//         subtitleFontSize: 16,
//       ),
//       bigTablet: _buildDashboard(
//         context: context,
//         horizontalPadding: 60,
//         titleFontSize: 28,
//         subtitleFontSize: 16,
//       ),
//       smallDesktop: _buildDashboard(
//         context: context,
//         horizontalPadding: 80,
//         titleFontSize: 30,
//         subtitleFontSize: 18,
//       ),
//       bigDesktop: _buildDashboard(
//         context: context,
//         horizontalPadding: 100,
//         titleFontSize: 32,
//         subtitleFontSize: 18,
//       ),
//     );
//   }

//   Widget _buildDashboard({
//     required BuildContext context,
//     required double horizontalPadding,
//     required double titleFontSize,
//     required double subtitleFontSize,
//   }) {
//     final isMobile = MediaQuery.of(context).size.width <= 600;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: horizontalPadding,
//           vertical: 20,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(context, titleFontSize, subtitleFontSize, isMobile),
//             const SizedBox(height: 20),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 40),

//                     _buildStatsLayout(context),
//                     const SizedBox(height: 20),
//                     _buildRecentResults(context, subtitleFontSize),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(
//     BuildContext context,
//     double titleFontSize,
//     double subtitleFontSize,
//     bool isMobile,
//   ) {
//     return isMobile
//         ? Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Typing Speed Test',
//               style: TextStyle(
//                 fontSize: titleFontSize,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Improve your typing speed and accuracy',
//               style: TextStyle(
//                 fontSize: subtitleFontSize,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const TypingTestScreen(),
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.keyboard),
//                     label: const Text('Start New Test'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                   IconButton.filled(
//                     onPressed: () {
//                       Provider.of<ThemeProvider>(
//                         context,
//                         listen: false,
//                       ).toggleTheme();
//                     },
//                     icon: Consumer<ThemeProvider>(
//                       builder: (context, themeProvider, child) {
//                         return Icon(
//                           themeProvider.isDarkMode
//                               ? Icons.light_mode
//                               : Icons.dark_mode,
//                           color:
//                               themeProvider.isDarkMode
//                                   ? Colors.amber
//                                   : Colors.grey[700],
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         )
//         : Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Typing Speed Test',
//                   style: TextStyle(
//                     fontSize: titleFontSize,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Improve your typing speed and accuracy',
//                   style: TextStyle(
//                     fontSize: subtitleFontSize,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const TypingTestScreen(),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.keyboard),
//                   label: const Text('Start New Test'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//                 IconButton.filled(
//                   onPressed: () {
//                     Provider.of<ThemeProvider>(
//                       context,
//                       listen: false,
//                     ).toggleTheme();
//                   },
//                   icon: Consumer<ThemeProvider>(
//                     builder: (context, themeProvider, child) {
//                       return Icon(
//                         themeProvider.isDarkMode
//                             ? Icons.light_mode
//                             : Icons.dark_mode,
//                         color:
//                             themeProvider.isDarkMode
//                                 ? Colors.amber
//                                 : Colors.grey[700],
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//   }

//   Widget _buildStatsLayout(BuildContext context) {
//     final provider = Provider.of<TypingProvider>(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = screenWidth <= 600;

//     if (isMobile) {
//       return Column(
//         children: [
//           StatsCard(
//             title: 'Average WPM',
//             value: provider.averageWPM.toStringAsFixed(1),
//             unit: 'WPM',
//             color: Colors.blue,
//             icon: Icons.speed,
//           ),
//           const SizedBox(height: 16),
//           StatsCard(
//             title: 'Average Accuracy',
//             value: provider.averageAccuracy.toStringAsFixed(1),
//             unit: '%',
//             color: Colors.green,
//             icon: Icons.flag,
//           ),
//           const SizedBox(height: 16),
//           StatsCard(
//             title: 'Total Tests',
//             value: provider.totalTests.toString(),
//             unit: 'Tests',
//             color: Colors.orange,
//             icon: Icons.assignment,
//           ),
//           const SizedBox(height: 16),
//           StatsCard(
//             title: 'Best WPM',
//             value:
//                 provider.results.isNotEmpty
//                     ? provider.results
//                         .map((r) => r.wpm)
//                         .reduce((a, b) => a > b ? a : b)
//                         .toString()
//                     : '0',
//             unit: 'WPM',
//             color: Colors.purple,
//             icon: Icons.emoji_events,
//           ),
//         ],
//       );
//     } else if (screenWidth <= 900) {
//       return Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: StatsCard(
//                   title: 'Average WPM',
//                   value: provider.averageWPM.toStringAsFixed(1),
//                   unit: 'WPM',
//                   color: Colors.blue,
//                   icon: Icons.speed,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: StatsCard(
//                   title: 'Average Accuracy',
//                   value: provider.averageAccuracy.toStringAsFixed(1),
//                   unit: '%',
//                   color: Colors.green,
//                   icon: Icons.flag,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: StatsCard(
//                   title: 'Total Tests',
//                   value: provider.totalTests.toString(),
//                   unit: 'Tests',
//                   color: Colors.orange,
//                   icon: Icons.assignment,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: StatsCard(
//                   title: 'Best WPM',
//                   value:
//                       provider.results.isNotEmpty
//                           ? provider.results
//                               .map((r) => r.wpm)
//                               .reduce((a, b) => a > b ? a : b)
//                               .toString()
//                           : '0',
//                   unit: 'WPM',
//                   color: Colors.purple,
//                   icon: Icons.emoji_events,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     } else if (screenWidth <= 1200) {
//       return Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: StatsCard(
//                   title: 'Average WPM',
//                   value: provider.averageWPM.toStringAsFixed(1),
//                   unit: 'WPM',
//                   color: Colors.blue,
//                   icon: Icons.speed,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: StatsCard(
//                   title: 'Average Accuracy',
//                   value: provider.averageAccuracy.toStringAsFixed(1),
//                   unit: '%',
//                   color: Colors.green,
//                   icon: Icons.flag,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: StatsCard(
//                   title: 'Total Tests',
//                   value: provider.totalTests.toString(),
//                   unit: 'Tests',
//                   color: Colors.orange,
//                   icon: Icons.assignment,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               SizedBox(
//                 width: 300,
//                 child: StatsCard(
//                   title: 'Best WPM',
//                   value:
//                       provider.results.isNotEmpty
//                           ? provider.results
//                               .map((r) => r.wpm)
//                               .reduce((a, b) => a > b ? a : b)
//                               .toString()
//                           : '0',
//                   unit: 'WPM',
//                   color: Colors.purple,
//                   icon: Icons.emoji_events,
//                 ),
//               ),
//               const Spacer(flex: 1),
//             ],
//           ),
//         ],
//       );
//     } else {
//       return Row(
//         children: [
//           Expanded(
//             child: StatsCard(
//               title: 'Average WPM',
//               value: provider.averageWPM.toStringAsFixed(1),
//               unit: 'WPM',
//               color: Colors.blue,
//               icon: Icons.speed,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: StatsCard(
//               title: 'Average Accuracy',
//               value: provider.averageAccuracy.toStringAsFixed(1),
//               unit: '%',
//               color: Colors.green,
//               icon: Icons.flag,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: StatsCard(
//               title: 'Total Tests',
//               value: provider.totalTests.toString(),
//               unit: 'Tests',
//               color: Colors.orange,
//               icon: Icons.assignment,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: StatsCard(
//               title: 'Best WPM',
//               value:
//                   provider.results.isNotEmpty
//                       ? provider.results
//                           .map((r) => r.wpm)
//                           .reduce((a, b) => a > b ? a : b)
//                           .toString()
//                       : '0',
//               unit: 'WPM',
//               color: Colors.purple,
//               icon: Icons.emoji_events,
//             ),
//           ),
//         ],
//       );
//     }
//   }

//   Widget _buildRecentResults(BuildContext context, double subtitleFontSize) {
//     final provider = Provider.of<TypingProvider>(context);
//     final recentResults = provider.getRecentResults(5);

//     return Column(
//       children: [
//         Row(
//           children: [
//             Text(
//               'Recent Tests',
//               style: TextStyle(
//                 fontSize: subtitleFontSize + 2,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const Spacer(),
//             if (provider.results.isNotEmpty)
//               TextButton(
//                 onPressed: provider.clearHistory,
//                 child: const Text(
//                   'Clear History',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         if (recentResults.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: Column(
//               children: [
//                 Icon(Icons.assignment, size: 48, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No tests completed yet',
//                   style: TextStyle(
//                     fontSize: subtitleFontSize,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Start your first typing test to see results here',
//                   style: TextStyle(
//                     fontSize: subtitleFontSize - 2,
//                     color: Colors.grey[400],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           )
//         else
//           Column(
//             children: [
//               AccuracyChart(results: recentResults),
//               const SizedBox(height: 20),
//               ...recentResults.map(
//                 (result) => _buildResultCard(result, subtitleFontSize),
//               ),
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _buildResultCard(TypingResult result, double subtitleFontSize) {
//     Color getDifficultyColor(String difficulty) {
//       switch (difficulty.toLowerCase()) {
//         case 'hard':
//           return Color(0xFFFF6B6B);
//         case 'medium':
//           return Color(0xFFFFA726);
//         case 'easy':
//           return Color(0xFF66BB6A);
//         default:
//           return Color(0xFF42A5F5);
//       }
//     }

//     Color getDifficultyGradientColor(String difficulty) {
//       switch (difficulty.toLowerCase()) {
//         case 'hard':
//           return Color(0xFFFF5252);
//         case 'medium':
//           return Color(0xFFFF9800);
//         case 'easy':
//           return Color(0xFF4CAF50);
//         default:
//           return Color(0xFF2196F3);
//       }
//     }

//     IconData getDifficultyIcon(String difficulty) {
//       switch (difficulty.toLowerCase()) {
//         case 'hard':
//           return Icons.whatshot;
//         case 'medium':
//           return Icons.trending_up;
//         case 'easy':
//           return Icons.flag;
//         default:
//           return Icons.star;
//       }
//     }

//     final difficultyColor = getDifficultyColor(result.difficulty);
//     final difficultyGradientColor = getDifficultyGradientColor(
//       result.difficulty,
//     );
//     final difficultyIcon = getDifficultyIcon(result.difficulty);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Stack(
//         children: [
//           Container(
//             height: 100,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white, Colors.grey[50]!],
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),

//           Container(
//             height: 100,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey[100]!),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.9),
//                   Colors.grey[50]!.withOpacity(0.9),
//                 ],
//               ),
//             ),
//             child: Row(
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     SizedBox(
//                       width: 60,
//                       height: 60,
//                       child: CircularProgressIndicator(
//                         value: result.wpm / 100,
//                         strokeWidth: 5,
//                         backgroundColor: Colors.grey[200],
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
//                       ),
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${result.wpm}',
//                           style: TextStyle(
//                             fontSize: subtitleFontSize + 1,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Text(
//                           'WPM',
//                           style: TextStyle(
//                             fontSize: subtitleFontSize - 7,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(width: 20),

//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: Color(0xFF66BB6A).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Image.asset(
//                               "assets/images/png/accuracy.png",
//                               color: Color(0xFF66BB6A),
//                               width: subtitleFontSize,
//                               height: subtitleFontSize,
//                             ),
//                           ),

//                           const SizedBox(width: 8),
//                           Text(
//                             '${result.accuracy.toStringAsFixed(1)}%',
//                             style: TextStyle(
//                               fontSize: subtitleFontSize + 0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Accuracy',
//                             style: TextStyle(
//                               fontSize: subtitleFontSize - 1,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 6),

//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.access_time,
//                               size: subtitleFontSize - 1,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Row(
//                             children: [
//                               Text(
//                                 '${result.duration.inSeconds}s',
//                                 style: TextStyle(
//                                   fontSize: subtitleFontSize - 2,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'Duration',
//                                 style: TextStyle(
//                                   fontSize: subtitleFontSize - 2,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 20),

//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [difficultyColor, difficultyGradientColor],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: difficultyColor.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         difficultyIcon,
//                         size: subtitleFontSize + 2,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         result.difficulty,
//                         style: TextStyle(
//                           fontSize: subtitleFontSize - 5,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Positioned(
//             top: 0,
//             right: 0,
//             child: Container(
//               padding: EdgeInsets.only(
//                 top: 80,
//                 right: 80,
//                 left: 30,
//                 bottom: 20,
//               ),
//               decoration: BoxDecoration(
//                 color: difficultyColor.withOpacity(0.1),
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.only(
//                   bottomRight: Radius.circular(0),
//                   bottomLeft: Radius.circular(30),
//                   topRight: Radius.circular(20),
//                   topLeft: Radius.circular(0),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/typing_result.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/responsive_layout.dart';
import '../providers/typing_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/accuracy_chart.dart';
import 'typing_test_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      smallMobile: _buildDashboard(
        context: context,
        horizontalPadding: 12,
        titleFontSize: 22,
        subtitleFontSize: 14,
      ),
      bigMobile: _buildDashboard(
        context: context,
        horizontalPadding: 24,
        titleFontSize: 24,
        subtitleFontSize: 14,
      ),
      smallTablet: _buildDashboard(
        context: context,
        horizontalPadding: 40,
        titleFontSize: 26,
        subtitleFontSize: 16,
      ),
      bigTablet: _buildDashboard(
        context: context,
        horizontalPadding: 60,
        titleFontSize: 28,
        subtitleFontSize: 16,
      ),
      smallDesktop: _buildDashboard(
        context: context,
        horizontalPadding: 80,
        titleFontSize: 30,
        subtitleFontSize: 18,
      ),
      bigDesktop: _buildDashboard(
        context: context,
        horizontalPadding: 100,
        titleFontSize: 32,
        subtitleFontSize: 18,
      ),
    );
  }

  Widget _buildDashboard({
    required BuildContext context,
    required double horizontalPadding,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildHeader(context, titleFontSize, subtitleFontSize, isMobile),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildStatsLayout(context),
                    const SizedBox(height: 20),
                    _buildRecentResults(context, subtitleFontSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildHeader(
  //   BuildContext context,
  //   double titleFontSize,
  //   double subtitleFontSize,
  //   bool isMobile,
  // ) {
  //   final themeProvider = Provider.of<ThemeProvider>(context);
  //   final titleColor =
  //       themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
  //   final subtitleColor =
  //       themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

  //   return isMobile
  //       ? Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Typing Speed Test',
  //             style: TextStyle(
  //               fontSize: titleFontSize,
  //               fontWeight: FontWeight.bold,
  //               color: titleColor,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             'Improve your typing speed and accuracy',
  //             style: TextStyle(
  //               fontSize: subtitleFontSize,
  //               color: subtitleColor,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           SizedBox(
  //             width: double.infinity,
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 ElevatedButton.icon(
  //                   onPressed: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => const TypingTestScreen(),
  //                       ),
  //                     );
  //                   },
  //                   icon: const Icon(Icons.keyboard),
  //                   label: const Text('Start New Test'),
  //                   style: ElevatedButton.styleFrom(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 20,
  //                       vertical: 14,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 14),
  //                 IconButton.filled(
  //                   onPressed: () {
  //                     Provider.of<ThemeProvider>(
  //                       context,
  //                       listen: false,
  //                     ).toggleTheme();
  //                   },
  //                   icon: Consumer<ThemeProvider>(
  //                     builder: (context, themeProvider, child) {
  //                       return Icon(
  //                         themeProvider.isDarkMode
  //                             ? Icons.light_mode
  //                             : Icons.dark_mode,
  //                         color:
  //                             themeProvider.isDarkMode
  //                                 ? Colors.amber
  //                                 : Colors.grey[700],
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       )
  //       : Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Typing Speed Test',
  //                 style: TextStyle(
  //                   fontSize: titleFontSize,
  //                   fontWeight: FontWeight.bold,
  //                   color: titleColor,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 'Improve your typing speed and accuracy',
  //                 style: TextStyle(
  //                   fontSize: subtitleFontSize,
  //                   color: subtitleColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Row(
  //             children: [
  //               ElevatedButton.icon(
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => const TypingTestScreen(),
  //                     ),
  //                   );
  //                 },
  //                 icon: const Icon(Icons.keyboard),
  //                 label: const Text('Start New Test'),
  //                 style: ElevatedButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 20,
  //                     vertical: 12,
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(width: 14),
  //               IconButton.filled(
  //                 onPressed: () {
  //                   Provider.of<ThemeProvider>(
  //                     context,
  //                     listen: false,
  //                   ).toggleTheme();
  //                 },
  //                 icon: Consumer<ThemeProvider>(
  //                   builder: (context, themeProvider, child) {
  //                     return Icon(
  //                       themeProvider.isDarkMode
  //                           ? Icons.light_mode
  //                           : Icons.dark_mode,
  //                       color:
  //                           themeProvider.isDarkMode
  //                               ? Colors.amber
  //                               : Colors.grey[700],
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  // }

  Widget _buildStatsLayout(BuildContext context) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    if (isMobile) {
      return Column(
        children: [
          StatsCard(
            title: 'Average WPM',
            value: provider.averageWPM.toStringAsFixed(1),
            unit: 'WPM',
            color: Colors.blue,
            icon: Icons.speed,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'Average Accuracy',
            value: provider.averageAccuracy.toStringAsFixed(1),
            unit: '%',
            color: Colors.green,
            icon: Icons.flag,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'Total Tests',
            value: provider.totalTests.toString(),
            unit: 'Tests',
            color: Colors.orange,
            icon: Icons.assignment,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'Best WPM',
            value:
                provider.results.isNotEmpty
                    ? provider.results
                        .map((r) => r.wpm)
                        .reduce((a, b) => a > b ? a : b)
                        .toString()
                    : '0',
            unit: 'WPM',
            color: Colors.purple,
            icon: Icons.emoji_events,
            isDarkMode: themeProvider.isDarkMode,
          ),
        ],
      );
    } else if (screenWidth <= 900) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Average WPM',
                  value: provider.averageWPM.toStringAsFixed(1),
                  unit: 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Average Accuracy',
                  value: provider.averageAccuracy.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.green,
                  icon: Icons.flag,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Tests',
                  value: provider.totalTests.toString(),
                  unit: 'Tests',
                  color: Colors.orange,
                  icon: Icons.assignment,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Best WPM',
                  value:
                      provider.results.isNotEmpty
                          ? provider.results
                              .map((r) => r.wpm)
                              .reduce((a, b) => a > b ? a : b)
                              .toString()
                          : '0',
                  unit: 'WPM',
                  color: Colors.purple,
                  icon: Icons.emoji_events,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (screenWidth <= 1200) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Average WPM',
                  value: provider.averageWPM.toStringAsFixed(1),
                  unit: 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Average Accuracy',
                  value: provider.averageAccuracy.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.green,
                  icon: Icons.flag,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Total Tests',
                  value: provider.totalTests.toString(),
                  unit: 'Tests',
                  color: Colors.orange,
                  icon: Icons.assignment,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: StatsCard(
                  title: 'Best WPM',
                  value:
                      provider.results.isNotEmpty
                          ? provider.results
                              .map((r) => r.wpm)
                              .reduce((a, b) => a > b ? a : b)
                              .toString()
                          : '0',
                  unit: 'WPM',
                  color: Colors.purple,
                  icon: Icons.emoji_events,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: StatsCard(
              title: 'Average WPM',
              value: provider.averageWPM.toStringAsFixed(1),
              unit: 'WPM',
              color: Colors.blue,
              icon: Icons.speed,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsCard(
              title: 'Average Accuracy',
              value: provider.averageAccuracy.toStringAsFixed(1),
              unit: '%',
              color: Colors.green,
              icon: Icons.flag,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsCard(
              title: 'Total Tests',
              value: provider.totalTests.toString(),
              unit: 'Tests',
              color: Colors.orange,
              icon: Icons.assignment,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsCard(
              title: 'Best WPM',
              value:
                  provider.results.isNotEmpty
                      ? provider.results
                          .map((r) => r.wpm)
                          .reduce((a, b) => a > b ? a : b)
                          .toString()
                      : '0',
              unit: 'WPM',
              color: Colors.purple,
              icon: Icons.emoji_events,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildRecentResults(BuildContext context, double subtitleFontSize) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final recentResults = provider.getRecentResults(5);

    final titleColor =
        themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
    final borderColor =
        themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200];
    final textColor =
        themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[500];
    final iconColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[400];

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Recent Tests',
              style: TextStyle(
                fontSize: subtitleFontSize + 2,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const Spacer(),
            if (provider.results.isNotEmpty)
              TextButton(
                onPressed: provider.clearHistory,
                child: Text(
                  'Clear History',
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.red[300] : Colors.red,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentResults.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor ?? Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  'No tests completed yet',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your first typing test to see results here',
                  style: TextStyle(
                    fontSize: subtitleFontSize - 2,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              AccuracyChart(
                results: recentResults,
                isDarkMode: themeProvider.isDarkMode,
              ),
              const SizedBox(height: 20),
              ...recentResults.map(
                (result) => _buildResultCard(
                  result,
                  subtitleFontSize,
                  themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResultCard(
    TypingResult result,
    double subtitleFontSize,
    bool isDarkMode,
  ) {
    Color getDifficultyColor(String difficulty) {
      switch (difficulty.toLowerCase()) {
        case 'hard':
          return Color(0xFFFF6B6B);
        case 'medium':
          return Color(0xFFFFA726);
        case 'easy':
          return Color(0xFF66BB6A);
        default:
          return Color(0xFF42A5F5);
      }
    }

    Color getDifficultyGradientColor(String difficulty) {
      switch (difficulty.toLowerCase()) {
        case 'hard':
          return Color(0xFFFF5252);
        case 'medium':
          return Color(0xFFFF9800);
        case 'easy':
          return Color(0xFF4CAF50);
        default:
          return Color(0xFF2196F3);
      }
    }

    IconData getDifficultyIcon(String difficulty) {
      switch (difficulty.toLowerCase()) {
        case 'hard':
          return Icons.whatshot;
        case 'medium':
          return Icons.trending_up;
        case 'easy':
          return Icons.flag;
        default:
          return Icons.star;
      }
    }

    final difficultyColor = getDifficultyColor(result.difficulty);
    final difficultyGradientColor = getDifficultyGradientColor(
      result.difficulty,
    );
    final difficultyIcon = getDifficultyIcon(result.difficulty);

    final backgroundColor1 = isDarkMode ? Colors.grey[800]! : Colors.white;
    final backgroundColor2 = isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final progressBackgroundColor =
        isDarkMode ? Colors.grey[700] : Colors.grey[200];
    final iconBackgroundColor =
        isDarkMode ? Colors.grey[600] : Colors.grey.withOpacity(0.1);
    final iconColor = isDarkMode ? Colors.grey[300] : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [backgroundColor1, backgroundColor2],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Container(
            height: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor1.withOpacity(0.9),
                  backgroundColor2.withOpacity(0.9),
                ],
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: result.wpm / 100,
                        strokeWidth: 5,
                        backgroundColor: progressBackgroundColor,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${result.wpm}',
                          style: TextStyle(
                            fontSize: subtitleFontSize + 1,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'WPM',
                          style: TextStyle(
                            fontSize: subtitleFontSize - 7,
                            fontWeight: FontWeight.w500,
                            color: subtitleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFF66BB6A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              "assets/images/png/accuracy.png",
                              color: Color(0xFF66BB6A),
                              width: subtitleFontSize,
                              height: subtitleFontSize,
                            ),
                          ),

                          const SizedBox(width: 8),
                          Text(
                            '${result.accuracy.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: subtitleFontSize + 0,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Accuracy',
                            style: TextStyle(
                              fontSize: subtitleFontSize - 1,
                              color: subtitleTextColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: iconBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.access_time,
                              size: subtitleFontSize - 1,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Text(
                                '${result.duration.inSeconds}s',
                                style: TextStyle(
                                  fontSize: subtitleFontSize - 2,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: subtitleFontSize - 2,
                                  color: subtitleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [difficultyColor, difficultyGradientColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: difficultyColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        difficultyIcon,
                        size: subtitleFontSize + 2,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.difficulty,
                        style: TextStyle(
                          fontSize: subtitleFontSize - 5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 80,
                right: 80,
                left: 30,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(0),
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
