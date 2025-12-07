import 'package:flutter/material.dart';
import '../../app/theme/theme_controller.dart';

class ThemeModeSelector extends StatelessWidget {
	const ThemeModeSelector({super.key});

	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder<ThemeMode>(
			valueListenable: ThemeController.instance.mode,
			builder: (context, mode, _) {
				return Wrap(
					spacing: 8,
					runSpacing: 8,
					children: [
						_chip(
							context,
							label: 'Sistema',
							icon: Icons.phone_android,
							selected: mode == ThemeMode.system,
							onTap: () => ThemeController.instance.set(ThemeMode.system),
						),
						_chip(
							context,
							label: 'Claro',
							icon: Icons.light_mode,
							selected: mode == ThemeMode.light,
							onTap: () => ThemeController.instance.set(ThemeMode.light),
						),
						_chip(
							context,
							label: 'Oscuro',
							icon: Icons.dark_mode,
							selected: mode == ThemeMode.dark,
							onTap: () => ThemeController.instance.set(ThemeMode.dark),
						),
					],
				);
			},
		);
	}

	Widget _chip(BuildContext context, {required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
		final cs = Theme.of(context).colorScheme;
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(12),
			child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
				decoration: BoxDecoration(
					color: selected ? cs.primary : Colors.transparent,
					borderRadius: BorderRadius.circular(12),
					border: Border.all(color: cs.primary),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(icon, size: 16, color: selected ? cs.onPrimary : cs.primary),
						const SizedBox(width: 6),
						Text(
							label,
							style: TextStyle(
								color: selected ? cs.onPrimary : cs.primary,
								fontWeight: FontWeight.w600,
							),
						),
					],
				),
			),
		);
	}
}

