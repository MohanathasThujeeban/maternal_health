import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../models/baby.dart';
import '../../../models/vaccination.dart';
import '../../../models/growth_entry.dart';
import '../../../models/thiriposa_record.dart';
import '../../../models/appointment.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/growth_entry_service.dart';
import '../../../services/thiriposa_service.dart';
import '../../../services/eye_ear_record_service.dart';
import '../../../services/appointment_service.dart';
import '../../../services/patient_note_service.dart';

class BabyComprehensiveRecordsScreen extends StatefulWidget {
  final Baby baby;
  final String motherNic;

  const BabyComprehensiveRecordsScreen({
    Key? key,
    required this.baby,
    required this.motherNic,
  }) : super(key: key);

  @override
  _BabyComprehensiveRecordsScreenState createState() =>
      _BabyComprehensiveRecordsScreenState();
}

class _BabyComprehensiveRecordsScreenState
    extends State<BabyComprehensiveRecordsScreen> {
  List<Vaccination> _vaccinations = [];
  List<GrowthEntry> _growthEntries = [];
  List<ThiriposaRecord> _thiriposaRecords = [];
  List<Map<String, dynamic>> _eyeEarRecords = [];
  List<Appointment> _appointments = [];
  List<Map<String, dynamic>> _patientNotes = [];

  bool _isLoading = true;
  String? _errorMessage;

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
      final results = await Future.wait([
        VaccinationService.getVaccinationsByBaby(widget.baby.id),
        GrowthEntryService.getEntriesByBaby(widget.baby.id),
        ThiriposaService.getRecordsByBaby(widget.baby.id),
        EyeEarRecordService.getRecordsByBabyId(widget.baby.id),
        AppointmentService.getAppointmentsByNic(widget.motherNic),
        PatientNoteService.getNotesByMotherNic(widget.motherNic),
      ]);

      setState(() {
        _vaccinations = results[0] as List<Vaccination>;
        _growthEntries = results[1] as List<GrowthEntry>;
        _thiriposaRecords = results[2] as List<ThiriposaRecord>;
        _eyeEarRecords = results[3] as List<Map<String, dynamic>>;

        // Extract appointments from the service response
        final appointmentResponse = results[4] as Map<String, dynamic>;
        _appointments =
            appointmentResponse['appointments'] as List<Appointment>;

        _patientNotes = results[5] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading records: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

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
                  color: PdfColors.pink,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Baby Health Records Report',
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

              // Baby Information Section
              pw.Text(
                'Baby Information',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.pink,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfInfoSection([
                ['Baby Name', widget.baby.name],
                ['Mother NIC', widget.baby.motherNic],
                ['Birth Date', widget.baby.dateOfBirth],
                ['Gender', widget.baby.gender],
                [
                  'Birth Weight',
                  widget.baby.birthWeight != null
                      ? '${widget.baby.birthWeight}g'
                      : 'N/A',
                ],
                [
                  'Birth Height',
                  widget.baby.birthHeight != null
                      ? '${widget.baby.birthHeight}cm'
                      : 'N/A',
                ],
                ['Baby Order', '${widget.baby.babyOrder}'],
                [
                  'Current Age',
                  '${widget.baby.ageInMonths} months (${widget.baby.ageInDays} days)',
                ],
                [
                  'Report Generated',
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                ],
              ]),
              pw.SizedBox(height: 30),

              // Vaccination Records Section
              pw.Text(
                'Vaccination Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_vaccinations.isEmpty)
                pw.Text(
                  'No vaccination records found',
                  style: pw.TextStyle(color: PdfColors.grey),
                )
              else
                _buildVaccinationTable(),
              pw.SizedBox(height: 30),

              // Growth Records Section
              pw.Text(
                'Growth Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_growthEntries.isEmpty)
                pw.Text(
                  'No growth records found',
                  style: pw.TextStyle(color: PdfColors.grey),
                )
              else
                _buildGrowthTable(),
              pw.SizedBox(height: 30),

              // Thiriposa Records Section
              pw.Text(
                'Thiriposa Supply Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_thiriposaRecords.isEmpty)
                pw.Text(
                  'No thiriposa records found',
                  style: pw.TextStyle(color: PdfColors.grey),
                )
              else
                _buildThiriposaTable(),
              pw.SizedBox(height: 30),

              // Eye & Ear Records Section
              pw.Text(
                'Eye & Ear Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_eyeEarRecords.isEmpty)
                pw.Text(
                  'No eye and ear records found',
                  style: pw.TextStyle(color: PdfColors.grey),
                )
              else
                _buildEyeEarPdfTable(),
              pw.SizedBox(height: 30),

              // Appointments Section
              pw.Text(
                'Appointments',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_appointments.isEmpty)
                pw.Text(
                  'No appointments found',
                  style: pw.TextStyle(color: PdfColors.grey),
                )
              else
                _buildAppointmentsPdfTable(),
              pw.SizedBox(height: 30),

              // Patient Notes Section
              pw.Text(
                'Doctor Notes',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_patientNotes.isEmpty)
                pw.Text(
                  'No doctor notes found',
                  style: pw.TextStyle(color: PdfColors.grey),
                )
              else
                _buildPatientNotesPdfTable(),
              pw.SizedBox(height: 30),

              // Summary Section
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildSummarySection(),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _buildPdfInfoSection(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: data.map((row) {
        return pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                row[0],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[1]),
            ),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _buildVaccinationTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Vaccination Type',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Age to Give',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Date Given',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Status',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ..._vaccinations.map((vaccination) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(vaccination.vaccinationType),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(vaccination.ageToGive),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(vaccination.vaccinationDate),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(vaccination.status),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildGrowthTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Height (cm)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Weight (kg)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ..._growthEntries.map((entry) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(DateFormat('dd/MM/yyyy').format(entry.date)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${entry.height}'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${entry.weight}'),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildThiriposaTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple100),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Supply Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Quantity (packets)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ..._thiriposaRecords.map((record) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(DateFormat('dd/MM/yyyy').format(record.date)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${record.quantity}'),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildEyeEarPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Eye Problem',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Ear Problem',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Duration',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Date & Remarks',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ..._eyeEarRecords.map((record) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(record['eyeProblem'] ?? 'None'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(record['earProblem'] ?? 'None'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(record['symptomsDuration'] ?? 'Unknown'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${record['dateOfDiagnosis'] ?? 'Unknown'}\n${record['remarks'] ?? ''}',
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildAppointmentsPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Type',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Provider',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Status',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Notes',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ..._appointments.map((appointment) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(appointment.appointmentType.toUpperCase()),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(appointment.providerName),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  DateFormat('dd/MM/yyyy').format(appointment.appointmentDate),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(appointment.status),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(appointment.notes ?? 'None'),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPatientNotesPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple100),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Doctor',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Notes & Treatment',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ..._patientNotes.map((note) {
          final createdAt = note['createdAt'] != null
              ? DateTime.tryParse(note['createdAt'])
              : null;
          final dateString = createdAt != null
              ? DateFormat('dd/MM/yyyy').format(createdAt)
              : 'Unknown';

          final noteDetails = [
            if (note['notes'] != null && note['notes'].toString().isNotEmpty)
              'Notes: ${note['notes']}',
            if (note['diagnosis'] != null &&
                note['diagnosis'].toString().isNotEmpty)
              'Diagnosis: ${note['diagnosis']}',
            if (note['treatmentPlan'] != null &&
                note['treatmentPlan'].toString().isNotEmpty)
              'Treatment: ${note['treatmentPlan']}',
            if (note['nextAppointment'] != null &&
                note['nextAppointment'].toString().isNotEmpty)
              'Next: ${note['nextAppointment']}',
          ].join('\n');

          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(note['doctorName'] ?? 'Unknown Doctor'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(dateString),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  noteDetails.isNotEmpty ? noteDetails : 'No details',
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildSummarySection() {
    final completedVaccinations = _vaccinations
        .where((v) => v.status.toUpperCase() == 'COMPLETED')
        .length;
    final pendingVaccinations = _vaccinations
        .where((v) => v.status.toUpperCase() == 'PENDING')
        .length;
    final latestGrowth = _growthEntries.isNotEmpty ? _growthEntries.last : null;
    final totalThiriposa = _thiriposaRecords.fold<int>(
      0,
      (sum, record) => sum + record.quantity,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.orange),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Total Vaccination Records: ${_vaccinations.length}'),
          pw.Text('Completed Vaccinations: $completedVaccinations'),
          pw.Text('Pending Vaccinations: $pendingVaccinations'),
          pw.SizedBox(height: 10),
          pw.Text('Total Growth Records: ${_growthEntries.length}'),
          if (latestGrowth != null) ...[
            pw.Text('Latest Height: ${latestGrowth.height}cm'),
            pw.Text('Latest Weight: ${latestGrowth.weight}kg'),
          ],
          pw.SizedBox(height: 10),
          pw.Text('Total Thiriposa Records: ${_thiriposaRecords.length}'),
          pw.Text('Total Thiriposa Packets: $totalThiriposa'),
          pw.SizedBox(height: 10),
          pw.Text('Total Eye & Ear Records: ${_eyeEarRecords.length}'),
          pw.Text('Total Appointments: ${_appointments.length}'),
          pw.Text(
            'Completed Appointments: ${_appointments.where((a) => a.status.toLowerCase() == 'completed').length}',
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total Doctor Notes: ${_patientNotes.length}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.baby.name} - Records',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Complete Health Report',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.pink[100],
        elevation: 0,
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: _exportToPdf,
              tooltip: 'Export to PDF',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAllRecords,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAllRecords,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baby Info Card
                    _buildBabyInfoCard(),
                    SizedBox(height: 20),

                    // Statistics Cards
                    _buildStatisticsCards(),
                    SizedBox(height: 20),

                    // Records Sections
                    _buildVaccinationSection(),
                    SizedBox(height: 20),
                    _buildGrowthSection(),
                    SizedBox(height: 20),
                    _buildThiriposaSection(),
                    SizedBox(height: 20),
                    _buildEyeEarSection(),
                    SizedBox(height: 20),
                    _buildAppointmentsSection(),
                    SizedBox(height: 20),
                    _buildPatientNotesSection(),
                    SizedBox(height: 20),

                    // Export Button
                    _buildExportSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBabyInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.pink[100],
                  radius: 30,
                  child: Text(
                    widget.baby.babyOrder.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.baby.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700],
                        ),
                      ),
                      Text('Birth Date: ${widget.baby.formattedBirthDate}'),
                      Text('Gender: ${widget.baby.gender}'),
                      Text(
                        'Age: ${widget.baby.ageInMonths} months (${widget.baby.ageInDays} days)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                if (widget.baby.birthWeight != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birth Weight',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${widget.baby.birthWeight}g'),
                      ],
                    ),
                  ),
                if (widget.baby.birthHeight != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birth Height',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${widget.baby.birthHeight}cm'),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mother NIC',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.baby.motherNic),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final completedVaccinations = _vaccinations
        .where((v) => v.status.toUpperCase() == 'COMPLETED')
        .length;
    final totalThiriposa = _thiriposaRecords.fold<int>(
      0,
      (sum, record) => sum + record.quantity,
    );
    final completedAppointments = _appointments
        .where((a) => a.status.toLowerCase() == 'completed')
        .length;

    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.green[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.vaccines, color: Colors.green[600], size: 30),
                      SizedBox(height: 8),
                      Text(
                        '$completedVaccinations/${_vaccinations.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Vaccinations', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.blue[600],
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_growthEntries.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Growth Records', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_pharmacy,
                        color: Colors.purple[600],
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$totalThiriposa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Thiriposa Packets', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Second row
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.cyan[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.visibility, color: Colors.cyan[600], size: 30),
                      SizedBox(height: 8),
                      Text(
                        '${_eyeEarRecords.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Eye & Ear Records', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.orange[600],
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$completedAppointments/${_appointments.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Appointments', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.pink[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.note_alt, color: Colors.pink[600], size: 30),
                      SizedBox(height: 8),
                      Text(
                        '${_patientNotes.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Doctor Notes', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVaccinationSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vaccines, color: Colors.green[600]),
                SizedBox(width: 8),
                Text(
                  'Vaccination Records (${_vaccinations.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_vaccinations.isEmpty)
              Text(
                'No vaccination records found',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: _vaccinations.map((vaccination) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: vaccination.isCompleted
                            ? Colors.green[100]
                            : Colors.orange[100],
                        child: Icon(
                          vaccination.isCompleted ? Icons.check : Icons.pending,
                          color: vaccination.isCompleted
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                      title: Text(vaccination.vaccinationType),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Age: ${vaccination.ageToGive}'),
                          Text('Date: ${vaccination.vaccinationDate}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(vaccination.status),
                        backgroundColor: vaccination.isCompleted
                            ? Colors.green[100]
                            : Colors.orange[100],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[600]),
                SizedBox(width: 8),
                Text(
                  'Growth Records (${_growthEntries.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_growthEntries.isEmpty)
              Text(
                'No growth records found',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: _growthEntries.map((entry) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.trending_up, color: Colors.blue[700]),
                      ),
                      title: Text(
                        'Height: ${entry.height}cm, Weight: ${entry.weight}kg',
                      ),
                      subtitle: Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(entry.date)}',
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThiriposaSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_pharmacy, color: Colors.purple[600]),
                SizedBox(width: 8),
                Text(
                  'Thiriposa Records (${_thiriposaRecords.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_thiriposaRecords.isEmpty)
              Text(
                'No thiriposa records found',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: _thiriposaRecords.map((record) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: Icon(
                          Icons.local_pharmacy,
                          color: Colors.purple[700],
                        ),
                      ),
                      title: Text('Quantity: ${record.quantity} packets'),
                      subtitle: Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(record.date)}',
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red[600]),
                SizedBox(width: 8),
                Text(
                  'Export Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToPdf,
                icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  'Export Complete Report as PDF',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This will generate a comprehensive PDF report containing all vaccination, growth, thiriposa, eye/ear, appointments, and doctor notes records for ${widget.baby.name}.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeEarSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, color: Colors.blue[600]),
                SizedBox(width: 8),
                Text(
                  'Eye & Ear Records (${_eyeEarRecords.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_eyeEarRecords.isEmpty)
              Text(
                'No eye and ear records found',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: _eyeEarRecords.map((record) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.visibility, color: Colors.blue[700]),
                      ),
                      title: Text(
                        '${record['eyeProblem'] ?? 'None'} | ${record['earProblem'] ?? 'None'}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration: ${record['symptomsDuration'] ?? 'Unknown'}',
                          ),
                          Text(
                            'Date: ${record['dateOfDiagnosis'] ?? 'Unknown'}',
                          ),
                          if (record['remarks'] != null &&
                              record['remarks'].toString().isNotEmpty)
                            Text('Remarks: ${record['remarks']}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green[600]),
                SizedBox(width: 8),
                Text(
                  'Appointments (${_appointments.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_appointments.isEmpty)
              Text(
                'No appointments found',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: _appointments.map((appointment) {
                  final isCompleted =
                      appointment.status.toLowerCase() == 'completed';
                  final isPending =
                      appointment.status.toLowerCase() == 'pending';

                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCompleted
                            ? Colors.green[100]
                            : isPending
                            ? Colors.orange[100]
                            : Colors.red[100],
                        child: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : isPending
                              ? Icons.schedule
                              : Icons.cancel,
                          color: isCompleted
                              ? Colors.green[700]
                              : isPending
                              ? Colors.orange[700]
                              : Colors.red[700],
                        ),
                      ),
                      title: Text(
                        '${appointment.appointmentType.toUpperCase()} - ${appointment.providerName}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${DateFormat('dd/MM/yyyy').format(appointment.appointmentDate)}',
                          ),
                          Text('Time: ${appointment.timeSlot}'),
                          Text('Status: ${appointment.status}'),
                          if (appointment.notes != null &&
                              appointment.notes!.isNotEmpty)
                            Text('Notes: ${appointment.notes}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientNotesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, color: Colors.purple[600]),
                SizedBox(width: 8),
                Text(
                  'Doctor Notes (${_patientNotes.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_patientNotes.isEmpty)
              Text(
                'No doctor notes found',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: _patientNotes.map((note) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: Icon(Icons.note_alt, color: Colors.purple[700]),
                      ),
                      title: Text(
                        note['doctorName'] ?? 'Unknown Doctor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Date: ${note['createdAt'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(note['createdAt'])) : 'Unknown'}',
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note['notes'] != null &&
                                  note['notes'].toString().isNotEmpty) ...[
                                Text(
                                  'Notes:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(note['notes']),
                                SizedBox(height: 8),
                              ],
                              if (note['diagnosis'] != null &&
                                  note['diagnosis'].toString().isNotEmpty) ...[
                                Text(
                                  'Diagnosis:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(note['diagnosis']),
                                SizedBox(height: 8),
                              ],
                              if (note['treatmentPlan'] != null &&
                                  note['treatmentPlan']
                                      .toString()
                                      .isNotEmpty) ...[
                                Text(
                                  'Treatment Plan:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(note['treatmentPlan']),
                                SizedBox(height: 8),
                              ],
                              if (note['nextAppointment'] != null &&
                                  note['nextAppointment']
                                      .toString()
                                      .isNotEmpty) ...[
                                Text(
                                  'Next Appointment:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(note['nextAppointment']),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
