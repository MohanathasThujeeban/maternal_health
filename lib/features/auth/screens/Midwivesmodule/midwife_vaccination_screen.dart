import 'package:flutter/material.dart';
import '../../../../services/vaccination_service.dart';

class MidwifeVaccinationScreen extends StatefulWidget {
  const MidwifeVaccinationScreen({super.key});

  @override
  State<MidwifeVaccinationScreen> createState() => _MidwifeVaccinationScreenState();
}

class _MidwifeVaccinationScreenState extends State<MidwifeVaccinationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _vaccinations = [];
  String _selectedMotherNic = '';
  bool _isLoading = false;

  // Mock vaccination data for now
  final List<Map<String, dynamic>> _mockVaccinations = [
    {
      'id': 1,
      'motherNic': '123456789V',
      'childName': 'Baby John',
      'vaccinationType': 'BCG',
      'ageToGive': '0-2 months',
      'vaccinationDate': DateTime(2025, 8, 15),
      'batchNumber': 'BCG2025001',
      'effectsFollowingImmunization': 'None',
      'status': 'COMPLETED'
    },
    {
      'id': 2,
      'motherNic': '123456789V',
      'childName': 'Baby John',
      'vaccinationType': 'OPV',
      'ageToGive': '2-4 months',
      'vaccinationDate': null,
      'batchNumber': '',
      'effectsFollowingImmunization': '',
      'status': 'PENDING'
    },
  ];

  void _searchVaccinations() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Mother NIC')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedMotherNic = _searchController.text.trim();
    });

    try {
      // Fetch vaccinations from backend
      final vaccinations = await VaccinationService.getVaccinationsByMotherNic(_selectedMotherNic);
      setState(() {
        _vaccinations = vaccinations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching vaccinations: $e');
      // Fallback to mock data on error
      setState(() {
        _vaccinations = _mockVaccinations
            .where((v) => v['motherNic'] == _selectedMotherNic)
            .toList();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
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
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
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
                    'motherNic': isEdit ? vaccination['motherNic'] : _selectedMotherNic,
                    'childName': childNameController.text.trim(),
                    'vaccinationType': vaccinationTypeController.text.trim(),
                    'ageToGive': ageToGiveController.text.trim(),
                    'vaccinationDate': selectedDate?.toIso8601String(),
                    'batchNumber': batchNumberController.text.trim(),
                    'effectsFollowingImmunization': effectsController.text.trim(),
                    'status': selectedStatus,
                  };

                  if (isEdit) {
                    // Update existing vaccination
                    await VaccinationService.updateVaccination(
                      vaccination['id'],
                      vaccinationData,
                    );
                  } else {
                    // Create new vaccination
                    await VaccinationService.createVaccination(vaccinationData);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Vaccination updated successfully'
                            : 'Vaccination added successfully',
                      ),
                    ),
                  );
                  
                  // Refresh the list
                  if (_selectedMotherNic.isNotEmpty) {
                    _searchVaccinations();
                  }
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
      await VaccinationService.updateVaccinationStatus(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vaccination status updated to $status')),
      );
      
      // Refresh the list
      if (_selectedMotherNic.isNotEmpty) {
        _searchVaccinations();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: ${e.toString()}')),
      );
    }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Enter Mother NIC',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _searchVaccinations,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D5A),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Search'),
                        ),
                      ],
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
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showVaccinationDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add New'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
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

            // Vaccinations List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _vaccinations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.vaccines_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedMotherNic.isEmpty
                                    ? 'Enter a Mother NIC to search vaccinations'
                                    : 'No vaccinations found',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _vaccinations.length,
                          itemBuilder: (context, index) {
                            final vaccination = _vaccinations[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          vaccination['vaccinationType'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D5A),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                vaccination['status']),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            vaccination['status'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Child: ${vaccination['childName']}'),
                                    Text('Age: ${vaccination['ageToGive']}'),
                                    if (vaccination['vaccinationDate'] != null)
                                      Text(
                                          'Date: ${vaccination['vaccinationDate'].toString().split(' ')[0]}'),
                                    if (vaccination['batchNumber'].isNotEmpty)
                                      Text(
                                          'Batch: ${vaccination['batchNumber']}'),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showVaccinationDialog(
                                                  vaccination: vaccination),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('Edit'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF4FC3A1),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (vaccination['status'] == 'PENDING')
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _updateVaccinationStatus(
                                                    vaccination['id'],
                                                    'COMPLETED'),
                                            icon: const Icon(Icons.check,
                                                size: 16),
                                            label: const Text('Complete'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF8BC34A),
                                            ),
                                          ),
                                        if (vaccination['status'] == 'PENDING')
                                          const SizedBox(width: 8),
                                        if (vaccination['status'] == 'PENDING')
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _updateVaccinationStatus(
                                                    vaccination['id'], 'MISSED'),
                                            icon: const Icon(Icons.close,
                                                size: 16),
                                            label: const Text('Miss'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFF44336),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
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
