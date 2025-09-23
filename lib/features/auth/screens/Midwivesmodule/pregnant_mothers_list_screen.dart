import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/api_config.dart';
import 'pregnant_mother_details_screen.dart';

class PregnantMothersListScreen extends StatefulWidget {
  const PregnantMothersListScreen({super.key});

  @override
  State<PregnantMothersListScreen> createState() =>
      _PregnantMothersListScreenState();
}

class _PregnantMothersListScreenState extends State<PregnantMothersListScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _allMothers = [];
  List<Map<String, dynamic>> _pregnantMothers = [];
  List<Map<String, dynamic>> _filteredMothers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'All'; // All, Pregnant, Non Pregnant

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMothers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // First, get all registered mothers
      final mothersResponse = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/user/mothers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (mothersResponse.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(
          mothersResponse.body,
        );
        if (responseData['success'] && responseData['mothers'] != null) {
          final List<dynamic> mothersData = responseData['mothers'];
          _allMothers = mothersData.cast<Map<String, dynamic>>();

          // Filter for pregnant mothers (those with maternal profiles indicating pregnancy)
          await _filterPregnantMothers();
        } else {
          throw Exception('No mothers data in response');
        }
      } else {
        throw Exception(
          'Failed to load mothers - Server returned ${mothersResponse.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading mothers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _filterPregnantMothers() async {
    List<Map<String, dynamic>> pregnantMothers = [];

    print(
      'Treating all ${_allMothers.length} registered mothers as pregnant mothers...',
    );

    for (var mother in _allMothers) {
      try {
        // Check if mother has a maternal profile (optional)
        final profileResponse = await http.get(
          Uri.parse(
            '${ApiConfig.baseApiUrl}/maternal-profile/${mother['nicNumber']}',
          ),
          headers: {'Content-Type': 'application/json'},
        );

        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);

          if (profileData['success'] && profileData['profile'] != null) {
            // Add existing pregnancy profile information
            mother['pregnancyInfo'] = profileData['profile'];
            print('Profile found for ${mother['fullName']}');
          } else {
            // No profile exists yet - will be created when midwife updates
            mother['pregnancyInfo'] = null;
            print(
              'No profile found for ${mother['fullName']} - profile will be created when needed',
            );
          }
        } else {
          mother['pregnancyInfo'] = null;
        }

        // Add all mothers to pregnant mothers list
        pregnantMothers.add(mother);
      } catch (e) {
        print('Error loading profile for ${mother['nicNumber']}: $e');
        // Still add mother even if profile loading fails
        mother['pregnancyInfo'] = null;
        pregnantMothers.add(mother);
      }
    }

    print(
      'Found ${pregnantMothers.length} pregnant mothers (all registered mothers)',
    );

    if (!mounted) return;
    setState(() {
      _pregnantMothers = pregnantMothers;
      _filteredMothers = pregnantMothers;
      _isLoading = false;
    });
  }

  void _filterMothers(String query) {
    setState(() {
      List<Map<String, dynamic>> baseList = _pregnantMothers;

      // First filter by pregnancy status
      if (_selectedFilter != 'All') {
        baseList = _pregnantMothers.where((mother) {
          // Safely handle the pregnancy info casting
          Map<String, dynamic>? pregnancyInfo;
          if (mother['pregnancyInfo'] != null) {
            pregnancyInfo = Map<String, dynamic>.from(
              mother['pregnancyInfo'] as Map,
            );
          }

          final pregnancyStatus =
              pregnancyInfo?['currentPregnancyStatus'] ?? 'PREGNANT';
          final isPregnant = pregnancyStatus != 'NOT_PREGNANT';

          if (_selectedFilter == 'Pregnant') {
            return isPregnant;
          } else if (_selectedFilter == 'Non Pregnant') {
            return !isPregnant;
          }
          return true;
        }).toList();
      }

      // Then filter by search query
      if (query.isEmpty) {
        _filteredMothers = baseList;
      } else {
        _filteredMothers = baseList.where((mother) {
          final name = mother['fullName']?.toString().toLowerCase() ?? '';
          final nic = mother['nicNumber']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || nic.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _applyStatusFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterMothers(
      _searchController.text,
    ); // Re-apply current search with new filter
  }

  void _navigateToMotherDetails(Map<String, dynamic> motherData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PregnantMotherDetailsScreen(motherData: motherData),
      ),
    );
  }

  Future<void> _updatePregnancyStatus(
    Map<String, dynamic> mother,
    bool isPregnant,
  ) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updating pregnancy status...'),
          backgroundColor: const Color(0xFF4FC3A1),
          duration: Duration(seconds: 1),
        ),
      );

      // Prepare the profile data
      final profileData = {
        'currentPregnancyStatus': isPregnant ? 'PREGNANT' : 'NOT_PREGNANT',
        'midwifeNotes': 'Pregnancy status updated by midwife',
      };

      // Update or create maternal profile
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/maternal-profile/${mother['nicNumber']}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          // Update local data
          setState(() {
            if (isPregnant) {
              mother['pregnancyInfo'] = responseData['profile'];
            } else {
              // Safely handle the existing pregnancy info
              Map<String, dynamic> existingInfo = {};
              if (mother['pregnancyInfo'] != null) {
                existingInfo = Map<String, dynamic>.from(
                  mother['pregnancyInfo'] as Map,
                );
              }

              mother['pregnancyInfo'] = {
                ...existingInfo,
                'currentPregnancyStatus': 'NOT_PREGNANT',
              };
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${mother['fullName']} marked as ${isPregnant ? 'Pregnant' : 'Non Pregnant'}',
              ),
              backgroundColor: const Color(0xFF4FC3A1),
            ),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update status');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMotherCard(Map<String, dynamic> mother) {
    // Safely handle the pregnancy info casting
    Map<String, dynamic>? pregnancyInfo;
    if (mother['pregnancyInfo'] != null) {
      pregnancyInfo = Map<String, dynamic>.from(mother['pregnancyInfo'] as Map);
    }

    final pregnancyWeek = pregnancyInfo?['currentPregnancyWeek'];
    final expectedDeliveryDate = pregnancyInfo?['expectedDeliveryDate'];
    final lastMenstrualPeriod = pregnancyInfo?['lastMenstrualPeriod'];

    // Check pregnancy status
    final pregnancyStatus =
        pregnancyInfo?['currentPregnancyStatus'] ?? 'PREGNANT';
    final isPregnant = pregnancyStatus != 'NOT_PREGNANT';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToMotherDetails(mother),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          (isPregnant ? const Color(0xFF4FC3A1) : Colors.grey)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPregnant ? Icons.pregnant_woman : Icons.person,
                      color: isPregnant ? const Color(0xFF4FC3A1) : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mother['fullName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIC: ${mother['nicNumber'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPregnant
                              ? const Color(0xFF4FC3A1)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPregnant ? 'PREGNANT' : 'NON PREGNANT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () =>
                            _updatePregnancyStatus(mother, !isPregnant),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF4FC3A1)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            isPregnant ? 'Mark Non Pregnant' : 'Mark Pregnant',
                            style: const TextStyle(
                              color: Color(0xFF4FC3A1),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Pregnancy Week',
                            pregnancyWeek != null
                                ? '${pregnancyWeek} weeks'
                                : 'Not set',
                            Icons.calendar_today,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Expected Delivery',
                            expectedDeliveryDate != null
                                ? _formatDate(expectedDeliveryDate)
                                : 'Not set',
                            Icons.event,
                          ),
                        ),
                      ],
                    ),
                    if (lastMenstrualPeriod != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        'Last Menstrual Period',
                        _formatDate(lastMenstrualPeriod),
                        Icons.date_range,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phone: ${mother['phoneNumber3'] ?? 'Not available'}',
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF4FC3A1),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4FC3A1)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E7D5A),
                  fontFamily: 'SpotifyCircular',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not set';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F7),
      appBar: AppBar(
        title: const Text(
          'Pregnant Mother\'s Records',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpotifyCircular',
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMothers),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF4FC3A1),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterMothers,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or NIC number...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'SpotifyCircular',
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF4FC3A1),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'SpotifyCircular'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter dropdown
                  Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter:',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              dropdownColor: const Color(0xFF4FC3A1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'SpotifyCircular',
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              items: ['All', 'Pregnant', 'Non Pregnant'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SpotifyCircular',
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _applyStatusFilter(newValue);
                                }
                              },
                            ),
                          ),
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
                      'Found ${_filteredMothers.length} pregnant mothers',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4FC3A1),
                        ),
                      ),
                    )
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMothers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Debug Info:\nAPI: ${ApiConfig.baseApiUrl}/user/mothers\nLoaded ${_allMothers.length} mothers',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _filteredMothers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pregnant_woman,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No pregnant mothers found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pregnant mothers will appear here when maternal profiles are created.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredMothers.length,
                      itemBuilder: (context, index) {
                        return _buildMotherCard(_filteredMothers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add new pregnant mother screen or help
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'To add a pregnant mother, create a maternal profile first',
              ),
              backgroundColor: Color(0xFF4FC3A1),
            ),
          );
        },
        backgroundColor: const Color(0xFF4FC3A1),
        label: const Text(
          'Add Pregnant Mother',
          style: TextStyle(color: Colors.white, fontFamily: 'SpotifyCircular'),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
