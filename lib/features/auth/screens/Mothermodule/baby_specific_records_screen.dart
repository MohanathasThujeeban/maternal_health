import 'package:flutter/material.dart';
import '../../../../services/baby_service.dart';
import '../../../../services/vaccination_service.dart';
import '../../../../services/thiriposa_service.dart';
import '../../../../services/user_service.dart';
import '../../../../models/baby.dart';
import '../../../../widgets/custom_loading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  String? _motherNic;

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

      // Get current user's NIC
      final userData = await UserService.getUserData();
      _motherNic = userData['nic'];

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
          'http://10.11.8.134:8080/api/baby-problems/baby/${_selectedBaby!.id}',
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
      final response = await http.get(
        Uri.parse(
          'http://10.11.8.134:8080/api/growth-records/baby/${_selectedBaby!.id}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _growthRecords = List<Map<String, dynamic>>.from(data);
        });
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
