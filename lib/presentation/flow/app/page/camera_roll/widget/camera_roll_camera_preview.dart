import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../presentation.dart';

class CameraRollCameraPreview extends StatefulWidget {
  const CameraRollCameraPreview({super.key});

  @override
  State<CameraRollCameraPreview> createState() =>
      _CameraRollCameraPreviewState();
}

class _CameraRollCameraPreviewState extends State<CameraRollCameraPreview> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _takePicture();
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (_controller == null || !_controller!.value.isInitialized)
            Container(
              color: AppColors.strokePrimaryAlpha,
            )
          else
            AspectRatio(
              aspectRatio: 1,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          Assets.icons.camera24.svg(
            colorFilter: const ColorFilter.mode(
              AppColors.iconInvert,
              BlendMode.srcIn,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    final XFile? result = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (result == null) {
      return;
    }

    if (context.mounted && mounted) {
      context.read<ChatCubit>().sendMessage(
        mediaPaths: <String>[
          result.path,
        ],
      );

      context.router.maybePop();
    }
  }
}
