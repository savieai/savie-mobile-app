import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/application.dart';
import '../../presentation.dart';
import 'get_invite_cubit.dart';

@RoutePage()
class GetInvitePage extends StatefulWidget {
  const GetInvitePage({super.key});

  @override
  State<GetInvitePage> createState() => _GetInvitePageState();
}

class _GetInvitePageState extends State<GetInvitePage> {
  @override
  void initState() {
    super.initState();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.popupScreenEvents.screenOpened);
  }

  @override
  void dispose() {
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.popupScreenEvents.screenClosed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GetInviteCubit>(
      create: (_) => getIt.get<GetInviteCubit>(),
      child: PopupTemplate(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 44),
              const _GiftWidget(),
              const SizedBox(height: 20),
              Text(
                'Gift Savie',
                style: AppTextStyles.title2,
              ),
              const _InviteInfoBody(),
              const SizedBox(height: 24),
              const _ShareButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteInfoBody extends StatelessWidget {
  const _InviteInfoBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetInviteCubit, GetInviteState>(
      builder: (BuildContext context, GetInviteState state) {
        return AnimatedOpacity(
          opacity: state.maybeMap(fetched: (_) => 1, orElse: () => 0),
          duration: const Duration(milliseconds: 450),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 450),
            curve: Curves.linearToEaseOut,
            alignment: Alignment.topCenter,
            child: state.maybeWhen(
              fetched: (String? code, int numOfAvailable) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Text(
                      numOfAvailable <= 0
                          ? "You've used all your invites.\nStay tuned for more!"
                          : 'Invite up to five friends',
                      style: AppTextStyles.paragraph.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (numOfAvailable > 0) ...<Widget>[
                      const SizedBox(height: 24),
                      _InviteCodeBox(
                        code: code ?? '',
                      ),
                    ],
                  ],
                );
              },
              orElse: () {
                return const SizedBox(width: double.infinity);
              },
            ),
          ),
        );
      },
    );
  }
}

class _GiftWidget extends StatelessWidget {
  const _GiftWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFFFB5012),
                Color(0xFFFF783A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Assets.icons.gift24.svg(),
        ),
        BlocBuilder<GetInviteCubit, GetInviteState>(
          builder: (BuildContext context, GetInviteState state) {
            final int? numOfAvailable = state.maybeWhen(
              orElse: () => null,
              fetched: (_, int n) => n,
            );

            return Transform.translate(
              offset: const Offset(2, 2),
              child: AnimatedOpacity(
                opacity: numOfAvailable == null ? 0 : 1,
                duration: const Duration(milliseconds: 450),
                curve: Curves.linearToEaseOut,
                child: AnimatedScale(
                  scale: numOfAvailable == null ? 0.75 : 1,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.linearToEaseOut,
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                        strokeAlign: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      numOfAvailable?.toString() ?? '',
                      style: AppTextStyles.callout,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InviteCodeBox extends StatelessWidget {
  const _InviteCodeBox({
    required this.code,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundChatInput,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Invite Code',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: AppTextStyles.paragraph,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              InAppNotification.show(
                child: const _CopiedNotification(),
                duration: const Duration(seconds: 3),
                curve: Curves.linearToEaseOut,
                context: context,
              );
              Clipboard.setData(ClipboardData(text: code));
              getIt
                  .get<TrackUseActivityUseCase>()
                  .execute(AppEvents.popupScreenEvents.copyClicked);
            },
            child: Assets.icons.copy24.svg(),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetInviteCubit, GetInviteState>(
      builder: (BuildContext context, GetInviteState state) {
        return CustomButton(
          onPressed: state.maybeWhen(
            orElse: () => null,
            fetched: (String? code, int numOfAvailable) => () {
              if (numOfAvailable > 0) {
                getIt
                    .get<TrackUseActivityUseCase>()
                    .execute(AppEvents.popupScreenEvents.shareClicked);
                Share.share(code ?? '');
              } else {
                context.router.maybePop();
              }
            },
          ),
          child: state.maybeWhen(
            fetched: (_, int numOfAvailable) {
              return Text(
                numOfAvailable > 0 ? 'Share' : 'Close',
              );
            },
            orElse: () => const CircularProgressIndicator.adaptive(
              backgroundColor: AppColors.textInvert,
            ),
          ),
        );
      },
    );
  }
}

class _CopiedNotification extends StatelessWidget {
  const _CopiedNotification();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 20),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            'Copied',
            style: AppTextStyles.paragraph,
          ),
        ),
      ),
    );
  }
}
