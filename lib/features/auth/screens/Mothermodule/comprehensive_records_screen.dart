import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../config/api_config.dart';
import '../../../../services/user_service.dart';
import '../../../../services/eye_ear_record_service.dart';
import '../../../../widgets/custom_loading.dart';

class ComprehensiveRecordsScreen extends StatefulWidget {
  const ComprehensiveRecordsScreen({super.key});

  @override
  State<ComprehensiveRecordsScreen> createState() =>
      _ComprehensiveRecordsScreenState();
}

class _ComprehensiveRecordsScreenState
    extends State<ComprehensiveRecordsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _motherNic;
  String? _motherName;

  // All record types
  List<Map<String, dynamic>> _vaccinationRecords = [];
  List<Map<String, dynamic>> _thiriposaRecords = [];
  List<Map<String, dynamic>> _growthRecords = [];
  List<Map<String, dynamic>> _eyeEarRecords = [];
  List<Map<String, dynamic>> _doctorNotes = [];

  @override
  void initState() {
    super.initState();
    _loadAllRecords();
  }

  Future<void> _loadAllRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user data
      final userData = await UserService.getUserData();
      _motherNic = userData['nic'];
      _motherName = userData['fullName'] ?? userData['name'];

      if (_motherNic == null) {
        throw Exception('User not logged in');
      }

      // Load all records in parallel
      await Future.wait([
        _loadVaccinationRecords(),
        _loadThiriposaRecords(),
        _loadGrowthRecords(),
        _loadEyeEarRecords(),
        _loadDoctorNotes(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVaccinationRecords() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/vaccinations/mother/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _vaccinationRecords = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error loading vaccination records: $e');
    }
  }

  Future<void> _loadThiriposaRecords() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/thiriposa/get/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _thiriposaRecords = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error loading thiriposa records: $e');
    }
  }

  Future<void> _loadGrowthRecords() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/growth/get/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _growthRecords = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error loading growth records: $e');
    }
  }

  Future<void> _loadEyeEarRecords() async {
    try {
      final records = await EyeEarRecordService.getMyBabyRecords();
      _eyeEarRecords = records;
    } catch (e) {
      print('Error loading eye/ear records: $e');
    }
  }

  Future<void> _loadDoctorNotes() async {
    try {
      // Assuming there's a doctor notes endpoint
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/doctor-notes/mother/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _doctorNotes = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error loading doctor notes: $e');
      // Doctor notes might not exist yet, that's okay
    }
  }

  Future<void> _generatePDFReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Maternal Health Records',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal,
                    ),
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Mother Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Mother Information',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Name: ${_motherName ?? 'N/A'}'),
                  pw.Text('NIC: ${_motherNic ?? 'N/A'}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Records Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Records Summary',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Vaccination Records: ${_vaccinationRecords.length}'),
                  pw.Text('Thiriposa Records: ${_thiriposaRecords.length}'),
                  pw.Text('Growth Records: ${_growthRecords.length}'),
                  pw.Text('Eye & Ear Records: ${_eyeEarRecords.length}'),
                  pw.Text('Doctor Notes: ${_doctorNotes.length}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Vaccination Records
            if (_vaccinationRecords.isNotEmpty) ...[
              pw.Text(
                'Vaccination Records',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Vaccine', 'Dose', 'Notes'],
                data: _vaccinationRecords
                    .map(
                      (record) => [
                        record['vaccinationDate'] ?? 'N/A',
                        record['vaccineName'] ?? 'N/A',
                        record['dose']?.toString() ?? 'N/A',
                        record['notes'] ?? 'N/A',
                      ],
                    )
                    .toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
            ],

            // Growth Records
            if (_growthRecords.isNotEmpty) ...[
              pw.Text(
                'Growth Records',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Height (cm)', 'Weight (kg)'],
                data: _growthRecords
                    .map(
                      (record) => [
                        record['date'] ?? 'N/A',
                        record['height']?.toString() ?? 'N/A',
                        record['weight']?.toString() ?? 'N/A',
                      ],
                    )
                    .toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
            ],

            // Eye & Ear Records
            if (_eyeEarRecords.isNotEmpty) ...[
              pw.Text(
                'Eye & Ear Records',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Eye Problem',
                  'Ear Problem',
                  'Duration',
                  'Remarks',
                ],
                data: _eyeEarRecords
                    .map(
                      (record) => [
                        record['dateOfDiagnosis'] ?? 'N/A',
                        record['eyeProblem'] ?? 'N/A',
                        record['earProblem'] ?? 'N/A',
                        record['symptomsDuration'] ?? 'N/A',
                        record['remarks'] ?? 'N/A',
                      ],
                    )
                    .toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
            ],

            // Thiriposa Records
            if (_thiriposaRecords.isNotEmpty) ...[
              pw.Text(
                'Thiriposa Supplement Records',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Quantity', 'Notes'],
                data: _thiriposaRecords
                    .map(
                      (record) => [
                        record['date'] ?? 'N/A',
                        record['quantity']?.toString() ?? 'N/A',
                        record['notes'] ?? 'N/A',
                      ],
                    )
                    .toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
            ],

            // Doctor Notes
            if (_doctorNotes.isNotEmpty) ...[
              pw.Text(
                'Doctor Notes',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...(_doctorNotes.map(
                (note) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Date: ${note['date'] ?? 'N/A'}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Doctor: ${note['doctorName'] ?? 'N/A'}'),
                      pw.SizedBox(height: 4),
                      pw.Text('Notes: ${note['notes'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              )),
            ],

            // Footer
            pw.SizedBox(height: 30),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'This report was generated by Maternal Health Care System',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Maternal_Health_Records_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: CustomLoading());
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Records'),
          backgroundColor: const Color(0xFF4FC3A1),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAllRecords,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'All Records',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF Report',
            onPressed: _generatePDFReport,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadAllRecords,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllRecords,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Records Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mother: ${_motherName ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'NIC: ${_motherNic ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            'Vaccination',
                            _vaccinationRecords.length,
                          ),
                          _buildSummaryItem('Growth', _growthRecords.length),
                          _buildSummaryItem('Eye & Ear', _eyeEarRecords.length),
                          _buildSummaryItem(
                            'Thiriposa',
                            _thiriposaRecords.length,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Generate PDF Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generatePDFReport,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text(
                    'Generate PDF Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Records Sections
              _buildRecordsSection(
                'Vaccination Records',
                Icons.vaccines,
                _vaccinationRecords,
                _buildVaccinationCard,
              ),

              _buildRecordsSection(
                'Growth Records',
                Icons.trending_up,
                _growthRecords,
                _buildGrowthCard,
              ),

              _buildRecordsSection(
                'Eye & Ear Records',
                Icons.visibility,
                _eyeEarRecords,
                _buildEyeEarCard,
              ),

              _buildRecordsSection(
                'Thiriposa Supplement Records',
                Icons.inventory_2,
                _thiriposaRecords,
                _buildThiriposaCard,
              ),

              if (_doctorNotes.isNotEmpty)
                _buildRecordsSection(
                  'Doctor Notes',
                  Icons.note_alt,
                  _doctorNotes,
                  _buildDoctorNotesCard,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRecordsSection(
    String title,
    IconData icon,
    List<Map<String, dynamic>> records,
    Widget Function(Map<String, dynamic>) cardBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4FC3A1), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${records.length}',
                style: const TextStyle(
                  color: Color(0xFF4FC3A1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(icon, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No ${title.toLowerCase()} found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: cardBuilder(record),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.vaccines, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['vaccineName'] ?? 'Unknown Vaccine',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${record['vaccinationDate'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (record['dose'] != null)
                    Text(
                      'Dose: ${record['dose']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (record['notes'] != null &&
                      record['notes'].toString().isNotEmpty)
                    Text(
                      'Notes: ${record['notes']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Growth Record',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${record['date'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      Text(
                        'Height: ${record['height'] ?? 'N/A'} cm',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Weight: ${record['weight'] ?? 'N/A'} kg',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeEarCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.visibility,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['patientName'] ?? 'Eye & Ear Record',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${record['dateOfDiagnosis'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (record['eyeProblem'] != 'None')
                    Text(
                      'Eye: ${record['eyeProblem'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (record['earProblem'] != 'None')
                    Text(
                      'Ear: ${record['earProblem'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (record['remarks'] != null &&
                      record['remarks'].toString().isNotEmpty)
                    Text(
                      'Remarks: ${record['remarks']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThiriposaCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thiriposa Supplement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${record['date'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Quantity: ${record['quantity'] ?? 'N/A'} packets',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (record['notes'] != null &&
                      record['notes'].toString().isNotEmpty)
                    Text(
                      'Notes: ${record['notes']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorNotesCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.note_alt, color: Colors.teal, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${record['doctorName'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${record['date'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    record['notes'] ?? 'No notes available',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
