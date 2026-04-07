import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/attendance_service.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  Map<String, dynamic> _attendanceSummary = {};
  List<Floor> _floors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsightsData();
  }

  Future<void> _loadInsightsData() async {
    try {
      final summary = await _attendanceService.getAttendanceSummary();
      final hostelData = await _attendanceService.loadHostelData();
      
      if (mounted) {
        setState(() {
          _attendanceSummary = summary;
          _floors = hostelData.floors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportPDF() async {
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



  Map<String, int> _getFloorData(Floor floor) {
    int present = 0;
    int absent = 0;

    for (final room in floor.rooms) {
      for (final student in room.students) {
        if (_attendanceService.isStudentPresentToday(student.studentId)) {
          present++;
        } else {
          absent++;
        }
      }
    }

    return {'present': present, 'absent': absent};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Insights'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPDF,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Students',
                          _attendanceSummary['total_students']?.toString() ?? '0',
                          AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Present Today',
                          _attendanceSummary['present_today']?.toString() ?? '0',
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Absent Today',
                          _attendanceSummary['absent_today']?.toString() ?? '0',
                          AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Attendance %',
                          '${_attendanceSummary['attendance_percentage'] ?? '0.0'}%',
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Per-floor breakdown
                  const Text(
                    'Per-Floor Breakdown',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._floors.map((floor) => _buildFloorCard(floor)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorCard(Floor floor) {
    final floorData = _getFloorData(floor);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          'Floor ${floor.floor} — Present: ${floorData['present']} | Absent: ${floorData['absent']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          ...floor.rooms.map((room) => _buildRoomCard(room)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text('Room ${room.roomNumber}'),
        children: [
          ...room.students.map((student) {
            final isPresent = _attendanceService.isStudentPresentToday(student.studentId);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isPresent ? AppColors.success : AppColors.error,
                child: Icon(
                  isPresent ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: Text(student.name),
              subtitle: Text('ID: ${student.studentId}'),
              trailing: Chip(
                label: Text(
                  isPresent ? 'Present' : 'Absent',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: isPresent ? AppColors.success : AppColors.error,
              ),
            );
          }),
        ],
      ),
    );
  }
} 