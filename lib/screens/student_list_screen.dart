import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../services/attendance_service.dart';

class StudentListScreen extends StatefulWidget {
  final String roomNumber;

  const StudentListScreen({
    super.key,
    required this.roomNumber,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _attendanceService.getStudentsByRoom(widget.roomNumber);
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading students: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.roomNumber}'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStudents();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : _students.isEmpty
              ? _buildEmptyState()
              : _buildStudentList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textMuted,
          ),
          AppWidgets.spacer(height: 16),
          Text(
            'No Students Found',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppWidgets.spacer(height: 8),
          Text(
            'This room currently has no assigned students.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header
          AppWidgets.customCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.door_front_door,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room ${widget.roomNumber}',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppWidgets.spacer(height: 4),
                      Text(
                        '${_students.length} ${_students.length == 1 ? 'Student' : 'Students'} Assigned',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppWidgets.spacer(height: 24),
          
          // Students List Header
          Text(
            'Students',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppWidgets.spacer(height: 16),
          
          // Students List
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return _buildStudentCard(student, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student, int index) {
    final isPresent = _attendanceService.isStudentPresentToday(student.studentId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPresent 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Student Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          student.name.split(' ').map((n) => n[0]).join('').toUpperCase(),
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Student Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: AppTextStyles.h6.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppWidgets.spacer(height: 4),
                          Text(
                            'Register No: ${student.studentId}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Attendance Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPresent 
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPresent ? Icons.check_circle : Icons.schedule,
                            size: 16,
                            color: isPresent ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPresent ? 'Present' : 'Absent',
                            style: AppTextStyles.caption.copyWith(
                              color: isPresent ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppWidgets.spacer(height: 16),
                
                // QR Code Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                                                const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register Number:',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppWidgets.spacer(height: 2),
                            Text(
                              student.studentId,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontFamily: 'monospace',
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyToClipboard(student.studentId),
                        icon: const Icon(
                          Icons.copy,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        tooltip: 'Copy Register Number',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Register Number copied to clipboard: $text'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}