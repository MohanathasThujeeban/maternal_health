import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/baby_service.dart';
import 'baby_comprehensive_records_screen.dart';
import '../../../models/baby.dart';

class MidwifeBabySelectionScreen extends StatefulWidget {
  final Map<String, dynamic> motherData;

  const MidwifeBabySelectionScreen({Key? key, required this.motherData})
    : super(key: key);

  @override
  State<MidwifeBabySelectionScreen> createState() =>
      _MidwifeBabySelectionScreenState();
}

class _MidwifeBabySelectionScreenState extends State<MidwifeBabySelectionScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> babies = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadBabies();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBabies() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final motherNic = widget.motherData['nicNumber'];
      if (motherNic == null) {
        throw Exception('Mother NIC not found');
      }

      final fetchedBabies = await BabyService.getBabiesByMotherNic(motherNic);

      setState(() {
        babies = fetchedBabies.where((baby) {
          // Filter out babies with null or empty names
          return baby['babyName'] != null &&
              baby['babyName'].toString().trim().isNotEmpty &&
              baby['babyName'].toString().trim() != 'N/A';
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _viewBabyRecords(Map<String, dynamic> babyData) {
    // Convert map to Baby object for the comprehensive records screen
    final baby = Baby(
      id: babyData['id'] ?? 0,
      name: babyData['babyName'] ?? 'Unknown Baby',
      motherNic: widget.motherData['nicNumber'] ?? '',
      motherName: widget.motherData['fullName'] ?? 'Unknown Mother',
      dateOfBirth:
          babyData['birthDate'] ??
          DateTime.now().toIso8601String().split('T')[0],
      gender: babyData['gender'] ?? 'Unknown',
      birthWeight: babyData['birthWeight']?.toDouble(),
      birthHeight: babyData['birthHeight']?.toDouble(),
      babyOrder: babyData['babyOrder'] ?? 1,
      isActive: babyData['isActive'] ?? true,
      createdAt: babyData['createdAt'] != null
          ? DateTime.tryParse(babyData['createdAt'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      updatedAt: babyData['updatedAt'] != null
          ? DateTime.tryParse(babyData['updatedAt'].toString()) ??
                DateTime.now()
          : DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabyComprehensiveRecordsScreen(
          baby: baby,
          motherNic: widget.motherData['nicNumber'] ?? '',
        ),
      ),
    );
  }

  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(birthDate);

    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();
      if (remainingMonths > 0) {
        return '$years year${years > 1 ? 's' : ''} $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
      }
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Baby Records - ${widget.motherData['fullName'] ?? 'Unknown Mother'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.child_care,
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
                                'Registered Babies',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                              Text(
                                'NIC: ${widget.motherData['nicNumber'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${babies.length} Baby${babies.length != 1 ? 's' : ''} Found',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4FC3A1),
                        ),
                      )
                    : errorMessage != null
                    ? _buildErrorState()
                    : babies.isEmpty
                    ? _buildEmptyState()
                    : _buildBabiesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error Loading Babies',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBabies,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Babies Registered',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This mother has not registered any babies yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBabies,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabiesList() {
    return RefreshIndicator(
      onRefresh: _loadBabies,
      color: const Color(0xFF4FC3A1),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: babies.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildBabyCard(babies[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBabyCard(Map<String, dynamic> baby) {
    final birthDate = baby['birthDate'] != null
        ? DateTime.tryParse(baby['birthDate'].toString())
        : null;
    final age = _calculateAge(birthDate);
    final gender = baby['gender']?.toString() ?? 'Unknown';
    final weight = baby['birthWeight']?.toString();
    final height = baby['birthHeight']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFF4FC3A1).withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewBabyRecords(baby),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gender.toLowerCase() == 'male'
                              ? [Colors.blue.shade300, Colors.blue.shade500]
                              : gender.toLowerCase() == 'female'
                              ? [
                                  const Color(0xFF4FC3A1),
                                  const Color(0xFF66D4B7),
                                ]
                              : [
                                  Colors.purple.shade300,
                                  Colors.purple.shade500,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        gender.toLowerCase() == 'male'
                            ? Icons.boy
                            : gender.toLowerCase() == 'female'
                            ? Icons.girl
                            : Icons.child_care,
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
                            baby['babyName'] ?? 'Unknown Baby',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: gender.toLowerCase() == 'male'
                                      ? Colors.blue.shade100
                                      : gender.toLowerCase() == 'female'
                                      ? const Color(0xFF4FC3A1).withOpacity(0.2)
                                      : Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: gender.toLowerCase() == 'male'
                                        ? Colors.blue.shade700
                                        : gender.toLowerCase() == 'female'
                                        ? const Color(0xFF2E7D5A)
                                        : Colors.purple.shade700,
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  age,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
                if (birthDate != null || weight != null || height != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (birthDate != null)
                          _buildInfoRow(
                            'Birth Date',
                            DateFormat('MMM dd, yyyy').format(birthDate),
                            Icons.cake,
                          ),
                        if (weight != null && weight.isNotEmpty)
                          _buildInfoRow(
                            'Birth Weight',
                            '${weight} kg',
                            Icons.monitor_weight,
                          ),
                        if (height != null && height.isNotEmpty)
                          _buildInfoRow(
                            'Birth Height',
                            '${height} cm',
                            Icons.height,
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View Health Records & Export PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontFamily: 'CircularStd',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
              fontFamily: 'CircularStd',
            ),
          ),
        ],
      ),
    );
  }
}
