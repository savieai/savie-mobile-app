import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG rendering
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Singleton(as: FavIconRepository)
class FavIconRepositoryImpl implements FavIconRepository {
  FavIconRepositoryImpl(
    this._sharedPreferences,
    this._cacheService,
  ) {
    _favIconUrls = _fecthFavIconUrls();
  }

  final SharedPreferences _sharedPreferences;
  final MultiKeyCacheService _cacheService;

  static const String _faviconUrlsKey = 'fav_icon_urls';
  late final Map<String, String> _favIconUrls;

  @override
  bool hasIconUrlInRuntime(String url) => _favIconUrls.containsKey(url);

  @override
  String? getIconUrlSync(String url) {
    if (_favIconUrls.containsKey(url)) {
      return _favIconUrls[url];
    }
    return null;
  }

  @override
  Future<String?> getIconUrl(String url) async {
    if (_favIconUrls.containsKey(url)) {
      return _favIconUrls[url]!;
    }

    final Favicon? favicon = await FaviconFinder.getBest(url);

    if (favicon == null) {
      return null;
    }

    final Response<dynamic> response = await Dio().get(
      favicon.url,
      options: Options(responseType: ResponseType.bytes),
    );

    final Uint8List? data = response.data as Uint8List?;
    if (data == null) {
      return null;
    }

    final String? contentType = response.headers.value('content-type');
    final bool isSvg = contentType != null && contentType.contains('svg');

    if (isSvg) {
      // Convert SVG to PNG and cache it
      await _convertSvgToPng(
        favicon.url,
        data,
      );
    } else {
      // Cache the regular image (non-SVG)
      await _cacheImage(
        favicon.url,
        data,
        '.data',
      );
    }

    _favIconUrls[url] = favicon.url;
    _saveFavIconUrls(_favIconUrls);

    return favicon.url;
  }

  Future<String> _convertSvgToPng(
    String key,
    Uint8List svgData,
  ) async {
    // Step 1: Load the SVG using the new PictureInfo API
    final String rawSvg = String.fromCharCodes(svgData);

    // Step 2: Extract dimensions from SVG
    final RegExp widthRegex = RegExp(r'width="([0-9.]+)"');
    final RegExp heightRegex = RegExp(r'height="([0-9.]+)"');
    final RegExp viewBoxRegex = RegExp(r'viewBox="([0-9. ]+)"');

    double? width;
    double? height;

    // Extract width and height if available
    final RegExpMatch? widthMatch = widthRegex.firstMatch(rawSvg);
    final RegExpMatch? heightMatch = heightRegex.firstMatch(rawSvg);

    if (widthMatch != null && heightMatch != null) {
      width = double.tryParse(widthMatch.group(1)!);
      height = double.tryParse(heightMatch.group(1)!);
    } else {
      // If no explicit width and height are provided, use viewBox dimensions
      final RegExpMatch? viewBoxMatch = viewBoxRegex.firstMatch(rawSvg);
      if (viewBoxMatch != null) {
        final List<String> viewBoxValues = viewBoxMatch.group(1)!.split(' ');
        if (viewBoxValues.length == 4) {
          width = double.tryParse(viewBoxValues[2]);
          height = double.tryParse(viewBoxValues[3]);
        }
      }
    }

    // Fall back to default if no dimensions were found
    width ??= 100.0;
    height ??= 100.0;

    // Load the SVG
    final PictureInfo pictureInfo = await vg.loadPicture(
      SvgStringLoader(rawSvg),
      null, // You can pass a custom size if needed, but we'll use the intrinsic size
    );

    // Step 3: Convert PictureInfo to Image with the extracted dimensions
    final ui.Image image = await pictureInfo.picture.toImage(
      width.toInt(),
      height.toInt(),
    );

    // Step 4: Convert Image to PNG byte data
    final ByteData? pngBytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytes == null) {
      throw Exception('Failed to convert SVG to PNG');
    }

    // Step 5: Save PNG to cache
    return _cacheImage(
      key,
      pngBytes.buffer.asUint8List(),
      '.png',
    );
  }

  Future<String> _cacheImage(
    String key,
    Uint8List imageData,
    String extension,
  ) async {
    final String cachePath = (await getApplicationCacheDirectory()).path;
    final String dirPath = '$cachePath/favicons';

    if (!Directory(dirPath).existsSync()) {
      Directory(dirPath).createSync(recursive: true);
    }

    final File file = File('$dirPath/${const Uuid().v4()}$extension');
    await file.writeAsBytes(imageData);

    // Assuming _cacheService is already defined elsewhere
    _cacheService.cacheFile(url: key, key: key, file: file);

    return key;
  }

  Map<String, String> _fecthFavIconUrls() {
    final String? favIconUrlsData =
        _sharedPreferences.getString(_faviconUrlsKey);
    final Map<String, dynamic> faviconUrls = favIconUrlsData == null
        ? <String, String>{}
        : jsonDecode(favIconUrlsData) as Map<String, dynamic>;
    return faviconUrls.cast<String, String>();
  }

  Future<void> _saveFavIconUrls(Map<String, String> urls) async {
    await _sharedPreferences.setString(_faviconUrlsKey, jsonEncode(urls));
  }
}
