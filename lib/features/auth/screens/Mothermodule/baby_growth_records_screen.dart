import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:maternal_health/services/user_service.dart';
import 'package:maternal_health/config/api_config.dart';
import 'dart:convert';

class BabyGrowthRecordsScreen extends StatefulWidget {
  BabyGrowthRecordsScreen({super.key});

  @override
  State<BabyGrowthRecordsScreen> createState() =>
      _BabyGrowthRecordsScreenState();
}

class _BabyGrowthRecordsScreenState extends State<BabyGrowthRecordsScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> growthData = [];

  @override
  void initState() {
    super.initState();
    _loadGrowthData();
  }

  Future<void> _loadGrowthData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/growth/get/$motherNic'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          growthData = data
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          // Sort by date descending
          growthData.sort(
            (a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
          );
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load growth data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Growth Records',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          flexibleSpace: ClipPath(
            clipper: AppBarClipper(),
            child: Container(color: const Color(0xFF4FC3A1)),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3A1)),
              ),
            )
          : errorMessage != null
          ? _buildErrorWidget()
          : growthData.isEmpty
          ? const Center(
              child: Text(
                'No growth records found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGrowthChart(),
                  const SizedBox(height: 24),
                  _buildGrowthHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadGrowthData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    if (growthData.isEmpty) return const SizedBox.shrink();

    final List<FlSpot> heightSpots = [];
    final List<FlSpot> weightSpots = [];
    final List<String> dates = [];

    for (var i = 0; i < growthData.length; i++) {
      final entry = growthData[i];
      final height = (entry['height'] as num).toDouble();
      final weight = (entry['weight'] as num).toDouble();
      final date = DateTime.parse(entry['date']);

      heightSpots.add(FlSpot(i.toDouble(), height));
      weightSpots.add(FlSpot(i.toDouble(), weight));
      dates.add(DateFormat('MMM d').format(date));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xFFE0E0E0), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < dates.length &&
                      value.toInt() % 2 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dates[value.toInt()],
                        style: const TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: heightSpots,
              isCurved: true,
              color: const Color(0xFF4FC3A1),
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
            LineChartBarData(
              spots: weightSpots,
              isCurved: true,
              color: const Color(0xFFFF9800),
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Growth History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D5A),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: growthData.length,
          itemBuilder: (context, index) {
            final entry = growthData[index];
            final date = DateFormat(
              'MMM d, yyyy',
            ).format(DateTime.parse(entry['date']));

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Height: ${(entry['height'] as num).toDouble()} cm',
                      style: const TextStyle(color: Color(0xFF4FC3A1)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weight: ${(entry['weight'] as num).toDouble()} kg',
                      style: const TextStyle(color: Color(0xFFFF9800)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
