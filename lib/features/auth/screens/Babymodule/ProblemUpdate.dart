import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Main App Setup
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Problems Management',
      debugShowCheckedModeBanner: false,
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
      home: ProblemsManagementScreen(),
    );
  }
}

// ✅ Custom Class for Expansion Panel
class ExpansionPanelData {
  final Widget body;
  final Widget Function(BuildContext, bool) headerBuilder;
  final bool isExpanded;

  ExpansionPanelData({
    required this.body,
    required this.headerBuilder,
    required this.isExpanded,
  });
}

// ✅ Data Model for Problems
class Problem {
  final int id;
  String issueTitle;
  String description;
  String reportedBy;
  DateTime dateReported;
  String status; // Pending or Resolved
  String actionTaken;
  List<String> history;

  Problem({
    required this.id,
    required this.issueTitle,
    required this.description,
    required this.reportedBy,
    required this.dateReported,
    required this.status,
    required this.actionTaken,
    required this.history,
  });
}

// ✅ Main Screen Widget
class ProblemsManagementScreen extends StatefulWidget {
  const ProblemsManagementScreen({super.key});

  @override
  _ProblemsManagementScreenState createState() =>
      _ProblemsManagementScreenState();
}

class _ProblemsManagementScreenState extends State<ProblemsManagementScreen> {
  List<Problem> problems = [];
  List<ExpansionPanelData> _expansionPanelData = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reportedByController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSampleProblems();
    _updateExpansionPanelData();
  }

  void _initializeSampleProblems() {
    problems = [
      Problem(
        id: 1,
        issueTitle: 'App Crashes During Patient Save',
        description:
            'The application crashes when saving patient records with special characters.',
        reportedBy: 'Dr. Priya Silva',
        dateReported: DateTime.now().subtract(Duration(days: 3)),
        status: 'Pending',
        actionTaken: 'Initial investigation started. Encoding issue suspected.',
        history: [
          'Issue reported by Dr. Priya Silva',
          'Assigned to dev team',
          'Investigating character encoding',
        ],
      ),
      Problem(
        id: 2,
        issueTitle: 'Date Picker Not Responsive',
        description: 'Date picker freezes when rapidly selecting dates.',
        reportedBy: 'Nurse Kamala Perera',
        dateReported: DateTime.now().subtract(Duration(days: 7)),
        status: 'Resolved',
        actionTaken: 'Updated date picker lib and added debouncing.',
        history: [
          'Issue reported by Nurse Kamala',
          'Bug reproduced',
          'Fix deployed',
          'Issue resolved',
        ],
      ),
    ];
  }

  void _updateExpansionPanelData() {
    _expansionPanelData = problems.map<ExpansionPanelData>((problem) {
      return ExpansionPanelData(
        body: _buildProblemDetails(problem),
        headerBuilder: (context, isExpanded) => _buildProblemHeader(problem),
        isExpanded: false,
      );
    }).toList();
  }

  // Header UI
  Widget _buildProblemHeader(Problem problem) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(problem.status),
        child: Icon(
          problem.status == 'Resolved'
              ? Icons.check_circle
              : Icons.error_outline,
          color: Colors.white,
        ),
      ),
      title: Text(
        problem.issueTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text('Reported by: ${problem.reportedBy}'),
          Text('Date: ${_formatDate(problem.dateReported)}'),
          SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(
                  problem.status,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(problem.status),
              ),
              Spacer(),
              if (problem.status == 'Pending')
                ElevatedButton(
                  onPressed: () => _showResolveDialog(problem),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('Resolve'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Detail Body UI
  Widget _buildProblemDetails(Problem problem) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Description:', problem.description),
          SizedBox(height: 16),
          _buildSection('Action Taken / Notes:', problem.actionTaken),
          SizedBox(height: 16),
          Text('History:', style: _sectionTitleStyle()),
          SizedBox(height: 8),
          ...problem.history.asMap().entries.map((entry) {
            int index = entry.key;
            String text = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFF00D4D4),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
                ],
              ),
            );
          }),
          SizedBox(height: 16),
          if (problem.status == 'Pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.note_add),
                    label: Text('Add Note'),
                    onPressed: () => _showAddNoteDialog(problem),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF00D4D4),
                      side: BorderSide(color: Color(0xFF00D4D4)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: Text('Mark Resolved'),
                    onPressed: () => _showResolveDialog(problem),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle()),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(content, style: TextStyle(fontSize: 14, height: 1.4)),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() => TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Color(0xFF00D4D4),
  );

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showResolveDialog(Problem problem) {
    _actionController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve Problem'),
        content: TextFormField(
          controller: _actionController,
          decoration: InputDecoration(
            labelText: 'Resolution Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_actionController.text.isNotEmpty) {
                setState(() {
                  problem.status = 'Resolved';
                  problem.actionTaken = _actionController.text;
                  problem.history.add(
                    'Problem resolved: ${_actionController.text}',
                  );
                  _updateExpansionPanelData();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Problem marked as resolved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(Problem problem) {
    _actionController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: TextFormField(
          controller: _actionController,
          decoration: InputDecoration(
            labelText: 'Progress Note',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_actionController.text.isNotEmpty) {
                setState(() {
                  problem.history.add('Note: ${_actionController.text}');
                  _updateExpansionPanelData();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Note added!')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00D4D4)),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🛠️ Problems & Updates Management')),
      body: problems.isEmpty
          ? Center(
              child: Text(
                'No problems reported.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ExpansionPanelList(
                  elevation: 2,
                  expansionCallback: (index, isExpanded) {
                    setState(() {
                      _expansionPanelData[index] = ExpansionPanelData(
                        body: _expansionPanelData[index].body,
                        headerBuilder: _expansionPanelData[index].headerBuilder,
                        isExpanded: !isExpanded,
                      );
                    });
                  },
                  children: _expansionPanelData.map<ExpansionPanel>((item) {
                    return ExpansionPanel(
                      headerBuilder: item.headerBuilder,
                      body: item.body,
                      isExpanded: item.isExpanded,
                      canTapOnHeader: true,
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
