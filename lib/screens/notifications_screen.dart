import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;
  
  const NotificationsScreen({super.key, required this.userId});

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
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

  Widget _buildLeaveNotification(Map<String, dynamic> notification) {
    final data = notification['data'] ?? {};
    final status = notification['status'] ?? 'Pending';
    final leaveType = data['leaveType'] ?? 'Leave';
    final fromDate = data['fromDate'] ?? 'N/A';
    final toDate = data['toDate'] ?? 'N/A';
    final reason = data['reason'] ?? '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _getStatusColor(status).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _getStatusColor(status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'Leave Update',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification['body'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: $leaveType',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Period: $fromDate to $toDate',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (reason.isNotEmpty)
                    Text(
                      'Admin Note: $reason',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralNotification(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue,
          child: Icon(
            _getNotificationIcon(notification['type'] ?? 'general'),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['body'] ?? ''),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: notification['read'] == true ? Colors.transparent : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: userId.isEmpty
          ? const Center(child: Text('Please log in to view notifications'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firebaseService.getUserNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading notifications: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final notifications = snapshot.data?.docs ?? [];
                
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No notifications yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index].data();
                    final isRead = notification['read'] ?? false;
                    final type = notification['type'] ?? 'general';

                    // Mark as read when tapped
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!isRead) {
                        firebaseService.markNotificationAsRead(notifications[index].id);
                      }
                    });

                    // Build different notification types
                    if (type == 'leave_update') {
                      return _buildLeaveNotification(notification);
                    } else {
                      return _buildGeneralNotification(notification);
                    }
                  },
                );
              },
            ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'leave_update':
        return Icons.calendar_today;
      case 'complaint_update':
        return Icons.report_problem;
      default:
        return Icons.notifications;
    }
  }
} 