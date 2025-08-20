import 'package:flutter/material.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/growth_chart_view.dart';

class GrowthEntry {
  final DateTime date;
  final double height;
  final double weight;
  final String motherNic;

  GrowthEntry({
    required this.date,
    required this.height,
    required this.weight,
    required this.motherNic,
  });
}

class GrowthChartScreen extends StatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  final _nicController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final List<GrowthEntry> _entries = [];

  void _addEntry() {
    if (_nicController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      _entries.add(
        GrowthEntry(
          date: DateTime.now(),
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          motherNic: _nicController.text,
        ),
      );
    });

    // Clear the input fields after adding
    _heightController.clear();
    _weightController.clear();

    _nicController.clear();
    _heightController.clear();
    _weightController.clear();
  }

  void _viewChart() {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No growth data available to display")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewGraphScreen(entries: _entries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Growth Chart Entry'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nicController,
              decoration: const InputDecoration(
                labelText: 'Mother\'s NIC',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Add Entry',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _viewChart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'View Growth Chart',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('NIC: ${entry.motherNic}'),
                      subtitle: Text(
                        'Height: ${entry.height}cm, Weight: ${entry.weight}kg\n'
                        'Date: ${entry.date.toString().split('.')[0]}',
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
}
