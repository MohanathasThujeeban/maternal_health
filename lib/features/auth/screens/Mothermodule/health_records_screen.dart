import 'package:flutter/material.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  String selectedMonth = "Choose month";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Custom App Bar
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).padding.top + 60,
            decoration: BoxDecoration(color: Color(0xFF4ECDC4)),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      'Health Records',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),

                  SizedBox(height: 24),

                  // Measurements Section
                  _buildMeasurementsSection(),

                  SizedBox(height: 24),

                  // History Section
                  _buildHistorySection(),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image with Status Indicator
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color(0xFF4ECDC4), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Image.asset(
                    'assets/images/profile_woman.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Color(0xFFFFF4E6),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF48BB78),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          // Name and ID with additional info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fatima Khan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: 123456789',
                  style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6FFFA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '28 weeks pregnant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE6FFFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.monitor_heart_outlined,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Measurements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Measurements Grid with improved design
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildEnhancedMeasurementCard(
                'Height',
                '165',
                'cm',
                Icons.height,
                Color(0xFF4299E1),
                MeasurementStatus.normal,
              ),
              _buildEnhancedMeasurementCard(
                'Weight',
                '68.5',
                'kg',
                Icons.monitor_weight_outlined,
                Color(0xFF48BB78),
                MeasurementStatus.normal,
              ),
              _buildEnhancedMeasurementCard(
                'Blood Pressure',
                '120/80',
                'mmHg',
                Icons.favorite_outline,
                Color(0xFF48BB78),
                MeasurementStatus.normal,
              ),
              _buildEnhancedMeasurementCard(
                'Abdominal Girth',
                '92',
                'cm',
                Icons.straighten,
                Color(0xFF9F7AEA),
                MeasurementStatus.normal,
              ),
              _buildEnhancedMeasurementCard(
                'Fetal Heart Rate',
                '140',
                'bpm',
                Icons.child_care,
                Color(0xFF48BB78),
                MeasurementStatus.normal,
              ),
              _buildEnhancedMeasurementCard(
                'Glucose Level',
                '95',
                'mg/dL',
                Icons.water_drop_outlined,
                Color(0xFF48BB78),
                MeasurementStatus.normal,
              ),
            ],
          ),

          SizedBox(height: 12),

          // Additional measurements in single row
          Row(
            children: [
              Expanded(
                child: _buildEnhancedMeasurementCard(
                  'Hemoglobin',
                  '11.2',
                  'g/dL',
                  Icons.bloodtype,
                  Color(0xFFED8936),
                  MeasurementStatus.low,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedMeasurementCard(
                  'Urine Test',
                  'Negative',
                  '',
                  Icons.science_outlined,
                  Color(0xFF48BB78),
                  MeasurementStatus.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMeasurementCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color iconColor,
    MeasurementStatus status,
  ) {
    Color statusColor;
    Color backgroundColor;

    switch (status) {
      case MeasurementStatus.normal:
        statusColor = Color(0xFF48BB78);
        backgroundColor = Color(0xFFF0FFF4);
        break;
      case MeasurementStatus.low:
        statusColor = Color(0xFFED8936);
        backgroundColor = Color(0xFFFFF5F0);
        break;
      case MeasurementStatus.high:
        statusColor = Color(0xFFE53E3E);
        backgroundColor = Color(0xFFFFF5F5);
        break;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4A5568),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFE6FFFA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.history,
                      color: Color(0xFF4ECDC4),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMonth,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                    ),
                    items:
                        [
                          'Choose month',
                          'January 2024',
                          'February 2024',
                          'March 2024',
                          'April 2024',
                          'May 2024',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          _buildHistoryItem(
            'Hemoglobin',
            '12.5 g/dL',
            '12/05/2024',
            Icons.bloodtype,
            Color(0xFF48BB78),
          ),
          _buildHistoryItem(
            'Blood Pressure',
            '115/75 mmHg',
            '12/05/2024',
            Icons.favorite_outline,
            Color(0xFF48BB78),
          ),
          _buildHistoryItem(
            'Weight',
            '62 kg',
            '12/05/2024',
            Icons.monitor_weight_outlined,
            Color(0xFF4299E1),
          ),
          _buildHistoryItem(
            'Abdominal Girth',
            '88 cm',
            '12/05/2024',
            Icons.straighten,
            Color(0xFF9F7AEA),
          ),
          _buildHistoryItem(
            'Urine Test',
            'Negative',
            '12/05/2024',
            Icons.science_outlined,
            Color(0xFF48BB78),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String value,
    String date,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum MeasurementStatus { normal, low, high }
