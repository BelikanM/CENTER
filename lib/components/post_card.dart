import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'futuristic_card.dart';

class PostCard extends StatefulWidget {
  final String userName;
  final String userRole;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final int shares;
  final String? imageUrl;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.userName,
    required this.userRole,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    this.imageUrl,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _likeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          if (widget.imageUrl != null) _buildImage(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.userRole} • ${widget.timeAgo}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showPostOptions(),
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.white.withValues(alpha: 0.1),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D4FF),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.white.withValues(alpha: 0.1),
            child: const Icon(
              Icons.image_not_supported_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _likeAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _likeAnimation.value,
                    child: _buildActionButton(
                      icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      label: widget.likes.toString(),
                      color: _isLiked ? Colors.red : Colors.white.withValues(alpha: 0.7),
                      onTap: _handleLike,
                    ),
                  );
                },
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: widget.comments.toString(),
                color: Colors.white.withValues(alpha: 0.7),
                onTap: widget.onComment,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.share_rounded,
                label: widget.shares.toString(),
                color: Colors.white.withValues(alpha: 0.7),
                onTap: widget.onShare,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.bookmark_border_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    widget.onLike();
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionItem(Icons.bookmark_rounded, 'Enregistrer', () {}),
            _buildOptionItem(Icons.link_rounded, 'Copier le lien', () {}),
            _buildOptionItem(Icons.report_rounded, 'Signaler', () {}),
            _buildOptionItem(Icons.block_rounded, 'Masquer', () {}),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.8),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
