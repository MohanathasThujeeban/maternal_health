import 'package:flutter/material.dart';
import '../services/baby_service.dart';
import '../features/auth/screens/Mothermodule/baby_selection_screen.dart';

class BabySelectionWidget extends StatefulWidget {
  final Function(Map<String, dynamic>?) onBabyChanged;
  final Map<String, dynamic>? selectedBaby;

  const BabySelectionWidget({
    Key? key,
    required this.onBabyChanged,
    this.selectedBaby,
  }) : super(key: key);

  @override
  _BabySelectionWidgetState createState() => _BabySelectionWidgetState();
}

class _BabySelectionWidgetState extends State<BabySelectionWidget> {
  List<Map<String, dynamic>> babies = [];
  bool isLoading = true;
  Map<String, dynamic>? currentBaby;

  @override
  void initState() {
    super.initState();
    currentBaby = widget.selectedBaby;
    _loadBabies();
  }

  Future<void> _loadBabies() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedBabies = await BabyService.getMyBabies();
      setState(() {
        babies = fetchedBabies;

        // If no baby is selected and we have babies, select the first one
        if (currentBaby == null && babies.isNotEmpty) {
          currentBaby = babies.first;
          widget.onBabyChanged(currentBaby);
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectBaby() async {
    final selectedBaby = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => BabySelectionScreen(
          onBabySelected: (baby) {},
          showSelectionOnly: true,
        ),
      ),
    );

    if (selectedBaby != null) {
      setState(() {
        currentBaby = selectedBaby;
      });
      widget.onBabyChanged(selectedBaby);
    }
  }

  Future<void> _manageBabies() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabySelectionScreen(
          onBabySelected: (baby) {},
          showSelectionOnly: false,
        ),
      ),
    );

    if (result != null) {
      _loadBabies(); // Refresh babies list
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading babies...'),
            ],
          ),
        ),
      );
    }

    if (babies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No babies added yet',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _manageBabies,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Your First Baby'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade300,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.child_friendly, color: Colors.pink.shade400),
                const SizedBox(width: 8),
                Text(
                  'Selected Baby',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _manageBabies,
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: babies.length > 1 ? _selectBaby : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.pink.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.pink.shade100,
                      child: Icon(
                        Icons.child_friendly,
                        color: Colors.pink.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentBaby != null
                                ? BabyService.getBabyDisplayName(currentBaby!)
                                : 'No baby selected',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (currentBaby != null &&
                              currentBaby!['birthDate'] != null)
                            Text(
                              BabyService.formatBabyAge(
                                DateTime.parse(currentBaby!['birthDate']),
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (babies.length > 1)
                      Icon(Icons.expand_more, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            if (babies.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                'Tap to switch between ${babies.length} babies',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
