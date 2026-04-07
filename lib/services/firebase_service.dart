import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up for students
  Future<UserCredential?> signUpStudent({
    required String email,
    required String password,
    required String name,
    required String roomNumber,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('students').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'roomNumber': roomNumber,
        'userType': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'attendance': {
          'present': 0,
          'absent': 0,
        },
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ===== Student Requests (Leave / Complaint) =====

  /// Submit a leave application to Firestore
  Future<void> submitLeaveApplication({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // Fetch student profile to enrich the record
    final studentDoc = await _firestore.collection('students').doc(user.uid).get();
    final studentData = studentDoc.data() ?? {};

    await _firestore.collection('leave_applications').add({
      'studentUid': user.uid,
      'student': studentData['name'] ?? user.email ?? 'Unknown',
      'room': studentData['roomNumber'] ?? '-',
      'type': leaveType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'status': 'Pending',
      'appliedDate': FieldValue.serverTimestamp(),
    });
  }

  /// Submit a complaint to Firestore
  Future<void> submitComplaint({
    required String complaintType,
    required String subject,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // Fetch student profile
    final studentDoc = await _firestore.collection('students').doc(user.uid).get();
    final studentData = studentDoc.data() ?? {};

    await _firestore.collection('complaints').add({
      'studentUid': user.uid,
      'student': studentData['name'] ?? user.email ?? 'Unknown',
      'type': complaintType,
      'subject': subject,
      'description': description,
      'status': 'Pending',
      'date': FieldValue.serverTimestamp(),
      'room': studentData['roomNumber'] ?? '-',
    });
  }

  /// Stream leave applications (for admins)
  Stream<QuerySnapshot<Map<String, dynamic>>> leaveApplicationsStream() {
    return _firestore
        .collection('leave_applications')
        .orderBy('appliedDate', descending: true)
        .snapshots();
  }

  /// Stream complaints (for admins)
  Stream<QuerySnapshot<Map<String, dynamic>>> complaintsStream() {
    return _firestore
        .collection('complaints')
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Update leave application status
  Future<void> updateLeaveStatus(String documentId, String status, {String? reason}) async {
    try {
      // Get the leave application data first
      final leaveDoc = await _firestore.collection('leave_applications').doc(documentId).get();
      if (!leaveDoc.exists) {
        throw Exception('Leave application not found');
      }

      final leaveData = leaveDoc.data()!;
      final studentUid = leaveData['studentUid'] as String;
      final studentName = leaveData['student'] as String? ?? 'Unknown';
      final startDate = leaveData['startDate'] as Timestamp?;
      final endDate = leaveData['endDate'] as Timestamp?;
      final leaveType = leaveData['type'] as String? ?? 'Leave';

      // Update the leave application status
      await _firestore.collection('leave_applications').doc(documentId).update({
        'status': status,
        'processedDate': FieldValue.serverTimestamp(),
        'processedBy': _auth.currentUser?.uid,
        'reason': reason ?? '',
      });

      // Create notification for the student
      await _createLeaveNotification(
        studentUid: studentUid,
        studentName: studentName,
        status: status,
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveType,
        reason: reason,
      );

      // Create audit log entry
      await _createAuditLog(
        action: 'leave_${status.toLowerCase()}',
        targetUserId: studentUid,
        details: {
          'leaveId': documentId,
          'studentName': studentName,
          'status': status,
          'reason': reason ?? '',
        },
      );
    } catch (e) {
      throw Exception('Failed to update leave status: $e');
    }
  }

  /// Create notification for leave application update
  Future<void> _createLeaveNotification({
    required String studentUid,
    required String studentName,
    required String status,
    required Timestamp? startDate,
    required Timestamp? endDate,
    required String leaveType,
    String? reason,
  }) async {
    final fromDate = startDate?.toDate();
    final toDate = endDate?.toDate();
    
    final fromDateStr = fromDate != null 
        ? '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}'
        : 'N/A';
    final toDateStr = toDate != null 
        ? '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}'
        : 'N/A';

    final title = 'Leave request — ${status == 'Approved' ? 'Accepted' : 'Rejected'}';
    final body = 'Your $leaveType from $fromDateStr to $toDateStr has been ${status.toLowerCase()}.${reason != null && reason.isNotEmpty ? ' Reason: $reason' : ''}';

    // Store notification in Firestore
    await _firestore.collection('notifications').add({
      'userId': studentUid,
      'title': title,
      'body': body,
      'type': 'leave_update',
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'data': {
        'leaveType': leaveType,
        'fromDate': fromDateStr,
        'toDate': toDateStr,
        'reason': reason ?? '',
      },
    });

    // TODO: Send push notification if FCM is configured
    // await _sendPushNotification(studentUid, title, body);
  }

  /// Create audit log entry
  Future<void> _createAuditLog({
    required String action,
    required String targetUserId,
    required Map<String, dynamic> details,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('audit_logs').add({
      'action': action,
      'performedBy': currentUser.uid,
      'targetUserId': targetUserId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Create required Firebase indexes for the application
  Future<void> createRequiredIndexes() async {
    try {
      // This method can be called to ensure required indexes exist
      // Note: Firebase indexes are typically created automatically when queries are first run
      // This is just a placeholder for future index management
      print('Firebase indexes will be created automatically when needed');
    } catch (e) {
      print('Error creating indexes: $e');
    }
  }

  /// Get leave application data for PDF generation
  Future<Map<String, dynamic>?> getLeaveApplicationForPDF(String documentId) async {
    try {
      final leaveDoc = await _firestore.collection('leave_applications').doc(documentId).get();
      if (!leaveDoc.exists) {
        return null;
      }

      final leaveData = leaveDoc.data()!;
      
      // Get student details
      final studentDoc = await _firestore.collection('students').doc(leaveData['studentUid']).get();
      final studentData = studentDoc.data() ?? {};

      return {
        'leaveData': leaveData,
        'studentData': studentData,
      };
    } catch (e) {
      print('Error getting leave application for PDF: $e');
      return null;
    }
  }

  /// Get all leave applications for a specific student
  Future<List<Map<String, dynamic>>> getStudentLeaveApplications(String studentUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('leave_applications')
          .where('studentUid', isEqualTo: studentUid)
          .orderBy('appliedDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting student leave applications: $e');
      return [];
    }
  }

  /// Get notifications for a user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  /// Update complaint status
  Future<void> updateComplaintStatus(String documentId, String status) async {
    await _firestore
        .collection('complaints')
        .doc(documentId)
        .update({'status': status});
  }

  // ===== Out Pass Methods =====

  /// Submit an out pass application to Firestore
  Future<void> submitOutpassApplication({
    required String outpassType,
    required DateTime outDate,
    required TimeOfDay outTime,
    required TimeOfDay returnTime,
    required String destination,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // Fetch student profile to enrich the record
    final studentDoc = await _firestore.collection('students').doc(user.uid).get();
    final studentData = studentDoc.data() ?? {};

    // Create DateTime objects for out and return times
    final outDateTime = DateTime(
      outDate.year,
      outDate.month,
      outDate.day,
      outTime.hour,
      outTime.minute,
    );
    final returnDateTime = DateTime(
      outDate.year,
      outDate.month,
      outDate.day,
      returnTime.hour,
      returnTime.minute,
    );

    await _firestore.collection('outpass_applications').add({
      'studentUid': user.uid,
      'student': studentData['name'] ?? user.email ?? 'Unknown',
      'room': studentData['roomNumber'] ?? '-',
      'type': outpassType,
      'outDate': Timestamp.fromDate(outDate),
      'outTime': Timestamp.fromDate(outDateTime),
      'returnTime': Timestamp.fromDate(returnDateTime),
      'destination': destination,
      'reason': reason,
      'status': 'Pending',
      'appliedDate': FieldValue.serverTimestamp(),
    });
  }

  /// Stream out pass applications (for admins)
  Stream<QuerySnapshot<Map<String, dynamic>>> outpassApplicationsStream() {
    return _firestore
        .collection('outpass_applications')
        .orderBy('appliedDate', descending: true)
        .snapshots();
  }

  /// Stream out pass applications for current student
  Stream<QuerySnapshot<Map<String, dynamic>>> studentOutpassApplicationsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('outpass_applications')
        .where('studentUid', isEqualTo: user.uid)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .handleError((error) {
          // Handle Firebase index errors gracefully
          if (error.toString().contains('failed-precondition') && 
              error.toString().contains('index')) {
            // Return empty stream if index is not ready
            return Stream.empty();
          }
          throw error;
        });
  }

  /// Update out pass application status
  Future<void> updateOutpassStatus(String documentId, String status, {String? reason}) async {
    try {
      // Get the out pass application data first
      final outpassDoc = await _firestore.collection('outpass_applications').doc(documentId).get();
      if (!outpassDoc.exists) {
        throw Exception('Out pass application not found');
      }

      final outpassData = outpassDoc.data()!;
      final studentUid = outpassData['studentUid'] as String;
      final studentName = outpassData['student'] as String? ?? 'Unknown';
      final outDate = outpassData['outDate'] as Timestamp?;
      final outTime = outpassData['outTime'] as Timestamp?;
      final returnTime = outpassData['returnTime'] as Timestamp?;
      final outpassType = outpassData['type'] as String? ?? 'Out Pass';

      // Update the out pass application status
      await _firestore.collection('outpass_applications').doc(documentId).update({
        'status': status,
        'processedDate': FieldValue.serverTimestamp(),
        'processedBy': _auth.currentUser?.uid,
        'reason': reason ?? '',
      });

      // Create notification for the student
      await _createOutpassNotification(
        studentUid: studentUid,
        studentName: studentName,
        status: status,
        outDate: outDate,
        outTime: outTime,
        returnTime: returnTime,
        outpassType: outpassType,
        reason: reason,
      );

      // Create audit log entry
      await _createAuditLog(
        action: 'outpass_${status.toLowerCase()}',
        targetUserId: studentUid,
        details: {
          'outpassId': documentId,
          'studentName': studentName,
          'status': status,
          'reason': reason ?? '',
        },
      );
    } catch (e) {
      throw Exception('Failed to update out pass status: $e');
    }
  }

  /// Create notification for out pass application update
  Future<void> _createOutpassNotification({
    required String studentUid,
    required String studentName,
    required String status,
    required Timestamp? outDate,
    required Timestamp? outTime,
    required Timestamp? returnTime,
    required String outpassType,
    String? reason,
  }) async {
    final date = outDate?.toDate();
    final outTimeDate = outTime?.toDate();
    final returnTimeDate = returnTime?.toDate();
    
    final dateStr = date != null 
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : 'N/A';
    final outTimeStr = outTimeDate != null 
        ? '${outTimeDate.hour.toString().padLeft(2, '0')}:${outTimeDate.minute.toString().padLeft(2, '0')}'
        : 'N/A';
    final returnTimeStr = returnTimeDate != null 
        ? '${returnTimeDate.hour.toString().padLeft(2, '0')}:${returnTimeDate.minute.toString().padLeft(2, '0')}'
        : 'N/A';

    final title = 'Out pass request — ${status == 'Approved' ? 'Accepted' : 'Rejected'}';
    final body = 'Your $outpassType on $dateStr from $outTimeStr to $returnTimeStr has been ${status.toLowerCase()}.${reason != null && reason.isNotEmpty ? ' Reason: $reason' : ''}';

    // Store notification in Firestore
    await _firestore.collection('notifications').add({
      'userId': studentUid,
      'title': title,
      'body': body,
      'type': 'outpass_update',
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'data': {
        'outpassType': outpassType,
        'date': dateStr,
        'outTime': outTimeStr,
        'returnTime': returnTimeStr,
        'reason': reason ?? '',
      },
    });
  }

  // Sign up for admins
  Future<UserCredential?> signUpAdmin({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'userType': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid, String userType) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(userType).doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, String userType, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(userType).doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Check if user is student
  Future<bool> isStudent(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('students').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get attendance summary for PDF export
  Future<Map<String, dynamic>> getAttendanceSummaryForPDF() async {
    try {
      // Get all students
      final studentsQuery = await _firestore.collection('students').get();
      final students = studentsQuery.docs;
      
      // Get today's attendance records
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final attendanceQuery = await _firestore
          .collection('attendance_records')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('date', isLessThan: Timestamp.fromDate(todayEnd))
          .get();
      
      final presentStudentIds = attendanceQuery.docs
          .map((doc) => doc.data()['studentUid'] as String)
          .toSet();
      
      final attendanceData = students.map((studentDoc) {
        final studentData = studentDoc.data();
        final studentId = studentDoc.id;
        final isPresent = presentStudentIds.contains(studentId);
        
        return {
          'studentId': studentId,
          'name': studentData['name'] ?? 'Unknown',
          'roomNumber': studentData['roomNumber'] ?? '-',
          'status': isPresent ? 'Present' : 'Absent',
          'timestamp': isPresent ? studentData['lastAttendance'] : null,
        };
      }).toList();
      
      // Group by room
      final roomGroups = <String, List<Map<String, dynamic>>>{};
      for (final student in attendanceData) {
        final room = student['roomNumber'] as String;
        roomGroups.putIfAbsent(room, () => []).add(student);
      }
      
      return {
        'date': today,
        'totalStudents': students.length,
        'presentCount': presentStudentIds.length,
        'absentCount': students.length - presentStudentIds.length,
        'attendancePercentage': students.isNotEmpty 
            ? (presentStudentIds.length / students.length * 100).toStringAsFixed(1)
            : '0.0',
        'roomGroups': roomGroups,
        'attendanceData': attendanceData,
      };
    } catch (e) {
      print('Error getting attendance summary for PDF: $e');
      return {};
    }
  }

  /// Get all attendance records for a specific date range
  Future<List<Map<String, dynamic>>> getAttendanceRecordsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate.add(const Duration(days: 1)));
      
      final querySnapshot = await _firestore
          .collection('attendance_records')
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThan: endTimestamp)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting attendance records for date range: $e');
      return [];
    }
  }

  /// Mark student attendance
  Future<void> markStudentAttendance(String studentUid, {bool isPresent = true}) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Check if attendance already exists for today
      final existingQuery = await _firestore
          .collection('attendance_records')
          .where('studentUid', isEqualTo: studentUid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('date', isLessThan: Timestamp.fromDate(todayStart.add(const Duration(days: 1))))
          .get();
      
      if (existingQuery.docs.isNotEmpty) {
        // Update existing record
        await existingQuery.docs.first.reference.update({
          'isPresent': isPresent,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new record
        await _firestore.collection('attendance_records').add({
          'studentUid': studentUid,
          'date': Timestamp.fromDate(todayStart),
          'isPresent': isPresent,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Update student's last attendance
      await _firestore.collection('students').doc(studentUid).update({
        'lastAttendance': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'firebase-not-initialized':
        return 'Firebase not initialized. Please restart the app.';
      default:
        return 'Login failed: ${e.message ?? 'An error occurred. Please try again.'}';
    }
  }
} 