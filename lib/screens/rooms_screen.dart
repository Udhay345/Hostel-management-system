import 'package:flutter/material.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../services/attendance_service.dart';
import 'student_list_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Rooms'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.looks_one),
              text: 'Floor 1',
            ),
            Tab(
              icon: Icon(Icons.looks_two),
              text: 'Floor 2',
            ),
            Tab(
              icon: Icon(Icons.looks_3),
              text: 'Floor 3',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFloorView(1),
          _buildFloorView(2),
          _buildFloorView(3),
        ],
      ),
    );
  }

  Widget _buildFloorView(int floor) {
    final startRoom = floor * 100 + 1;
    final endRoom = floor * 100 + 20;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Floor $floor',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppWidgets.spacer(height: 8),
          Text(
            'Rooms ${startRoom.toString().padLeft(3, '0')} - ${endRoom.toString().padLeft(3, '0')}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppWidgets.spacer(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                final roomNumber = (startRoom + index).toString();
                return _buildRoomCard(roomNumber);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String roomNumber) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _navigateToStudentList(roomNumber),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.door_front_door,
                color: AppColors.white,
                size: 24,
              ),
              AppWidgets.spacer(height: 8),
              Text(
                roomNumber,
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppWidgets.spacer(height: 4),
              FutureBuilder<List<Student>>(
                future: _attendanceService.getStudentsByRoom(roomNumber),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final studentCount = snapshot.data!.length;
                    return Text(
                      studentCount == 1 ? '1 Student' : '$studentCount Students',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    );
                  }
                  return Text(
                    'Loading...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStudentList(String roomNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentListScreen(roomNumber: roomNumber),
      ),
    );
  }
}