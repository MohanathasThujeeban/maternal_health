import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/eye_ear_record_service.dart';
import '../../../../widgets/custom_loading.dart';

class EyeEarRecordsScreen extends StatefulWidget {
  const EyeEarRecordsScreen({super.key});

  @override
  State<EyeEarRecordsScreen> createState() => _EyeEarRecordsScreenState();
}

class _EyeEarRecordsScreenState extends State<EyeEarRecordsScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final records = await EyeEarRecordService.getMyBabyRecords();

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshRecords() async {
    await _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eye & Ear Records',
          style: TextStyle(
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4FC3A1), Color(0xFFF0F9F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3],
          ),
        ),
        child: _isLoading
            ? const Center(child: CustomLoading())
            : _errorMessage != null
            ? _buildErrorWidget()
            : RefreshIndicator(
                onRefresh: _refreshRecords,
                child: _buildRecordsList(),
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading records',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'SpotifyCircular',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecords,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_red_eye_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Eye & Ear Records Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your baby\'s eye and ear examination records will appear here when added by your midwife.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'SpotifyCircular',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshRecords,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final eyeProblem = record['eyeProblem'] ?? 'None';
    final earProblem = record['earProblem'] ?? 'None';
    final hasEyeIssue = eyeProblem != 'None' && eyeProblem.isNotEmpty;
    final hasEarIssue = earProblem != 'None' && earProblem.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and patient name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasEyeIssue || hasEarIssue
                        ? Icons.warning_amber_rounded
                        : Icons.health_and_safety,
                    color: hasEyeIssue || hasEarIssue
                        ? Colors.orange
                        : const Color(0xFF4FC3A1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['patientName'] ?? 'Unknown Patient',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      Text(
                        _formatDate(record['dateOfDiagnosis']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Eye and Ear problems
            if (hasEyeIssue) ...[
              _buildProblemSection(
                'Eye Problem',
                eyeProblem,
                Icons.remove_red_eye,
                Colors.blue,
              ),
              const SizedBox(height: 12),
            ],

            if (hasEarIssue) ...[
              _buildProblemSection(
                'Ear Problem',
                earProblem,
                Icons.hearing,
                Colors.orange,
              ),
              const SizedBox(height: 12),
            ],

            if (!hasEyeIssue && !hasEarIssue) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'No eye or ear problems detected',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Symptoms duration
            if (record['symptomsDuration'] != null) ...[
              _buildInfoRow('Duration', record['symptomsDuration']),
              const SizedBox(height: 8),
            ],

            // Remarks
            if (record['remarks'] != null &&
                record['remarks'].toString().isNotEmpty) ...[
              _buildInfoRow('Remarks', record['remarks']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProblemSection(
    String title,
    String problem,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
                Text(
                  problem,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'SpotifyCircular',
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontFamily: 'SpotifyCircular'),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown Date';

    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        dateTime = date as DateTime;
      }
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }
}
