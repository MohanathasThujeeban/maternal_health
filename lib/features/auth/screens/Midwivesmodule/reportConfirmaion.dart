import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reports & Problems Management',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Color(0xFF00D4D4),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF00D4D4),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [ReportsScreen(), ProblemsScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Color(0xFF00D4D4),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Problems'),
        ],
      ),
    );
  }
}

// REPORTS SCREEN
class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String? _reportData;
  bool _isReportGenerated = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setDefaultDateRange();
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    switch (_tabController.index) {
      case 0: // Daily
        _selectedDateRange = DateTimeRange(start: now, end: now);
        break;
      case 1: // Weekly
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        _selectedDateRange = DateTimeRange(start: weekStart, end: now);
        break;
      case 2: // Monthly
        final monthStart = DateTime(now.year, now.month, 1);
        _selectedDateRange = DateTimeRange(start: monthStart, end: now);
        break;
      case 3: // Yearly
        final yearStart = DateTime(now.year, 1, 1);
        _selectedDateRange = DateTimeRange(start: yearStart, end: now);
        break;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _isReportGenerated = false;
      });
    }
  }

  void _generateReport() {
    setState(() {
      _isReportGenerated = true;
      _reportData = _generateMockReportData();
    });
  }

  String _generateMockReportData() {
    final reportType = [
      'Daily',
      'Weekly',
      'Monthly',
      'Yearly',
    ][_tabController.index];
    return """
📊 $reportType Report Summary

📅 Period: ${_selectedDateRange!.start.toString().split(' ')[0]} to ${_selectedDateRange!.end.toString().split(' ')[0]}

👁️ Eye Problems Treated: ${15 + _tabController.index * 5}
👂 Ear Problems Treated: ${12 + _tabController.index * 3}
👶 Total Patients: ${20 + _tabController.index * 8}

🔍 Most Common Issues:
• Blocked Tear Duct: ${8 + _tabController.index * 2}
• Ear Infection: ${6 + _tabController.index * 2}
• Conjunctivitis: ${4 + _tabController.index}

✅ Recovery Rate: ${85 + _tabController.index * 2}%
📈 Compared to previous period: +${5 + _tabController.index}%
""";
  }

  void _confirmReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Report'),
        content: Text('Are you sure you want to confirm this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report confirmed and saved!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00D4D4)),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📅 Reports'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _setDefaultDateRange();
              _isReportGenerated = false;
            });
          },
          tabs: [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Picker
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4D4),
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range, color: Color(0xFF00D4D4)),
                            SizedBox(width: 12),
                            Text(
                              _selectedDateRange == null
                                  ? 'Select Date Range'
                                  : '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Generate Report Button
            if (!_isReportGenerated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedDateRange != null
                      ? _generateReport
                      : null,
                  icon: Icon(Icons.assessment),
                  label: Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00D4D4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

            // Report Data
            if (_isReportGenerated) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generated Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF00D4D4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _reportData!,
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Notes
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText:
                              'Add any additional notes or observations...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmReport,
                  icon: Icon(Icons.check_circle),
                  label: Text('Confirm Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// PROBLEMS SCREEN
class Problem {
  final int id;
  String title;
  String description;
  String reportedBy;
  DateTime dateReported;
  String status;
  String actionTaken;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.reportedBy,
    required this.dateReported,
    required this.status,
    required this.actionTaken,
  });
}

class ProblemsScreen extends StatefulWidget {
  @override
  _ProblemsScreenState createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  List<Problem> problems = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reportedByController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSampleProblems();
  }

  void _initializeSampleProblems() {
    problems = [
      Problem(
        id: 1,
        title: 'App Crashes on Save',
        description:
            'The app crashes when trying to save patient records with long names.',
        reportedBy: 'Dr. Silva',
        dateReported: DateTime.now().subtract(Duration(days: 2)),
        status: 'Pending',
        actionTaken: 'Investigating the issue. Will update by tomorrow.',
      ),
      Problem(
        id: 2,
        title: 'Date Picker Not Working',
        description: 'Date picker doesn\'t open on some Android devices.',
        reportedBy: 'Nurse Perera',
        dateReported: DateTime.now().subtract(Duration(days: 5)),
        status: 'Resolved',
        actionTaken: 'Updated Flutter version and fixed compatibility issues.',
      ),
      Problem(
        id: 3,
        title: 'Report Generation Slow',
        description: 'Monthly reports take too long to generate.',
        reportedBy: 'Admin User',
        dateReported: DateTime.now().subtract(Duration(days: 1)),
        status: 'Pending',
        actionTaken: 'Optimizing database queries.',
      ),
    ];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _addNewProblem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report New Problem',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4D4),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Issue Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _reportedByController,
                decoration: InputDecoration(
                  labelText: 'Reported By',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _titleController.clear();
                        _descriptionController.clear();
                        _reportedByController.clear();
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          setState(() {
                            problems.add(
                              Problem(
                                id: problems.length + 1,
                                title: _titleController.text,
                                description: _descriptionController.text,
                                reportedBy: _reportedByController.text,
                                dateReported: DateTime.now(),
                                status: 'Pending',
                                actionTaken: 'Issue reported, awaiting review.',
                              ),
                            );
                          });
                          _titleController.clear();
                          _descriptionController.clear();
                          _reportedByController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Problem reported successfully!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00D4D4),
                      ),
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resolveProblem(Problem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add action taken to resolve this issue:'),
            SizedBox(height: 16),
            TextFormField(
              controller: _actionController,
              decoration: InputDecoration(
                labelText: 'Action Taken',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                problem.status = 'Resolved';
                problem.actionTaken = _actionController.text;
              });
              _actionController.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Problem marked as resolved!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Resolve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🛠️ Problems & Updates')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: problems.length,
        itemBuilder: (context, index) {
          final problem = problems[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(problem.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  problem.status == 'Resolved'
                      ? Icons.check_circle
                      : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                problem.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reported by: ${problem.reportedBy}'),
                  Text(
                    'Date: ${problem.dateReported.toString().split(' ')[0]}',
                  ),
                  Chip(
                    label: Text(problem.status),
                    backgroundColor: _getStatusColor(
                      problem.status,
                    ).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _getStatusColor(problem.status),
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(problem.description),
                      SizedBox(height: 16),
                      Text(
                        'Action Taken:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(problem.actionTaken),
                      SizedBox(height: 16),
                      if (problem.status == 'Pending')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _resolveProblem(problem),
                            icon: Icon(Icons.check_circle),
                            label: Text('Mark as Resolved'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProblem,
        backgroundColor: Color(0xFF00D4D4),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
