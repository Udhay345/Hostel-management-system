import 'dart:convert';
import 'package:flutter/services.dart';

class Student {
  final String studentId;
  final String name;
  final String roomNumber;
  final String idCardQr;

  Student({
    required this.studentId,
    required this.name,
    required this.roomNumber,
    required this.idCardQr,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'],
      name: json['name'],
      roomNumber: json['room_number'],
      idCardQr: json['id_card_qr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'room_number': roomNumber,
      'id_card_qr': idCardQr,
    };
  }
}

class Room {
  final String roomNumber;
  final List<Student> students;

  Room({
    required this.roomNumber,
    required this.students,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomNumber: json['room_number'],
      students: (json['students'] as List)
          .map((student) => Student.fromJson(student))
          .toList(),
    );
  }
}

class Floor {
  final int floor;
  final List<Room> rooms;

  Floor({
    required this.floor,
    required this.rooms,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      floor: json['floor'],
      rooms: (json['rooms'] as List)
          .map((room) => Room.fromJson(room))
          .toList(),
    );
  }
}

class HostelData {
  final List<Floor> floors;

  HostelData({required this.floors});

  factory HostelData.fromJson(Map<String, dynamic> json) {
    return HostelData(
      floors: (json['floors'] as List)
          .map((floor) => Floor.fromJson(floor))
          .toList(),
    );
  }
}

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  // In-memory attendance storage
  final Map<String, DateTime> _attendanceRecords = {};
  HostelData? _hostelData;

  // Get attendance records
  Map<String, DateTime> get attendanceRecords => Map.unmodifiable(_attendanceRecords);

  // Load hostel data from JSON file
  Future<HostelData> loadHostelData() async {
    if (_hostelData != null) return _hostelData!;

    try {
      final String response = await rootBundle.loadString('assets/data/hostel_students_dummy.json');
      final Map<String, dynamic> data = json.decode(response);
      _hostelData = HostelData.fromJson(data);
      return _hostelData!;
    } catch (e) {
      throw Exception('Failed to load hostel data: $e');
    }
  }

  // Get all students
  Future<List<Student>> getAllStudents() async {
    final hostelData = await loadHostelData();
    List<Student> allStudents = [];
    
    for (final floor in hostelData.floors) {
      for (final room in floor.rooms) {
        allStudents.addAll(room.students);
      }
    }
    
    return allStudents;
  }

  // Find student by register number (QR code matches student ID or id_card_qr)
  Future<Student?> findStudentByQR(String qrCode) async {
    final students = await getAllStudents();
    
    try {
      // First try to match by student_id
      return students.firstWhere((student) => student.studentId == qrCode);
    } catch (e) {
      try {
        // Then try to match by id_card_qr field
        return students.firstWhere((student) => student.idCardQr == qrCode);
      } catch (e) {
        return null;
      }
    }
  }

  // Mark attendance
  bool markAttendance(String studentId) {
    if (studentId.isEmpty) return false;
    
    _attendanceRecords[studentId] = DateTime.now();
    return true;
  }

  // Check if student is present today
  bool isStudentPresentToday(String studentId) {
    final attendanceDate = _attendanceRecords[studentId];
    if (attendanceDate == null) return false;
    
    final today = DateTime.now();
    return attendanceDate.year == today.year &&
           attendanceDate.month == today.month &&
           attendanceDate.day == today.day;
  }

  // Get present students count for today
  int getPresentStudentsCount() {
    final today = DateTime.now();
    return _attendanceRecords.values.where((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day
    ).length;
  }

  // Get students by room
  Future<List<Student>> getStudentsByRoom(String roomNumber) async {
    final hostelData = await loadHostelData();
    
    for (final floor in hostelData.floors) {
      for (final room in floor.rooms) {
        if (room.roomNumber == roomNumber) {
          return room.students;
        }
      }
    }
    
    return [];
  }

  // Get room by number
  Future<Room?> getRoomByNumber(String roomNumber) async {
    final hostelData = await loadHostelData();
    
    for (final floor in hostelData.floors) {
      for (final room in floor.rooms) {
        if (room.roomNumber == roomNumber) {
          return room;
        }
      }
    }
    
    return null;
  }

  // Validate QR code format - must be exactly 13 digits starting with "2117"
  bool isValidRITQR(String qrCode) {
    // Check if QR code has exactly 13 digits and starts with '2117'
    if (qrCode.length != 13) return false;
    if (!qrCode.startsWith('2117')) return false;
    
    // Check if all characters are digits
    for (int i = 0; i < qrCode.length; i++) {
      if (!RegExp(r'[0-9]').hasMatch(qrCode[i])) {
        return false;
      }
    }
    
    return true;
  }

  // Clear attendance records (for testing)
  void clearAttendanceRecords() {
    _attendanceRecords.clear();
  }

  // Get attendance summary
  Future<Map<String, dynamic>> getAttendanceSummary() async {
    final allStudents = await getAllStudents();
    final totalStudents = allStudents.length;
    final presentCount = getPresentStudentsCount();
    
    return {
      'total_students': totalStudents,
      'present_today': presentCount,
      'absent_today': totalStudents - presentCount,
      'attendance_percentage': totalStudents > 0 
          ? (presentCount / totalStudents * 100).toStringAsFixed(1)
          : '0.0',
    };
  }
}