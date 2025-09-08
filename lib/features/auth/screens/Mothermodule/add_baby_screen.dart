import 'package:flutter/material.dart';
import '../../../../services/baby_service.dart';

class AddBabyScreen extends StatefulWidget {
  const AddBabyScreen({Key? key}) : super(key: key);

  @override
  _AddBabyScreenState createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['MALE', 'FEMALE'];

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
      initialDate: DateTime.now(),
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

  Future<void> _saveBaby() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await BabyService.createBaby(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Baby added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Baby',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade300,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: 16),
                _buildBabyNameField(),
                const SizedBox(height: 16),
                _buildBirthDateField(),
                const SizedBox(height: 16),
                _buildGenderField(),
                const SizedBox(height: 24),
                _buildSectionHeader('Birth Details (Optional)'),
                const SizedBox(height: 16),
                _buildWeightField(),
                const SizedBox(height: 16),
                _buildHeightField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildBabyNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Baby Name *',
        hintText: 'Enter baby\'s name',
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
          hintText: 'Select birth date',
          prefixIcon: Icon(Icons.calendar_today, color: Colors.pink.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pink.shade300, width: 2),
          ),
        ),
        child: Text(
          _selectedBirthDate != null
              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
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
        hintText: 'Select gender',
        prefixIcon: Icon(Icons.person, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink.shade300, width: 2),
        ),
      ),
      items: _genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(
            gender.toLowerCase().replaceFirst(
              gender[0],
              gender[0].toUpperCase(),
            ),
          ),
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
        hintText: 'e.g., 3200',
        prefixIcon: Icon(Icons.monitor_weight, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink.shade300, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final weight = double.tryParse(value);
          if (weight == null || weight <= 0) {
            return 'Please enter a valid weight';
          }
        }
        return null;
      },
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Birth Height (cm)',
        hintText: 'e.g., 50',
        prefixIcon: Icon(Icons.height, color: Colors.pink.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink.shade300, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final height = double.tryParse(value);
          if (height == null || height <= 0) {
            return 'Please enter a valid height';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveBaby,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade300,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Save Baby',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
