import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/api_config.dart';

class MidwifeVaccinationScreen extends StatefulWidget {
  const MidwifeVaccinationScreen({super.key});

  @override
  State<MidwifeVaccinationScreen> createState() =>
      _MidwifeVaccinationScreenState();
}

class _MidwifeVaccinationScreenState extends State<MidwifeVaccinationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _registeredMothers = [];
  List<Map<String, dynamic>> _filteredMothers = [];
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllRegisteredMothers();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        Uri.parse('${ApiConfig.baseApiUrl}/registrations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _registeredMothers = data
              .map((item) => item as Map<String, dynamic>)
              .toList();
          _filteredMothers = List.from(_registeredMothers);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load registered mothers');
      }
    } catch (e) {
      print('Error loading registered mothers: $e');
      setState(() {
        _registeredMothers = [];
        _filteredMothers = [];
        _isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to load registered mothers. Please check your internet connection and try again.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadAllRegisteredMothers,
            ),
          ),
        );
      }
    }
  }

  // Filter mothers based on search input
  void _filterMothers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMothers = List.from(_registeredMothers);
      } else {
        _filteredMothers = _registeredMothers.where((mother) {
          final fullName = mother['fullName']?.toString().toLowerCase() ?? '';
          final nicNumber = mother['nicNumber']?.toString().toLowerCase() ?? '';
          final phoneNumber =
              mother['phoneNumber3']?.toString().toLowerCase() ?? '';
          final email = mother['email']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return fullName.contains(searchQuery) ||
              nicNumber.contains(searchQuery) ||
              phoneNumber.contains(searchQuery) ||
              email.contains(searchQuery);
        }).toList();
      }
    });
  }

  // Show vaccination management dialog for a specific mother
  void _showVaccinationDialog(Map<String, dynamic> mother) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vaccination Records for ${mother['fullName']}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mother Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('NIC: ${mother['nicNumber']}'),
                      Text('Phone: ${mother['phoneNumber3']}'),
                      Text('Email: ${mother['email']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vaccination Records',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.vaccines_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Vaccination management system\nwill be implemented here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to detailed vaccination management screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Managing vaccinations for ${mother['fullName']}',
                  ),
                ),
              );
            },
            child: const Text('Manage Vaccinations'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vaccination Management',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'All Mothers'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Mothers Tab
          _buildAllMothersTab(),
          // Search Tab
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildAllMothersTab() {
    return Column(
      children: [
        // Header with count
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Color(0xFF4FC3A1)),
              const SizedBox(width: 8),
              Text(
                'Registered Mothers (${_filteredMothers.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAllRegisteredMothers,
                  tooltip: 'Refresh',
                ),
            ],
          ),
        ),
        // Mothers List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredMothers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _filteredMothers.length,
                  itemBuilder: (context, index) {
                    final mother = _filteredMothers[index];
                    return _buildMotherCard(mother);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, NIC, phone, or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterMothers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _filterMothers,
          ),
        ),
        // Search Results
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredMothers.isEmpty
              ? _buildEmptySearchState()
              : ListView.builder(
                  itemCount: _filteredMothers.length,
                  itemBuilder: (context, index) {
                    final mother = _filteredMothers[index];
                    return _buildMotherCard(mother);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMotherCard(Map<String, dynamic> mother) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showVaccinationDialog(mother),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: const Color(0xFF4FC3A1).withOpacity(0.1),
                child: Text(
                  (mother['fullName'] ?? 'U')
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4FC3A1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Mother Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mother['fullName'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIC: ${mother['nicNumber'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Phone: ${mother['phoneNumber3'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Action Button
              Column(
                children: [
                  Icon(Icons.vaccines, color: Colors.grey.shade400),
                  const SizedBox(height: 4),
                  Text(
                    'Manage',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No registered mothers found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registered mothers will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAllRegisteredMothers,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Start typing to search mothers'
                : 'No mothers found matching "${_searchController.text}"',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _filterMothers('');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
}
