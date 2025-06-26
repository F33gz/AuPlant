import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantCard extends StatelessWidget {
  final String plantName;
  final String emoji;
  final String humidity;
  final String light;
  final String lastWatered;
  final bool isOnline;

  const PlantCard({
    super.key,
    required this.plantName,
    required this.emoji,
    required this.humidity,
    required this.light,
    required this.lastWatered,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x14000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7CB342), Color(0xFF4A7C59)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Humedad: $humidity',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Luz: $light',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          lastWatered,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          isOnline ? 'En línea' : 'Sin conexión',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isOnline
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
