// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:typing_speed_master/models/typing_result.dart';
// import '../providers/typing_provider.dart';
// import '../widgets/stats_card.dart';
// import '../widgets/accuracy_chart.dart';
// import 'typing_test_screen.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(context),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       _buildStatsGrid(context),
//                       const SizedBox(height: 20),
//                       _buildRecentResults(context),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Typing Speed Test',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Improve your typing speed and accuracy',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         ElevatedButton.icon(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => TypingTestScreen()),
//             );
//           },
//           icon: const Icon(Icons.keyboard),
//           label: const Text('Start New Test'),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsGrid(BuildContext context) {
//     final provider = Provider.of<TypingProvider>(context);

//     return GridView(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 2.5,
//       ),
//       children: [
//         StatsCard(
//           title: 'Average WPM',
//           value: provider.averageWPM.toStringAsFixed(1),
//           unit: 'WPM',
//           color: Colors.blue,
//           icon: Icons.speed,
//         ),
//         StatsCard(
//           title: 'Average Accuracy',
//           value: provider.averageAccuracy.toStringAsFixed(1),
//           unit: '%',
//           color: Colors.green,
//           icon: Icons.flag,
//         ),
//         StatsCard(
//           title: 'Total Tests',
//           value: provider.totalTests.toString(),
//           unit: 'Tests',
//           color: Colors.orange,
//           icon: Icons.assignment,
//         ),
//         StatsCard(
//           title: 'Best WPM',
//           value:
//               provider.results.isNotEmpty
//                   ? provider.results
//                       .map((r) => r.wpm)
//                       .reduce((a, b) => a > b ? a : b)
//                       .toString()
//                   : '0',
//           unit: 'WPM',
//           color: Colors.purple,
//           icon: Icons.emoji_events,
//         ),
//       ],
//     );
//   }

//   Widget _buildRecentResults(BuildContext context) {
//     final provider = Provider.of<TypingProvider>(context);
//     final recentResults = provider.getRecentResults(5);

//     return Column(
//       children: [
//         Row(
//           children: [
//             Text(
//               'Recent Tests',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const Spacer(),
//             if (provider.results.isNotEmpty)
//               TextButton(
//                 onPressed: provider.clearHistory,
//                 child: Text(
//                   'Clear History',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         if (recentResults.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(40),
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
//                   style: TextStyle(fontSize: 16, color: Colors.grey[500]),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Start your first typing test to see results here',
//                   style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
//               ...recentResults.map((result) => _buildResultCard(result)),
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _buildResultCard(TypingResult result) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${result.wpm} WPM',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               Text(
//                 '${result.accuracy.toStringAsFixed(1)}% Accuracy',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               ),
//             ],
//           ),
//           const Spacer(),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${result.duration.inSeconds}s',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               ),
//               Text(
//                 result.difficulty,
//                 style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/typing_result.dart';
import '../providers/typing_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/accuracy_chart.dart';
import 'typing_test_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        final isTablet =
            constraints.maxWidth > 600 && constraints.maxWidth <= 1000;
        final isMobile = constraints.maxWidth <= 600;

        final horizontalPadding =
            isDesktop
                ? 100.0
                : isTablet
                ? 40.0
                : 20.0;

        final titleFontSize =
            isDesktop
                ? 32.0
                : isTablet
                ? 26.0
                : 22.0;

        final subtitleFontSize =
            isDesktop
                ? 18.0
                : isTablet
                ? 16.0
                : 14.0;

        final gridCrossAxisCount =
            isDesktop
                ? 4
                : isTablet
                ? 2
                : 1;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    titleFontSize,
                    subtitleFontSize,
                    isMobile,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildStatsGrid(context, gridCrossAxisCount),
                          const SizedBox(height: 20),
                          _buildRecentResults(context, subtitleFontSize),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
    bool isMobile,
  ) {
    return isMobile
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Typing Speed Test',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Improve your typing speed and accuracy',
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TypingTestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.keyboard),
                label: const Text('Start New Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        )
        : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Typing Speed Test',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Improve your typing speed and accuracy',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TypingTestScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.keyboard),
              label: const Text('Start New Test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
  }

  Widget _buildStatsGrid(BuildContext context, int crossAxisCount) {
    final provider = Provider.of<TypingProvider>(context);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: crossAxisCount == 1 ? 3 : 2,
      ),
      children: [
        StatsCard(
          title: 'Average WPM',
          value: provider.averageWPM.toStringAsFixed(1),
          unit: 'WPM',
          color: Colors.blue,
          icon: Icons.speed,
        ),
        StatsCard(
          title: 'Average Accuracy',
          value: provider.averageAccuracy.toStringAsFixed(1),
          unit: '%',
          color: Colors.green,
          icon: Icons.flag,
        ),
        StatsCard(
          title: 'Total Tests',
          value: provider.totalTests.toString(),
          unit: 'Tests',
          color: Colors.orange,
          icon: Icons.assignment,
        ),
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
        ),
      ],
    );
  }

  Widget _buildRecentResults(BuildContext context, double subtitleFontSize) {
    final provider = Provider.of<TypingProvider>(context);
    final recentResults = provider.getRecentResults(5);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Recent Tests',
              style: TextStyle(
                fontSize: subtitleFontSize + 2,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (provider.results.isNotEmpty)
              TextButton(
                onPressed: provider.clearHistory,
                child: const Text(
                  'Clear History',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentResults.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tests completed yet',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your first typing test to see results here',
                  style: TextStyle(
                    fontSize: subtitleFontSize - 2,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              AccuracyChart(results: recentResults),
              const SizedBox(height: 20),
              ...recentResults.map(
                (result) => _buildResultCard(result, subtitleFontSize),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResultCard(TypingResult result, double subtitleFontSize) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.wpm} WPM',
                style: TextStyle(
                  fontSize: subtitleFontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${result.accuracy.toStringAsFixed(1)}% Accuracy',
                style: TextStyle(
                  fontSize: subtitleFontSize - 2,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.duration.inSeconds}s',
                style: TextStyle(
                  fontSize: subtitleFontSize - 2,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                result.difficulty,
                style: TextStyle(
                  fontSize: subtitleFontSize - 4,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
