import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ViewComplaintsScreen extends StatelessWidget {
  const ViewComplaintsScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
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

  Widget _statCard(String title, String value, Color color, {IconData? icon}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (icon != null) Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(title),
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

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'View Complaints',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firebaseService.complaintsStream(),
            builder: (context, snapshot) {
              final total = snapshot.data?.docs.length ?? 0;
              final pending = snapshot.data?.docs
                      .where((d) => (d.data()['status'] ?? 'Pending') == 'Pending')
                      .length ??
                  0;
              return Row(
                children: [
                  _statCard('Total Complaints', total.toString(), Colors.orange, icon: Icons.report_problem),
                  const SizedBox(width: 16),
                  _statCard('Pending', pending.toString(), Colors.blue, icon: Icons.pending),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firebaseService.complaintsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load complaints'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No complaints yet'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final complaint = doc.data();
                    final String status = complaint['status'] ?? 'Pending';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: getStatusColor(status),
                          child: Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          complaint['subject'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: ${complaint['student'] ?? '-'}'),
                            Text('Type: ${complaint['type'] ?? '-'}'),
                            Text('Date: ${_formatDate(complaint['date'])}'),
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
                                  'Description:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(complaint['description'] ?? '-'),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => firebaseService.updateComplaintStatus(doc.id, 'Resolved'),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Mark Resolved'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Handle contact student
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Contacting student...'),
                                            backgroundColor: Colors.blue,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.phone),
                                      label: const Text('Contact'),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 