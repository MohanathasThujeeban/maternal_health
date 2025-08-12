import 'package:flutter/material.dart';
import 'package:maternal_health/services/thiriposa_api_service.dart';
import 'package:maternal_health/services/user_service.dart';

class ThiriposaRecordsScreen extends StatefulWidget {
  const ThiriposaRecordsScreen({super.key});

  @override
  State<ThiriposaRecordsScreen> createState() => _ThiriposaRecordsScreenState();
}

class _ThiriposaRecordsScreenState extends State<ThiriposaRecordsScreen> {
  List<dynamic> _records = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserRecords();
  }

  Future<void> _loadUserRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get user NIC from UserService
      final nic = await UserService.getUserNic();
      if (nic == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      // Fetch Thiriposa records for this user
      final result = await ThiriposaApiService.getRecordsByNic(nic);

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _records = result['records'];
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading records: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: const Text(
          'My Thiriposa Records',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3A1), Color(0xFF3AB38A)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.inventory_2, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Thiriposa Nutrition Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'SpotifyCircular',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your nutrition supplement history',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: 'SpotifyCircular',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3A1)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your records...',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Color(0xFF4FC3A1),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Thiriposa Records Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
                fontFamily: 'SpotifyCircular',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your midwife will add records when you receive Thiriposa supplements.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserRecords,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sort records by date (newest first)
    _records.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4FC3A1).withOpacity(0.1),
                  const Color(0xFF4FC3A1).withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3A1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Color(0xFF4FC3A1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Records',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      Text(
                        '${_records.length} entries',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Quantity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    Text(
                      '${_calculateTotalQuantity()} packets',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D5A),
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Recent Records',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D5A),
            fontFamily: 'SpotifyCircular',
          ),
        ),
        const SizedBox(height: 12),

        // Records List
        Expanded(
          child: ListView.builder(
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              return _buildRecordCard(record);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final date = DateTime.parse(record['date']);
    final quantity = record['quantity'];
    final notes = record['notes'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
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
                    child: const Icon(
                      Icons.inventory,
                      color: Color(0xFF4FC3A1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D5A),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                        Text(
                          _getRelativeDate(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3A1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$quantity packets',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ],
              ),

              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _calculateTotalQuantity() {
    return _records.fold(0, (sum, record) => sum + (record['quantity'] as int));
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
