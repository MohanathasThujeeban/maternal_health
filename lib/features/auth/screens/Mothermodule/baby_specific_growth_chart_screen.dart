import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_loading.dart';
import '../../../../services/baby_service.dart';
import '../../../../services/growth_entry_service.dart';
import '../../../../services/user_service.dart';
import '../../../../models/growth_entry.dart';

class BabySpecificGrowthChartScreen extends StatefulWidget {
  const BabySpecificGrowthChartScreen({super.key});

  @override
  State<BabySpecificGrowthChartScreen> createState() =>
      _BabySpecificGrowthChartScreenState();
}

class _BabySpecificGrowthChartScreenState
    extends State<BabySpecificGrowthChartScreen> {
  List<Map<String, dynamic>> babies = [];
  Map<String, dynamic>? selectedBaby;
  List<GrowthEntry> growthData = [];
  bool isLoading = true;
  bool isLoadingChart = false;
  String? errorMessage;
  String chartType = 'weight'; // 'weight' or 'height'

  // Global key for chart widget to capture it as image
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadBabies();
  }

  Future<void> _loadBabies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final babyList = await BabyService.getMyBabies();

      // Debug: Print baby data to see what fields are available
      print('Debug: Loaded babies: $babyList');
      for (var baby in babyList) {
        print('Debug: Baby data keys: ${baby.keys.toList()}');
        print('Debug: Baby data: $baby');
      }

      setState(() {
        babies = babyList;
        isLoading = false;
        // Auto-select first baby if available
        if (babies.isNotEmpty) {
          selectedBaby = babies.first;
          _loadGrowthData();
        }
      });
    } catch (e) {
      print('Debug: Error loading babies: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadGrowthData() async {
    if (selectedBaby == null) return;

    setState(() {
      isLoadingChart = true;
    });

    try {
      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];
      final babyId = selectedBaby!['id'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final entries = await GrowthEntryService.getEntriesByMotherAndBaby(
        motherNic,
        babyId,
      );

      // Sort by date (oldest first)
      entries.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        growthData = entries;
        isLoadingChart = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingChart = false;
      });
    }
  }

  // Method to capture chart as image and download it
  Future<void> _downloadChartAsImage() async {
    try {
      if (selectedBaby == null || growthData.isEmpty) {
        _showSnackBar('No chart data available to download', Colors.red);
        return;
      }

      // Find the chart widget
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get directory to save file
      final directory = await getApplicationDocumentsDirectory();
      final babyName = _getBabyName(selectedBaby!);
      final fileName =
          '${babyName}_${chartType}_chart_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.png';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '$babyName\'s $chartType growth chart');

      _showSnackBar('Chart downloaded successfully!', Colors.green);
    } catch (e) {
      print('Error downloading chart: $e');
      _showSnackBar('Failed to download chart: $e', Colors.red);
    }
  }

  // Method to generate and download PDF report
  Future<void> _downloadChartAsPDF() async {
    try {
      if (selectedBaby == null || growthData.isEmpty) {
        _showSnackBar('No chart data available to download', Colors.red);
        return;
      }

      final babyName = _getBabyName(selectedBaby!);
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#4FC3A1'),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$babyName - ${chartType.toUpperCase()} Growth Chart',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Baby Information
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Baby Information',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text('Name: $babyName'),
                      pw.Text(
                        'Gender: ${selectedBaby!['gender'] ?? 'Not specified'}',
                      ),
                      if (selectedBaby!['dateOfBirth'] != null)
                        pw.Text(
                          'Date of Birth: ${selectedBaby!['dateOfBirth']}',
                        ),
                      pw.Text('Total Measurements: ${growthData.length}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Growth Data Table
                pw.Text(
                  '${chartType.toUpperCase()} Measurements',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F0F9F7'),
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Date',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            chartType == 'weight'
                                ? 'Weight (kg)'
                                : 'Height (cm)',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Notes',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    // Data rows
                    ...growthData.map(
                      (entry) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              DateFormat('MMM dd, yyyy').format(entry.date),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              chartType == 'weight'
                                  ? entry.weight.toStringAsFixed(1)
                                  : entry.height.toStringAsFixed(1),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Normal growth'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save and share the PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${babyName}_${chartType}_report_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '$babyName\'s $chartType growth report');

      _showSnackBar('PDF report generated successfully!', Colors.green);
    } catch (e) {
      print('Error generating PDF: $e');
      _showSnackBar('Failed to generate PDF: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Download Options',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                  fontFamily: 'CircularStd',
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF4FC3A1)),
                title: const Text('Download as Image'),
                subtitle: const Text('Save chart as PNG image'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadChartAsImage();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF4FC3A1),
                ),
                title: const Text('Download as PDF Report'),
                subtitle: const Text('Generate detailed PDF with growth data'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadChartAsPDF();
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'CircularStd',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        actions: [
          if (selectedBaby != null && growthData.isNotEmpty) ...[
            // Download as Image button
            IconButton(
              onPressed: _downloadChartAsImage,
              icon: const Icon(Icons.image, color: Colors.white),
              tooltip: 'Download as Image',
            ),
            // Download as PDF button
            IconButton(
              onPressed: _downloadChartAsPDF,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              tooltip: 'Download as PDF',
            ),
          ],
        ],
      ),
      body: isLoading
          ? Center(
              child: CustomLoading(
                message: 'Loading your babies...',
                size: 100,
                backgroundColor: Colors.transparent,
              ),
            )
          : babies.isEmpty
          ? _buildNoBabiesWidget()
          : _buildMainContent(),
      floatingActionButton: (selectedBaby != null && growthData.isNotEmpty)
          ? FloatingActionButton(
              onPressed: _showDownloadOptions,
              backgroundColor: const Color(0xFF4FC3A1),
              child: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Download Chart',
            )
          : null,
    );
  }

  Widget _buildNoBabiesWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No babies found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please add a baby to view growth charts',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'CircularStd',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Baby',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'CircularStd',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baby Selection Section
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Baby',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                  fontFamily: 'CircularStd',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedBaby,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Choose a baby'),
                  items: babies.map((baby) {
                    DateTime? birthDate;

                    // Debug: Print all date-related fields for this baby
                    print('Debug: Baby data for age calculation: $baby');
                    print('Debug: dateOfBirth field: ${baby['dateOfBirth']}');
                    print('Debug: birthDate field: ${baby['birthDate']}');
                    print('Debug: All keys: ${baby.keys.toList()}');

                    // Try multiple field names for birth date
                    final dateString = baby['dateOfBirth'] ?? baby['birthDate'];

                    try {
                      if (dateString != null &&
                          dateString.toString().isNotEmpty) {
                        // Handle different date formats
                        String dateStr = dateString.toString();
                        // If it's just YYYY-MM-DD, add time for parsing
                        if (dateStr.length == 10 && dateStr.contains('-')) {
                          dateStr += 'T00:00:00.000Z';
                        }
                        birthDate = DateTime.parse(dateStr);
                        print(
                          'Debug: Successfully parsed birth date: $birthDate',
                        );
                      }
                    } catch (e) {
                      print(
                        'Debug: Error parsing birth date for baby: $dateString, error: $e',
                      );
                    }

                    final age = birthDate != null
                        ? _calculateAge(birthDate)
                        : 'Unknown age';

                    print('Debug: Calculated age: $age');

                    // Handle multiple possible field names for baby name
                    final babyName = _getBabyName(baby);

                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: baby,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FC3A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              baby['gender'] == 'male'
                                  ? Icons.boy
                                  : baby['gender'] == 'female'
                                  ? Icons.girl
                                  : Icons.child_care,
                              color: const Color(0xFF4FC3A1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  babyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                                Text(
                                  age,
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
                  }).toList(),
                  onChanged: (baby) {
                    setState(() {
                      selectedBaby = baby;
                    });
                    if (baby != null) {
                      _loadGrowthData();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Chart Type Toggle
        if (selectedBaby != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        chartType = 'weight';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chartType == 'weight'
                          ? const Color(0xFF4FC3A1)
                          : Colors.grey.shade300,
                      foregroundColor: chartType == 'weight'
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      localizations.weight,
                      style: const TextStyle(fontFamily: 'CircularStd'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        chartType = 'height';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chartType == 'height'
                          ? const Color(0xFF4FC3A1)
                          : Colors.grey.shade300,
                      foregroundColor: chartType == 'height'
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      localizations.height,
                      style: const TextStyle(fontFamily: 'CircularStd'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Chart Section
        Expanded(
          child: selectedBaby == null
              ? const Center(
                  child: Text(
                    'Please select a baby to view growth chart',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                )
              : isLoadingChart
              ? Center(
                  child: CustomLoading(
                    message:
                        'Loading ${_getBabyName(selectedBaby!)}\'s growth data...',
                    size: 80,
                    backgroundColor: Colors.transparent,
                  ),
                )
              : growthData.isEmpty
              ? _buildNoDataWidget()
              : _buildChart(),
        ),
      ],
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No growth data available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Growth records will appear here once the midwife adds them during checkups',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'CircularStd',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final localizations = AppLocalizations.of(context)!;

    if (growthData.isEmpty) {
      return _buildNoDataWidget();
    }

    // Prepare chart data
    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < growthData.length; i++) {
      final entry = growthData[i];
      final value = chartType == 'weight' ? entry.weight : entry.height;
      spots.add(FlSpot(i.toDouble(), value));

      if (value < minY) minY = value;
      if (value > maxY) maxY = value;
    }

    // Add some padding to min/max values
    // If maxY and minY are equal, set a small default difference
    final double difference = (maxY - minY) <= 0
        ? maxY * 0.1 + 0.1
        : (maxY - minY);
    final padding = difference * 0.1;
    minY = (minY - padding).clamp(0, double.infinity);
    maxY = maxY + padding;

    return RepaintBoundary(
      key: _chartKey,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  chartType == 'weight' ? Icons.monitor_weight : Icons.height,
                  color: const Color(0xFF4FC3A1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getBabyName(selectedBaby!)} - ${chartType == 'weight' ? localizations.weight : localizations.height} Chart',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      Text(
                        '${growthData.length} measurements recorded',
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
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF4FC3A1),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4FC3A1).withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontFamily: 'CircularStd',
                            ),
                          );
                        },
                      ),
                      axisNameWidget: Text(
                        chartType == 'weight'
                            ? '${localizations.weight} (kg)'
                            : '${localizations.height} (cm)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < growthData.length) {
                            final date = growthData[index].date;
                            return Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontFamily: 'CircularStd',
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      axisNameWidget: const Text(
                        'Months',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) <= 0
                        ? 1.0
                        : (maxY - minY) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          if (index >= 0 && index < growthData.length) {
                            final entry = growthData[index];
                            final value = chartType == 'weight'
                                ? entry.weight
                                : entry.height;
                            final unit = chartType == 'weight' ? 'kg' : 'cm';
                            final date = DateFormat(
                              'MMM dd, yyyy',
                            ).format(entry.date);

                            return LineTooltipItem(
                              '$value $unit\n$date',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'CircularStd',
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Latest measurement
            if (growthData.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF4FC3A1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest Measurement',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          Text(
                            '${chartType == 'weight' ? growthData.last.weight : growthData.last.height} ${chartType == 'weight' ? 'kg' : 'cm'} on ${DateFormat('MMM dd, yyyy').format(growthData.last.date)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ), // Column closing
      ), // Container closing
    ); // RepaintBoundary closing
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final days = difference.inDays;

    if (days < 30) {
      return '$days days old';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months months old';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? 'year' : 'years'} old';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'}, $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'} old';
      }
    }
  }

  String _getBabyName(Map<String, dynamic> baby) {
    return baby['name'] ??
        baby['babyName'] ??
        baby['fullName'] ??
        'Unknown Baby';
  }
}
