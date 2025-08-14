import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/thiriposa_record.dart';
import '../../../../services/thiriposa_service.dart';

class ThiriposaRecordScreen extends StatefulWidget {
  final String? motherNic;
  final bool isMidwife;

  const ThiriposaRecordScreen({
    super.key,
    this.motherNic,
    this.isMidwife = false,
  });

  @override
  State<ThiriposaRecordScreen> createState() => _ThiriposaRecordScreenState();
}

class _ThiriposaRecordScreenState extends State<ThiriposaRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _quantity = 1;
  List<ThiriposaRecord> _records = [];
  bool _isLoading = false;
  bool _isMidwife = false;
  String? _currentUserNic;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMidwife = prefs.getBool('isMidwife') ?? false;
      _currentUserNic = prefs.getString('userNic');
    });
    await _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isMidwife && widget.motherNic != null) {
        _records = await ThiriposaService.getRecordsByNic(widget.motherNic!);
      } else if (!widget.isMidwife) {
        _records = await ThiriposaService.getMyRecords();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading records: \${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchRecords(String nic) async {
    if (nic.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      _records = await ThiriposaService.getRecordsByNic(nic);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching records: \${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ThiriposaService.addRecord(
        motherNic: widget.motherNic!,
        date: _selectedDate,
        quantity: _quantity,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record added successfully')),
      );
      _loadRecords();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding record: \${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiriposa Records'),
        backgroundColor: const Color(0xFF4FC3A1),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4FC3A1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isMidwife) ...[
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by NIC',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () =>
                              _searchRecords(_searchController.text),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.isMidwife && widget.motherNic != null)
                    Form(
                      key: _formKey,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Record',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _selectDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Supply Date',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_selectedDate),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: _quantity.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Quantity (packets)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter quantity';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _quantity = int.tryParse(value) ?? 1;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _submitRecord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4FC3A1),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Add Record',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Records History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.inventory,
                            color: Color(0xFF4FC3A1),
                          ),
                          title: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(record.date)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Quantity: ${record.quantity} packets',
                          ),
                          trailing: widget.isMidwife
                              ? Text(record.motherNic)
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
