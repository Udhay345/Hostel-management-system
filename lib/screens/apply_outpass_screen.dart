import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';

class ApplyOutpassScreen extends StatefulWidget {
  const ApplyOutpassScreen({super.key});

  @override
  State<ApplyOutpassScreen> createState() => _ApplyOutpassScreenState();
}

class _ApplyOutpassScreenState extends State<ApplyOutpassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _outDate;
  TimeOfDay? _outTime;
  TimeOfDay? _returnTime;
  String _outpassType = 'Short Outing';
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  final List<String> _outpassTypes = [
    'Short Outing',
    'Shopping',
    'Medical',
    'Personal Work',
    'Family Visit',
    'Other',
  ];

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _outDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOutTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOutTime) {
          _outTime = picked;
        } else {
          _returnTime = picked;
        }
      });
    }
  }

  Future<void> _submitOutpass() async {
    if (!_formKey.currentState!.validate() || 
        _outDate == null || 
        _outTime == null || 
        _returnTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }

    // Validate that return time is after out time
    final outDateTime = DateTime(
      _outDate!.year,
      _outDate!.month,
      _outDate!.day,
      _outTime!.hour,
      _outTime!.minute,
    );
    final returnDateTime = DateTime(
      _outDate!.year,
      _outDate!.month,
      _outDate!.day,
      _returnTime!.hour,
      _returnTime!.minute,
    );

    if (returnDateTime.isBefore(outDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return time must be after out time'), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firebaseService.submitOutpassApplication(
        outpassType: _outpassType,
        outDate: _outDate!,
        outTime: _outTime!,
        returnTime: _returnTime!,
        destination: _destinationController.text.trim(),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Out pass application submitted!'), 
          backgroundColor: Colors.green
        ),
      );

      setState(() {
        _isLoading = false;
        _reasonController.clear();
        _destinationController.clear();
        _outDate = null;
        _outTime = null;
        _returnTime = null;
        _outpassType = 'Short Outing';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'), 
          backgroundColor: Colors.red
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Out Pass'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppWidgets.heading('Request Out Pass'),
            AppWidgets.spacer(height: 16),
            
            // Application Form
            AppWidgets.customCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Out Pass Details', style: AppTextStyles.h5),
                    AppWidgets.spacer(height: 16),
                    
                    // Out Pass Type
                    DropdownButtonFormField<String>(
                      value: _outpassType,
                      decoration: const InputDecoration(
                        labelText: 'Out Pass Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _outpassTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _outpassType = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select out pass type';
                        }
                        return null;
                      },
                    ),
                    
                    AppWidgets.spacer(height: 16),
                    
                    // Date Selection
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _outDate != null 
                              ? '${_outDate!.day}/${_outDate!.month}/${_outDate!.year}'
                              : 'Select Date',
                          style: _outDate != null 
                              ? AppTextStyles.bodyMedium
                              : AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    AppWidgets.spacer(height: 16),
                    
                    // Time Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Out Time',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _outTime != null 
                                    ? _outTime!.format(context)
                                    : 'Select Time',
                                style: _outTime != null 
                                    ? AppTextStyles.bodyMedium
                                    : AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        AppWidgets.hSpacer(),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Return Time',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _returnTime != null 
                                    ? _returnTime!.format(context)
                                    : 'Select Time',
                                style: _returnTime != null 
                                    ? AppTextStyles.bodyMedium
                                    : AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    AppWidgets.spacer(height: 16),
                    
                    // Destination
                    TextFormField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination/Place',
                        border: OutlineInputBorder(),
                        hintText: 'Where are you going?',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter destination';
                        }
                        return null;
                      },
                    ),
                    
                    AppWidgets.spacer(height: 16),
                    
                    // Reason
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                        hintText: 'Why do you need to go out?',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter reason';
                        }
                        return null;
                      },
                    ),
                    
                    AppWidgets.spacer(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: AppWidgets.customButton(
                        text: _isLoading ? 'Submitting...' : 'Submit Out Pass',
                        onPressed: () => _submitOutpass(),
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppWidgets.spacer(height: 24),
            
            // Previous Applications
            AppWidgets.customCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Previous Out Pass Applications', style: AppTextStyles.h5),
                  AppWidgets.spacer(height: 16),
                                     StreamBuilder<QuerySnapshot>(
                     stream: _firebaseService.studentOutpassApplicationsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // Handle Firebase index error gracefully
                        final error = snapshot.error.toString();
                        if (error.contains('failed-precondition') && error.contains('index')) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Database is being set up. Please try again in a few moments.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading applications: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final applications = snapshot.data?.docs ?? [];

                      if (applications.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No out pass applications yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final app = applications[index].data() as Map<String, dynamic>;
                          final status = app['status'] as String? ?? 'Pending';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                app['type'] as String? ?? 'Out Pass',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${_formatDate(app['outDate'] as Timestamp)}'),
                                  Text('Time: ${_formatTime(app['outTime'] as Timestamp)} - ${_formatTime(app['returnTime'] as Timestamp)}'),
                                  Text('Destination: ${app['destination'] as String? ?? 'N/A'}'),
                                  if (app['reason'] != null && app['reason'].isNotEmpty)
                                    Text('Reason: ${app['reason']}'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
} 