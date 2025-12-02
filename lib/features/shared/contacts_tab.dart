import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/admin_service.dart';
import '../../../models/user_model.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  List<UserModel> _allContacts = [];
  List<UserModel> _filteredContacts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contacts = await AdminService.getAllUsers();
      setState(() {
        _allContacts = contacts;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      List<UserModel> filtered = _allContacts;

      // Apply role filter
      if (_selectedFilter != 'All') {
        filtered = filtered
            .where((contact) => contact.userRole == _selectedFilter)
            .toList();
      }

      // Apply search filter (by name or NIC)
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((contact) {
          final name = contact.fullName.toLowerCase();
          final nic = contact.nicNumber.toLowerCase();
          return name.contains(searchQuery) || nic.contains(searchQuery);
        }).toList();
      }

      _filteredContacts = filtered;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadContacts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Header with filters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.contacts,
                            color: Color(0xFF4FC3A1),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Contacts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadContacts,
                            color: const Color(0xFF4FC3A1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => _applyFilter(),
                        decoration: InputDecoration(
                          hintText: 'Search by name or NIC...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'CircularStd',
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF4FC3A1),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFilter();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', Icons.people),
                            const SizedBox(width: 8),
                            _buildFilterChip('MOTHER', Icons.child_care),
                            const SizedBox(width: 8),
                            _buildFilterChip('MIDWIFE', Icons.local_hospital),
                            const SizedBox(width: 8),
                            _buildFilterChip('DOCTOR', Icons.medical_services),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contacts list
                Expanded(
                  child: _filteredContacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No contacts found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadContacts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredContacts.length,
                            itemBuilder: (context, index) {
                              return _buildContactCard(
                                _filteredContacts[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF4FC3A1),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
          _applyFilter();
        });
      },
      selectedColor: const Color(0xFF4FC3A1),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF4FC3A1),
        fontWeight: FontWeight.w600,
        fontFamily: 'CircularStd',
      ),
      side: BorderSide(
        color: const Color(0xFF4FC3A1),
        width: isSelected ? 0 : 1,
      ),
    );
  }

  Widget _buildContactCard(UserModel contact) {
    Color roleColor;
    IconData roleIcon;

    switch (contact.userRole) {
      case 'MOTHER':
        roleColor = const Color(0xFFEC4899);
        roleIcon = Icons.child_care;
        break;
      case 'MIDWIFE':
        roleColor = const Color(0xFF10B981);
        roleIcon = Icons.local_hospital;
        break;
      case 'DOCTOR':
        roleColor = const Color(0xFF3B82F6);
        roleIcon = Icons.medical_services;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.person;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [roleColor, roleColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(roleIcon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'CircularStd',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          contact.userRole,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Show NIC only for mothers
                  if (contact.userRole == 'MOTHER') ...[
                    _buildInfoRow(Icons.badge, contact.nicNumber, null),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow(
                    Icons.email,
                    contact.email,
                    () => _sendEmail(contact.email),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.phone,
                    contact.phoneNumber,
                    () => _makePhoneCall(contact.phoneNumber),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  fontFamily: 'CircularStd',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
