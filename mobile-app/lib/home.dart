import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'upload_csv_page.dart';
import 'env_data_page.dart';
import 'chicken_health_page.dart';
import 'env_charts_page.dart';
import 'alerts_page.dar.dart';
import 'profile_settings_page.dart';
import 'real_time_env_page.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  String _userFullName = "Loading...";
  final double cardHeight = 140;
  final double cardWidth = double.infinity;

  @override
  void initState() {
    super.initState();
    _fetchUserFullName();
  }

  Future<void> _fetchUserFullName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (mounted) {
          if (userDoc.exists && userDoc.data() != null) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            setState(() {
              _userFullName =
                  userData['fullName'] ?? currentUser.email ?? "Guest";
            });
          } else {
            setState(() {
              _userFullName = currentUser.email ?? "Guest";
            });
          }
        }
      } catch (e) {
        print("Error fetching user full name: $e");
        if (mounted) {
          setState(() {
            _userFullName = currentUser.email ?? "Guest";
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _userFullName = "Guest";
        });
      }
    }
  }

  Future<void> _refreshUserNameAfterProfileUpdate() async {
    await _fetchUserFullName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Image.asset(
            'assets/chiken4.jpg', // Main background
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.4)), // Dark overlay
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.home, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'aviTech Services',
                          style: GoogleFonts.pacifico(
                            fontSize: 21,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              // This now correctly refers to FarmerProfilePage from 'profile_settings_page.dart'
                              builder: (_) => const FarmerProfilePage(),
                            ),
                          );
                          _refreshUserNameAfterProfileUpdate();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _userFullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      children: [
                        _buildDashboardCard(
                          label: 'Upload CSV',
                          description:
                              'Import CSV files for bulk environmental or health data.',
                          imagePath: 'assets/chiken6.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UploadCSVPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardCard(
                          label: 'Chickens Env Data',
                          description:
                              'Manually enter environmental data like temperature, humidity, etc.',
                          imagePath: 'assets/chiken7.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EnvDataPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardCard(
                          label: 'Real-time Monitoring',
                          description:
                              'Monitor live environmental data and start/stop analysis.',
                          imagePath: 'assets/chiken12.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RealTimeEnvPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardCard(
                          label: 'Check Chicken Health',
                          description:
                              'Get insights about the health status of your chickens.',
                          imagePath: 'assets/chiken8.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChickenHealthPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardCard(
                          label: 'View Env Charts',
                          description:
                              'Visualize historical environmental data with charts.',
                          imagePath: 'assets/chiken9.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EnvChartsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardCard(
                          label: 'View Alerts',
                          description:
                              'Check alerts based on abnormal data or conditions.',
                          imagePath: 'assets/chiken10.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AlertsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardCard(
                          label: 'Profile Settings',
                          description:
                              'Manage your profile and app preferences.',
                          imagePath: 'assets/chiken11.png',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FarmerProfilePage(),
                              ),
                            );
                            _refreshUserNameAfterProfileUpdate();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: const Color.fromARGB(
                    255,
                    114,
                    113,
                    113,
                  ).withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.home, color: Colors.white),
                      Icon(Icons.logout, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String label,
    required String description,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: 90,
                  height: 90,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[700],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 40),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
