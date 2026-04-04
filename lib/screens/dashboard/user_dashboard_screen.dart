import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/backend_analytics_service.dart';
import '../../widgets/spectra_card.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  late Future<Map<String, dynamic>?> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = BackendAnalyticsService.getDashboardSummary();
  }

  // --- Strict UI Guideline: Unified Calm Aesthetics ---
  // We use muted pastel structures without aggressively altering colors
  // to maintain high predictability for the user.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Your Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState();
          }

          final metrics = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _dashboardFuture = BackendAnalyticsService.getDashboardSummary();
              });
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailySummaryCard(metrics['daily_summary'] ?? "You're taking great steps today."),
                  const SizedBox(height: 16),
                  
                  // Row for quantifiable metrics (Calm & VR)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBlock(
                          icon: Icons.water_drop_rounded,
                          title: "Calm Usage",
                          value: "${(metrics['today_calm_time'] ?? 0) ~/ 60}m",
                          trend: "Total: ${(metrics['calm_time'] ?? 0) ~/ 60}m",
                          color: AppColors.moodCalm,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricBlock(
                          icon: Icons.view_in_ar_rounded,
                          title: "VR Progress",
                          value: "${metrics['today_vr_sessions'] ?? 0}",
                          trend: "Total: ${metrics['vr_sessions'] ?? 0}",
                          color: AppColors.primarySoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 🧠 The Heart of the Dashboard: Pattern Insights
                  Text(
                    'Pattern Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildPatternInsights(metrics['insights']),
                  
                  const SizedBox(height: 32),
                  // Positive Encouragement Footer
                  Center(
                    child: Text(
                      "You are navigating things really well.\nKeep going at your own pace.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailySummaryCard(String summary) {
    return SpectraCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFE8EAF6), Color(0xFFF3E5F5)], // Soft Pastel Blue/Purple
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF9FA8DA)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Flow",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7986CB),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBlock({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required Color color,
  }) {
    return SpectraCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInsights(dynamic insightsRaw) {
    List<String> insights = [];
    if (insightsRaw is List) {
      insights = insightsRaw.map((e) => e.toString()).toList();
    } else {
      insights = ["You are taking meaningful steps to reflect on your daily routine."];
    }

    return Column(
      children: insights.map((insight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SpectraCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 64,
                color: AppColors.primarySoft,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "You're just getting started.",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Your insights space will naturally populate as you explore SPECTRA and identify what works for you.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
