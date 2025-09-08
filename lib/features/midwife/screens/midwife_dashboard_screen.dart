import 'package:flutter/material.dart';
import '../../../services/baby_service.dart';
import '../../../models/baby.dart';
import 'midwife_baby_records_screen.dart';
import 'baby_comprehensive_records_screen.dart';
import 'midwife_thiriposa_records_screen.dart';

class MidwifeDashboardScreen extends StatefulWidget {
  const MidwifeDashboardScreen({Key? key}) : super(key: key);

  @override
  _MidwifeDashboardScreenState createState() => _MidwifeDashboardScreenState();
}

class _MidwifeDashboardScreenState extends State<MidwifeDashboardScreen> {
  final TextEditingController _nicController = TextEditingController();
  List<Map<String, dynamic>> _babies = [];
  bool _isLoading = false;
  String? _selectedMotherNic;
  String? _motherName;

  @override
  void dispose() {
    _nicController.dispose();
    super.dispose();
  }

  Future<void> _searchBabies() async {
    if (_nicController.text.trim().isEmpty) {
      _showSnackBar('Please enter mother\'s NIC number', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _babies = [];
      _selectedMotherNic = null;
      _motherName = null;
    });

    try {
      final babies = await BabyService.getBabiesByMotherNic(
        _nicController.text.trim(),
      );
      setState(() {
        _babies = babies;
        _selectedMotherNic = _nicController.text.trim();
        _motherName = babies.isNotEmpty
            ? babies.first['motherName'] ?? 'Unknown'
            : 'Unknown';
        _isLoading = false;
      });

      if (babies.isEmpty) {
        _showSnackBar('No babies found for this mother', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error searching babies: $e', isError: true);
    }
  }

  void _viewBabyRecords(Map<String, dynamic> babyData) {
    // Convert Map to Baby object
    final baby = Baby(
      id: babyData['id'],
      motherNic: babyData['motherNic'],
      motherName: babyData['motherName'] ?? _motherName ?? 'Unknown',
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidwifeBabyRecordsScreen(
          baby: baby,
          motherNic: _selectedMotherNic!,
        ),
      ),
    );
  }

  void _viewComprehensiveRecords(Map<String, dynamic> babyData) {
    // Convert Map to Baby object
    final baby = Baby(
      id: babyData['id'],
      motherNic: babyData['motherNic'],
      motherName: babyData['motherName'] ?? _motherName ?? 'Unknown',
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabyComprehensiveRecordsScreen(
          baby: baby,
          motherNic: _selectedMotherNic!,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToThiriposaRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MidwifeThiriposaRecordsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Midwife Dashboard'),
        backgroundColor: Colors.pink[100],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Mother & Babies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nicController,
                              decoration: InputDecoration(
                                labelText: 'Mother\'s NIC Number',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.pink[300],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.pink[300]!,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _searchBabies(),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _searchBabies,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[300],
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Search',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Results Section
              if (_selectedMotherNic != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.pink[300],
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mother: $_motherName',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'NIC: $_selectedMotherNic',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total Babies: ${_babies.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Babies List
              if (_babies.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Baby to Manage Records:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700],
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _babies.length,
                          itemBuilder: (context, index) {
                            final baby = _babies[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.pink[100],
                                  child: Text(
                                    (baby['babyOrder'] ?? index + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.pink[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  baby['babyName'] ?? 'Baby ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.pink[700],
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Birth Date: ${baby['dateOfBirth'] ?? 'Not set'}',
                                    ),
                                    Text(
                                      'Gender: ${baby['gender'] ?? 'Not specified'}',
                                    ),
                                    if (baby['birthWeight'] != null)
                                      Text(
                                        'Birth Weight: ${baby['birthWeight']}g',
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.assignment,
                                        color: Colors.pink[400],
                                      ),
                                      onPressed: () =>
                                          _viewComprehensiveRecords(baby),
                                      tooltip: 'Complete Records',
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.pink[300],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                onTap: () => _viewBabyRecords(baby),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else if (_selectedMotherNic != null && !_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.baby_changing_station,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No babies found for this mother',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Enter mother\'s NIC to view babies',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToThiriposaRecords,
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        icon: Icon(Icons.inventory_2),
        label: Text('Thiriposa Records'),
      ),
    );
  }
}
