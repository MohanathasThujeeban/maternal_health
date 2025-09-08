import 'package:flutter/material.dart';
import '../../../models/baby.dart';
import '../../../models/vaccination.dart';
import '../../../models/growth_entry.dart';
import '../../../models/thiriposa_record.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/growth_entry_service.dart';
import '../../../services/thiriposa_service.dart';
import 'midwife_add_vaccination_screen.dart';
import 'midwife_add_growth_screen.dart';
import 'midwife_add_thiriposa_screen.dart';
import 'baby_comprehensive_records_screen.dart';

class MidwifeBabyRecordsScreen extends StatefulWidget {
  final Baby baby;
  final String motherNic;

  const MidwifeBabyRecordsScreen({
    Key? key,
    required this.baby,
    required this.motherNic,
  }) : super(key: key);

  @override
  _MidwifeBabyRecordsScreenState createState() =>
      _MidwifeBabyRecordsScreenState();
}

class _MidwifeBabyRecordsScreenState extends State<MidwifeBabyRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Vaccination> _vaccinations = [];
  List<GrowthEntry> _growthEntries = [];
  List<ThiriposaRecord> _thiriposaRecords = [];

  bool _isLoadingVaccinations = false;
  bool _isLoadingGrowth = false;
  bool _isLoadingThiriposa = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRecords() async {
    await Future.wait([
      _loadVaccinations(),
      _loadGrowthEntries(),
      _loadThiriposaRecords(),
    ]);
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoadingVaccinations = true);
    try {
      final vaccinations = await VaccinationService.getVaccinationsByBaby(
        widget.baby.id,
      );
      setState(() {
        _vaccinations = vaccinations;
        _isLoadingVaccinations = false;
      });
    } catch (e) {
      setState(() => _isLoadingVaccinations = false);
      _showSnackBar('Error loading vaccinations: $e', isError: true);
    }
  }

  Future<void> _loadGrowthEntries() async {
    setState(() => _isLoadingGrowth = true);
    try {
      final entries = await GrowthEntryService.getEntriesByBaby(widget.baby.id);
      setState(() {
        _growthEntries = entries;
        _isLoadingGrowth = false;
      });
    } catch (e) {
      setState(() => _isLoadingGrowth = false);
      _showSnackBar('Error loading growth entries: $e', isError: true);
    }
  }

  Future<void> _loadThiriposaRecords() async {
    setState(() => _isLoadingThiriposa = true);
    try {
      final records = await ThiriposaService.getRecordsByBaby(widget.baby.id);
      setState(() {
        _thiriposaRecords = records;
        _isLoadingThiriposa = false;
      });
    } catch (e) {
      setState(() => _isLoadingThiriposa = false);
      _showSnackBar('Error loading thiriposa records: $e', isError: true);
    }
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

  void _addNewRecord(int tabIndex) async {
    Widget? screen;

    switch (tabIndex) {
      case 0: // Vaccination
        screen = MidwifeAddVaccinationScreen(
          baby: widget.baby,
          motherNic: widget.motherNic,
        );
        break;
      case 1: // Growth
        screen = MidwifeAddGrowthScreen(
          baby: widget.baby,
          motherNic: widget.motherNic,
        );
        break;
      case 2: // Thiriposa
        screen = MidwifeAddThiriposaScreen(
          baby: widget.baby,
          motherNic: widget.motherNic,
        );
        break;
    }

    if (screen != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );

      if (result == true) {
        // Refresh the relevant tab
        switch (tabIndex) {
          case 0:
            _loadVaccinations();
            break;
          case 1:
            _loadGrowthEntries();
            break;
          case 2:
            _loadThiriposaRecords();
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.baby.name, style: TextStyle(fontSize: 18)),
            Text(
              'Age: ${widget.baby.ageInMonths} months',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.pink[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BabyComprehensiveRecordsScreen(
                    baby: widget.baby,
                    motherNic: widget.motherNic,
                  ),
                ),
              );
            },
            tooltip: 'View Complete Records',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.vaccines), text: 'Vaccinations'),
            Tab(icon: Icon(Icons.trending_up), text: 'Growth'),
            Tab(icon: Icon(Icons.local_pharmacy), text: 'Thiriposa'),
          ],
          labelColor: Colors.pink[700],
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Baby Info Card
            Container(
              margin: EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.pink[100],
                        radius: 30,
                        child: Text(
                          widget.baby.babyOrder.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.baby.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[700],
                              ),
                            ),
                            Text(
                              'Birth Date: ${widget.baby.formattedBirthDate}',
                            ),
                            Text('Gender: ${widget.baby.gender}'),
                            if (widget.baby.birthWeight != null)
                              Text('Birth Weight: ${widget.baby.birthWeight}g'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVaccinationTab(),
                  _buildGrowthTab(),
                  _buildThiriposaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewRecord(_tabController.index),
        backgroundColor: Colors.pink[300],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVaccinationTab() {
    if (_isLoadingVaccinations) {
      return Center(child: CircularProgressIndicator());
    }

    if (_vaccinations.isEmpty) {
      return _buildEmptyState('No vaccinations recorded yet', Icons.vaccines);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = _vaccinations[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.vaccines, color: Colors.green[700]),
            ),
            title: Text(vaccination.vaccinationType),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Child: ${vaccination.childName}'),
                Text('Date: ${vaccination.vaccinationDate}'),
                Text('Status: ${vaccination.status}'),
              ],
            ),
            trailing: Chip(
              label: Text(vaccination.status),
              backgroundColor: vaccination.status == 'COMPLETED'
                  ? Colors.green[100]
                  : Colors.orange[100],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrowthTab() {
    if (_isLoadingGrowth) {
      return Center(child: CircularProgressIndicator());
    }

    if (_growthEntries.isEmpty) {
      return _buildEmptyState('No growth records yet', Icons.trending_up);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _growthEntries.length,
      itemBuilder: (context, index) {
        final entry = _growthEntries[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.trending_up, color: Colors.blue[700]),
            ),
            title: Text('Height: ${entry.height}cm, Weight: ${entry.weight}kg'),
            subtitle: Text('Date: ${entry.date.toString().split(' ')[0]}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildThiriposaTab() {
    if (_isLoadingThiriposa) {
      return Center(child: CircularProgressIndicator());
    }

    if (_thiriposaRecords.isEmpty) {
      return _buildEmptyState('No thiriposa records yet', Icons.local_pharmacy);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _thiriposaRecords.length,
      itemBuilder: (context, index) {
        final record = _thiriposaRecords[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Icon(Icons.local_pharmacy, color: Colors.purple[700]),
            ),
            title: Text('Quantity: ${record.quantity}'),
            subtitle: Text('Date: ${record.date.toString().split(' ')[0]}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _addNewRecord(_tabController.index),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[300]),
            child: Text(
              'Add New Record',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
