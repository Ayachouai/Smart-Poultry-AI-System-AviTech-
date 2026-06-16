import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> alerts = [
      {
        'type': 'Account',
        'message': 'You have successfully created a new farmer account.',
        'icon': Icons.person,
        'color': Colors.white.withOpacity(0.2),
      },
      {
        'type': 'Temperature',
        'message':
            'Alert: Ambient temperature exceeds the established normative range.',
        'icon': Icons.thermostat,
        'color': Colors.red.withOpacity(0.2),
      },
      {
        'type': 'Humidity',
        'message': 'Relative humidity is below the recommended threshold.',
        'icon': Icons.water_drop,
        'color': const Color.fromARGB(255, 106, 127, 219),
      },
      {
        'type': 'CO2',
        'message':
            'Carbon dioxide (CO₂) concentration surpasses the permissible limit.',
        'icon': Icons.cloud,
        'color': const Color.fromARGB(255, 43, 51, 58).withOpacity(0.2),
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Image.asset(
            'assets/chiken4.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar simulée avec bouton Home
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Bouton Home fonctionnel
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FarmerDashboard(),
                            ),
                          );
                        },
                        child: const Icon(Icons.home, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Stay updated',
                        style: GoogleFonts.pacifico(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Notifications list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: alert['color'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(alert['icon'], color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                alert['message'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
