// lib/src/presentation/widgets/banner_carousel.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart' as banner_entity;

class BannerCarousel extends StatefulWidget {
  final List<banner_entity.Banner> banners;
  final VoidCallback? onTap;
  final double height;
  final bool showIndicator;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onTap,
    this.height = 180.0,
    this.showIndicator = true,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasPreloaded = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Remove _preloadImages() from here - it causes the MediaQuery error

    if (widget.autoPlay && widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Move preloading here - MediaQuery is now available
    if (!_hasPreloaded) {
      _preloadImages();
      _hasPreloaded = true;
    }
  }

  void _preloadImages() {
    if (widget.banners.isEmpty) return;

    // Preload first image immediately - MediaQuery is now available
    if (widget.banners.isNotEmpty) {
      precacheImage(CachedNetworkImageProvider(widget.banners[0].url), context);
    }

    // Preload second image after a short delay
    if (widget.banners.length > 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          precacheImage(
            CachedNetworkImageProvider(widget.banners[1].url),
            context,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval).then((_) {
      if (mounted) {
        if (_currentIndex == widget.banners.length - 1) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return _buildBannerItem(banner);
              },
            ),
          ),
          if (widget.showIndicator && widget.banners.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.banners.length,
                  (index) => _buildIndicator(index == _currentIndex),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(banner_entity.Banner banner) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: banner.url,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey.shade700,
                      ),
                    ),
                httpHeaders:
                    kIsWeb ? {'Access-Control-Allow-Origin': '*'} : null,
              ),
              if (banner.title.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      banner.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
