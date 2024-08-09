import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/model/app_log.dart';
import '../../infrastructure/service/logging_service.dart';
import '../presentation.dart';

@RoutePage()
class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: CustomIconButton(
          onTap: () {
            context.router.maybePop();
          },
          svgGenImage: Assets.icons.arrowLeft24,
        ),
        middle: const Text('Logs'),
      ),
      body: StreamBuilder<List<AppLog>>(
        stream: getIt.get<LoggingService>().watchLogs(),
        builder: (BuildContext context, AsyncSnapshot<List<AppLog>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (_, int index) {
              final AppLog log = snapshot.data![index];

              return Container(
                color: Colors.grey.shade100,
                child: log.map(
                  info: (InfoLog info) => Text(info.info),
                  error: (ErrorLog error) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (error.message != null) ...<Widget>[
                        Text(error.message ?? ''),
                        const SizedBox(height: 8),
                      ],
                      Text(error.error.toString()),
                      const SizedBox(height: 8),
                      Text(error.stackTrace.toString()),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
