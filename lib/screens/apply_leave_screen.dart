import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'Sick Leave';
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  final List<String> _leaveTypes = [
    'Sick Leave',
    'Personal Leave',
    'Emergency Leave',
    'Other',
  ];

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firebaseService.submitLeaveApplication(
        leaveType: _leaveType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave application submitted!'), backgroundColor: Colors.green),
      );

      setState(() {
        _isLoading = false;
        _reasonController.clear();
        _startDate = null;
        _endDate = null;
        _leaveType = 'Sick Leave';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Leave'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Application Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apply Leave',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _leaveType,
                        decoration: const InputDecoration(
                          labelText: 'Leave Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _leaveTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _leaveType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _startDate == null
                                      ? 'Select Start Date'
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _endDate == null
                                      ? 'Select End Date'
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Leave',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter reason for leave';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitLeave,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit Leave Application'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Leave Application History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Leave Application History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _firebaseService.leaveApplicationsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final leaveApplications = snapshot.data?.docs ?? [];
                        
                        // Filter applications for current user
                        final currentUser = _firebaseService.currentUser;
                        if (currentUser == null) {
                          return const Center(child: Text('Please log in to view your applications'));
                        }
                        
                        final userApplications = leaveApplications.where((doc) {
                          final data = doc.data();
                          return data['studentUid'] == currentUser.uid;
                        }).toList();

                        if (userApplications.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No leave applications yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userApplications.length,
                          itemBuilder: (context, index) {
                            final application = userApplications[index].data();
                            final status = application['status'] ?? 'Pending';
                            final leaveType = application['type'] ?? 'Leave';
                            final startDate = application['startDate'] as Timestamp?;
                            final endDate = application['endDate'] as Timestamp?;
                            final reason = application['reason'] ?? '';
                            final appliedDate = application['appliedDate'] as Timestamp?;
                            final processedDate = application['processedDate'] as Timestamp?;
                            final adminReason = application['reason'] ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: _getStatusColor(status).withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          leaveType,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (startDate != null && endDate != null)
                                      Text(
                                        'From: ${_formatDate(startDate)} To: ${_formatDate(endDate)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    if (reason.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Reason: $reason',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      'Applied: ${appliedDate != null ? _formatDate(appliedDate) : 'N/A'}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    if (processedDate != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Processed: ${_formatDate(processedDate)}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                    if (adminReason.isNotEmpty && status != 'Pending') ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Admin Note: $adminReason',
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          color: Colors.blue,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
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
            ),
            
            const SizedBox(height: 16),
            
            // Leave Policy
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leave Policy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Sick Leave: Up to 7 days'),
                    Text('• Personal Leave: Up to 3 days'),
                    Text('• Emergency Leave: Up to 5 days'),
                    Text('• All leaves require prior approval'),
                  ],
                ),
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
    super.dispose();
  }
} 