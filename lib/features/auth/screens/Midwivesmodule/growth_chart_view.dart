import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/growth_chart_input.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewGraphScreen extends StatefulWidget {
  final List<GrowthEntry> entries;

  const ViewGraphScreen({super.key, required this.entries});

  @override
  State<ViewGraphScreen> createState() => _ViewGraphScreenState();
}

class _ViewGraphScreenState extends State<ViewGraphScreen> {
  final GlobalKey _chartKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredNics = [];
  String? _selectedNic;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Sort entries by date
    widget.entries.sort((a, b) => b.date.compareTo(a.date));

    _filteredNics = widget.entries.map((e) => e.motherNic).toSet().toList();
    if (_filteredNics.isNotEmpty) {
      _selectedNic = widget.entries.first.motherNic;
      _fetchEntriesFromBackend(_selectedNic!);
    }

    _searchController.addListener(() {
      String search = _searchController.text.toLowerCase();
      setState(() {
        _filteredNics = widget.entries
            .map((e) => e.motherNic)
            .toSet()
            .where((nic) => nic.toLowerCase().contains(search))
            .toList();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocus);
    });
  }

  Future<void> _downloadGraph() async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

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

  Future<void> _fetchEntriesFromBackend(String nic) async {
    final url = Uri.parse('http://10.11.8.134:8080/api/growth/get/$nic');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        List<GrowthEntry> fetchedEntries = data
            .map(
              (e) => GrowthEntry(
                motherNic: e['motherNic'],
                height: e['height'],
                weight: e['weight'],
                date: DateTime.parse(e['date']),
              ),
            )
            .toList();
        setState(() {
          // Replace widget.entries with fetched data for this NIC
          widget.entries.clear();
          widget.entries.addAll(fetchedEntries);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _selectedNic == null
        ? []
        : widget.entries
              .where((entry) => entry.motherNic == _selectedNic)
              .toList();

    final spotsHeight = filteredEntries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.height.toDouble());
    }).toList();

    final spotsWeight = filteredEntries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight.toDouble());
    }).toList();

    final dates = filteredEntries.map((e) {
      return DateFormat('d MMM').format(e.date);
    }).toList();

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
          // Header + Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.show_chart, size: 50, color: Colors.white),
                const SizedBox(width: 16),
                const Text(
                  "Mother's Growth Chart",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // NIC Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Search Mother NIC:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  focusNode: _searchFocus,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Type NIC to search...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _filteredNics.map((nic) {
                      bool isSelected = nic == _selectedNic;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedNic = nic;
                          });
                          _fetchEntriesFromBackend(
                            nic,
                          ); // Fetch backend entries
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.shade600
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            nic,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
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

          const SizedBox(height: 12),

          // Graph
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _chartKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: filteredEntries.isEmpty
                      ? const Center(
                          child: Text(
                            "No data for this NIC",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.blue.shade100,
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.purple.shade100,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
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
                                      return Text(
                                        dates[value.toInt()],
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 2,
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spotsHeight,
                                isCurved: true,
                                barWidth: 3,
                                color: Colors.blue,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              LineChartBarData(
                                spots: spotsWeight,
                                isCurved: true,
                                barWidth: 3,
                                color: Colors.orange,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.3),
                                      Colors.orange.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
