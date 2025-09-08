import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../config/api_config.dart';
import '../../../../services/user_service.dart';
import '../../../../widgets/custom_loading.dart';

class ComprehensiveProfileScreen extends StatefulWidget {
  const ComprehensiveProfileScreen({super.key});

  @override
  State<ComprehensiveProfileScreen> createState() =>
      _ComprehensiveProfileScreenState();
}

class _ComprehensiveProfileScreenState
    extends State<ComprehensiveProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _currentNic;
  Map<String, dynamic>? _currentProfile;
  File? _selectedImage;

  // Personal Information Controllers
  final _ageController = TextEditingController();
  final _religionController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  // Father's Information Controllers
  final _fatherNameController = TextEditingController();
  final _fatherNicController = TextEditingController();
  final _fatherAgeController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherPhoneController = TextEditingController();

  // Address Controllers
  final _houseNumberController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Administrative Divisions
  String? _selectedDistrict;
  String? _selectedProvince;
  final _gsDivisionController = TextEditingController();
  final _dsDivisionController = TextEditingController();
  final _mohAreaController = TextEditingController();
  final _phmAreaController = TextEditingController();

  // Emergency Contact Controllers
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Pregnancy Information Controllers
  final _pregnanciesController = TextEditingController();
  final _liveBirthsController = TextEditingController();
  final _stillbirthsController = TextEditingController();
  final _abortionsController = TextEditingController();
  final _livingChildrenController = TextEditingController();
  final _pregnancyWeekController = TextEditingController();
  final _prePregnancyWeightController = TextEditingController();
  final _prePregnancyHeightController = TextEditingController();
  DateTime? _lastMenstrualPeriod;
  DateTime? _expectedDeliveryDate;
  String? _pregnancyStatus;

  // Medical History Controllers
  String? _bloodType;
  String? _rhesusFactor;
  final _chronicDiseasesController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _pregnancyComplicationsController = TextEditingController();
  final _familyHistoryController = TextEditingController();

  // Lifestyle Controllers
  bool _smokingStatus = false;
  bool _alcoholConsumption = false;
  final _exerciseController = TextEditingController();
  final _dietaryRestrictionsController = TextEditingController();
  final _supplementsController = TextEditingController();
  final _specialNotesController = TextEditingController();

  // Sri Lankan Districts
  final List<String> _districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Moneragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  // Sri Lankan Provinces
  final List<String> _provinces = [
    'Central',
    'Eastern',
    'North Central',
    'Northern',
    'North Western',
    'Sabaragamuwa',
    'Southern',
    'Uva',
    'Western',
  ];

  // Blood Types
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Rhesus Factors
  final List<String> _rhesusFactors = ['Positive', 'Negative'];

  // Pregnancy Status Options
  final List<String> _pregnancyStatusOptions = [
    'First Trimester',
    'Second Trimester',
    'Third Trimester',
    'Post Delivery',
    'Not Pregnant',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    // Dispose all controllers
    _ageController.dispose();
    _religionController.dispose();
    _ethnicityController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _fatherNameController.dispose();
    _fatherNicController.dispose();
    _fatherAgeController.dispose();
    _fatherOccupationController.dispose();
    _fatherPhoneController.dispose();
    _houseNumberController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _gsDivisionController.dispose();
    _dsDivisionController.dispose();
    _mohAreaController.dispose();
    _phmAreaController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyPhoneController.dispose();
    _pregnanciesController.dispose();
    _liveBirthsController.dispose();
    _stillbirthsController.dispose();
    _abortionsController.dispose();
    _livingChildrenController.dispose();
    _pregnancyWeekController.dispose();
    _prePregnancyWeightController.dispose();
    _prePregnancyHeightController.dispose();
    _chronicDiseasesController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _pregnancyComplicationsController.dispose();
    _familyHistoryController.dispose();
    _exerciseController.dispose();
    _dietaryRestrictionsController.dispose();
    _supplementsController.dispose();
    _specialNotesController.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);

    try {
      _currentNic = await UserService.getUserNic();
      if (_currentNic == null) {
        throw Exception('User session not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/maternal-profile/$_currentNic'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Debug: Maternal profile response status: ${response.statusCode}');
      print('Debug: Maternal profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['profile'] != null) {
          setState(() {
            _currentProfile = responseData['profile'];
            _populateFormFields(_currentProfile!);
          });
        }
      }
    } catch (e) {
      print('Error loading maternal profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFormFields(Map<String, dynamic> profile) {
    // Personal Information
    _ageController.text = profile['age']?.toString() ?? '';
    _religionController.text = profile['religion'] ?? '';
    _ethnicityController.text = profile['ethnicity'] ?? '';
    _educationController.text = profile['educationLevel'] ?? '';
    _occupationController.text = profile['occupation'] ?? '';
    _incomeController.text = profile['monthlyIncome']?.toString() ?? '';

    // Father's Information
    _fatherNameController.text = profile['fatherName'] ?? '';
    _fatherNicController.text = profile['fatherNic'] ?? '';
    _fatherAgeController.text = profile['fatherAge']?.toString() ?? '';
    _fatherOccupationController.text = profile['fatherOccupation'] ?? '';
    _fatherPhoneController.text = profile['fatherPhone'] ?? '';

    // Address
    _houseNumberController.text = profile['houseNumber'] ?? '';
    _streetAddressController.text = profile['streetAddress'] ?? '';
    _cityController.text = profile['city'] ?? '';
    _postalCodeController.text = profile['postalCode'] ?? '';
    _selectedDistrict = profile['district'];
    _selectedProvince = profile['province'];
    _gsDivisionController.text = profile['gsDivision'] ?? '';
    _dsDivisionController.text = profile['dsDivision'] ?? '';
    _mohAreaController.text = profile['mohArea'] ?? '';
    _phmAreaController.text = profile['phmArea'] ?? '';

    // Emergency Contact
    _emergencyNameController.text = profile['emergencyContactName'] ?? '';
    _emergencyRelationshipController.text =
        profile['emergencyContactRelationship'] ?? '';
    _emergencyPhoneController.text = profile['emergencyContactPhone'] ?? '';

    // Pregnancy Information
    _pregnanciesController.text =
        profile['numberOfPregnancies']?.toString() ?? '';
    _liveBirthsController.text =
        profile['numberOfLiveBirths']?.toString() ?? '';
    _stillbirthsController.text =
        profile['numberOfStillbirths']?.toString() ?? '';
    _abortionsController.text = profile['numberOfAbortions']?.toString() ?? '';
    _livingChildrenController.text =
        profile['numberOfLivingChildren']?.toString() ?? '';
    _pregnancyWeekController.text =
        profile['currentPregnancyWeek']?.toString() ?? '';
    _prePregnancyWeightController.text =
        profile['prePregnancyWeight']?.toString() ?? '';
    _prePregnancyHeightController.text =
        profile['prePregnancyHeight']?.toString() ?? '';
    _pregnancyStatus = profile['currentPregnancyStatus'];

    // Medical History
    _bloodType = profile['bloodType'];
    // Map backend rhesus factor values to dropdown values
    String? backendRhesusFactor = profile['rhesusFactor'];
    if (backendRhesusFactor != null) {
      if (backendRhesusFactor.toUpperCase() == 'POSITIVE') {
        _rhesusFactor = 'Positive';
      } else if (backendRhesusFactor.toUpperCase() == 'NEGATIVE') {
        _rhesusFactor = 'Negative';
      } else {
        _rhesusFactor = backendRhesusFactor; // fallback
      }
    } else {
      _rhesusFactor = null;
    }
    _chronicDiseasesController.text = profile['chronicDiseases'] ?? '';
    _allergiesController.text = profile['allergies'] ?? '';
    _medicationsController.text = profile['currentMedications'] ?? '';
    _pregnancyComplicationsController.text =
        profile['previousPregnancyComplications'] ?? '';
    _familyHistoryController.text = profile['familyMedicalHistory'] ?? '';

    // Lifestyle
    _smokingStatus = profile['smokingStatus'] ?? false;
    _alcoholConsumption = profile['alcoholConsumption'] ?? false;
    _exerciseController.text = profile['exerciseRoutine'] ?? '';
    _dietaryRestrictionsController.text = profile['dietaryRestrictions'] ?? '';
    _supplementsController.text = profile['nutritionalSupplements'] ?? '';
    _specialNotesController.text = profile['specialNotes'] ?? '';

    // Parse dates
    if (profile['dateOfBirth'] != null) {
      _selectedDateOfBirth = DateTime.parse(profile['dateOfBirth']);
    }
    if (profile['lastMenstrualPeriod'] != null) {
      _lastMenstrualPeriod = DateTime.parse(profile['lastMenstrualPeriod']);
    }
    if (profile['expectedDeliveryDate'] != null) {
      _expectedDeliveryDate = DateTime.parse(profile['expectedDeliveryDate']);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final profileData = {
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'age': int.tryParse(_ageController.text),
        'religion': _religionController.text.trim(),
        'ethnicity': _ethnicityController.text.trim(),
        'educationLevel': _educationController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'monthlyIncome': double.tryParse(_incomeController.text),

        // Father's Information
        'fatherName': _fatherNameController.text.trim(),
        'fatherNic': _fatherNicController.text.trim(),
        'fatherAge': int.tryParse(_fatherAgeController.text),
        'fatherOccupation': _fatherOccupationController.text.trim(),
        'fatherPhone': _fatherPhoneController.text.trim(),

        // Address
        'houseNumber': _houseNumberController.text.trim(),
        'streetAddress': _streetAddressController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _selectedDistrict,
        'province': _selectedProvince,
        'postalCode': _postalCodeController.text.trim(),
        'gsDivision': _gsDivisionController.text.trim(),
        'dsDivision': _dsDivisionController.text.trim(),
        'mohArea': _mohAreaController.text.trim(),
        'phmArea': _phmAreaController.text.trim(),

        // Emergency Contact
        'emergencyContactName': _emergencyNameController.text.trim(),
        'emergencyContactRelationship': _emergencyRelationshipController.text
            .trim(),
        'emergencyContactPhone': _emergencyPhoneController.text.trim(),

        // Pregnancy Information
        'numberOfPregnancies': int.tryParse(_pregnanciesController.text),
        'numberOfLiveBirths': int.tryParse(_liveBirthsController.text),
        'numberOfStillbirths': int.tryParse(_stillbirthsController.text),
        'numberOfAbortions': int.tryParse(_abortionsController.text),
        'numberOfLivingChildren': int.tryParse(_livingChildrenController.text),
        'lastMenstrualPeriod': _lastMenstrualPeriod?.toIso8601String(),
        'expectedDeliveryDate': _expectedDeliveryDate?.toIso8601String(),
        'currentPregnancyWeek': int.tryParse(_pregnancyWeekController.text),
        'currentPregnancyStatus': _pregnancyStatus,
        'prePregnancyWeight': double.tryParse(
          _prePregnancyWeightController.text,
        ),
        'prePregnancyHeight': double.tryParse(
          _prePregnancyHeightController.text,
        ),

        // Medical History
        'bloodType': _bloodType,
        'rhesusFactor': _rhesusFactor == 'Positive'
            ? 'POSITIVE'
            : _rhesusFactor == 'Negative'
            ? 'NEGATIVE'
            : _rhesusFactor,
        'chronicDiseases': _chronicDiseasesController.text.trim(),
        'allergies': _allergiesController.text.trim(),
        'currentMedications': _medicationsController.text.trim(),
        'previousPregnancyComplications': _pregnancyComplicationsController.text
            .trim(),
        'familyMedicalHistory': _familyHistoryController.text.trim(),

        // Lifestyle
        'smokingStatus': _smokingStatus,
        'alcoholConsumption': _alcoholConsumption,
        'exerciseRoutine': _exerciseController.text.trim(),
        'dietaryRestrictions': _dietaryRestrictionsController.text.trim(),
        'nutritionalSupplements': _supplementsController.text.trim(),
        'specialNotes': _specialNotesController.text.trim(),

        'profileCompleted': true,
      };

      print('Debug: Saving maternal profile data: $profileData');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseApiUrl}/maternal-profile/$_currentNic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      );

      print('Debug: Save response status: ${response.statusCode}');
      print('Debug: Save response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully! ✅'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          throw Exception(responseData['message'] ?? 'Failed to save profile');
        }
      } else {
        throw Exception('Failed to save profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'dob':
            _selectedDateOfBirth = picked;
            break;
          case 'lmp':
            _lastMenstrualPeriod = picked;
            // Calculate EDD (280 days from LMP)
            _expectedDeliveryDate = picked.add(const Duration(days: 280));
            break;
          case 'edd':
            _expectedDeliveryDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CustomLoading(
            message: 'Loading your profile...',
            size: 100,
            backgroundColor: Colors.transparent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4FC3A1),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildPersonalInfoPage(),
            _buildFatherInfoPage(),
            _buildAddressPage(),
            _buildPregnancyInfoPage(),
            _buildMedicalHistoryPage(),
            _buildLifestylePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Previous'),
              )
            else
              const SizedBox.shrink(),

            // Page indicator
            Row(
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? const Color(0xFF4FC3A1)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),

            if (_currentPage < 5)
              ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              )
            else
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Save Profile'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information', Icons.person),
          const SizedBox(height: 20),

          // Profile Photo
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: const Color(0xFF4FC3A1), width: 3),
                ),
                child: _selectedImage != null
                    ? ClipOval(
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Color(0xFF4FC3A1),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Tap to add your photo',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Date of Birth
          _buildDateField(
            'Date of Birth',
            _selectedDateOfBirth,
            () => _selectDate(context, 'dob'),
          ),
          const SizedBox(height: 16),

          // Age
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isNotEmpty == true) {
                final age = int.tryParse(value!);
                if (age == null || age < 10 || age > 60) {
                  return 'Please enter a valid age (10-60)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Religion
          _buildTextField(controller: _religionController, label: 'Religion'),
          const SizedBox(height: 16),

          // Ethnicity
          _buildTextField(controller: _ethnicityController, label: 'Ethnicity'),
          const SizedBox(height: 16),

          // Education Level
          _buildTextField(
            controller: _educationController,
            label: 'Education Level',
          ),
          const SizedBox(height: 16),

          // Occupation
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation',
          ),
          const SizedBox(height: 16),

          // Monthly Income
          _buildTextField(
            controller: _incomeController,
            label: 'Monthly Income (LKR)',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildFatherInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Father\'s Information', Icons.man),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _fatherNameController,
            label: 'Father\'s Full Name',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Father\'s name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _fatherNicController,
            label: 'Father\'s NIC Number',
            validator: (value) {
              if (value?.isNotEmpty == true) {
                if (!RegExp(r'^[0-9]{9}[vVxX]$|^[0-9]{12}$').hasMatch(value!)) {
                  return 'Invalid NIC format';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _fatherAgeController,
            label: 'Father\'s Age',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _fatherOccupationController,
            label: 'Father\'s Occupation',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _fatherPhoneController,
            label: 'Father\'s Phone Number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isNotEmpty == true) {
                if (!RegExp(r'^0[0-9]{9}$').hasMatch(value!)) {
                  return 'Invalid phone number format';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Address & Administrative Information',
            Icons.location_on,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTextField(
                  controller: _houseNumberController,
                  label: 'House No.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: _streetAddressController,
                  label: 'Street Address',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(controller: _cityController, label: 'City/Town'),
          const SizedBox(height: 16),

          // District Dropdown
          _buildDropdownField<String>(
            value: _selectedDistrict,
            label: 'District',
            items: _districts,
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Province Dropdown
          _buildDropdownField<String>(
            value: _selectedProvince,
            label: 'Province',
            items: _provinces,
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
              });
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _postalCodeController,
            label: 'Postal Code',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _gsDivisionController,
            label: 'GS Division (Grama Sevaka)',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'GS Division is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _dsDivisionController,
            label: 'DS Division (Divisional Secretariat)',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _mohAreaController,
            label: 'MOH Area (Medical Officer of Health)',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _phmAreaController,
            label: 'PHM Area (Public Health Midwife)',
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Emergency Contact', Icons.emergency),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emergencyNameController,
            label: 'Emergency Contact Name',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Emergency contact name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emergencyRelationshipController,
            label: 'Relationship',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Relationship is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emergencyPhoneController,
            label: 'Emergency Contact Phone',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Emergency contact phone is required';
              }
              if (!RegExp(r'^0[0-9]{9}$').hasMatch(value!)) {
                return 'Invalid phone number format';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Pregnancy Information', Icons.pregnant_woman),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _pregnanciesController,
                  label: 'Total Pregnancies',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final count = int.tryParse(value!);
                      if (count == null || count < 0) {
                        return 'Invalid number';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _liveBirthsController,
                  label: 'Live Births',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stillbirthsController,
                  label: 'Stillbirths',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _abortionsController,
                  label: 'Abortions',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _livingChildrenController,
            label: 'Living Children',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildDateField(
            'Last Menstrual Period (LMP)',
            _lastMenstrualPeriod,
            () => _selectDate(context, 'lmp'),
          ),
          const SizedBox(height: 16),

          _buildDateField(
            'Expected Delivery Date (EDD)',
            _expectedDeliveryDate,
            () => _selectDate(context, 'edd'),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _pregnancyWeekController,
                  label: 'Current Week',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final week = int.tryParse(value!);
                      if (week == null || week < 1 || week > 42) {
                        return 'Week must be 1-42';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField<String>(
                  value: _pregnancyStatus,
                  label: 'Pregnancy Status',
                  items: _pregnancyStatusOptions,
                  onChanged: (value) {
                    setState(() {
                      _pregnancyStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildSectionHeader(
            'Pre-Pregnancy Measurements',
            Icons.monitor_weight,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _prePregnancyWeightController,
                  label: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final weight = double.tryParse(value!);
                      if (weight == null || weight < 30 || weight > 200) {
                        return 'Weight: 30-200 kg';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _prePregnancyHeightController,
                  label: 'Height (cm)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final height = double.tryParse(value!);
                      if (height == null || height < 120 || height > 250) {
                        return 'Height: 120-250 cm';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Medical History', Icons.medical_services),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField<String>(
                  value: _bloodType,
                  label: 'Blood Type',
                  items: _bloodTypes,
                  onChanged: (value) {
                    setState(() {
                      _bloodType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField<String>(
                  value: _rhesusFactor,
                  label: 'Rhesus Factor',
                  items: _rhesusFactors,
                  onChanged: (value) {
                    setState(() {
                      _rhesusFactor = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _chronicDiseasesController,
            label: 'Chronic Diseases',
            maxLines: 3,
            hint: 'List any chronic conditions (diabetes, hypertension, etc.)',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _allergiesController,
            label: 'Allergies',
            maxLines: 2,
            hint: 'Food allergies, drug allergies, etc.',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _medicationsController,
            label: 'Current Medications',
            maxLines: 3,
            hint: 'List all medications you are currently taking',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _pregnancyComplicationsController,
            label: 'Previous Pregnancy Complications',
            maxLines: 3,
            hint: 'Any complications in previous pregnancies',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _familyHistoryController,
            label: 'Family Medical History',
            maxLines: 3,
            hint: 'Hereditary conditions, family history of diseases',
          ),
        ],
      ),
    );
  }

  Widget _buildLifestylePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Lifestyle Information', Icons.health_and_safety),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Smoking'),
                  subtitle: const Text('Do you smoke?'),
                  value: _smokingStatus,
                  onChanged: (value) {
                    setState(() {
                      _smokingStatus = value;
                    });
                  },
                  activeColor: const Color(0xFF4FC3A1),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Alcohol Consumption'),
                  subtitle: const Text('Do you consume alcohol?'),
                  value: _alcoholConsumption,
                  onChanged: (value) {
                    setState(() {
                      _alcoholConsumption = value;
                    });
                  },
                  activeColor: const Color(0xFF4FC3A1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _exerciseController,
            label: 'Exercise Routine',
            maxLines: 2,
            hint: 'Describe your regular exercise activities',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _dietaryRestrictionsController,
            label: 'Dietary Restrictions',
            maxLines: 2,
            hint: 'Any dietary restrictions or special diets',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _supplementsController,
            label: 'Nutritional Supplements',
            maxLines: 2,
            hint: 'Vitamins, minerals, or other supplements',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _specialNotesController,
            label: 'Special Notes',
            maxLines: 3,
            hint: 'Any additional information you\'d like to share',
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4FC3A1), width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF4FC3A1),
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4FC3A1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completing your profile helps your healthcare providers give you better care. All information is kept confidential and secure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'CircularStd',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(value: item, child: Text(item.toString()));
      }).toList(),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: selectedDate != null
                        ? Colors.black87
                        : Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color: const Color(0xFF4FC3A1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
