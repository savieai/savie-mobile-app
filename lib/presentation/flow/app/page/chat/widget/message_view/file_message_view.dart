part of 'message_view.dart';

class FileMessageView extends StatelessWidget {
  const FileMessageView({
    super.key,
    required this.fileMessage,
  });

  final FileMessage fileMessage;

  @override
  Widget build(BuildContext context) {
    return _MessageContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: StreamBuilder<(double?, File?)>(
          stream: getIt
              .get<GetFileStreamUseCase>()
              .execute(name: fileMessage.file.name),
          builder: (
            BuildContext context,
            AsyncSnapshot<(double?, File?)> snapshot,
          ) {
            final File? file = snapshot.data?.$2;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (file == null && !snapshot.hasData) {
                  getIt.get<GetFileUseCase>().execute(
                        localFullPath: fileMessage.file.localFullPath,
                        signedUrl: fileMessage.file.signedUrl,
                        name: fileMessage.file.name,
                      );
                } else if (file != null) {
                  OpenFile.open(file.path);
                }
              },
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FilePreview(
                      file: fileMessage.file,
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth - 12 - 60,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            fileMessage.file.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.paragraph,
                          ),
                          if (snapshot.hasData && file == null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CustomPercentIndicator(
                                  progress: snapshot.data?.$1,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${((snapshot.data?.$1 ?? 0) * 100).round()}%',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FilePreview extends StatelessWidget {
  const FilePreview({
    super.key,
    required this.file,
  });

  final Attachment file;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.strokePrimaryAlpha,
        ),
        color: AppColors.backgroundSecondary,
      ),
      clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: switch (file.fileType) {
          FileType.image => _ImageFilePreview(image: file),
          FileType.pdf => file.placeholderUrl == null
              ? _DefaultFilePreview(file: file)
              : _PdfFilePreview(placeholderUrl: file.placeholderUrl!),
          FileType.other => _DefaultFilePreview(file: file),
        },
      ),
    );
  }
}

class _ImageFilePreview extends StatelessWidget {
  const _ImageFilePreview({
    required this.image,
  });

  final Attachment image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomImage(
          attachment: image,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 4,
          bottom: 4,
          right: 4,
          child: _FileExtensionLabel(
            fileName: image.name,
          ),
        ),
      ],
    );
  }
}

class _PdfFilePreview extends StatelessWidget {
  const _PdfFilePreview({
    required this.placeholderUrl,
  });

  final String placeholderUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomImage(
          attachment: Attachment(
            name: placeholderUrl,
            remoteStorageName: placeholderUrl,
            signedUrl: placeholderUrl,
            localFullPath: null,
            placeholderUrl: placeholderUrl,
          ),
          height: 60,
          width: 60,
          fit: BoxFit.cover,
        ),
        const Positioned(
          left: 4,
          bottom: 4,
          right: 4,
          child: _FileExtensionLabel(
            fileName: 'pdf',
          ),
        ),
      ],
    );
  }
}

class _DefaultFilePreview extends StatelessWidget {
  const _DefaultFilePreview({
    required this.file,
  });

  final Attachment file;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Assets.icons.file12.svg(
            colorFilter: const ColorFilter.mode(
              AppColors.iconAccent,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            file.name.split('.').last.toLowerCase(),
            maxLines: 1,
            style: AppTextStyles.description.copyWith(
              color: AppColors.iconAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileExtensionLabel extends StatelessWidget {
  const _FileExtensionLabel({
    required this.fileName,
  });

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppColors.strokePrimaryAlpha.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            children: <Widget>[
              Assets.icons.file12.svg(
                colorFilter: const ColorFilter.mode(
                  AppColors.textInvert,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: FittedBox(
                  child: Text(
                    fileName.split('.').last.toUpperCase(),
                    maxLines: 1,
                    style: AppTextStyles.description.copyWith(
                      color: AppColors.textInvert,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
