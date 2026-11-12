import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/conditional_hero.dart';

class AppSettingsCategory {
  final String name;
  final IconData icon;
  final String path;
  final String? heroKey;
  final bool Function()? available;

  AppSettingsCategory(this.name, this.icon, this.path, { this.heroKey, this.available });

  bool isAvailable() => available == null || available!();
}

class SettingsCategoryGrid extends StatelessWidget {

  final List<AppSettingsCategory> categories;

  const SettingsCategoryGrid ({ super.key, required this.categories });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              GoRouter.of(context).push(category.path);
            },
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ConditionalHero(
                        tag: category.heroKey == null ? null : "${category.heroKey}-icon",
                        child: Icon(category.icon, size: 32)
                      )
                    ),
                    ConditionalHero(
                      tag: category.heroKey == null ? null : "${category.heroKey}-title",
                      flightShuttleBuilder: textHeroFlightShuttleBuilder,
                      child: Text(category.name, textAlign: TextAlign.center)
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
