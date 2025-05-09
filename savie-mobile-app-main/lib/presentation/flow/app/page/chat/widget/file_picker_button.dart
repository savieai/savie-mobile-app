import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../application/application.dart';
import '../../../../../presentation.dart';
import '../../../../../router/app_router.gr.dart';
import '../../camera_roll/widget/widget.dart';
import '../cubit/cubit.dart';

class FilePickerButton extends StatefulWidget {
  const FilePickerButton({super.key});

  @override
  State<FilePickerButton> createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hideMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _buttonKey,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: _isMenuOpen 
          ? Container(
              key: const ValueKey<String>('close'),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleMenu(context),
                child: Padding(
                  padding: EdgeInsets.all(AppSpaces.space200),
                  child: SvgPicture.asset(
                    'assets/icons/close-menu.svg',
                    height: Platform.isMacOS ? 20 : 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.iconSecodary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            )
          : Container(
              key: const ValueKey<String>('attachment'),
              child: CustomIconButton(
                onTap: () => _toggleMenu(context),
                color: AppColors.iconSecodary,
                svgGenImage: Assets.icons.attachment24,
              ),
            ),
      ),
    );
  }

  void _toggleMenu(BuildContext context) {
    if (_overlayEntry != null) {
      _hideMenu();
    } else {
      _showMenu(context);
    }
  }

  void _hideMenu() {
    if (_overlayEntry == null) return;
    
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() {
        _isMenuOpen = false;
      });
    });
  }

  void _showMenu(BuildContext context) {
    // Trigger haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Get the position of the button
    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    
    // Calculate menu position
    const double menuWidth = 200.0;
    const double menuHeight = 160.0;
    
    // Ensure menu doesn't go off screen left/right
    final double left = (position.dx + menuWidth > MediaQuery.of(context).size.width)
        ? MediaQuery.of(context).size.width - menuWidth - 16
        : max(16, position.dx - 16);
    
    // Position the menu with less overlap on the input field
    final double top = position.dy - menuHeight + 5; // reduced from 15 to 5
    
    setState(() {
      _isMenuOpen = true;
    });
    
    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  alignment: Alignment.bottomCenter,
                  child: _PaperclipMenu(
                    width: menuWidth,
                    onAttachPhoto: () {
                      _hideMenu();
                      _openCameraRoll(context);
                    },
                    onAttachFile: () {
                      _hideMenu();
                      if (Platform.isMacOS) {
                        pushFilePicker(context);
                      } else {
                        _openFilePicker(context);
                      }
                    },
                    onCreateTodo: () {
                      _hideMenu();
                      // Create a to-do list using the QuillControllerCubit
                      final QuillControllerCubit quillControllerCubit = context.read<QuillControllerCubit>();
                      
                      // Preserve current size before enabling todos
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        quillControllerCubit.enableTodos();
                        // Request focus after operation is complete
                        quillControllerCubit.requestFocus();
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  Future<void> _openFilePicker(BuildContext context) async {
    pushFilePicker(context);
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.chat.mediaButtonClicked);
  }

  Future<void> _openCameraRoll(BuildContext context) async {
    try {
      final BuildContext capturedContext = context;
      // Fix freezing issue with proper async handling
      await Future<void>.delayed(Duration.zero);
      
      if (!capturedContext.mounted) return;
      
      // Use router.push without awaiting to prevent UI block
      capturedContext.router.push(const CameraRollRoute());
      
      // Track analytics event
      getIt
          .get<TrackUseActivityUseCase>()
          .execute(AppEvents.chat.mediaButtonClicked);
    } catch (e) {
      debugPrint('Error opening camera roll: $e');
      // Show a simple error message if navigation fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open camera roll')),
        );
      }
    }
  }
}

class _PaperclipMenu extends StatelessWidget {
  const _PaperclipMenu({
    required this.width,
    required this.onAttachFile,
    required this.onAttachPhoto,
    required this.onCreateTodo,
  });

  final double width;
  final VoidCallback onAttachFile;
  final VoidCallback onAttachPhoto;
  final VoidCallback onCreateTodo;

  @override
  Widget build(BuildContext context) {
    // Double-wrap with Material to ensure no inheriting of yellow underlines
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.strokeSecondaryAlpha),
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
            ),
            BoxShadow(
              offset: const Offset(0, -4),
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaperclipMenuItem(
                title: 'Photos',
                icon: Assets.icons.gallery24,
                onTap: onAttachPhoto,
              ),
              Container(
                height: 1,
                color: AppColors.strokeSecondaryAlpha,
              ),
              _PaperclipMenuItem(
                title: 'Docs',
                icon: Assets.icons.folder24,
                onTap: onAttachFile,
              ),
              Container(
                height: 1,
                color: AppColors.strokeSecondaryAlpha,
              ),
              _PaperclipMenuItem(
                title: 'To-do',
                assetPath: 'assets/icons/to-do-menu.svg',
                onTap: onCreateTodo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperclipMenuItem extends StatefulWidget {
  const _PaperclipMenuItem({
    required this.title,
    this.icon,
    this.assetPath,
    required this.onTap,
  }) : assert(icon != null || assetPath != null, 'Either icon or assetPath must be provided');

  final String title;
  final SvgGenImage? icon;
  final String? assetPath;
  final VoidCallback onTap;

  @override
  State<_PaperclipMenuItem> createState() => _PaperclipMenuItemState();
}

class _PaperclipMenuItemState extends State<_PaperclipMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      textStyle: const TextStyle(decoration: TextDecoration.none),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            height: 50, // Fixed height for the menu item
            alignment: Alignment.centerLeft,
            color: _isHovered ? AppColors.strokePrimaryAlpha : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: widget.icon != null
                      ? widget.icon!.svg(
                          height: 20, // Fixed height of 20px
                          width: 20,  // Fixed width of 20px
                          colorFilter: const ColorFilter.mode(
                            AppColors.iconSecodary,
                            BlendMode.srcIn,
                          ),
                        )
                      : SvgPicture.asset(
                          widget.assetPath!,
                          height: 20, // Fixed height of 20px
                          width: 20,  // Fixed width of 20px
                          colorFilter: const ColorFilter.mode(
                            AppColors.iconSecodary,
                            BlendMode.srcIn,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 17, // Keep text size at 17px
                      height: 22/17, // line-height as a ratio
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
