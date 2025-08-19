import 'package:flutter/material.dart';
import '../../../../services/vaccination_service.dart';

class MidwifeVaccinationScreen extends StatefulWidget {
  const MidwifeVaccinationScreen({super.key});

  @override
  State<MidwifeVaccinationScreen> createState() =>
      _MidwifeVaccinationScreenState();
}

class _MidwifeVaccinationScreenState extends State<MidwifeVaccinationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _allMothersVaccinations = [];
  String _selectedMotherNic = '';
  bool _isLoading = false;
  bool _showAllMothers = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllMothersVaccinations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllMothersVaccinations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch from backend - no fallback to mock data
      final allVaccinations = await VaccinationService.getAllVaccinations();
      setState(() {
        _allMothersVaccinations = allVaccinations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading vaccinations: $e');
      setState(() {
        _allMothersVaccinations = [];
        _isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load vaccination records. Please check your internet connection and try again.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadAllMothersVaccinations,
            ),
          ),
        );
      }
    }
  }

  void _searchVaccinations() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter Mother NIC')));
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedMotherNic = _searchController.text.trim();
    });

    try {
      // Fetch vaccinations from backend
      final vaccinations = await VaccinationService.getVaccinationsByMotherNic(
        _selectedMotherNic,
      );
      setState(() {
        _vaccinations = vaccinations;
        _isLoading = false;
      });

      if (vaccinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No vaccination records found for NIC: $_selectedMotherNic',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error fetching vaccinations: $e');
      setState(() {
        _vaccinations = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load vaccination records. Please check the NIC and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVaccinationDialog({Map<String, dynamic>? vaccination}) {
    final isEdit = vaccination != null;
    final childNameController = TextEditingController(
      text: vaccination?['childName'] ?? '',
    );
    final vaccinationTypeController = TextEditingController(
      text: vaccination?['vaccinationType'] ?? '',
    );
    final ageToGiveController = TextEditingController(
      text: vaccination?['ageToGive'] ?? '',
    );
    final batchNumberController = TextEditingController(
      text: vaccination?['batchNumber'] ?? '',
    );
    final effectsController = TextEditingController(
      text: vaccination?['effectsFollowingImmunization'] ?? '',
    );

    DateTime? selectedDate = vaccination?['vaccinationDate'];
    String selectedStatus = vaccination?['status'] ?? 'PENDING';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEdit ? 'Edit Vaccination' : 'Add New Vaccination',
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) ...[
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Mother NIC',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                ],
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
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageToGiveController,
                  decoration: const InputDecoration(
                    labelText: 'Age to Give',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? 'Date: ${selectedDate.toString().split(' ')[0]}'
                            : 'No date selected',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
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
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['PENDING', 'COMPLETED', 'MISSED']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final vaccinationData = {
                    'motherNic': isEdit
                        ? vaccination['motherNic']
                        : _selectedMotherNic,
                    'childName': childNameController.text.trim(),
                    'vaccinationType': vaccinationTypeController.text.trim(),
                    'ageToGive': ageToGiveController.text.trim(),
                    'vaccinationDate': selectedDate?.toIso8601String(),
                    'batchNumber': batchNumberController.text.trim(),
                    'effectsFollowingImmunization': effectsController.text
                        .trim(),
                    'status': selectedStatus,
                  };

                  if (isEdit) {
                    // Update existing vaccination with email notification
                    await VaccinationService.updateVaccinationWithNotification(
                      vaccination['id'],
                      vaccinationData,
                    );
                  } else {
                    // Create new vaccination with email notification
                    await VaccinationService.createVaccinationWithNotification(
                      vaccinationData,
                    );
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Vaccination updated successfully. Email sent to mother.'
                            : 'Vaccination added successfully. Email sent to mother.',
                      ),
                      backgroundColor: const Color(0xFF4FC3A1),
                    ),
                  );

                  // Refresh the lists
                  if (_selectedMotherNic.isNotEmpty) {
                    _searchVaccinations();
                  }
                  _loadAllMothersVaccinations();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5A),
              ),
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateVaccinationStatus(int id, String status) async {
    try {
      // Use the method with email notification
      await VaccinationService.updateVaccinationStatusWithNotification(
        id,
        status,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vaccination status updated to $status. Email notification sent to mother.',
          ),
          backgroundColor: const Color(0xFF4FC3A1),
        ),
      );

      // Refresh the list
      if (_selectedMotherNic.isNotEmpty) {
        _searchVaccinations();
      }
      _loadAllMothersVaccinations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMotherSelectionDialog() async {
    try {
      final mothers = await VaccinationService.searchMothers('');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Select Mother',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by name or NIC',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF4FC3A1),
                    ),
                  ),
                  onChanged: (value) async {
                    // Implement real-time search here if needed
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: mothers.length,
                    itemBuilder: (context, index) {
                      final mother = mothers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF4FC3A1),
                            child: Text(
                              mother['motherName']
                                  .toString()
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            mother['motherName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NIC: ${mother['motherNic']}'),
                              if (mother['motherEmail'] != null)
                                Text('Email: ${mother['motherEmail']}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _selectMother(mother['motherNic']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Select',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading mothers: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectMother(String motherNic) {
    setState(() {
      _selectedMotherNic = motherNic;
      _searchController.text = motherNic;
    });
    _searchVaccinations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vaccination Management',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5A),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Search by Mother', icon: Icon(Icons.search)),
            Tab(text: 'All Mothers', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSearchByMotherTab(), _buildAllMothersTab()],
      ),
    );
  }

  Widget _buildSearchByMotherTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Enter Mother NIC',
                            hintText: 'e.g., 123456789V',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF4FC3A1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF4FC3A1),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _searchVaccinations,
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text(
                          'Search',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D5A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Select Mother Button Row
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'SpotifyCircular',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showMotherSelectionDialog,
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      label: const Text(
                        'Select from Registered Mothers',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3A1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedMotherNic.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vaccinations for: $_selectedMotherNic',
                          style: const TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showVaccinationDialog(),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add New',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3A1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4FC3A1)),
                  )
                : _vaccinations.isEmpty
                ? _buildEmptyState()
                : _buildVaccinationList(_vaccinations),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMothersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Stats Cards
          _buildStatsCards(),
          const SizedBox(height: 16),

          // Filter and Actions
          Row(
            children: [
              Expanded(
                child: Text(
                  'All Registered Mothers',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D5A),
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showMotherSelectionDialog(),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Select Mother',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadAllMothersVaccinations,
                icon: const Icon(Icons.refresh, color: Color(0xFF4FC3A1)),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All Mothers Vaccination List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4FC3A1)),
                  )
                : _allMothersVaccinations.isEmpty
                ? _buildEmptyState()
                : _buildGroupedVaccinationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.vaccines_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedMotherNic.isEmpty
                ? 'Enter a Mother NIC to search vaccinations'
                : 'No vaccinations found',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalVaccinations = _allMothersVaccinations.length;
    final completedVaccinations = _allMothersVaccinations
        .where((v) => v['status'] == 'COMPLETED')
        .length;
    final pendingVaccinations = _allMothersVaccinations
        .where((v) => v['status'] == 'PENDING')
        .length;
    final overdueVaccinations = _allMothersVaccinations
        .where((v) => v['status'] == 'MISSED')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '$totalVaccinations',
            Icons.vaccines,
            const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '$completedVaccinations',
            Icons.check_circle,
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '$pendingVaccinations',
            Icons.schedule,
            const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Overdue',
            '$overdueVaccinations',
            Icons.warning,
            const Color(0xFFF44336),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedVaccinationList() {
    // Group vaccinations by mother NIC
    final Map<String, List<Map<String, dynamic>>> groupedVaccinations = {};
    for (final vaccination in _allMothersVaccinations) {
      final motherNic = vaccination['motherNic'];
      if (!groupedVaccinations.containsKey(motherNic)) {
        groupedVaccinations[motherNic] = [];
      }
      groupedVaccinations[motherNic]!.add(vaccination);
    }

    return ListView.builder(
      itemCount: groupedVaccinations.length,
      itemBuilder: (context, index) {
        final motherNic = groupedVaccinations.keys.elementAt(index);
        final motherVaccinations = groupedVaccinations[motherNic]!;
        final completedCount = motherVaccinations
            .where((v) => v['status'] == 'COMPLETED')
            .length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4FC3A1),
              child: Text(
                motherNic.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Mother: $motherNic',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'SpotifyCircular',
                color: Color(0xFF2E7D5A),
              ),
            ),
            subtitle: Text(
              '$completedCount/${motherVaccinations.length} vaccinations completed',
              style: const TextStyle(color: Colors.grey),
            ),
            children: motherVaccinations
                .map((vaccination) => _buildVaccinationTile(vaccination))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationList(List<Map<String, dynamic>> vaccinations) {
    return ListView.builder(
      itemCount: vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = vaccinations[index];
        return _buildVaccinationCard(vaccination);
      },
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vaccination['vaccinationType'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D5A),
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(vaccination['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vaccination['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.child_care, 'Child:', vaccination['childName']),
            _buildInfoRow(
              Icons.calendar_today,
              'Age:',
              vaccination['ageToGive'],
            ),
            if (vaccination['vaccinationDate'] != null)
              _buildInfoRow(
                Icons.event,
                'Date:',
                vaccination['vaccinationDate'].toString().split(' ')[0],
              ),
            if (vaccination['batchNumber'] != null &&
                vaccination['batchNumber'].toString().isNotEmpty)
              _buildInfoRow(
                Icons.inventory,
                'Batch:',
                vaccination['batchNumber'],
              ),
            if (vaccination['effectsFollowingImmunization'] != null &&
                vaccination['effectsFollowingImmunization']
                    .toString()
                    .isNotEmpty)
              _buildInfoRow(
                Icons.info_outline,
                'Effects:',
                vaccination['effectsFollowingImmunization'],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showVaccinationDialog(vaccination: vaccination),
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (vaccination['status'] == 'PENDING') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateVaccinationStatus(
                        vaccination['id'],
                        'COMPLETED',
                      ),
                      icon: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Complete',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateVaccinationStatus(vaccination['id'], 'MISSED'),
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Miss',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationTile(Map<String, dynamic> vaccination) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(vaccination['status']),
        radius: 20,
        child: Icon(
          vaccination['status'] == 'COMPLETED'
              ? Icons.check
              : vaccination['status'] == 'PENDING'
              ? Icons.schedule
              : Icons.close,
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(
        vaccination['vaccinationType'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'SpotifyCircular',
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Child: ${vaccination['childName']}'),
          Text('Age: ${vaccination['ageToGive']}'),
          if (vaccination['vaccinationDate'] != null)
            Text(
              'Date: ${vaccination['vaccinationDate'].toString().split(' ')[0]}',
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Color(0xFF4FC3A1)),
        onPressed: () => _showVaccinationDialog(vaccination: vaccination),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4FC3A1)),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Color(0xFF2E2E2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF8BC34A);
      case 'PENDING':
        return const Color(0xFFFF9800);
      case 'MISSED':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }
}
