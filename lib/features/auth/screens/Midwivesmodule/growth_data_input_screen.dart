import 'package:flutter/material.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/growth_chart_view.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/growth_chart_input.dart';
import 'package:maternal_health/config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GrowthDataInputScreen extends StatefulWidget {
  final String motherName;
  final String motherNic;

  const GrowthDataInputScreen({
    super.key,
    required this.motherName,
    required this.motherNic,
  });

  @override
  State<GrowthDataInputScreen> createState() => _GrowthDataInputScreenState();
}

class _GrowthDataInputScreenState extends State<GrowthDataInputScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<GrowthEntry> _entries = [];
  DateTime? _selectedDate;
  bool _isSaving = false;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadExistingGrowthData();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingGrowthData() async {
    setState(() => _isLoadingHistory = true);

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}/growth/get/${widget.motherNic}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final existingEntries = data
            .map(
              (e) => GrowthEntry(
                motherNic: e['motherNic'],
                height: e['height'].toDouble(),
                weight: e['weight'].toDouble(),
                date: DateTime.parse(e['date']),
              ),
            )
            .toList();

        setState(() {
          _entries.clear();
          _entries.addAll(existingEntries);
        });
      }
    } catch (e) {
      print('Error loading existing growth data: $e');
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _saveEntryToBackend(GrowthEntry entry) async {
    final url = Uri.parse("${ApiConfig.baseApiUrl}/growth/add");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Growth data saved successfully ✅"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception("Failed to save: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving growth data: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      rethrow;
    }
  }

  Future<void> _addEntry() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a date"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final entry = GrowthEntry(
        date: _selectedDate!,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        motherNic: widget.motherNic,
      );

      // Save to backend first
      await _saveEntryToBackend(entry);

      // Add to local list
      setState(() {
        _entries.add(entry);
        _entries.sort((a, b) => a.date.compareTo(b.date));
      });

      // Clear form
      _heightController.clear();
      _weightController.clear();
      _selectedDate = null;
    } catch (e) {
      // Error already shown in _saveEntryToBackend
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _viewChart() {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No growth data available to display"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewGraphScreen(entries: _entries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Growth Data for ${widget.motherName}',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3A1).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.monitor_heart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.motherName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'NIC: ${widget.motherNic}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      Text(
                        'Growth Records: ${_entries.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add new entry section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Growth Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'SpotifyCircular',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D5A),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Height input
                            TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Height (cm)',
                                prefixIcon: const Icon(
                                  Icons.height,
                                  color: Color(0xFF4FC3A1),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4FC3A1),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter height';
                                }
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height <= 0 ||
                                    height > 200) {
                                  return 'Please enter a valid height (1-200 cm)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Weight input
                            TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: const Icon(
                                  Icons.monitor_weight,
                                  color: Color(0xFF4FC3A1),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4FC3A1),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter weight';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null ||
                                    weight <= 0 ||
                                    weight > 10) {
                                  return 'Please enter a valid weight (0.1-10 kg)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date picker
                            InkWell(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF4FC3A1),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() => _selectedDate = pickedDate);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedDate == null
                                        ? Colors.grey.shade300
                                        : const Color(0xFF4FC3A1),
                                    width: _selectedDate == null ? 1 : 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: _selectedDate == null
                                          ? Colors.grey
                                          : const Color(0xFF4FC3A1),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      style: TextStyle(
                                        color: _selectedDate == null
                                            ? Colors.grey
                                            : const Color(0xFF2E7D5A),
                                        fontSize: 16,
                                        fontFamily: 'SpotifyCircular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isSaving ? null : _addEntry,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(Icons.add, size: 18),
                                    label: Text(
                                      _isSaving ? 'Saving...' : 'Add Record',
                                      style: const TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4FC3A1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _entries.isEmpty
                                        ? null
                                        : _viewChart,
                                    icon: const Icon(
                                      Icons.show_chart,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'View Chart',
                                      style: TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Growth history section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Growth History',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'SpotifyCircular',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D5A),
                                  ),
                                ),
                                const Spacer(),
                                if (_isLoadingHistory)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4FC3A1),
                                      ),
                                    ),
                                  )
                                else
                                  IconButton(
                                    onPressed: _loadExistingGrowthData,
                                    icon: const Icon(Icons.refresh),
                                    color: const Color(0xFF4FC3A1),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (_entries.isEmpty && !_isLoadingHistory)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No growth records yet',
                                      style: TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add the first growth record to start tracking',
                                      style: TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _entries.length,
                                itemBuilder: (context, index) {
                                  final entry = _entries[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: const Border(
                                        left: BorderSide(
                                          color: Color(0xFF4FC3A1),
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF4FC3A1,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.analytics,
                                            color: Color(0xFF4FC3A1),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                                style: const TextStyle(
                                                  fontFamily: 'SpotifyCircular',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2E7D5A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Height: ${entry.height} cm • Weight: ${entry.weight} kg',
                                                style: TextStyle(
                                                  fontFamily: 'SpotifyCircular',
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
