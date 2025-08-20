import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/growth_chart_input.dart';
import 'package:flutter/rendering.dart';

class ViewGraphScreen extends StatefulWidget {
  final List<GrowthEntry> entries;

  const ViewGraphScreen({super.key, required this.entries});

  @override
  State<ViewGraphScreen> createState() => _ViewGraphScreenState();
}

class _ViewGraphScreenState extends State<ViewGraphScreen> {
  final GlobalKey _chartKey = GlobalKey();

  Future<void> _downloadGraph() async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save or share - here using share_plus for quick demo
      await Share.shareXFiles([
        XFile.fromData(
          pngBytes,
          name: "growth_chart.png",
          mimeType: "image/png",
        ),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving graph: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare height & weight data for FL Chart
    final spotsHeight = widget.entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.height.toDouble());
    }).toList();

    final spotsWeight = widget.entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight.toDouble());
    }).toList();

    final months = widget.entries
        .map((e) => DateFormat.MMM().format(e.date))
        .toList();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text(
          "Growth Graph",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadGraph,
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _chartKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.purple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(months[value.toInt()]);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsHeight,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: spotsWeight,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.orange,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
