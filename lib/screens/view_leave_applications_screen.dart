import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show PdfColors;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import '../services/firebase_service.dart';

class ViewLeaveApplicationsScreen extends StatelessWidget {
  const ViewLeaveApplicationsScreen({super.key});

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
          title: const Text('Reject Leave Application'),
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
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isNotEmpty) {
                  try {
                    await firebaseService.updateLeaveStatus(
                      documentId, 
                      'Rejected',
                      reason: reasonController.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Leave application rejected successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error rejecting application: $e'),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportLeaveApplicationPDF(
    BuildContext context,
    FirebaseService firebaseService,
    String documentId,
    Map<String, dynamic> application,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Generating PDF...'),
              ],
            ),
          );
        },
      );

      // Get detailed leave application data
      final leaveData = await firebaseService.getLeaveApplicationForPDF(documentId);
      if (leaveData == null) {
        throw Exception('Could not retrieve leave application data');
      }

      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Add content to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'RIT HMS — Leave Application',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '$dateStr $timeStr',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Student Information
            pw.Header(
              level: 1,
              text: 'Student Information',
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(leaveData['studentData']['name'] ?? 'N/A'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Room Number', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(leaveData['studentData']['roomNumber'] ?? 'N/A'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Email', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(leaveData['studentData']['email'] ?? 'N/A'),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Leave Application Details
            pw.Header(
              level: 1,
              text: 'Leave Application Details',
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Leave Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(leaveData['leaveData']['type'] ?? 'N/A'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Start Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(_formatDate(leaveData['leaveData']['startDate'])),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('End Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(_formatDate(leaveData['leaveData']['endDate'])),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Reason', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(leaveData['leaveData']['reason'] ?? 'N/A'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        leaveData['leaveData']['status'] ?? 'N/A',
                        style: pw.TextStyle(
                          color: leaveData['leaveData']['status'] == 'Approved' 
                              ? PdfColors.green 
                              : PdfColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (leaveData['leaveData']['processedDate'] != null) ...[
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Processed Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(_formatDate(leaveData['leaveData']['processedDate'])),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/leave_application_$documentId.pdf');
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message and share
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Leave application exported — saved as leave_application_$documentId.pdf'),
            backgroundColor: Colors.green,
          ),
        );

        // Share the PDF
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'RIT HMS Leave Application - $documentId',
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave Applications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          
          // Statistics Cards
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firebaseService.leaveApplicationsStream(),
            builder: (context, snapshot) {
              final total = snapshot.data?.docs.length ?? 0;
              final pending = snapshot.data?.docs
                      .where((d) => (d.data()['status'] ?? 'Pending') == 'Pending')
                      .length ??
                  0;
              final approved = snapshot.data?.docs
                      .where((d) => (d.data()['status'] ?? '') == 'Approved')
                      .length ??
                  0;

              return Row(
                children: [
                  _statCard('Total', total.toString(), Colors.blue),
                  const SizedBox(width: 16),
                  _statCard('Pending', pending.toString(), Colors.orange),
                  const SizedBox(width: 16),
                  _statCard('Approved', approved.toString(), Colors.green),
                ],
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Applications List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firebaseService.leaveApplicationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load applications'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No leave applications yet'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final application = doc.data();
                    final String status = application['status'] ?? 'Pending';
                    final String studentName = (application['student'] ?? '-').toString();
                    final String leaveType = (application['type'] ?? '-').toString();
                    final String room = (application['room'] ?? '-').toString();
                    final String startDate = _formatDate(application['startDate']);
                    final String endDate = _formatDate(application['endDate']);
                    final String appliedDate = _formatDate(application['appliedDate']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: getStatusColor(status),
                          child: Icon(
                            getStatusIcon(status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '$studentName - $leaveType',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Room: $room'),
                            Text('Date: $startDate to $endDate'),
                            Text('Applied: $appliedDate'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: getStatusColor(status),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reason:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(application['reason'] ?? '-'),
                                const SizedBox(height: 16),
                                if (status == 'Pending') ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              await firebaseService.updateLeaveStatus(
                                                doc.id, 
                                                'Approved',
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Leave application approved successfully'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error approving application: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.check),
                                          label: const Text('Approve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showRejectionDialog(context, firebaseService, doc.id),
                                          icon: const Icon(Icons.close),
                                          label: const Text('Reject'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Card(
                                    color: getStatusColor(status).withOpacity(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            getStatusIcon(status),
                                            color: getStatusColor(status),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Application ${status.toLowerCase()}',
                                              style: TextStyle(
                                                color: getStatusColor(status),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (status == 'Approved') ...[
                                            IconButton(
                                              icon: const Icon(Icons.picture_as_pdf),
                                              onPressed: () => _exportLeaveApplicationPDF(
                                                context,
                                                firebaseService,
                                                doc.id,
                                                application,
                                              ),
                                              tooltip: 'Export PDF',
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 