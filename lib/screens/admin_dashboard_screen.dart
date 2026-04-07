import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scan_attendance_screen.dart';
import 'view_complaints_screen.dart';
import 'view_leave_applications_screen.dart';
import 'view_outpass_applications_screen.dart';
import 'post_weekly_poll_screen.dart';
import 'rooms_screen.dart';
import 'insights_screen.dart';
import '../services/attendance_service.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const ScanAttendanceScreen(),
    const RoomsScreen(),
    const ViewComplaintsScreen(),
    const ViewLeaveApplicationsScreen(),
    const ViewOutpassApplicationsScreen(),
    const PostWeeklyPollScreen(),
    const InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Warden',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan Attendance'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Rooms'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('View Complaints'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('View Leave Applications'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('View Out Pass Applications'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll),
              title: const Text('Post Weekly Poll'),
              selected: _selectedIndex == 6,
              onTap: () {
                setState(() {
                  _selectedIndex = 6;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Warden Insights'),
              selected: _selectedIndex == 7,
              onTap: () {
                setState(() {
                  _selectedIndex = 7;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  final firebaseService = FirebaseService();
                  await firebaseService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> _attendanceSummary = {};
  Map<String, int> _dashboardMetrics = {
    'pending_complaints': 0,
    'leave_requests': 0,
    'outpass_requests': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final summary = await _attendanceService.getAttendanceSummary();
      final metrics = await _loadDashboardMetrics();
      
      setState(() {
        _attendanceSummary = summary;
        _dashboardMetrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, int>> _loadDashboardMetrics() async {
    try {
      // Get pending complaints count
      final complaintsSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('status', isEqualTo: 'Pending')
          .get();
      
      // Get pending leave applications count
      final leaveSnapshot = await FirebaseFirestore.instance
          .collection('leave_applications')
          .where('status', isEqualTo: 'Pending')
          .get();
      
      // Get pending out pass applications count
      final outpassSnapshot = await FirebaseFirestore.instance
          .collection('outpass_applications')
          .where('status', isEqualTo: 'Pending')
          .get();

      return {
        'pending_complaints': complaintsSnapshot.docs.length,
        'leave_requests': leaveSnapshot.docs.length,
        'outpass_requests': outpassSnapshot.docs.length,
      };
    } catch (e) {
      return {
        'pending_complaints': 0,
        'leave_requests': 0,
        'outpass_requests': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Admin!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 40,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Total Students',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          _isLoading ? '...' : '${_attendanceSummary['total_students'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 40,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Present Today',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          _isLoading ? '...' : '${_attendanceSummary['present_today'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.report_problem,
                          size: 40,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pending Complaints',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${_dashboardMetrics['pending_complaints'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 40,
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Leave Requests',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${_dashboardMetrics['leave_requests'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.exit_to_app,
                          size: 40,
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Out Pass Requests',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${_dashboardMetrics['outpass_requests'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.analytics,
                          size: 40,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Attendance Rate',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          _isLoading ? '...' : '${_attendanceSummary['attendance_percentage'] ?? 0}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to scan attendance
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ScanAttendanceScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Scan Attendance'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to rooms
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RoomsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.meeting_room),
                              label: const Text('View Rooms'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to post poll
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PostWeeklyPollScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentPurple,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.poll),
                              label: const Text('Post Weekly Poll'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to out pass applications
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ViewOutpassApplicationsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.exit_to_app),
                              label: const Text('Out Pass Apps'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _exportAttendancePDF,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.download),
                              label: const Text('Export Attendance'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to insights
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const InsightsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.analytics),
                              label: const Text('View Insights'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAttendancePDF() async {
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

      final firebaseService = FirebaseService();
      final attendanceData = await firebaseService.getAttendanceSummaryForPDF();
      
      if (attendanceData.isEmpty) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No attendance data available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';
      final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

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
                    'RIT HMS — Attendance Report',
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
            
            // Summary Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Attendance Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Total Students', '${attendanceData['totalStudents'] ?? 0}'),
                      _buildSummaryItem('Present Today', '${attendanceData['presentCount'] ?? 0}'),
                      _buildSummaryItem('Absent Today', '${attendanceData['absentCount'] ?? 0}'),
                      _buildSummaryItem('Attendance %', '${attendanceData['attendancePercentage'] ?? '0.0'}%'),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Room-wise Attendance
            pw.Text(
              'Room-wise Attendance Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            
            // Generate room-wise tables
            ..._buildRoomAttendanceTables(attendanceData['roomGroups'] ?? {}),
          ],
        ),
      );

      final bytes = await pdf.save();
      
      // Create file without using path_provider to avoid plugin issues
      final file = XFile.fromData(
        bytes,
        name: 'attendance_report_${now.day}_${now.month}_${now.year}.pdf',
      );
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        await Share.shareXFiles([file], text: 'Attendance Report - RIT HMS');
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildRoomAttendanceTables(Map<String, List<Map<String, dynamic>>> roomGroups) {
    final tables = <pw.Widget>[];
    
    roomGroups.forEach((roomNumber, students) {
      if (students.isNotEmpty) {
        tables.addAll([
          pw.SizedBox(height: 16),
          pw.Text(
            'Room $roomNumber',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Student ID',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Name',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Status',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...students.map((student) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(student['studentId'] ?? 'N/A'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(student['name'] ?? 'N/A'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: student['status'] == 'Present' ? PdfColors.green : PdfColors.red,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        student['status'] ?? 'N/A',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              )).toList(),
            ],
          ),
        ]);
      }
    });
    
    return tables;
  }
} 