import 'package:flutter/material.dart';
import '../../../../services/baby_service.dart';
import '../../../../services/email_service.dart';
import '../../../../services/user_service.dart';

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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4FC3A1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
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

      // Send confirmation email to the mother
      try {
        final motherEmail = await UserService.getUserEmail();
        final motherName = await UserService.getUserName();

        if (motherEmail != null && motherName != null) {
          await EmailService.sendBabyRegistrationConfirmation(
            babyName: _nameController.text.trim(),
            motherEmail: motherEmail,
            motherName: motherName,
            birthDate: _selectedBirthDate != null
                ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                : null,
            gender: _selectedGender,
          );
        }
      } catch (emailError) {
        // Don't fail the whole process if email fails
        print('Email notification failed: $emailError');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Baby added successfully! Confirmation email sent.',
          ),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A), Color(0xFF2E7D5A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Add New Baby',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with baby icon
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF4FC3A1).withOpacity(0.1),
                                    const Color(0xFF3A9B7A).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.child_friendly,
                                size: 60,
                                color: Color(0xFF4FC3A1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Baby Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              fontFamily: 'SpotifyCircular',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please fill in your baby\'s details',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontFamily: 'SpotifyCircular',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          _buildModernTextField(
                            controller: _nameController,
                            label: 'Baby Name',
                            hint: 'Enter baby\'s name',
                            icon: Icons.child_friendly,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter baby\'s name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildDateField(),
                          const SizedBox(height: 20),

                          _buildGenderDropdown(),
                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF4FC3A1,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF4FC3A1),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Birth Details (Optional)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                        fontFamily: 'SpotifyCircular',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildModernTextField(
                                  controller: _weightController,
                                  label: 'Birth Weight (grams)',
                                  hint: 'e.g., 3200',
                                  icon: Icons.monitor_weight,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final weight = double.tryParse(value);
                                      if (weight == null || weight <= 0) {
                                        return 'Please enter a valid weight';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                _buildModernTextField(
                                  controller: _heightController,
                                  label: 'Birth Height (cm)',
                                  hint: 'e.g., 50',
                                  icon: Icons.height,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final height = double.tryParse(value);
                                      if (height == null || height <= 0) {
                                        return 'Please enter a valid height';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          _buildModernSaveButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4FC3A1), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontFamily: 'SpotifyCircular',
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontFamily: 'SpotifyCircular',
          ),
        ),
        style: const TextStyle(fontFamily: 'SpotifyCircular', fontSize: 16),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectBirthDate,
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Birth Date',
            hintText: 'Select birth date',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF4FC3A1),
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          child: Text(
            _selectedBirthDate != null
                ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                : 'Select birth date',
            style: TextStyle(
              color: _selectedBirthDate != null
                  ? Colors.black87
                  : Colors.grey.shade400,
              fontFamily: 'SpotifyCircular',
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          hintText: 'Select gender',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: Color(0xFF4FC3A1), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontFamily: 'SpotifyCircular',
          ),
        ),
        style: const TextStyle(
          fontFamily: 'SpotifyCircular',
          fontSize: 16,
          color: Colors.black87,
        ),
        dropdownColor: Colors.white,
        items: _genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(
              gender.toLowerCase().replaceFirst(
                gender[0],
                gender[0].toUpperCase(),
              ),
              style: const TextStyle(fontFamily: 'SpotifyCircular'),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
      ),
    );
  }

  Widget _buildModernSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3A1).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveBaby,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Save Baby',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
