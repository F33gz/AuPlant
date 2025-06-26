import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plant_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '🌱 Mis Plantas',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A27),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                // Add plant action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Agregar Planta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Monitorea y cuida tus plantas con AuPlant IoT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    PlantCard(
                      plantName: 'Violeta Africana',
                      emoji: '🌸',
                      humidity: '78%',
                      light: '85 lx',
                      lastWatered: 'Regada hace 2h',
                      isOnline: true,
                    ),
                    PlantCard(
                      plantName: 'Cactus del Desierto',
                      emoji: '🌵',
                      humidity: '45%',
                      light: '92 lx',
                      lastWatered: 'Regada hace 5 días',
                      isOnline: true,
                    ),
                    PlantCard(
                      plantName: 'Albahaca',
                      emoji: '🌿',
                      humidity: '22%',
                      light: '34 lx',
                      lastWatered: 'Regada hace 1 día',
                      isOnline: false,
                    ),
                    PlantCard(
                      plantName: 'Ficus Benjamina',
                      emoji: '🌳',
                      humidity: '82%',
                      light: '88 lx',
                      lastWatered: 'Regada hace 5 días',
                      isOnline: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
