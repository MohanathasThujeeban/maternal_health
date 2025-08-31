import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../services/comprehensive_records_service.dart';

class ComprehensiveRecordsScreen extends StatefulWidget {
  final Map<String, dynamic> mother;

  const ComprehensiveRecordsScreen({super.key, required this.mother});

  @override
  State<ComprehensiveRecordsScreen> createState() =>
      _ComprehensiveRecordsScreenState();
}

class _ComprehensiveRecordsScreenState extends State<ComprehensiveRecordsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _allRecords;
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRecords() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final motherNic = widget.mother['nicNumber'] ?? '';
      final records = await ComprehensiveRecordsService.getAllRecords(
        motherNic,
      );

      if (!mounted) return;

      setState(() {
        _allRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'N/A';
      }
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _exportToPdf() async {
    if (_allRecords == null) return;

    try {
      final pdf = pw.Document();

      // Add comprehensive single-page report
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Comprehensive Health Records',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Maternal Health Care System',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Mother Information Section
              pw.Text(
                'Patient Information',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfInfoSection([
                ['Full Name', widget.mother['fullName'] ?? 'N/A'],
                ['NIC Number', widget.mother['nicNumber'] ?? 'N/A'],
                ['Email Address', widget.mother['email'] ?? 'N/A'],
                ['Phone Number', widget.mother['phoneNumber'] ?? 'N/A'],
                ['Address', widget.mother['address'] ?? 'N/A'],
                [
                  'Registration Date',
                  _formatDate(widget.mother['registrationDate']),
                ],
                ['Report Generated', _formatDate(DateTime.now())],
              ]),
              pw.SizedBox(height: 30),

              // Records Summary Section
              pw.Text(
                'Records Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfInfoSection([
                [
                  'Total Vaccination Records',
                  '${(_allRecords!['vaccinationRecords'] as List).length}',
                ],
                [
                  'Total Thiriposa Records',
                  '${(_allRecords!['thiriposaRecords'] as List).length}',
                ],
                [
                  'Total Appointment Records',
                  '${(_allRecords!['appointmentRecords'] as List).length}',
                ],
                [
                  'Total Growth Records',
                  '${(_allRecords!['growthRecords'] as List).length}',
                ],
                [
                  'Total Eye & Ear Records',
                  '${(_allRecords!['eyeEarRecords'] as List).length}',
                ],
              ]),
              pw.SizedBox(height: 30),

              // Vaccination Records Section
              _buildVaccinationSection(),
              pw.SizedBox(height: 25),

              // Thiriposa Records Section
              _buildThiriposaSection(),
              pw.SizedBox(height: 25),

              // Appointment Records Section
              _buildAppointmentSection(),
              pw.SizedBox(height: 25),

              // Growth Records Section
              _buildGrowthSection(),
              pw.SizedBox(height: 25),

              // Eye & Ear Records Section
              _buildEyeEarSection(),
              pw.SizedBox(height: 30),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'This report was automatically generated by the Maternal Health Care System',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey700,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'For any questions or concerns, please contact your healthcare provider',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: data.map((row) {
        return pw.TableRow(
          children: row.map((cell) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(cell, style: pw.TextStyle(fontSize: 10)),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfInfoSection(List<List<String>> data) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: data.map((row) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey200),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    row[0],
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(row[1], style: pw.TextStyle(fontSize: 11)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildVaccinationSection() {
    final vaccinationRecords = _allRecords!['vaccinationRecords'] as List;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Vaccination Records (${vaccinationRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 10),
        if (vaccinationRecords.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              'No vaccination records found',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          _buildPdfTable([
            ['Date', 'Vaccine Name', 'Dose', 'Status', 'Notes'],
            ...vaccinationRecords.map<List<String>>(
              (record) => [
                _formatDate(record['vaccinationDate']),
                record['vaccineName']?.toString() ?? 'N/A',
                record['doseNumber']?.toString() ?? 'N/A',
                record['status']?.toString() ?? 'N/A',
                (record['notes']?.toString() ?? 'No notes').length > 30
                    ? '${(record['notes']?.toString() ?? '').substring(0, 30)}...'
                    : record['notes']?.toString() ?? 'No notes',
              ],
            ),
          ]),
      ],
    );
  }

  pw.Widget _buildThiriposaSection() {
    final thiriposaRecords = _allRecords!['thiriposaRecords'] as List;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Thiriposa Records (${thiriposaRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 10),
        if (thiriposaRecords.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              'No thiriposa records found',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          _buildPdfTable([
            ['Date', 'Type', 'Quantity', 'Notes'],
            ...thiriposaRecords.map<List<String>>(
              (record) => [
                _formatDate(record['date']),
                record['thiriposaType']?.toString() ?? 'N/A',
                record['quantity']?.toString() ?? 'N/A',
                (record['notes']?.toString() ?? 'No notes').length > 40
                    ? '${(record['notes']?.toString() ?? '').substring(0, 40)}...'
                    : record['notes']?.toString() ?? 'No notes',
              ],
            ),
          ]),
      ],
    );
  }

  pw.Widget _buildAppointmentSection() {
    final appointmentRecords = _allRecords!['appointmentRecords'] as List;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Appointment Records (${appointmentRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 10),
        if (appointmentRecords.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              'No appointment records found',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          _buildPdfTable([
            ['Date', 'Time', 'Type', 'Status', 'Healthcare Provider'],
            ...appointmentRecords.map<List<String>>(
              (record) => [
                _formatDate(record['appointmentDate']),
                record['appointmentTime']?.toString() ?? 'N/A',
                record['appointmentType']?.toString() ?? 'N/A',
                record['status']?.toString() ?? 'N/A',
                record['doctorName']?.toString() ??
                    record['healthcareProvider']?.toString() ??
                    'N/A',
              ],
            ),
          ]),
      ],
    );
  }

  pw.Widget _buildGrowthSection() {
    final growthRecords = _allRecords!['growthRecords'] as List;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Growth Records (${growthRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 10),
        if (growthRecords.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              'No growth records found',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          pw.Column(
            children: [
              _buildPdfTable([
                ['Date', 'Height (cm)', 'Weight (kg)', 'BMI'],
                ...growthRecords.map<List<String>>((record) {
                  final height = record['height']?.toDouble() ?? 0;
                  final weight = record['weight']?.toDouble() ?? 0;
                  final bmi = height > 0
                      ? (weight / ((height / 100) * (height / 100)))
                            .toStringAsFixed(1)
                      : 'N/A';
                  return [
                    _formatDate(record['date']),
                    record['height']?.toString() ?? 'N/A',
                    record['weight']?.toString() ?? 'N/A',
                    bmi,
                  ];
                }),
              ]),
              if (growthRecords.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Growth Summary:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Latest: ${growthRecords.last['height']}cm, ${growthRecords.last['weight']}kg (${_formatDate(growthRecords.last['date'])})',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      if (growthRecords.length > 1)
                        pw.Text(
                          'Previous: ${growthRecords[growthRecords.length - 2]['height']}cm, ${growthRecords[growthRecords.length - 2]['weight']}kg',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  pw.Widget _buildEyeEarSection() {
    final eyeEarRecords = _allRecords!['eyeEarRecords'] as List;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Eye & Ear Examination Records (${eyeEarRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 10),
        if (eyeEarRecords.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              'No eye & ear examination records found',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          _buildPdfTable([
            ['Date', 'Examination Type', 'Findings', 'Recommendations'],
            ...eyeEarRecords.map<List<String>>(
              (record) => [
                _formatDate(record['examinationDate']),
                record['examinationType']?.toString() ?? 'N/A',
                (record['findings']?.toString() ?? 'Normal').length > 40
                    ? '${(record['findings']?.toString() ?? '').substring(0, 40)}...'
                    : record['findings']?.toString() ?? 'Normal',
                (record['recommendations']?.toString() ?? 'None').length > 40
                    ? '${(record['recommendations']?.toString() ?? '').substring(0, 40)}...'
                    : record['recommendations']?.toString() ?? 'None',
              ],
            ),
          ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4FC3A1),
        foregroundColor: Colors.white,
        title: Text(
          'Comprehensive Records - ${widget.mother['fullName'] ?? 'Mother'}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          if (_allRecords != null)
            IconButton(
              onPressed: _exportToPdf,
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export to PDF',
            ),
        ],
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Vaccination'),
                  Tab(text: 'Thiriposa'),
                  Tab(text: 'Appointments'),
                  Tab(text: 'Growth'),
                  Tab(text: 'Eye & Ear'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4FC3A1)),
                  SizedBox(height: 16),
                  Text(
                    'Loading comprehensive records...',
                    style: TextStyle(
                      color: Color(0xFF4FC3A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
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
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadAllRecords,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVaccinationTab(),
                _buildThiriposaTab(),
                _buildAppointmentsTab(),
                _buildGrowthTab(),
                _buildEyeEarTab(),
              ],
            ),
    );
  }

  Widget _buildVaccinationTab() {
    final records = _allRecords!['vaccinationRecords'] as List;

    if (records.isEmpty) {
      return _buildEmptyState('No vaccination records found', Icons.vaccines);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          title: record['vaccineName'] ?? 'Vaccination',
          subtitle: 'Dose ${record['doseNumber'] ?? 'N/A'}',
          date: _formatDate(record['vaccinationDate']),
          status: record['status'] ?? 'N/A',
          icon: Icons.vaccines,
          details: [
            'Notes: ${record['notes'] ?? 'No notes'}',
            'Location: ${record['location'] ?? 'N/A'}',
          ],
        );
      },
    );
  }

  Widget _buildThiriposaTab() {
    final records = _allRecords!['thiriposaRecords'] as List;

    if (records.isEmpty) {
      return _buildEmptyState('No thiriposa records found', Icons.food_bank);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          title: record['thiriposaType'] ?? 'Thiriposa',
          subtitle: 'Amount: ${record['amount'] ?? 'N/A'}',
          date: _formatDate(record['date']),
          status: record['status'] ?? 'Distributed',
          icon: Icons.food_bank,
          details: [
            'Notes: ${record['notes'] ?? 'No notes'}',
            'Distributed by: ${record['distributedBy'] ?? 'N/A'}',
          ],
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    final records = _allRecords!['appointmentRecords'] as List;

    if (records.isEmpty) {
      return _buildEmptyState(
        'No appointment records found',
        Icons.calendar_today,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          title: record['appointmentType'] ?? 'Appointment',
          subtitle: 'Time: ${record['appointmentTime'] ?? 'N/A'}',
          date: _formatDate(record['appointmentDate']),
          status: record['status'] ?? 'N/A',
          icon: Icons.calendar_today,
          details: [
            'Doctor: ${record['doctorName'] ?? 'N/A'}',
            'Location: ${record['location'] ?? 'N/A'}',
            'Notes: ${record['notes'] ?? 'No notes'}',
          ],
        );
      },
    );
  }

  Widget _buildGrowthTab() {
    final records = _allRecords!['growthRecords'] as List;

    if (records.isEmpty) {
      return _buildEmptyState('No growth records found', Icons.trending_up);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          title: 'Growth Measurement',
          subtitle:
              'Height: ${record['height'] ?? 'N/A'} cm, Weight: ${record['weight'] ?? 'N/A'} kg',
          date: _formatDate(record['date']),
          status: 'Recorded',
          icon: Icons.trending_up,
          details: [
            'Height: ${record['height'] ?? 'N/A'} cm',
            'Weight: ${record['weight'] ?? 'N/A'} kg',
            'Recorded by: ${record['recordedBy'] ?? 'Healthcare Provider'}',
          ],
        );
      },
    );
  }

  Widget _buildEyeEarTab() {
    final records = _allRecords!['eyeEarRecords'] as List;

    if (records.isEmpty) {
      return _buildEmptyState('No eye & ear records found', Icons.visibility);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          title: record['examinationType'] ?? 'Examination',
          subtitle: 'Findings available',
          date: _formatDate(record['examinationDate']),
          status: record['status'] ?? 'Completed',
          icon: Icons.visibility,
          details: [
            'Findings: ${record['findings'] ?? 'No findings'}',
            'Recommendations: ${record['recommendations'] ?? 'No recommendations'}',
            'Examiner: ${record['examinerName'] ?? 'Healthcare Provider'}',
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard({
    required String title,
    required String subtitle,
    required String date,
    required String status,
    required IconData icon,
    required List<String> details,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF4FC3A1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF2E7D5A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Date: $date',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  detail,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'active':
      case 'distributed':
      case 'recorded':
        return Colors.green;
      case 'pending':
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
      case 'missed':
        return Colors.red;
      default:
        return const Color(0xFF4FC3A1);
    }
  }
}
