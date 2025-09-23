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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with colored background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4FC3A1).withOpacity(0.15),
                  const Color(0xFF4FC3A1).withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3A1).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    hasEyeIssue || hasEarIssue
                        ? Icons.warning_amber_rounded
                        : Icons.health_and_safety,
                    color: hasEyeIssue || hasEarIssue
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF4FC3A1),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['patientName'] ?? 'Unknown Patient',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpotifyCircular',
                          color: Color(0xFF2E7D5A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3A1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event,
                              size: 16,
                              color: Color(0xFF4FC3A1),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(record['dateOfDiagnosis']),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4FC3A1),
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Problems Container
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Eye Problem Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasEyeIssue
                        ? const Color(0xFFFFF8E1)
                        : const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasEyeIssue
                          ? const Color(0xFFFFB74D).withOpacity(0.3)
                          : const Color(0xFF81C784).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (hasEyeIssue
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFF81C784))
                                      .withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.remove_red_eye,
                          color: hasEyeIssue
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Eye Examination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: hasEyeIssue
                                    ? const Color(0xFFE65100)
                                    : const Color(0xFF2E7D32),
                                letterSpacing: -0.3,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              eyeProblem,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.grey[800],
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Ear Problem Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasEarIssue
                        ? const Color(0xFFFFF8E1)
                        : const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasEarIssue
                          ? const Color(0xFFFFB74D).withOpacity(0.3)
                          : const Color(0xFF81C784).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (hasEarIssue
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFF81C784))
                                      .withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.hearing,
                          color: hasEarIssue
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ear Examination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: hasEarIssue
                                    ? const Color(0xFFE65100)
                                    : const Color(0xFF2E7D32),
                                letterSpacing: -0.3,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              earProblem,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.grey[800],
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional Information
                if (record['duration'] != null ||
                    record['remarks'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4FC3A1).withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Color(0xFF4FC3A1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Additional Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D5A),
                                letterSpacing: -0.3,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                        if (record['duration'] != null) ...[
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            icon: Icons.access_time_outlined,
                            label: 'Duration',
                            value: record['duration'] ?? '',
                          ),
                        ],
                        if (record['remarks'] != null) ...[
                          if (record['duration'] != null)
                            const SizedBox(height: 12),
                          _buildInfoItem(
                            icon: Icons.note_alt_outlined,
                            label: 'Remarks',
                            value: record['remarks'] ?? '',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // Note: symptomsDuration and remarks are now handled in the Additional Information section
  }

  // Removed unused _buildProblemSection method

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3A1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF4FC3A1)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E7D5A),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.4,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
            ],
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
