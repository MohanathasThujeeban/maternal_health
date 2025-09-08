import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/baby_service.dart';

class BabyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> baby;

  const BabyDetailsScreen({Key? key, required this.baby}) : super(key: key);

  @override
  _BabyDetailsScreenState createState() => _BabyDetailsScreenState();
}

class _BabyDetailsScreenState extends State<BabyDetailsScreen> {
  late Map<String, dynamic> baby;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['MALE', 'FEMALE'];

  @override
  void initState() {
    super.initState();
    baby = Map<String, dynamic>.from(widget.baby);
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: baby['babyName'] ?? '');
    _weightController = TextEditingController(
      text: baby['birthWeight']?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: baby['birthHeight']?.toString() ?? '',
    );

    if (baby['birthDate'] != null) {
      _selectedBirthDate = DateTime.parse(baby['birthDate']);
    }
    _selectedGender = baby['gender'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade300,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _updateBaby() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBaby = await BabyService.updateBaby(
        babyId: baby['id'],
        babyName: _nameController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        birthWeight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        birthHeight: _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null,
      );

      setState(() {
        baby = updatedBaby;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baby information updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBaby() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Baby'),
        content: Text(
          'Are you sure you want to delete ${baby['babyName']}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await BabyService.deleteBaby(baby['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Baby deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthDate = baby['birthDate'] != null
        ? DateTime.parse(baby['birthDate'])
        : null;
    final age = BabyService.formatBabyAge(birthDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baby['babyName'] ?? 'Baby Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink.shade300,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (!_isEditing)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteBaby();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isEditing
            ? _buildEditForm()
            : _buildDetailsView(age, birthDate),
      ),
    );
  }

  Widget _buildDetailsView(String age, DateTime? birthDate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baby avatar and basic info
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.pink.shade100,
                    child: Icon(
                      Icons.child_friendly,
                      size: 50,
                      color: Colors.pink.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    BabyService.getBabyDisplayName(baby),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    age,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details sections
          _buildDetailCard('Basic Information', [
            _buildDetailRow('Baby Order', '${baby['babyOrder'] ?? 'Unknown'}'),
            if (baby['gender'] != null)
              _buildDetailRow(
                'Gender',
                baby['gender'].toString().toLowerCase(),
              ),
            if (birthDate != null)
              _buildDetailRow(
                'Birth Date',
                DateFormat('MMMM dd, yyyy').format(birthDate),
              ),
          ]),

          if (baby['birthWeight'] != null || baby['birthHeight'] != null)
            _buildDetailCard('Birth Details', [
              if (baby['birthWeight'] != null)
                _buildDetailRow('Birth Weight', '${baby['birthWeight']} grams'),
              if (baby['birthHeight'] != null)
                _buildDetailRow('Birth Height', '${baby['birthHeight']} cm'),
            ]),

          _buildDetailCard('System Information', [
            _buildDetailRow('Created', _formatDateTime(baby['createdAt'])),
            _buildDetailRow('Last Updated', _formatDateTime(baby['updatedAt'])),
            _buildDetailRow(
              'Status',
              baby['isActive'] == true ? 'Active' : 'Inactive',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildBabyNameField(),
            const SizedBox(height: 16),
            _buildBirthDateField(),
            const SizedBox(height: 16),
            _buildGenderField(),
            const SizedBox(height: 16),
            _buildWeightField(),
            const SizedBox(height: 16),
            _buildHeightField(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _initializeControllers(); // Reset form
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateBaby,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Unknown';
    }
  }

  // Form field builders (similar to AddBabyScreen)
  Widget _buildBabyNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Baby Name *',
        prefixIcon: Icon(Icons.child_friendly, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink.shade300, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter baby\'s name';
        }
        return null;
      },
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Birth Date',
          prefixIcon: Icon(Icons.calendar_today, color: Colors.pink.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedBirthDate != null
              ? DateFormat('MMM dd, yyyy').format(_selectedBirthDate!)
              : 'Select birth date',
          style: TextStyle(
            color: _selectedBirthDate != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.person, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender.toLowerCase()),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Birth Weight (grams)',
        prefixIcon: Icon(Icons.monitor_weight, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Birth Height (cm)',
        prefixIcon: Icon(Icons.height, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
