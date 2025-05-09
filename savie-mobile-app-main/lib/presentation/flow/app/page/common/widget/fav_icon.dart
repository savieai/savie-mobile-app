import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../application/application.dart';
import '../../../../../presentation.dart';

class FavIcon extends StatefulWidget {
  const FavIcon({
    super.key,
    required this.completeLink,
  });

  final String completeLink;

  @override
  State<FavIcon> createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {
  String? _faviconUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavicon();
  }

  @override
  void didUpdateWidget(FavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completeLink != widget.completeLink) {
      _loadFavicon();
    }
  }

  Future<void> _loadFavicon() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? faviconUrl = await GetIt.instance
          .get<GetFavIconUrlUseCase>()
          .execute(widget.completeLink);

      if (mounted) {
        setState(() {
          _faviconUrl = faviconUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _faviconUrl = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 16,
        width: 16,
        child: Center(
          child: SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_faviconUrl != null) {
      return SizedBox(
        height: 16,
        width: 16,
        child: Image.network(
          _faviconUrl!,
          height: 16,
          width: 16,
          errorBuilder: (_, __, ___) => _defaultIcon(),
        ),
      );
    }

    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return SizedBox(
      height: 16,
      width: 16,
      child: Assets.icons.link16.svg(
        height: 16,
        width: 16,
        colorFilter: const ColorFilter.mode(
          AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
} 
