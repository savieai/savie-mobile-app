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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FilePreview(
                message: fileMessage,
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth - 12 - 60 - 2,
                ),
                child: Text(
                  fileMessage.file.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.paragraph,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilePreview extends StatelessWidget {
  const FilePreview({
    super.key,
    required this.message,
  });

  final FileMessage message;

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
        child: switch (message.file.fileType) {
          FileType.image => _ImageFilePreview(image: message.file),
          FileType.pdf => _PdfFilePreview(pdf: message.file),
          FileType.other => _DefaultFilePreview(file: message.file),
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
    required this.pdf,
  });

  final Attachment pdf;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomImage(
          attachment: Attachment(
            name: pdf.pdfThumbnailName!,
            remoteUrl: Supabase.instance.client.storage
                .from('message_attachments')
                .getAuthenticatedUrl(pdf.pdfThumbnailName!),
            localUrl: null,
          ),
          height: 60,
          width: 60,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 4,
          bottom: 4,
          right: 4,
          child: _FileExtensionLabel(
            fileName: pdf.name,
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
            color: AppColors.strokePrimaryAlpha.withOpacity(0.2),
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
