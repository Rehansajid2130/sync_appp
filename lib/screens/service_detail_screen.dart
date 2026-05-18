import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/service_provider.dart';
import 'booking_date_screen.dart';

class ServiceReview {
  final String name;
  final String date;
  final double rating;
  final String text;
  final Color avatarColor;
  const ServiceReview({required this.name, required this.date, required this.rating, required this.text, required this.avatarColor});
}

const List<Color> _photoColors = [Color(0xFF91CBAE), Color(0xFF7DD5F5), Color(0xFFFFB347), Color(0xFFB39DDB)];
const List<ServiceReview> _demoReviews = [
  ServiceReview(name: 'Sarah T.', date: 'March 15, 2024', rating: 5.0, text: 'Amazing service! My house has never looked this clean. Highly recommend!', avatarColor: Color(0xFF91CBAE)),
  ServiceReview(name: 'Michael Wong', date: 'Feb 28, 2024', rating: 5.0, text: 'Superb job! They tackled all the tough spots. Spotless result.', avatarColor: Color(0xFF7DD5F5)),
];

class ServiceDetailScreen extends StatefulWidget {
  final ServiceProvider provider;
  const ServiceDetailScreen({super.key, required this.provider});
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isBookmarked = false;
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(isDark),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceInfo(isDark),
                    Divider(indent: 24, endIndent: 24, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    _buildDescription(isDark),
                    Divider(indent: 24, endIndent: 24, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    _buildPhotosSection(isDark),
                    Divider(indent: 24, endIndent: 24, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    _buildReviewsSection(isDark),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
      elevation: 0,
      leading: _buildCircleButton(Icons.arrow_back, isDark, onTap: () => Navigator.pop(context)),
      actions: [_buildCircleButton(Icons.share_outlined, isDark), const SizedBox(width: 8)],
      title: Text('Detail Service', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: const EdgeInsets.only(top: 80),
          color: widget.provider.avatarColor.withOpacity(0.15),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: widget.provider.avatarColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.provider.avatarColor, width: 2),
                  ),
                  child: Icon(widget.provider.icon, color: widget.provider.avatarColor, size: 40),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.provider.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, bool isDark, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : Colors.white, shape: BoxShape.circle, boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
          child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildServiceInfo(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Service', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(widget.provider.category, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black))),
              GestureDetector(
                onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                child: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? AppColors.primary : Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('${widget.provider.rating} (${widget.provider.reviewCount} Reviews)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag(widget.provider.category, AppColors.primaryLight, AppColors.primary, Icons.grid_view, isDark),
              const SizedBox(width: 12),
              _buildTag(widget.provider.location, isDark ? const Color(0xFF262626) : const Color(0xFFF1F4F8), isDark ? Colors.white70 : Colors.grey, Icons.location_on_outlined, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, size: 14, color: text), const SizedBox(width: 6), Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 12))]),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          Text(
            'Keep your home spotless and welcoming with our ${widget.provider.category} Service! Trained, vetted, and dedicated to your satisfaction — we handle kitchens, bathrooms, and living areas with care.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], height: 1.5),
            maxLines: _isDescriptionExpanded ? null : 3,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(_isDescriptionExpanded ? 'Read Less' : 'Read More', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
              const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPhotoCard(_photoColors[0], isDark),
              const SizedBox(width: 12),
              _buildPhotoCard(_photoColors[1], isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    _buildPhotoCard(_photoColors[2], isDark),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('10+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(Color color, bool isDark) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.image, color: color),
      ),
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
              const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          ..._demoReviews.map((r) => _buildReviewCard(r, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ServiceReview review, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: review.avatarColor.withOpacity(0.2), child: Text(review.name[0], style: TextStyle(color: review.avatarColor, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
                    Text(review.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text(review.rating.toString(), style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black))]),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.text, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF161616) : Colors.white, border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)))),
        child: Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDateScreen(provider: widget.provider),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                  child: const Text('Book Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
