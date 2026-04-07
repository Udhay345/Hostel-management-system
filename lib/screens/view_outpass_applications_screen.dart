import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';

class ViewOutpassApplicationsScreen extends StatelessWidget {
  const ViewOutpassApplicationsScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }

  String _formatTime(dynamic value) {
    if (value == null) return '-';
    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRejectionDialog(BuildContext context, FirebaseService firebaseService, String documentId) async {
    final reasonController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Out Pass Application'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.trim().isNotEmpty) {
                  try {
                    await firebaseService.updateOutpassStatus(
                      documentId, 
                      'Rejected', 
                      reason: reasonController.text.trim()
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Out pass application rejected'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for rejection'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showApprovalDialog(BuildContext context, FirebaseService firebaseService, String documentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approve Out Pass Application'),
          content: const Text('Are you sure you want to approve this out pass application?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await firebaseService.updateOutpassStatus(documentId, 'Approved');
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Out pass application approved'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Out Pass Applications'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.outpassApplicationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = snapshot.data?.docs ?? [];
          
          // Calculate statistics
          int pendingCount = 0;
          int approvedCount = 0;
          int rejectedCount = 0;

          for (var doc in applications) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? 'Pending';
            switch (status) {
              case 'Pending':
                pendingCount++;
                break;
              case 'Approved':
                approvedCount++;
                break;
              case 'Rejected':
                rejectedCount++;
                break;
            }
          }

          return Column(
            children: [
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _statCard('Pending', pendingCount.toString(), Colors.orange),
                    const SizedBox(width: 8),
                    _statCard('Approved', approvedCount.toString(), Colors.green),
                    const SizedBox(width: 8),
                    _statCard('Rejected', rejectedCount.toString(), Colors.red),
                  ],
                ),
              ),

              // Applications List
              Expanded(
                child: applications.isEmpty
                    ? const Center(
                        child: Text(
                          'No out pass applications found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final doc = applications[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] as String? ?? 'Pending';
                          final studentName = data['student'] as String? ?? 'Unknown';
                          final room = data['room'] as String? ?? 'N/A';
                          final type = data['type'] as String? ?? 'Out Pass';
                          final outDate = data['outDate'] as Timestamp?;
                          final outTime = data['outTime'] as Timestamp?;
                          final returnTime = data['returnTime'] as Timestamp?;
                          final destination = data['destination'] as String? ?? 'N/A';
                          final reason = data['reason'] as String? ?? '';
                          final appliedDate = data['appliedDate'] as Timestamp?;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: Icon(
                                getStatusIcon(status),
                                color: getStatusColor(status),
                                size: 28,
                              ),
                              title: Text(
                                studentName,
                                style: AppTextStyles.h6.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Room: $room'),
                                  Text('Type: $type'),
                                  Text('Status: $status'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status),
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
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Date and Time Information
                                      Text(
                                        'Date & Time Details',
                                        style: AppTextStyles.h6.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Date: ${_formatDate(outDate)}'),
                                      Text('Out Time: ${_formatTime(outTime)}'),
                                      Text('Return Time: ${_formatTime(returnTime)}'),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Destination and Reason
                                      Text(
                                        'Purpose',
                                        style: AppTextStyles.h6.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Destination: $destination'),
                                      if (reason.isNotEmpty) Text('Reason: $reason'),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Application Date
                                      Text(
                                        'Application Details',
                                        style: AppTextStyles.h6.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Applied: ${_formatDate(appliedDate)}'),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Action Buttons (only for pending applications)
                                      if (status == 'Pending')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AppWidgets.customButton(
                                                text: 'Approve',
                                                onPressed: () => _showApprovalDialog(
                                                  context, 
                                                  firebaseService, 
                                                  doc.id
                                                ),
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: AppWidgets.secondaryButton(
                                                text: 'Reject',
                                                onPressed: () => _showRejectionDialog(
                                                  context, 
                                                  firebaseService, 
                                                  doc.id
                                                ),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
} 