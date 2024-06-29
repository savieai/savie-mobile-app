import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../application/application.dart';
import '../../presentation.dart';
import '../../router/app_router.gr.dart';

@RoutePage()
class OnboardingdPage extends StatelessWidget {
  const OnboardingdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 64),
            Text(
              'Savie',
              style: AppTextStyles.title1.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Unload your brain.\nChat with yourself.',
              style: AppTextStyles.paragraph.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Assets.images.voiceMemo.image(),
              ),
            ),
            // TODO: create custom button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(20),
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await getIt.get<CompleteOnboardingUseCase>().execute();
                  if (context.mounted) {
                    context.router.push(const ChatRoute());
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.strokeSecondaryAlpha,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.paragraph.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
