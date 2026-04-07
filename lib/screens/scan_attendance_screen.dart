import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../services/attendance_service.dart';
import '../services/firebase_service.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  MobileScannerController? controller;
  bool _isScanning = false;
  String _lastScannedId = '';
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppWidgets.heading('Scan Attendance'),
          AppWidgets.spacer(height: 24),
          
          // Scanner Card
          AppWidgets.customCard(
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: AppColors.primaryBlue,
                ),
                AppWidgets.spacer(height: 16),
                Text(
                  'QR Code Scanner',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                ),
                AppWidgets.spacer(height: 8),
                Text(
                  'Point camera at student QR code',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                AppWidgets.spacer(height: 24),
                
                // QR Scanner Widget
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isScanning 
                        ? Stack(
                            children: [
                              MobileScanner(
                                controller: controller,
                                onDetect: _onQRCodeDetected,
                              ),
                              // Custom overlay
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.primaryOrange,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code,
                                  size: 100,
                                  color: AppColors.primaryBlue,
                                ),
                                AppWidgets.spacer(height: 16),
                                Text(
                                  'Tap to start scanning',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                AppWidgets.spacer(height: 24),
                
                // Scan Button
                SizedBox(
                  width: double.infinity,
                  child: AppWidgets.customButton(
                    text: _isScanning ? 'Stop Scanning' : 'Start Scanning',
                    onPressed: _toggleScanning,
                    icon: Icon(
                      _isScanning ? Icons.stop : Icons.qr_code_scanner, 
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          AppWidgets.spacer(height: 24),
          
          // Last Scanned Result
          if (_lastScannedId.isNotEmpty) ...[
            AppWidgets.statusCard(
              title: 'Last Scanned',
              message: 'Register Number: $_lastScannedId',
              statusColor: AppColors.success,
              icon: Icons.person,
            ),
            AppWidgets.spacer(height: 16),
          ],
          
          // Instructions Card
          AppWidgets.customCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: AppTextStyles.h6.copyWith(color: AppColors.primaryOrange),
                ),
                AppWidgets.spacer(height: 8),
                AppWidgets.customText('• Only QR codes with exactly 13 digits starting with "2117" are valid'),
                AppWidgets.customText('• Example: 2117100001001 (Arjun Sharma, Room 101)'),
                AppWidgets.customText('• Ensure good lighting for scanning'),
                AppWidgets.customText('• Hold device steady'),
                AppWidgets.customText('• Position QR code within frame'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processQRCode(barcodes.first.rawValue!);
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    if (!_attendanceService.isValidRITQR(qrCode)) {
      _showErrorDialog('Invalid QR code format. Must be 13 digits starting with "2117"');
      return;
    }

    final student = await _attendanceService.findStudentByQR(qrCode);
    if (student == null) {
      _showErrorDialog('Student not found in records');
      return;
    }

    // Check if already marked present today
    if (_attendanceService.isStudentPresentToday(student.studentId)) {
      _showInfoDialog('Attendance already marked for ${student.name} today');
      return;
    }

    try {
      // Mark attendance in local service
      _attendanceService.markAttendance(student.studentId);
      
      // Also save to Firebase for admin export
      final firebaseService = FirebaseService();
      await firebaseService.markStudentAttendance(student.studentId, isPresent: true);
      
      setState(() {
        _lastScannedId = student.studentId;
        _isScanning = false;
      });

      await controller?.stop();
      _showSuccessDialog(student.name, student.studentId);
    } catch (e) {
      _showErrorDialog('Failed to save attendance: $e');
    }
  }

  Future<void> _toggleScanning() async {
    if (_isScanning) {
      setState(() {
        _isScanning = false;
      });
      await controller?.stop();
    } else {
      // Request camera permission
      final permission = await Permission.camera.request();
      if (permission.isGranted) {
        setState(() {
          _isScanning = true;
        });
        await controller?.start();
      } else {
        _showErrorDialog('Camera permission is required to scan QR codes');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: AppColors.error),
              const SizedBox(width: 8),
              const Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String studentName, String registerNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              const Text('Success', style: TextStyle(color: AppColors.success)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $studentName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Register Number: $registerNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.done, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Attendance Marked Present',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: AppColors.success)),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info, color: AppColors.info),
              const SizedBox(width: 8),
              const Text('Information'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}