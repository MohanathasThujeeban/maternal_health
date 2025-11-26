import 'package:flutter/material.dart';
import '../../../../services/baby_service.dart';
import '../../../../services/vaccination_service.dart';
import '../../../../services/thiriposa_service.dart';
import '../../../../services/user_service.dart';
import '../../../../models/baby.dart';
import '../../../../widgets/custom_loading.dart';
import '../../../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class BabySpecificRecordsScreen extends StatefulWidget {
  const BabySpecificRecordsScreen({super.key});

  @override
  State<BabySpecificRecordsScreen> createState() =>
      _BabySpecificRecordsScreenState();
}

class _BabySpecificRecordsScreenState extends State<BabySpecificRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Baby> _babies = [];
  Baby? _selectedBaby;
  bool _isLoadingBabies = true;
  bool _isLoadingRecords = false;
  bool _isDownloading = false;
  String? _motherNic;
  String? _motherName;

  // Records data
  List<Map<String, dynamic>> _vaccinationRecords = [];
  List<Map<String, dynamic>> _thiriposaRecords = [];
  List<Map<String, dynamic>> _eyeEarRecords = [];
  List<Map<String, dynamic>> _growthRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserAndBabies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndBabies() async {
    try {
      setState(() => _isLoadingBabies = true);

      // Get current user's NIC and name
      final userData = await UserService.getUserData();
      _motherNic = userData['nic'];
      _motherName =
          userData['name'] ?? userData['fullName'] ?? 'Unknown Mother';

      if (_motherNic == null) {
        throw Exception('User not logged in');
      }

      // Load babies for this mother
      final babiesData = await BabyService.getBabiesByMotherNic(_motherNic!);

      List<Baby> babies = babiesData.map((babyData) {
        return Baby(
          id: babyData['id'],
          motherNic: babyData['motherNic'],
          motherName: babyData['motherName'] ?? 'Unknown',
          name: babyData['babyName'] ?? 'Unnamed Baby',
          dateOfBirth: babyData['dateOfBirth'] ?? '',
          gender: babyData['gender'] ?? 'Not specified',
          birthWeight: babyData['birthWeight']?.toDouble(),
          birthHeight: babyData['birthHeight']?.toDouble(),
          babyOrder: babyData['babyOrder'] ?? 1,
          isActive: babyData['isActive'] ?? true,
          createdAt: babyData['createdAt'] != null
              ? DateTime.parse(babyData['createdAt'])
              : DateTime.now(),
          updatedAt: babyData['updatedAt'] != null
              ? DateTime.parse(babyData['updatedAt'])
              : DateTime.now(),
        );
      }).toList();

      setState(() {
        _babies = babies;
        _selectedBaby = babies.isNotEmpty ? babies.first : null;
        _isLoadingBabies = false;
      });

      // Load records for the first baby if available
      if (_selectedBaby != null) {
        await _loadRecordsForSelectedBaby();
      }
    } catch (e) {
      setState(() {
        _isLoadingBabies = false;
      });
      _showError('Failed to load babies: $e');
    }
  }

  Future<void> _loadRecordsForSelectedBaby() async {
    if (_selectedBaby == null) return;

    setState(() => _isLoadingRecords = true);

    try {
      // Load all types of records concurrently
      await Future.wait([
        _loadVaccinationRecords(),
        _loadThiriposaRecords(),
        _loadEyeEarRecords(),
        _loadGrowthRecords(),
      ]);
    } catch (e) {
      _showError('Failed to load records: $e');
    } finally {
      setState(() => _isLoadingRecords = false);
    }
  }

  Future<void> _loadVaccinationRecords() async {
    try {
      final records = await VaccinationService.getVaccinationsByBaby(
        _selectedBaby!.id,
      );
      setState(() {
        _vaccinationRecords = records
            .map(
              (vaccination) => {
                'id': vaccination.id,
                'vaccinationType': vaccination.vaccinationType,
                'ageToGive': vaccination.ageToGive,
                'vaccinationDate': vaccination.vaccinationDate.toString(),
                'effectsFollowingImmunization':
                    vaccination.effectsFollowingImmunization,
                'status': vaccination.status.toString(),
                'childName': vaccination.childName,
                'batchNumber': vaccination.batchNumber,
              },
            )
            .toList();
      });
    } catch (e) {
      print('Error loading vaccination records: $e');
      setState(() {
        _vaccinationRecords = [];
      });
    }
  }

  Future<void> _loadThiriposaRecords() async {
    try {
      final records = await ThiriposaService.getRecordsByBaby(
        _selectedBaby!.id,
      );
      setState(() {
        _thiriposaRecords = records.map((record) => record.toJson()).toList();
      });
    } catch (e) {
      print('Error loading thiriposa records: $e');
      setState(() {
        _thiriposaRecords = [];
      });
    }
  }

  Future<void> _loadEyeEarRecords() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/baby-problems/baby/${_selectedBaby!.id}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _eyeEarRecords = List<Map<String, dynamic>>.from(
              responseData['data'],
            );
          });
        } else {
          setState(() {
            _eyeEarRecords = [];
          });
        }
      } else {
        throw Exception('Failed to load eye/ear records');
      }
    } catch (e) {
      print('Error loading eye/ear records: $e');
      setState(() {
        _eyeEarRecords = [];
      });
    }
  }

  Future<void> _loadGrowthRecords() async {
    try {
      print('Loading growth records for baby ID: ${_selectedBaby!.id}');
      print('Mother NIC: $_motherNic');

      // Try the baby-specific endpoint first
      var response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/growth-records/baby/${_selectedBaby!.id}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        'Baby-specific growth records response status: ${response.statusCode}',
      );
      print('Baby-specific growth records response body: ${response.body}');

      // If baby-specific endpoint fails, try mother-based endpoint
      if (response.statusCode != 200 || response.body == '[]') {
        print('Trying mother-based endpoint...');
        response = await http.get(
          Uri.parse('${ApiConfig.baseApiUrl}/growth/get/$_motherNic'),
          headers: {'Content-Type': 'application/json'},
        );

        print(
          'Mother-based growth records response status: ${response.statusCode}',
        );
        print('Mother-based growth records response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isNotEmpty && responseBody != '[]') {
          final List<dynamic> data = json.decode(responseBody);
          print('Growth records count: ${data.length}');

          // Filter records for the selected baby if using mother-based endpoint
          List<Map<String, dynamic>> filteredRecords = [];
          for (var record in data) {
            if (record['babyId'] == _selectedBaby!.id ||
                record['baby_id'] == _selectedBaby!.id ||
                record['childId'] == _selectedBaby!.id) {
              filteredRecords.add(Map<String, dynamic>.from(record));
            }
          }

          setState(() {
            _growthRecords = filteredRecords.isNotEmpty
                ? filteredRecords
                : List<Map<String, dynamic>>.from(data);
          });
          print('Growth records loaded: $_growthRecords');
        } else {
          setState(() {
            _growthRecords = [];
          });
        }
      } else {
        throw Exception('Failed to load growth records');
      }
    } catch (e) {
      print('Error loading growth records: $e');
      setState(() {
        _growthRecords = [];
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _generateAndDownloadPDF() async {
    if (_selectedBaby == null || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      print('=== PDF Generation Debug ===');
      print('Selected baby: ${_selectedBaby?.name}');
      print('Mother name: $_motherName');
      print('Vaccination records count: ${_vaccinationRecords.length}');
      print('Thiriposa records count: ${_thiriposaRecords.length}');
      print('Growth records count: ${_growthRecords.length}');
      print('Eye/Ear records count: ${_eyeEarRecords.length}');

      if (_growthRecords.isNotEmpty) {
        print('Growth records data: $_growthRecords');
      }

      final pdf = pw.Document();

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            // Header
            _buildPDFHeader(),
            pw.SizedBox(height: 20),

            // Baby and Mother Information
            _buildBabyInfo(),
            pw.SizedBox(height: 20),

            // Vaccination Records
            if (_vaccinationRecords.isNotEmpty) ...[
              _buildVaccinationSection(),
              pw.SizedBox(height: 20),
            ],

            // Thiriposa Records
            if (_thiriposaRecords.isNotEmpty) ...[
              _buildThiriposaSection(),
              pw.SizedBox(height: 20),
            ],

            // Growth Records
            _buildGrowthSection(),
            pw.SizedBox(height: 20),

            // Eye & Ear Records
            if (_eyeEarRecords.isNotEmpty) ...[
              _buildEyeEarSection(),
              pw.SizedBox(height: 20),
            ],

            // Footer
            pw.Spacer(),
            _buildPDFFooter(),
          ],
        ),
      );

      // Save and share PDF
      final bytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final babyName = _selectedBaby!.name.replaceAll(' ', '_');
      final fileName =
          '${babyName}_complete_records_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${_selectedBaby!.name}\'s Complete Health Records',
        subject: 'Baby Health Records - ${_selectedBaby!.name}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated and shared successfully! 📄'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('PDF generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  // PDF Building Helper Methods
  pw.Widget _buildPDFHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Complete Health Records',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.Text(
                'Maternal Health Monitoring System',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated on',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now()),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBabyInfo() {
    final baby = _selectedBaby!;
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.teal200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Baby & Mother Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Mother\'s Name:', _motherName ?? 'Unknown'),
                    _buildInfoRow('Baby\'s Name:', baby.name),
                    _buildInfoRow('Gender:', baby.gender),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Date of Birth:', baby.dateOfBirth),
                    _buildInfoRow(
                      'Birth Weight:',
                      baby.birthWeight != null
                          ? '${baby.birthWeight} kg'
                          : 'Not recorded',
                    ),
                    _buildInfoRow(
                      'Birth Height:',
                      baby.birthHeight != null
                          ? '${baby.birthHeight} cm'
                          : 'Not recorded',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildVaccinationSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Vaccination Records (${_vaccinationRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _buildTableCell('Vaccine', isHeader: true),
                _buildTableCell('Age to Give', isHeader: true),
                _buildTableCell('Date Given', isHeader: true),
                _buildTableCell('Status', isHeader: true),
              ],
            ),
            // Data rows
            ..._vaccinationRecords.map(
              (record) => pw.TableRow(
                children: [
                  _buildTableCell(record['vaccinationType'] ?? 'Unknown'),
                  _buildTableCell(record['ageToGive']?.toString() ?? 'N/A'),
                  _buildTableCell(_formatDateForPDF(record['vaccinationDate'])),
                  _buildTableCell(record['status'] ?? 'Unknown'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildThiriposaSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Thiriposa Records (${_thiriposaRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.green50),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Quantity (packets)', isHeader: true),
                _buildTableCell('Notes', isHeader: true),
              ],
            ),
            // Data rows
            ..._thiriposaRecords.map(
              (record) => pw.TableRow(
                children: [
                  _buildTableCell(_formatDateForPDF(record['date'])),
                  _buildTableCell(record['quantity']?.toString() ?? 'N/A'),
                  _buildTableCell(record['notes'] ?? 'No notes'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildGrowthSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Growth Records (${_growthRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple800,
          ),
        ),
        pw.SizedBox(height: 10),
        if (_growthRecords.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'No growth records found for this baby.',
              style: pw.TextStyle(
                color: PdfColors.grey600,
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.purple50),
                children: [
                  _buildTableCell('Date', isHeader: true),
                  _buildTableCell('Weight (kg)', isHeader: true),
                  _buildTableCell('Height (cm)', isHeader: true),
                ],
              ),
              // Data rows
              ..._growthRecords.map(
                (record) => pw.TableRow(
                  children: [
                    _buildTableCell(_formatDateForPDF(record['date'])),
                    _buildTableCell(record['weight']?.toString() ?? 'N/A'),
                    _buildTableCell(record['height']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildEyeEarSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Eye & Ear Records (${_eyeEarRecords.length})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.orange800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.orange50),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Eye Problem', isHeader: true),
                _buildTableCell('Ear Problem', isHeader: true),
                _buildTableCell('Remarks', isHeader: true),
              ],
            ),
            // Data rows
            ..._eyeEarRecords.map(
              (record) => pw.TableRow(
                children: [
                  _buildTableCell(_formatDateForPDF(record['dateOfDiagnosis'])),
                  _buildTableCell(record['eyeProblem'] ?? 'None'),
                  _buildTableCell(record['earProblem'] ?? 'None'),
                  _buildTableCell(record['remarks'] ?? 'No remarks'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Maternal Health Monitoring System',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.Text(
              'This report contains confidential medical information',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateForPDF(dynamic date) {
    if (date == null) return 'Not recorded';
    try {
      DateTime parsedDate;
      if (date is String) {
        parsedDate = DateTime.parse(date);
      } else if (date is DateTime) {
        parsedDate = date;
      } else {
        return 'Invalid date';
      }
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedBaby != null
              ? '${_selectedBaby!.name} - Records'
              : 'Baby Records',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedBaby != null)
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white),
              onPressed: _isDownloading ? null : _generateAndDownloadPDF,
              tooltip: _isDownloading
                  ? 'Generating PDF...'
                  : 'Download Complete Records',
            ),
          const SizedBox(width: 8),
        ],
        bottom: _babies.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DropdownButtonFormField<Baby>(
                    value: _selectedBaby,
                    decoration: InputDecoration(
                      labelText: 'Select Baby',
                      labelStyle: const TextStyle(color: Colors.white70),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                    ),
                    dropdownColor: const Color(0xFF4FC3A1),
                    style: const TextStyle(color: Colors.white),
                    items: _babies.map((baby) {
                      return DropdownMenuItem<Baby>(
                        value: baby,
                        child: Text(
                          baby.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (Baby? newBaby) async {
                      if (newBaby != null && newBaby != _selectedBaby) {
                        setState(() {
                          _selectedBaby = newBaby;
                        });
                        await _loadRecordsForSelectedBaby();
                      }
                    },
                  ),
                ),
              )
            : null,
      ),
      body: _isLoadingBabies
          ? const Center(child: CustomLoading())
          : _babies.isEmpty
          ? _buildNoBabiesWidget()
          : Column(
              children: [
                // Baby info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          (_selectedBaby?.gender ?? '').toLowerCase() == 'male'
                              ? Icons.boy
                              : Icons.girl,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedBaby?.name ?? 'Unknown Baby',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Birth Date: ${_selectedBaby?.dateOfBirth ?? 'Unknown'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                            Text(
                              'Gender: ${_selectedBaby?.gender ?? 'Not specified'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF4FC3A1),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF4FC3A1),
                  isScrollable: true,
                  tabs: [
                    Tab(
                      text: 'Vaccines (${_vaccinationRecords.length})',
                      icon: const Icon(Icons.vaccines, size: 20),
                    ),
                    Tab(
                      text: 'Thiriposa (${_getTotalPackets()} packets)',
                      icon: const Icon(Icons.inventory_2, size: 20),
                    ),
                    Tab(
                      text: 'Eye & Ear (${_eyeEarRecords.length})',
                      icon: const Icon(Icons.visibility, size: 20),
                    ),
                    Tab(
                      text: 'Growth (${_growthRecords.length})',
                      icon: const Icon(Icons.trending_up, size: 20),
                    ),
                  ],
                ),
                // Tab content
                Expanded(
                  child: _isLoadingRecords
                      ? const Center(child: CustomLoading())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildVaccinationTab(),
                            _buildThiriposaTab(),
                            _buildEyeEarTab(),
                            _buildGrowthTab(),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoBabiesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.child_care, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No babies found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please add a baby to view records',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-baby');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Baby'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationTab() {
    if (_vaccinationRecords.isEmpty) {
      return _buildEmptyState(
        'No vaccination records found',
        Icons.vaccines,
        'Vaccination records will appear here once they are added by healthcare providers',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaccinationRecords.length,
      itemBuilder: (context, index) {
        final record = _vaccinationRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.vaccines, color: Color(0xFF42A5F5)),
            ),
            title: Text(
              record['vaccinationType'] ?? 'Unknown Vaccine',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age to give: ${record['ageToGive'] ?? 'N/A'}'),
                Text('Date: ${record['vaccinationDate'] ?? 'N/A'}'),
                if (record['effectsFollowingImmunization'] != null)
                  Text('Effects: ${record['effectsFollowingImmunization']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(record['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record['status'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThiriposaTab() {
    if (_thiriposaRecords.isEmpty) {
      return _buildEmptyState(
        'No Thiriposa records found',
        Icons.inventory_2,
        'Thiriposa supplement records will appear here once they are added',
      );
    }

    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thiriposa Summary for ${_selectedBaby?.name ?? 'Baby'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Records: ${_thiriposaRecords.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    Text(
                      'Total Packets: ${_getTotalPackets()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Records List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _thiriposaRecords.length,
            itemBuilder: (context, index) {
              final record = _thiriposaRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                  title: Text(
                    'Thiriposa Supplement for ${_selectedBaby?.name ?? 'Baby'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baby: ${_selectedBaby?.name ?? 'Unknown'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Quantity: ${record['quantity'] ?? 'N/A'} packets'),
                      Text('Date: ${_formatDate(record['date']?.toString())}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEyeEarTab() {
    if (_eyeEarRecords.isEmpty) {
      return _buildEmptyState(
        'No eye & ear examination records found',
        Icons.visibility,
        'Eye and ear examination records will appear here once they are added by healthcare providers',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eyeEarRecords.length,
      itemBuilder: (context, index) {
        final record = _eyeEarRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.visibility, color: Color(0xFF9C27B0)),
            ),
            title: Text(
              'Eye & Ear Examination',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record['eyeProblem'] != null &&
                    record['eyeProblem'] != 'None')
                  Text('Eye Problem: ${record['eyeProblem']}'),
                if (record['earProblem'] != null &&
                    record['earProblem'] != 'None')
                  Text('Ear Problem: ${record['earProblem']}'),
                Text('Date: ${record['dateOfDiagnosis'] ?? 'N/A'}'),
                if (record['remarks'] != null && record['remarks'].isNotEmpty)
                  Text('Remarks: ${record['remarks']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrowthTab() {
    if (_growthRecords.isEmpty) {
      return _buildEmptyState(
        'No growth records found',
        Icons.trending_up,
        'Growth measurement records will appear here once they are added by healthcare providers',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _growthRecords.length,
      itemBuilder: (context, index) {
        final record = _growthRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, color: Color(0xFF4FC3A1)),
            ),
            title: Text(
              'Growth Measurement',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weight: ${record['weight'] ?? 'N/A'} kg'),
                Text('Height: ${record['height'] ?? 'N/A'} cm'),
                Text('Date: ${record['date'] ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontFamily: 'SpotifyCircular',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'scheduled':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  int _getTotalPackets() {
    int total = 0;
    for (var record in _thiriposaRecords) {
      total += (record['quantity'] as int? ?? 0);
    }
    return total;
  }
}
