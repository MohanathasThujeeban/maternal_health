import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/baby_service.dart';
import 'add_baby_screen.dart';
import 'baby_details_screen.dart';

class BabySelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onBabySelected;
  final bool
  showSelectionOnly; // If true, just for selection. If false, show management

  const BabySelectionScreen({
    Key? key,
    required this.onBabySelected,
    this.showSelectionOnly = false,
  }) : super(key: key);

  @override
  _BabySelectionScreenState createState() => _BabySelectionScreenState();
}

class _BabySelectionScreenState extends State<BabySelectionScreen> {
  List<Map<String, dynamic>> babies = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBabies();
  }

  Future<void> _loadBabies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedBabies = await BabyService.getMyBabies();
      setState(() {
        babies = fetchedBabies;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addBaby() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBabyScreen()),
    );

    if (result == true) {
      _loadBabies(); // Refresh the list
    }
  }

  void _selectBaby(Map<String, dynamic> baby) {
    widget.onBabySelected(baby);
    if (widget.showSelectionOnly) {
      Navigator.pop(context, baby);
    }
  }

  Future<void> _viewBabyDetails(Map<String, dynamic> baby) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BabyDetailsScreen(baby: baby)),
    );

    if (result == true) {
      _loadBabies(); // Refresh if baby was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showSelectionOnly ? 'Select Baby' : 'My Babies',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink.shade300,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? _buildErrorState()
            : babies.isEmpty
            ? _buildEmptyState()
            : _buildBabiesList(),
      ),
      floatingActionButton: widget.showSelectionOnly
          ? null
          : FloatingActionButton(
              onPressed: _addBaby,
              backgroundColor: Colors.pink.shade300,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading babies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBabies,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_friendly, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No babies added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first baby to get started',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (!widget.showSelectionOnly) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addBaby,
              icon: const Icon(Icons.add),
              label: const Text('Add Baby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBabiesList() {
    return RefreshIndicator(
      onRefresh: _loadBabies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: babies.length,
        itemBuilder: (context, index) {
          final baby = babies[index];
          return _buildBabyCard(baby);
        },
      ),
    );
  }

  Widget _buildBabyCard(Map<String, dynamic> baby) {
    final birthDate = baby['birthDate'] != null
        ? DateTime.parse(baby['birthDate'])
        : null;
    final age = BabyService.formatBabyAge(birthDate);
    final displayName = BabyService.getBabyDisplayName(baby);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectBaby(baby),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Baby avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.pink.shade100,
                child: Icon(
                  Icons.child_friendly,
                  size: 30,
                  color: Colors.pink.shade400,
                ),
              ),
              const SizedBox(width: 16),
              // Baby details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      age,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (baby['gender'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            baby['gender'] == 'MALE'
                                ? Icons.male
                                : baby['gender'] == 'FEMALE'
                                ? Icons.female
                                : Icons.help_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            baby['gender']
                                .toString()
                                .toLowerCase()
                                .replaceFirst(
                                  baby['gender'].toString().toLowerCase()[0],
                                  baby['gender']
                                      .toString()
                                      .toLowerCase()[0]
                                      .toUpperCase(),
                                ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (birthDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Born: ${DateFormat('MMM dd, yyyy').format(birthDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Action buttons
              if (!widget.showSelectionOnly)
                IconButton(
                  onPressed: () => _viewBabyDetails(baby),
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                ),
              if (widget.showSelectionOnly)
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
