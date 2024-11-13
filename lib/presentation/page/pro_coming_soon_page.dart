import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../application/application.dart';
import '../presentation.dart';

@RoutePage()
class ProComingSoonPage extends StatefulWidget {
  const ProComingSoonPage({super.key});

  @override
  State<ProComingSoonPage> createState() => _ProComingSoonPageState();
}

class _ProComingSoonPageState extends State<ProComingSoonPage> {
  bool _buttonPressed = false;

  @override
  void dispose() {
    if (!_buttonPressed) {
      getIt.get<SetProPopupDisplayedUseCase>().execute();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupTemplate(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 23),
          const _ComingSoonLabel(),
          Assets.images.saviePro.image(),
          const SizedBox(height: 4),
          ...<Widget>[
            Text(
              'Savie Pro',
              style: AppTextStyles.title2,
            ),
            const SizedBox(height: 8),
            Text(
              'AI-powered categorization, voice-transcription, context-aware search and more',
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () {
                _buttonPressed = true;
                getIt.get<NotifyAboutProUseCase>().execute();
                context.router.maybePop();
              },
              child: const Text('Notify me'),
            ),
            const SizedBox(height: 32),
          ].map(
            (Widget w) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: w,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonLabel extends StatelessWidget {
  const _ComingSoonLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: AppColors.accentTint,
      ),
      child: Text(
        'coming soon',
        style: AppTextStyles.description.copyWith(
          color: AppColors.iconAccent,
        ),
      ),
    );
  }
}
