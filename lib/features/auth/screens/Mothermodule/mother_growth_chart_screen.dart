import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/api_config.dart';
import '../../../../services/user_service.dart';
import '../../../../widgets/custom_loading.dart';
import '../../../../l10n/app_localizations.dart';

class GrowthEntry {
  final DateTime date;
  final double height;
  final double weight;
  final String motherNic;

  GrowthEntry({
    required this.date,
    required this.height,
    required this.weight,
    required this.motherNic,
  });

  factory GrowthEntry.fromJson(Map<String, dynamic> json) {
    return GrowthEntry(
      date: DateTime.parse(json['date']),
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      motherNic: json['motherNic'],
    );
  }
}

class MotherGrowthChartScreen extends StatefulWidget {
  const MotherGrowthChartScreen({super.key});

  @override
  State<MotherGrowthChartScreen> createState() =>
      _MotherGrowthChartScreenState();
}

class _MotherGrowthChartScreenState extends State<MotherGrowthChartScreen> {
  List<GrowthEntry> _growthData = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _motherNic;

  @override
  void initState() {
    super.initState();
    _loadGrowthData();
  }

  Future<void> _loadGrowthData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current mother's NIC from user session
      _motherNic = await UserService.getUserNic();

      if (_motherNic == null || _motherNic!.isEmpty) {
        throw Exception('User session not found. Please login again.');
      }

      print('Debug: Loading growth data for mother NIC: $_motherNic');

      // Fetch growth data from backend
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}/growth/get/$_motherNic'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Debug: Growth data response status: ${response.statusCode}');
      print('Debug: Growth data response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final growthEntries = data.map((e) => GrowthEntry.fromJson(e)).toList();

        // Sort by date (oldest first for better chart visualization)
        growthEntries.sort((a, b) => a.date.compareTo(b.date));

        setState(() {
          _growthData = growthEntries;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load growth data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading growth data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4FC3A1),
        title: Text(
          localizations.babyGrowthChart,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CustomLoading(
                message: 'Loading your baby\'s growth data...',
                size: 100,
                backgroundColor: Colors.transparent,
              ),
            )
          : _errorMessage != null
          ? _buildErrorWidget()
          : _growthData.isEmpty
          ? _buildEmptyWidget()
          : _buildGrowthChart(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadGrowthData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.baby_changing_station,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Growth Data Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your midwife will update your baby\'s growth measurements during visits. Check back after your next appointment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadGrowthData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChart() {
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.show_chart, size: 48, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.babyGrowthChartTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your baby\'s health progress 💚',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats Cards
          if (_growthData.isNotEmpty) _buildStatsCards(),

          const SizedBox(height: 20),

          // Growth Chart
          _buildChartSection(),

          const SizedBox(height: 20),

          // Recent Measurements
          _buildRecentMeasurements(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final localizations = AppLocalizations.of(context)!;
    final latestEntry = _growthData.last;

    double? weightChange;
    double? heightChange;

    if (_growthData.length > 1) {
      final previousEntry = _growthData[_growthData.length - 2];
      weightChange = latestEntry.weight - previousEntry.weight;
      heightChange = latestEntry.height - previousEntry.height;
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Current ${localizations.weight}',
            value:
                '${latestEntry.weight.toStringAsFixed(1)} ${localizations.kg}',
            change: weightChange != null
                ? '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}${localizations.kg}'
                : null,
            isPositive: weightChange == null ? true : weightChange >= 0,
            icon: Icons.monitor_weight,
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Current ${localizations.height}',
            value:
                '${latestEntry.height.toStringAsFixed(1)} ${localizations.cm}',
            change: heightChange != null
                ? '${heightChange >= 0 ? '+' : ''}${heightChange.toStringAsFixed(1)}${localizations.cm}'
                : null,
            isPositive: heightChange == null ? true : heightChange >= 0,
            icon: Icons.height,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'CircularStd',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'CircularStd',
            ),
          ),
          if (change != null) ...[
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
                fontFamily: 'CircularStd',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final localizations = AppLocalizations.of(context)!;

    // Prepare chart data
    final weightSpots = _growthData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final heightSpots = _growthData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.height);
    }).toList();

    final dates = _growthData.map((entry) {
      return DateFormat('MMM d').format(entry.date);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.growthChartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D5A),
              fontFamily: 'CircularStd',
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Weight (kg)', const Color(0xFF2196F3)),
              const SizedBox(width: 24),
              _buildLegendItem('Height (cm)', const Color(0xFF4CAF50)),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  getDrawingVerticalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontFamily: 'CircularStd',
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < dates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                lineBarsData: [
                  // Weight line
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: true,
                    color: const Color(0xFF2196F3),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2196F3).withOpacity(0.2),
                          const Color(0xFF2196F3).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Height line
                  LineChartBarData(
                    spots: heightSpots,
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withOpacity(0.2),
                          const Color(0xFF4CAF50).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'CircularStd',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMeasurements() {
    final localizations = AppLocalizations.of(context)!;

    // Show last 3 measurements
    final recentData = _growthData.length > 3
        ? _growthData.sublist(_growthData.length - 3)
        : _growthData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.recentMeasurements,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D5A),
              fontFamily: 'CircularStd',
            ),
          ),
          const SizedBox(height: 16),
          ...recentData.reversed.map((entry) => _buildMeasurementCard(entry)),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(GrowthEntry entry) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3A1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.child_care, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(entry.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2E7D5A),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${localizations.weight}: ${entry.weight.toStringAsFixed(1)} ${localizations.kg} • ${localizations.height}: ${entry.height.toStringAsFixed(1)} ${localizations.cm}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'CircularStd',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
