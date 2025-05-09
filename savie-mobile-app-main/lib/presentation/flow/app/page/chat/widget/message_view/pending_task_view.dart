import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../application/application.dart';
import '../../../../../../../domain/domain.dart';
import '../../../../../../../domain/model/task_extraction_state.dart';
import '../../../../../../presentation.dart';

class PendingTaskView extends StatelessWidget {
  const PendingTaskView({
    super.key,
    required this.textMessage,
  });

  final TextMessage textMessage;

  @override
  Widget build(BuildContext context) {
    final TaskExtractionState? state = textMessage.taskExtractionState;
    final List<Task> tasks = state?.tasks ?? <Task>[];
    final bool tasksEmpty = tasks.isEmpty;

    final bool displayAnyContent = state != null && !tasksEmpty;

    if (!displayAnyContent) {
      return const SizedBox(width: double.infinity);
    }

    final bool isAdded = state.isAdded;

    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 12),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.backgroundChatAccentMuted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: StreamBuilder<bool>(
          stream: getIt.get<GoogleServicesRepository>().isConnectedStream,
          initialData: getIt.get<GoogleServicesRepository>().isConnected,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            final bool isConnected = snapshot.data ?? false;

            if (!isAdded && !isConnected) {
              return _ConnectPlaceholder(
                onCancelTap: () {
                  context.read<ChatCubit>().declineTasks(textMessage);
                },
              );
            }

            return _TasksView(
              isAdded: isAdded,
              isAdding: state.isAddding,
              tasks: tasks,
              onAddTap: () {
                context.read<ChatCubit>().confirmTasks(textMessage);
              },
              onCancelTap: () {
                context.read<ChatCubit>().declineTasks(textMessage);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConnectPlaceholder extends StatelessWidget {
  const _ConnectPlaceholder({
    required this.onCancelTap,
  });

  final VoidCallback onCancelTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Assets.icons.calenderAdd.svg(
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.iconAccent,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Looks like you’re trying to schedule something — connect your calendar and I’ll take care of the rest.',
            style: AppTextStyles.paragraph,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _Button(
                leading: Assets.icons.calenderAdd.svg(),
                text: 'Connect calendar',
                isPrimary: true,
                onTap: () {
                  getIt.get<GoogleServicesRepository>().connect();
                },
              ),
              const SizedBox(width: 8),
              _Button(
                leading: null,
                text: 'Cancel',
                isPrimary: false,
                onTap: onCancelTap,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.leading,
    required this.text,
    required this.isPrimary,
    required this.onTap,
    this.color,
  });

  final Widget? leading;
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      minSize: 0,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color ??
              (isPrimary ? AppColors.iconAccent : AppColors.textInvert),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTextStyles.footnote.copyWith(
                color: isPrimary ? AppColors.textInvert : AppColors.textPrimary,
                height: 18 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView({
    required this.isAdding,
    required this.isAdded,
    required this.tasks,
    required this.onAddTap,
    required this.onCancelTap,
  });

  final bool isAdding;
  final bool isAdded;
  final List<Task> tasks;
  final VoidCallback onAddTap;
  final VoidCallback onCancelTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Container(
            width: 6,
            color: isAdded ? AppColors.textSuccess : AppColors.iconAccent,
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final Task task in tasks) ...<Widget>[
                const SizedBox(height: 20),
                Text(
                  task.title,
                  style: AppTextStyles.paragraph,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _Button(
                    leading: isAdded
                        ? Assets.icons.calendarCheck.svg(
                            height: 16,
                            width: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textInvert,
                              BlendMode.srcIn,
                            ),
                          )
                        : isAdding
                            ? const _LoadingIndicator()
                            : Assets.icons.calenderAdd.svg(),
                    text: isAdded
                        ? 'Added'
                        : isAdding
                            ? 'Adding'
                            : 'Add to Calendar',
                    isPrimary: true,
                    onTap: isAdding ? () {} : onAddTap,
                    color: isAdded ? AppColors.textSuccess : null,
                  ),
                  if (!isAdded) ...<Widget>[
                    const SizedBox(width: 8),
                    _Button(
                      leading: null,
                      text: 'Cancel',
                      isPrimary: false,
                      onTap: onCancelTap,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 16,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: AppColors.textInvert.withValues(alpha: 0.3),
                strokeAlign: 0,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
            width: 10,
            child: FittedBox(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.textInvert,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
