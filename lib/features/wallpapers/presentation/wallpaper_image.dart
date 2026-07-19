import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../data/wallpaper_models.dart';

/// Duvar kagidi resmi: once sunucudan yukler, yoksa local asset'e duser.
/// CachedNetworkImage ile otomatik cache'ler.
class WallpaperImage extends StatelessWidget {
  final WallpaperItem item;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? errorBuilder;

  const WallpaperImage({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (item.hasRemoteImage) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: fit,
        placeholder: (context, url) => _localFallback(),
        errorWidget: (context, url, error) => errorBuilder != null
            ? errorBuilder!(context, url)
            : _localFallback(),
      );
    }
    return _localFallback();
  }

  Widget _localFallback() {
    return Image.asset(
      item.assetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: AppColors.surfaceCard);
      },
    );
  }
}
