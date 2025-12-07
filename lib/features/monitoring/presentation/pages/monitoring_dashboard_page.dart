import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Monitoring Dashboard Page
/// 
/// Central monitoring dashboard showing system-wide plant health,
/// alerts, and overview statistics.
class MonitoringDashboardPage extends StatefulWidget {
  const MonitoringDashboardPage({super.key});

  @override
  State<MonitoringDashboardPage> createState() => _MonitoringDashboardPageState();
}

class _MonitoringDashboardPageState extends State<MonitoringDashboardPage> {
  final List<String> _timePeriods = ['Today', 'This Week', 'This Month'];
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Monitoring Dashboard',
          style: AppTextStyles.titleMedium,
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dashboard refreshed'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimePeriodSelector(),
              const SizedBox(height: UIConstants.spacingL),
              _buildOverviewCards(),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildAlertsSection(),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildSystemStatusSection(),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Row(
      children: [
        Text(
          'Overview for: ',
          style: AppTextStyles.bodyMedium,
        ),
        DropdownButton<String>(
          value: _selectedPeriod,
          items: _timePeriods.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Plants',
                value: '12',
                icon: Icons.eco,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: UIConstants.spacingL),
            Expanded(
              child: _buildMetricCard(
                title: 'Online Devices',
                value: '11',
                icon: Icons.wifi,
                color: AppColors.online,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingL),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Active Alerts',
                value: '3',
                icon: Icons.warning,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: UIConstants.spacingL),
            Expanded(
              child: _buildMetricCard(
                title: 'Auto Watering',
                value: '8',
                icon: Icons.water_drop,
                color: AppColors.humidity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: UIConstants.iconL,
                ),
                const SizedBox(width: UIConstants.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Alerts',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: UIConstants.spacingL),
        _buildAlertCard(
          title: 'Low Humidity',
          plant: 'Tomato Plant #1',
          message: 'Humidity level is 25% - below optimal range',
          severity: AlertSeverity.warning,
          time: '2 hours ago',
        ),
        const SizedBox(height: UIConstants.spacingS),
        _buildAlertCard(
          title: 'Device Offline',
          plant: 'Basil Garden',
          message: 'Sensor has been offline for 30 minutes',
          severity: AlertSeverity.error,
          time: '30 minutes ago',
        ),
        const SizedBox(height: UIConstants.spacingS),
        _buildAlertCard(
          title: 'Watering Required',
          plant: 'Mint Plant',
          message: 'Scheduled watering cycle is due',
          severity: AlertSeverity.info,
          time: '1 hour ago',
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String plant,
    required String message,
    required AlertSeverity severity,
    required String time,
  }) {
    Color alertColor;
    IconData alertIcon;
    
    switch (severity) {
      case AlertSeverity.error:
        alertColor = AppColors.error;
        alertIcon = Icons.error;
        break;
      case AlertSeverity.warning:
        alertColor = AppColors.warning;
        alertIcon = Icons.warning;
        break;
      case AlertSeverity.info:
        alertColor = AppColors.info;
        alertIcon = Icons.info;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        child: Row(
          children: [
            Icon(
              alertIcon,
              color: alertColor,
              size: UIConstants.iconL,
            ),
            const SizedBox(width: UIConstants.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  Text(
                    plant,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  Text(
                    message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Dismiss alert
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alert dismissed'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Status',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: UIConstants.spacingL),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.paddingL),
            child: Column(
              children: [
                _buildStatusItem(
                  title: 'IoT Gateway',
                  status: 'Online',
                  isOnline: true,
                ),
                const Divider(),
                _buildStatusItem(
                  title: 'Cloud Sync',
                  status: 'Synced',
                  isOnline: true,
                ),
                const Divider(),
                _buildStatusItem(
                  title: 'Auto Watering System',
                  status: 'Active',
                  isOnline: true,
                ),
                const Divider(),
                _buildStatusItem(
                  title: 'Weather Integration',
                  status: 'Connected',
                  isOnline: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String status,
    required bool isOnline,
  }) {
    return Row(
      children: [
        Icon(
          isOnline ? Icons.check_circle : Icons.error_outline,
          color: isOnline ? AppColors.online : AppColors.offline,
          size: UIConstants.iconM,
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          status,
          style: AppTextStyles.bodySmall.copyWith(
            color: isOnline ? AppColors.online : AppColors.offline,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: UIConstants.spacingL),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.paddingL),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.water_drop,
                  title: 'Auto watering completed',
                  subtitle: 'Tomato Plant #1',
                  time: '5 minutes ago',
                  color: AppColors.humidity,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.eco,
                  title: 'New plant added',
                  subtitle: 'Lavender Plant',
                  time: '2 hours ago',
                  color: AppColors.primaryGreen,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.settings,
                  title: 'Threshold updated',
                  subtitle: 'Basil Garden',
                  time: '6 hours ago',
                  color: AppColors.info,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.wifi,
                  title: 'Device reconnected',
                  subtitle: 'Mint Plant sensor',
                  time: '1 day ago',
                  color: AppColors.online,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.paddingS),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: Icon(
            icon,
            color: color,
            size: UIConstants.iconM,
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXS),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
  }
}

enum AlertSeverity { error, warning, info }
