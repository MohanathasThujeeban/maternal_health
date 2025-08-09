import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mother & Baby Records',
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
      home: ViewUpdateRecordsScreen(),
    );
  }
}

class PatientRecord {
  final int id;
  String mothersName;
  String babysName;
  String nationalId;
  String mohId;
  DateTime motherDob;
  DateTime babyDob;
  String address;
  String contactNumber;
  String bloodGroup;
  String medicalHistory;
  DateTime lastVisitDate;
  DateTime nextAppointmentDate;

  PatientRecord({
    required this.id,
    required this.mothersName,
    required this.babysName,
    required this.nationalId,
    required this.mohId,
    required this.motherDob,
    required this.babyDob,
    required this.address,
    required this.contactNumber,
    required this.bloodGroup,
    required this.medicalHistory,
    required this.lastVisitDate,
    required this.nextAppointmentDate,
  });
}

class ViewUpdateRecordsScreen extends StatefulWidget {
  @override
  _ViewUpdateRecordsScreenState createState() =>
      _ViewUpdateRecordsScreenState();
}

class _ViewUpdateRecordsScreenState extends State<ViewUpdateRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PatientRecord> allRecords = [];
  List<PatientRecord> filteredRecords = [];
  PatientRecord? selectedRecord;
  bool isEditMode = false;

  // Form Controllers
  final TextEditingController _mothersNameController = TextEditingController();
  final TextEditingController _babysNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _mohIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _motherDobController = TextEditingController();
  final TextEditingController _babyDobController = TextEditingController();
  final TextEditingController _lastVisitController = TextEditingController();
  final TextEditingController _nextAppointmentController =
      TextEditingController();

  String? selectedBloodGroup;
  String? selectedMedicalHistory;

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> medicalHistoryOptions = [
    'None',
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Allergies',
    'Previous Cesarean',
    'Gestational Diabetes',
    'Other Complications',
  ];

  @override
  void initState() {
    super.initState();
    _initializeSampleRecords();
    filteredRecords = allRecords;
  }

  void _initializeSampleRecords() {
    allRecords = [
      PatientRecord(
        id: 1,
        mothersName: 'Priya Kumari Perera',
        babysName: 'Baby Perera',
        nationalId: '198523456789',
        mohId: 'MOH001',
        motherDob: DateTime(1985, 3, 15),
        babyDob: DateTime(2024, 6, 10),
        address: 'No. 45, Galle Road, Colombo 03',
        contactNumber: '0771234567',
        bloodGroup: 'A+',
        medicalHistory: 'Gestational Diabetes',
        lastVisitDate: DateTime.now().subtract(Duration(days: 7)),
        nextAppointmentDate: DateTime.now().add(Duration(days: 14)),
      ),
      PatientRecord(
        id: 2,
        mothersName: 'Kamala Silva',
        babysName: 'Baby Silva',
        nationalId: '199012345678',
        mohId: 'MOH002',
        motherDob: DateTime(1990, 8, 22),
        babyDob: DateTime(2024, 7, 5),
        address: 'No. 12, Temple Road, Kandy',
        contactNumber: '0772345678',
        bloodGroup: 'O+',
        medicalHistory: 'None',
        lastVisitDate: DateTime.now().subtract(Duration(days: 3)),
        nextAppointmentDate: DateTime.now().add(Duration(days: 10)),
      ),
      PatientRecord(
        id: 3,
        mothersName: 'Sandya Fernando',
        babysName: 'Baby Fernando',
        nationalId: '198756789012',
        mohId: 'MOH003',
        motherDob: DateTime(1987, 12, 8),
        babyDob: DateTime(2024, 5, 20),
        address: 'No. 78, Main Street, Galle',
        contactNumber: '0773456789',
        bloodGroup: 'B+',
        medicalHistory: 'Hypertension',
        lastVisitDate: DateTime.now().subtract(Duration(days: 14)),
        nextAppointmentDate: DateTime.now().add(Duration(days: 7)),
      ),
    ];
  }

  void _filterRecords(String searchTerm) {
    setState(() {
      filteredRecords = allRecords.where((record) {
        return record.mothersName.toLowerCase().contains(
              searchTerm.toLowerCase(),
            ) ||
            record.babysName.toLowerCase().contains(searchTerm.toLowerCase()) ||
            record.nationalId.contains(searchTerm) ||
            record.mohId.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    });
  }

  void _selectRecord(PatientRecord record) {
    setState(() {
      selectedRecord = record;
      isEditMode = false;
      _populateFormFields(record);
    });
  }

  void _populateFormFields(PatientRecord record) {
    _mothersNameController.text = record.mothersName;
    _babysNameController.text = record.babysName;
    _nationalIdController.text = record.nationalId;
    _mohIdController.text = record.mohId;
    _addressController.text = record.address;
    _contactController.text = record.contactNumber;
    _motherDobController.text = _formatDate(record.motherDob);
    _babyDobController.text = _formatDate(record.babyDob);
    _lastVisitController.text = _formatDate(record.lastVisitDate);
    _nextAppointmentController.text = _formatDate(record.nextAppointmentDate);
    selectedBloodGroup = record.bloodGroup;
    selectedMedicalHistory = record.medicalHistory;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _startEdit() {
    setState(() {
      isEditMode = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditMode = false;
      if (selectedRecord != null) {
        _populateFormFields(selectedRecord!);
      }
    });
  }

  void _updateRecord() {
    if (selectedRecord == null) return;

    setState(() {
      selectedRecord!.mothersName = _mothersNameController.text;
      selectedRecord!.babysName = _babysNameController.text;
      selectedRecord!.nationalId = _nationalIdController.text;
      selectedRecord!.mohId = _mohIdController.text;
      selectedRecord!.address = _addressController.text;
      selectedRecord!.contactNumber = _contactController.text;
      selectedRecord!.bloodGroup = selectedBloodGroup ?? 'O+';
      selectedRecord!.medicalHistory = selectedMedicalHistory ?? 'None';

      // Update in the main list
      int index = allRecords.indexWhere((r) => r.id == selectedRecord!.id);
      if (index != -1) {
        allRecords[index] = selectedRecord!;
      }

      isEditMode = false;
      _filterRecords(_searchController.text);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Record updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _goBack() {
    setState(() {
      selectedRecord = null;
      isEditMode = false;
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = _formatDate(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedRecord == null
              ? '👥 Mother & Baby Records'
              : 'Record Details',
        ),
        leading: selectedRecord != null
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _goBack)
            : null,
      ),
      body: selectedRecord == null
          ? _buildRecordsList()
          : _buildRecordDetails(),
    );
  }

  Widget _buildRecordsList() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.all(16),
          color: Color(0xFF00D4D4),
          child: TextField(
            controller: _searchController,
            onChanged: _filterRecords,
            decoration: InputDecoration(
              hintText: 'Search by name, National ID, or MOH ID',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Records List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredRecords.length,
            itemBuilder: (context, index) {
              final record = filteredRecords[index];
              return _buildRecordCard(record);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(PatientRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectRecord(record),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF00D4D4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.woman, color: Colors.white, size: 20),
                        Icon(Icons.child_care, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.mothersName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Baby: ${record.babysName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'MOH ID: ${record.mohId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00D4D4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Color(0xFF00D4D4)),
                ],
              ),

              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),

              // Quick Info
              Row(
                children: [
                  Expanded(child: _buildQuickInfo('📞', record.contactNumber)),
                  Expanded(child: _buildQuickInfo('🩸', record.bloodGroup)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickInfo(
                      '📅',
                      'Last: ${_formatDate(record.lastVisitDate)}',
                    ),
                  ),
                  Expanded(
                    child: _buildQuickInfo(
                      '🔜',
                      'Next: ${_formatDate(record.nextAppointmentDate)}',
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

  Widget _buildQuickInfo(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 14)),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Header
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFF00D4D4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.woman, color: Colors.white, size: 28),
                        Icon(Icons.child_care, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedRecord!.mothersName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Baby: ${selectedRecord!.babysName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'MOH ID: ${selectedRecord!.mohId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00D4D4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Form Fields
          _buildFormSection(),

          SizedBox(height: 32),

          // Action Buttons
          if (!isEditMode) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startEdit,
                icon: Icon(Icons.edit),
                label: Text('Edit Record'),
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
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cancelEdit,
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF00D4D4),
                      side: BorderSide(color: Color(0xFF00D4D4)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateRecord,
                    icon: Icon(Icons.save),
                    label: Text('Update'),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D4D4),
              ),
            ),
            SizedBox(height: 16),

            // Mother's Name
            _buildTextField(
              controller: _mothersNameController,
              label: 'Mother\'s Name',
              icon: Icons.woman,
              enabled: isEditMode,
            ),
            SizedBox(height: 16),

            // Baby's Name
            _buildTextField(
              controller: _babysNameController,
              label: 'Baby\'s Name',
              icon: Icons.child_care,
              enabled: isEditMode,
            ),
            SizedBox(height: 16),

            // National ID & MOH ID Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nationalIdController,
                    label: 'National ID',
                    icon: Icons.credit_card,
                    enabled: isEditMode,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _mohIdController,
                    label: 'MOH ID',
                    icon: Icons.local_hospital,
                    enabled: isEditMode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Date of Birth Row
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _motherDobController,
                    label: 'Mother DOB',
                    enabled: isEditMode,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    controller: _babyDobController,
                    label: 'Baby DOB',
                    enabled: isEditMode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Address
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home,
              enabled: isEditMode,
              maxLines: 2,
            ),
            SizedBox(height: 16),

            // Contact & Blood Group Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _contactController,
                    label: 'Contact Number',
                    icon: Icons.phone,
                    enabled: isEditMode,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    value: selectedBloodGroup,
                    label: 'Blood Group',
                    icon: Icons.bloodtype,
                    items: bloodGroups,
                    enabled: isEditMode,
                    onChanged: (value) =>
                        setState(() => selectedBloodGroup = value),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Medical History
            _buildDropdownField(
              value: selectedMedicalHistory,
              label: 'Medical History',
              icon: Icons.medical_information,
              items: medicalHistoryOptions,
              enabled: isEditMode,
              onChanged: (value) =>
                  setState(() => selectedMedicalHistory = value),
            ),
            SizedBox(height: 16),

            // Visit Dates Row
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _lastVisitController,
                    label: 'Last Visit',
                    enabled: isEditMode,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    controller: _nextAppointmentController,
                    label: 'Next Appointment',
                    enabled: isEditMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? Color(0xFF00D4D4) : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      onTap: enabled ? () => _selectDate(controller) : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.calendar_today,
          color: enabled ? Color(0xFF00D4D4) : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required bool enabled,
    required Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? Color(0xFF00D4D4) : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
