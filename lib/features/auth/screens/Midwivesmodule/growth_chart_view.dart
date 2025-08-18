import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';

// Growth Entry Model
class GrowthEntry {
  final DateTime date;
  final double height;
  final double weight;

  GrowthEntry({
    required this.date,
    required this.height,
    required this.weight,
  });
}

class ViewGraphScreen extends StatefulWidget {
  final List<GrowthEntry> entries;

  const ViewGraphScreen({super.key, required this.entries});

  @override
  State<ViewGraphScreen> createState() => _ViewGraphScreenState();
}

class _ViewGraphScreenState extends State<ViewGraphScreen> {
  final GlobalKey _chartKey = GlobalKey();
  bool _showHeight = true;
  bool _showWeight = true;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving graph: $e")),
      );
    }
  }

  List<FlSpot> _getHeightSpots() {
    return widget.entries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.height);
    }).toList();
  }

  List<FlSpot> _getWeightSpots() {
    return widget.entries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          title: const Text(
            "Growth Graph",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            "No growth data available",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

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
      body: Column(
        children: [
          // Toggle buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Height'),
                  selected: _showHeight,
                  onSelected: (selected) {
                    setState(() {
                      _showHeight = selected;
                    });
                  },
                  selectedColor: Colors.blue.withOpacity(0.3),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Weight'),
                  selected: _showWeight,
                  onSelected: (selected) {
                    setState(() {
                      _showWeight = selected;
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                ),
              ],
            ),
          ),
          // Chart
          Expanded(
            child: RepaintBoundary(
              key: _chartKey,
              child: Container(
                margin: const EdgeInsets.all(16),
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
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() >= 0 && 
                                value.toInt() < widget.entries.length) {
                              final entry = widget.entries[value.toInt()];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  DateFormat.MMM().format(entry.date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
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
                          interval: 5,
                          reservedSize: 40,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
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
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    lineBarsData: [
                      if (_showHeight)
                        LineChartBarData(
                          spots: _getHeightSpots(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          dotData: const FlDotData(show: true),
                        ),
                      if (_showWeight)
                        LineChartBarData(
                          spots: _getWeightSpots(),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withOpacity(0.1),
                          ),
                          dotData: const FlDotData(show: true),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showHeight) ...[
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Text('Height (cm)'),
                  const SizedBox(width: 20),
                ],
                if (_showWeight) ...[
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  const Text('Weight (kg)'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
