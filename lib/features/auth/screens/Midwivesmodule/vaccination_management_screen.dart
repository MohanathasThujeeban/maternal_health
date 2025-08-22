import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/api_config.dart';
import '../../../../services/vaccination_service.dart';

class VaccinationManagementScreen extends StatefulWidget {
  const VaccinationManagementScreen({super.key});

  @override
  State<VaccinationManagementScreen> createState() =>
      _VaccinationManagementScreenState();
}

class _VaccinationManagementScreenState extends State<VaccinationManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _registeredMothers = [];
  List<Map<String, dynamic>> _filteredMothers = [];
  Map<String, dynamic>? _selectedMother;
  List<Map<String, dynamic>> _vaccinations = [];
  
  bool _isLoading = false;
  bool _isLoadingVaccinations = false;

  @override
  void initState() {
    super.initState();
    _loadAllRegisteredMothers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load all registered mothers from the backend
  void _loadAllRegisteredMothers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/registration/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _registeredMothers = data.map((item) => item as Map<String, dynamic>).toList();
          _filteredMothers = _registeredMothers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load registered mothers');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading mothers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Load vaccinations for a specific mother
  void _loadVaccinationsForMother(Map<String, dynamic> mother) async {
    setState(() {
      _selectedMother = mother;
      _isLoadingVaccinations = true;
    });

    try {
      final nicNumber = mother['nicNumber'];
      final vaccinations = await VaccinationService.getVaccinationsByMotherNic(nicNumber);
      
      setState(() {
        _vaccinations = vaccinations;
        _isLoadingVaccinations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVaccinations = false;
        _vaccinations = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading vaccinations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter mothers based on search query
  void _filterMothers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMothers = _registeredMothers;
      } else {
        _filteredMothers = _registeredMothers.where((mother) {
          final fullName = mother['fullName']?.toString().toLowerCase() ?? '';
          final nicNumber = mother['nicNumber']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return fullName.contains(searchQuery) || nicNumber.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Vaccination Management',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.vaccines, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _selectedMother != null ? '${_vaccinations.length} Records' : 'Select Mother',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isTablet 
        ? Row(
            children: [
              // Left panel - Mother search and list (for tablets/desktop)
              Expanded(
                flex: 2,
                child: _buildMotherSelectionPanel(),
              ),
              // Right panel - Vaccination management
              Expanded(
                flex: 3,
                child: _selectedMother == null
                    ? _buildSelectMotherPrompt()
                    : _buildEnhancedVaccinationPanel(),
              ),
            ],
          )
        : _selectedMother == null
          ? _buildMotherSelectionPanel() // Show only mother selection on mobile
          : Column( // Show vaccination panel with back option on mobile
              children: [
                // Mobile back navigation
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedMother = null;
                            _vaccinations.clear();
                          });
                        },
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4FC3A1)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Mother List',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4FC3A1),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildEnhancedVaccinationPanel()),
              ],
            ),
      floatingActionButton: _selectedMother != null ? FloatingActionButton.extended(
        onPressed: _showEnhancedAddVaccinationDialog,
        backgroundColor: const Color(0xFF4FC3A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Vaccination',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ) : null,
    );
  }

  Widget _buildMotherSelectionPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Search header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4FC3A1).withOpacity(0.1),
                  const Color(0xFF4FC3A1).withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3A1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF4FC3A1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Mother',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                          Text(
                            'Search by name or NIC number',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3A1).withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterMothers,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type name or NIC number...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: 'SpotifyCircular',
                      ),
                      prefixIcon: const Icon(
                        Icons.search, 
                        color: Color(0xFF4FC3A1),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade400),
                              onPressed: () {
                                _searchController.clear();
                                _filterMothers('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Mothers list with enhanced design
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4FC3A1)),
                        SizedBox(height: 16),
                        Text(
                          'Loading mothers...',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredMothers.isEmpty
                ? _buildEmptyMothersList()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    itemCount: _filteredMothers.length,
                    itemBuilder: (context, index) {
                      final mother = _filteredMothers[index];
                      final isSelected = _selectedMother != null && 
                          _selectedMother!['nicNumber'] == mother['nicNumber'];
                      return _buildEnhancedMotherCard(mother, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMotherCard(Map<String, dynamic> mother, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  const Color(0xFF4FC3A1).withOpacity(0.15),
                  const Color(0xFF4FC3A1).withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: isSelected ? const Color(0xFF4FC3A1) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? const Color(0xFF4FC3A1).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: isSelected ? 2 : 1,
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _loadVaccinationsForMother(mother),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                          ? [const Color(0xFF4FC3A1), const Color(0xFF3A9B7A)]
                          : [const Color(0xFF4FC3A1).withOpacity(0.8), const Color(0xFF4FC3A1).withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3A1).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (mother['fullName'] ?? 'U')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mother['fullName'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isSelected ? const Color(0xFF2E7D5A) : const Color(0xFF374151),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mother['nicNumber'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mother['phoneNumber'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3A1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMothersList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No registered mothers found'
                : 'No mothers found matching "${_searchController.text}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _searchController.text.isEmpty 
                ? _loadAllRegisteredMothers
                : () {
                    _searchController.clear();
                    _filterMothers('');
                  },
            icon: Icon(_searchController.text.isEmpty ? Icons.refresh : Icons.clear),
            label: Text(_searchController.text.isEmpty ? 'Refresh' : 'Clear Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectMotherPrompt() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAFDFC), Color(0xFFF0F9F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.vaccines_outlined, 
                size: 80, 
                color: const Color(0xFF4FC3A1).withOpacity(0.8)
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a Mother',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D5A),
                fontFamily: 'SpotifyCircular',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a mother from the left panel to\nview and manage vaccination records',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'SpotifyCircular',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF4FC3A1).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF4FC3A1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search by name or NIC number',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4FC3A1).withOpacity(0.8),
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedVaccinationPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAFDFC), Color(0xFFF0F9F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3A1).withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (_selectedMother!['fullName'] ?? 'U')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMother!['fullName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            _selectedMother!['nicNumber'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            _selectedMother!['phoneNumber'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3A1).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showEnhancedAddVaccinationDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add Vaccination',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Vaccination Records
          Expanded(
            child: _isLoadingVaccinations
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4FC3A1)),
                        SizedBox(height: 16),
                        Text(
                          'Loading vaccination records...',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                  )
                : _vaccinations.isEmpty
                ? _buildEnhancedEmptyVaccinationsList()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _vaccinations.length,
                    itemBuilder: (context, index) {
                      final vaccination = _vaccinations[index];
                      return _buildEnhancedVaccinationCard(vaccination, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Add new vaccination dialog
  void _showAddVaccinationDialog() {
    if (_selectedMother == null) return;

    final childNameController = TextEditingController();
    final vaccinationTypeController = TextEditingController();
    final ageToGiveController = TextEditingController();
    final batchNumberController = TextEditingController();
    final effectsController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Vaccination for ${_selectedMother!['fullName']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: childNameController,
                    decoration: const InputDecoration(
                      labelText: 'Child Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: vaccinationTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Vaccination Type',
                      hintText: 'e.g., BCG, DPT, MMR',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageToGiveController,
                    decoration: const InputDecoration(
                      labelText: 'Age to Give',
                      hintText: 'e.g., Birth, 6 weeks, 3 months',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: effectsController,
                    decoration: const InputDecoration(
                      labelText: 'Effects Following Immunization',
                      hintText: 'Any side effects observed',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text('Vaccination Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (childNameController.text.isEmpty || 
                    vaccinationTypeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final vaccinationData = {
                    'motherNic': _selectedMother!['nicNumber'],
                    'childName': childNameController.text,
                    'vaccinationType': vaccinationTypeController.text,
                    'ageToGive': ageToGiveController.text,
                    'vaccinationDate': selectedDate.toIso8601String(),
                    'batchNumber': batchNumberController.text,
                    'effectsFollowingImmunization': effectsController.text,
                  };

                  await VaccinationService.createVaccination(vaccinationData);

                  Navigator.of(context).pop();
                  _loadVaccinationsForMother(_selectedMother!);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vaccination record added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add vaccination: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add Vaccination'),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced methods for better UI
  Widget _buildEnhancedEmptyVaccinationsList() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4FC3A1).withOpacity(0.2),
                  const Color(0xFF3A9B7A).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.vaccines_outlined,
                size: 60,
                color: const Color(0xFF4FC3A1).withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Vaccination Records Yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding the first vaccination record\nfor ${_selectedMother!['fullName'] ?? 'this mother'}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3A1).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showEnhancedAddVaccinationDialog,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add First Vaccination',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedVaccinationCard(Map<String, dynamic> vaccination, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFBFDFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4FC3A1).withOpacity(0.2),
                        const Color(0xFF3A9B7A).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4FC3A1),
                        fontSize: 18,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination['vaccineName'] ?? 'Unknown Vaccine',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF374151),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            vaccination['dateOfVaccination'] ?? 'No date',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEnhancedEditVaccinationDialog(vaccination);
                    } else if (value == 'delete') {
                      _confirmDeleteVaccination(vaccination['vaccinationId']);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4FC3A1)),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontFamily: 'SpotifyCircular')),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(fontFamily: 'SpotifyCircular')),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4FC3A1).withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3A1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info_outline, 
                                         size: 18, color: Color(0xFF4FC3A1)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vaccination Details',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                            if (vaccination['batchNumber'] != null && vaccination['batchNumber'].toString().isNotEmpty)
                              Text(
                                'Batch: ${vaccination['batchNumber']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                  fontSize: 14,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                            if (vaccination['effectsFollowingImmunization'] != null && vaccination['effectsFollowingImmunization'].toString().isNotEmpty)
                              Text(
                                'Effects: ${vaccination['effectsFollowingImmunization']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                  fontSize: 14,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                          ],
                        ),
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

  void _showEnhancedAddVaccinationDialog() {
    _showAddVaccinationDialog(); // Use existing functionality
  }

  void _showEnhancedEditVaccinationDialog(Map<String, dynamic> vaccination) {
    // For now, show the add dialog since edit functionality doesn't exist yet
    _showAddVaccinationDialog();
  }

  void _confirmDeleteVaccination(int? vaccinationId) {
    if (vaccinationId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccination'),
        content: const Text('Are you sure you want to delete this vaccination record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
