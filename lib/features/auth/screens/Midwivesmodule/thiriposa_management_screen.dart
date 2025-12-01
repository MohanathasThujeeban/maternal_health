// Thiriposa Management Screen
// This screen allows midwives to manage Thiriposa (nutritional supplement) distribution records
// Features: User search, record creation, and viewing previous distributions

import 'package:flutter/material.dart';
import 'package:maternal_health/services/thiriposa_api_service.dart';

/// Main screen for managing Thiriposa (nutritional supplement) distribution records
/// Displays a searchable list of all registered users and allows midwives to add new records
class ThiriposaManagementScreen extends StatefulWidget {
  const ThiriposaManagementScreen({super.key});

  @override
  State<ThiriposaManagementScreen> createState() =>
      _ThiriposaManagementScreenState();
}

/// State class for ThiriposaManagementScreen
/// Manages user list, search functionality, and loading states
class _ThiriposaManagementScreenState extends State<ThiriposaManagementScreen> {
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  // Complete list of all registered users from the database
  List<dynamic> _allUsers = [];

  // Filtered list based on search query (displayed to user)
  List<dynamic> _filteredUsers = [];

  // Loading state for initial data fetch
  bool _isLoading = true;

  // Error message to display if data loading fails
  String _errorMessage = '';

  /// Initialize state and load all users from the database
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Loads all registered users from the backend API
  /// Sets loading state, fetches data, and updates both user lists
  /// Handles errors by setting appropriate error messages
  Future<void> _loadUsers() async {
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Fetch all users from the API service
    final result = await ThiriposaApiService.getAllUsers();

    // Check again if widget is still mounted after async operation
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success']) {
        // Populate both lists with fetched users
        _allUsers = result['users'];
        _filteredUsers = _allUsers;
      } else {
        // Store error message for display
        _errorMessage = result['message'];
      }
    });
  }

  /// Filters the user list based on search query
  /// Searches in both NIC number and full name fields (case-insensitive)
  /// Updates the filtered list to reflect search results
  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        // Show all users when search is cleared
        _filteredUsers = _allUsers;
      } else {
        // Filter users where NIC or name contains the search query
        _filteredUsers = _allUsers.where((user) {
          final nicNumber = user['nicNumber'].toString().toLowerCase();
          final fullName = user['fullName'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          // Return true if either field matches the search query
          return nicNumber.contains(searchQuery) ||
              fullName.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: const Text(
          'Thiriposa Management',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A), Color(0xFF2E7D5A)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.food_bank, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_filteredUsers.length} Users',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Header Section
          // Contains title, description, and search bar with gradient background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3A1), Color(0xFF3AB38A)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thiriposa Records',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                          Text(
                            'Manage nutritional supplement records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Enhanced Search Bar
                // Allows real-time search by name or NIC with clear button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterUsers,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name or NIC...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: 'SpotifyCircular',
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF4FC3A1),
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _filterUsers('');
                              },
                            )
                          : const Icon(
                              Icons.filter_list,
                              color: Color(0xFF4FC3A1),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Enhanced Status Bar
          // Displays count of filtered users and active status indicator
          if (!_isLoading) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4FC3A1).withOpacity(0.1),
                    const Color(0xFF4FC3A1).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4FC3A1).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Color(0xFF4FC3A1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_filteredUsers.length} ${_filteredUsers.length == 1 ? 'User' : 'Users'} Found',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4FC3A1),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3A1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Users List
          // Scrollable list of all filtered users with their information
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  /// Builds the user list widget based on current state
  /// Shows loading spinner, error message, empty state, or list of user cards
  Widget _buildUsersList() {
    // Show loading indicator while fetching data
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3A1)),
        ),
      );
    }

    // Show error message with retry button if data loading failed
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state message when no users match search criteria
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Build scrollable list of user cards
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  /// Builds a card widget for a single user
  /// Displays user avatar, name, NIC, and phone number
  /// Taps navigate to the record form screen for that user
  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThiriposaRecordFormScreen(user: user),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF4FC3A1).withOpacity(0.1),
                  child: Text(
                    user['fullName']?.substring(0, 1).toUpperCase() ?? 'M',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4FC3A1),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['fullName'] ?? 'Unknown Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpotifyCircular',
                          color: Color(0xFF2E7D5A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIC: ${user['nicNumber'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      if (user['phoneNumber3'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Phone: ${user['phoneNumber3']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF4FC3A1),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Clean up resources when widget is disposed
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Screen for adding and viewing Thiriposa distribution records for a specific user
/// Allows midwives to record new distributions and view previous records
class ThiriposaRecordFormScreen extends StatefulWidget {
  // User data passed from the management screen
  final Map<String, dynamic> user;

  const ThiriposaRecordFormScreen({super.key, required this.user});

  @override
  State<ThiriposaRecordFormScreen> createState() =>
      _ThiriposaRecordFormScreenState();
}

/// State class for ThiriposaRecordFormScreen
/// Manages form inputs, record submission, and display of existing records
class _ThiriposaRecordFormScreenState extends State<ThiriposaRecordFormScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controller for quantity input field
  final TextEditingController _quantityController = TextEditingController();

  // Controller for notes input field
  final TextEditingController _notesController = TextEditingController();

  // Selected distribution date (defaults to today)
  DateTime _selectedDate = DateTime.now();

  // Loading state for form submission
  bool _isLoading = false;

  // List of previously recorded distributions for this user
  List<dynamic> _existingRecords = [];

  // Loading state for fetching existing records
  bool _isLoadingRecords = true;

  /// Initialize state and load existing records for the selected user
  @override
  void initState() {
    super.initState();
    _loadExistingRecords();
  }

  /// Fetches all existing Thiriposa records for the current user
  /// Uses the user's NIC number to retrieve their distribution history
  Future<void> _loadExistingRecords() async {
    // Fetch records from API using user's NIC
    final result = await ThiriposaApiService.getRecordsByNic(
      widget.user['nicNumber'],
    );

    setState(() {
      _isLoadingRecords = false;
      if (result['success']) {
        // Store the fetched records for display
        _existingRecords = result['records'];
      }
    });
  }

  /// Shows a date picker dialog for selecting the distribution date
  /// Allows selecting dates from 2020 to today
  /// Updates the selected date if user confirms selection
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Validates and submits a new Thiriposa distribution record
  /// Sends data to backend API and handles success/error responses
  /// Clears form and refreshes records list on success
  Future<void> _submitRecord() async {
    // Validate form inputs before submission
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state during API call
    setState(() {
      _isLoading = true;
    });

    // Submit new record to the backend API
    final result = await ThiriposaApiService.addThiriposaRecord(
      motherNic: widget.user['nicNumber'],
      supplyDate: _selectedDate,
      quantity: int.parse(_quantityController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() {
      _isLoading = false;
    });

    // Handle successful record creation
    if (result['success']) {
      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Refresh records and clear form
      _loadExistingRecords(); // Reload to show the new record
      _quantityController.clear(); // Clear quantity input
      _notesController.clear(); // Clear notes input
      setState(() {
        _selectedDate = DateTime.now(); // Reset date to today
      });
    } else {
      // Show error message if record creation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: const Text(
          'Update Thiriposa Record',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with user info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4FC3A1), Color(0xFF3AB38A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.user['fullName']?.substring(0, 1).toUpperCase() ??
                          'M',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user['fullName'] ?? 'Unknown Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'NIC: ${widget.user['nicNumber'] ?? 'Unknown'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Add New Record Form
                  // Form with date picker, quantity input, notes field, and submit button
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Thiriposa Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D5A),
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Date Selection
                            // Tappable field that opens date picker dialog
                            InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF4FC3A1),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Supply Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SpotifyCircular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Quantity Input
                            // Numeric input field with validation for positive integers
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Quantity (packets)',
                                prefixIcon: const Icon(
                                  Icons.inventory,
                                  color: Color(0xFF4FC3A1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4FC3A1),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                final quantity = int.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Please enter a valid quantity';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Notes Input
                            // Optional multi-line text field for additional information
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Notes (optional)',
                                prefixIcon: const Icon(
                                  Icons.notes,
                                  color: Color(0xFF4FC3A1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4FC3A1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            // Full-width button that submits the form (shows loading indicator during submission)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitRecord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4FC3A1),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Add Record',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'SpotifyCircular',
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Existing Records
                  // Displays list of all previous Thiriposa distributions for this user
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Previous Records',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isLoadingRecords)
                            const Center(child: CircularProgressIndicator())
                          else if (_existingRecords.isEmpty)
                            const Center(
                              child: Text(
                                'No previous records found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _existingRecords.length,
                              itemBuilder: (context, index) {
                                final record = _existingRecords[index];
                                final date = DateTime.parse(record['date']);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4FC3A1,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory,
                                        color: Color(0xFF4FC3A1),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${date.day}/${date.month}/${date.year}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'SpotifyCircular',
                                              ),
                                            ),
                                            Text(
                                              'Quantity: ${record['quantity']} packets',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                                fontFamily: 'SpotifyCircular',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean up controllers when widget is disposed
  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
