import 'package:flutter/material.dart';
import '../../../services/mothers_service.dart';
import 'midwife_baby_selection_screen.dart';

class MidwifeMotherSelectionScreen extends StatefulWidget {
  const MidwifeMotherSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MidwifeMotherSelectionScreen> createState() =>
      _MidwifeMotherSelectionScreenState();
}

class _MidwifeMotherSelectionScreenState
    extends State<MidwifeMotherSelectionScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> mothers = [];
  List<Map<String, dynamic>> filteredMothers = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
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
    _loadMothers();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMothers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedMothers = await MothersService.getAllMothers();

      setState(() {
        mothers = fetchedMothers;
        filteredMothers = fetchedMothers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterMothers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMothers = mothers;
      } else {
        filteredMothers = mothers.where((mother) {
          final name = mother['fullName']?.toString().toLowerCase() ?? '';
          final nic = mother['nicNumber']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || nic.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _selectMother(Map<String, dynamic> motherData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MidwifeBabySelectionScreen(motherData: motherData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Select Mother',
          style: TextStyle(
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
            // Header with search
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
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
                                  Icons.pregnant_woman,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Registered Mothers',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'CircularStd',
                                      ),
                                    ),
                                    Text(
                                      'Select a mother to view baby records',
                                      style: TextStyle(
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
                              '${filteredMothers.length} Mother${filteredMothers.length != 1 ? 's' : ''} Found',
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
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterMothers,
                        decoration: InputDecoration(
                          hintText: 'Search by name or NIC...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontFamily: 'CircularStd',
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterMothers('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'CircularStd'),
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
                    : filteredMothers.isEmpty
                    ? _buildEmptyState()
                    : _buildMothersList(),
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
              'Error Loading Mothers',
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
              onPressed: _loadMothers,
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
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No Mothers Registered'
                  : 'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'No registered mothers found in the system.'
                  : 'Try adjusting your search terms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontFamily: 'CircularStd',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchController.clear();
                  _filterMothers('');
                } else {
                  _loadMothers();
                }
              },
              icon: Icon(
                _searchController.text.isEmpty ? Icons.refresh : Icons.clear,
              ),
              label: Text(
                _searchController.text.isEmpty ? 'Refresh' : 'Clear Search',
              ),
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

  Widget _buildMothersList() {
    return RefreshIndicator(
      onRefresh: _loadMothers,
      color: const Color(0xFF4FC3A1),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMothers.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildMotherCard(filteredMothers[index], index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMotherCard(Map<String, dynamic> mother, int index) {
    final fullName = mother['fullName'] ?? 'Unknown Mother';
    final nicNumber = mother['nicNumber'] ?? 'Unknown NIC';
    final phoneNumber = mother['phoneNumber']?.toString();
    final address = mother['address']?.toString();

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
          onTap: () => _selectMother(mother),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.pregnant_woman,
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
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FC3A1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NIC: $nicNumber',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D5A),
                                fontFamily: 'CircularStd',
                              ),
                            ),
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
                if (phoneNumber != null || address != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (phoneNumber != null && phoneNumber.isNotEmpty)
                          _buildInfoRow('Phone', phoneNumber, Icons.phone),
                        if (address != null && address.isNotEmpty)
                          _buildInfoRow('Address', address, Icons.location_on),
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
                      Icon(Icons.child_care, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View Baby Records',
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
                fontFamily: 'CircularStd',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
