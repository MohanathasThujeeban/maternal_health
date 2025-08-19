import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
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
    List<charts.Series<GrowthEntry, String>> seriesList = [
      charts.Series<GrowthEntry, String>(
        id: 'Height',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (GrowthEntry entry, _) => DateFormat.MMM().format(entry.date),
        measureFn: (GrowthEntry entry, _) => entry.height,
        data: widget.entries,
      ),
      charts.Series<GrowthEntry, String>(
        id: 'Weight',
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (GrowthEntry entry, _) => DateFormat.MMM().format(entry.date),
        measureFn: (GrowthEntry entry, _) => entry.weight,
        data: widget.entries,
      ),
    ];

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
            child: charts.LineChart(
              seriesList,
              animate: true,
              defaultRenderer: charts.LineRendererConfig(
                includePoints: true,
                includeArea: true,
                stacked: false,
              ),
              domainAxis: const charts.OrdinalAxisSpec(),
              primaryMeasureAxis: const charts.NumericAxisSpec(),
            ),
          ),
        ),
      ),
    );
  }
}
