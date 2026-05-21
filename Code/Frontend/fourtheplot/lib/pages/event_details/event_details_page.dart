import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/mock/mock_comments.dart';
import 'package:fourtheplot/models/comment.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/join_event/join_event_page.dart';
import 'package:fourtheplot/widgets/comment_card.dart';
import 'package:fourtheplot/widgets/glassmorphism.dart';
import 'package:fourtheplot/widgets/gradient_text.dart';
import 'package:fourtheplot/widgets/info_card.dart';
import 'package:fourtheplot/widgets/tag_chip.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final Duration _autoAdvanceInterval = Duration(seconds: 6);
  final Duration _autoAdvanceResumeDelay = Duration(seconds: 4);

  late final PageController _pageController;
  int _currentBannerIndex = 0;
  late final List<String> _bannerImages;
  late final List<Comment> _comments;
  late final User _currentUser;
  late final TextEditingController _commentController;
  late final FocusNode _commentFocusNode;
  Timer? _autoAdvanceTimer;
  Timer? _resumeAutoAdvanceTimer;
  bool _isAutoAdvancePaused = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bannerImages = _buildBannerImages(widget.event.coverImageUrl);
    _comments = mockComments;
    _currentUser = _buildCurrentUser();
    _commentController = TextEditingController();
    _commentFocusNode = FocusNode();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _resumeAutoAdvanceTimer?.cancel();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_autoAdvanceInterval, (_) {
      if (_isAutoAdvancePaused || !_pageController.hasClients) {
        return;
      }
      if (_bannerImages.isEmpty) {
        return;
      }
      final nextPage = (_currentBannerIndex + 1) % _bannerImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _pauseAutoAdvance() {
    _isAutoAdvancePaused = true;
    _resumeAutoAdvanceTimer?.cancel();
    _resumeAutoAdvanceTimer = Timer(_autoAdvanceResumeDelay, () {
      _isAutoAdvancePaused = false;
    });
  }

  bool _handleBannerScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      _pauseAutoAdvance();
    }
    if (notification is UserScrollNotification && notification.direction != ScrollDirection.idle) {
      _pauseAutoAdvance();
    }
    if (notification is ScrollEndNotification) {
      _pauseAutoAdvance();
    }
    return false;
  }

  List<String> _buildBannerImages(String coverImageUrl) {
    return [
      coverImageUrl,
      'https://www.shutterstock.com/image-photo/sun-sets-behind-mountain-ranges-600nw-2479236003.jpg',
      'https://img.freepik.com/free-photo/lavender-field-sunset-near-valensole_268835-3910.jpg?semt=ais_hybrid&w=740&q=80',
      'https://img.magnific.com/free-photo/beautiful-lake-mountains_395237-44.jpg?semt=ais_hybrid&w=740&q=80',
      'https://cdn.pixabay.com/photo/2017/07/24/19/57/tiger-2535888_640.jpg',
    ];
  }

  User _buildCurrentUser() {
    final now = DateTime.now();
    return User(
      id: 'user_current',
      displayName: 'You',
      email: 'you@example.com',
      role: UserRole.goer,
      status: UserStatus.active,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
    );
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final comment = Comment(
      id: 'comment_${DateTime.now().microsecondsSinceEpoch}',
      userId: _currentUser.id,
      eventId: widget.event.id,
      text: text,
      createdAt: DateTime.now(),
      author: _currentUser,
    );
    setState(() {
      _comments.insert(0, comment);
      _commentController.clear();
    });
    _commentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final dateLabel = DateFormat('EEE, MMM d').format(event.startAt);
    final timeLabel = '${DateFormat('h:mm a').format(event.startAt)} - ${DateFormat('h:mm a').format(event.endAt)}';
    final capacityLabel = event.capacity.maxAttendees == null
        ? '${event.capacity.confirmedAttendees} joined'
        : '${event.capacity.confirmedAttendees}/${event.capacity.maxAttendees} joined';
    final statusLabel = _formatStatus(event.status);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildBanner(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleBlock(event, dateLabel, statusLabel),
                const SizedBox(height: 20),
                _buildQuickFacts(
                  context,
                  dateLabel: dateLabel,
                  timeLabel: timeLabel,
                  venueLabel: event.location.venueName ?? event.location.address,
                  capacityLabel: capacityLabel,
                ),
                const SizedBox(height: 20),
                _buildAboutSection(event),
                const SizedBox(height: 18),
                _buildCategorySection(event),
                const SizedBox(height: 20),
                _buildCommentsSection(),
                const SizedBox(height: 92),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildJoinBar(context, capacityLabel),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _handleBannerScroll,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return _buildBannerImage(_bannerImages[index]);
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Glassmorphism(
                color: Colors.white,
                opacity: 0.2,
                blur: 12,
                radius: 14,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.event.location.address,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildBannerIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _bannerImages.length,
        (index) {
          final isActive = index == _currentBannerIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(left: 6),
            height: 6,
            width: isActive ? 18 : 6,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerImage(String imageUrl) {
    final isNetwork = imageUrl.startsWith('http');
    final image = isNetwork
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }
              return _buildImageLoading();
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildImageFallback();
            },
          )
        : Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageFallback();
            },
          );

    return SizedBox.expand(child: image);
  }

  Widget _buildImageLoading() {
    return Container(
      color: panelColor,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: panelColor,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 36),
      ),
    );
  }

  Widget _buildTitleBlock(Event event, String dateLabel, String statusLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          event.title,
          gradient: LinearGradient(
            colors: [accentBlue, accentPurple],
          ),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusChip(statusLabel),
            const SizedBox(width: 10),
            Text(
              dateLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                event.location.address,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.person_pin_circle,
              size: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Hosted by ${event.hostName ?? 'Community'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String statusLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentPink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentPink.withValues(alpha: 0.4)),
      ),
      child: Text(
        statusLabel,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickFacts(
    BuildContext context, {
    required String dateLabel,
    required String timeLabel,
    required String venueLabel,
    required String capacityLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick facts',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 12.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: InfoCard(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: dateLabel,
                    accentColor: accentBlue,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: InfoCard(
                    icon: Icons.schedule,
                    label: 'Time',
                    value: timeLabel,
                    accentColor: accentPurple,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: InfoCard(
                    icon: Icons.place,
                    label: 'Venue',
                    value: venueLabel,
                    accentColor: accentPink,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: InfoCard(
                    icon: Icons.groups,
                    label: 'Capacity',
                    value: capacityLabel,
                    accentColor: accentOrange,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this event',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Text(
            event.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories and tags',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...event.categories.map(
              (category) => TagChip(
                label: category,
                color: accentPurple,
              ),
            ),
            ...event.tags.map(
              (tag) => TagChip(
                label: '#$tag',
                color: accentBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comments (${_comments.length})',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Most recent',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCommentComposer(),
        Divider(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        if (_comments.isEmpty)
          _buildEmptyComments()
        else
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return CommentCard(comment: _comments[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: _comments.length,
            ),
          ),
      ],
    );
  }

  Widget _buildCommentComposer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accentBlue.withValues(alpha: 0.25),
            child: const Text(
              'Y',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submitComment,
            icon: const Icon(Icons.send_rounded),
            color: Colors.white,
            tooltip: 'Post comment',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        'No comments yet. Be the first to say something.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildJoinBar(BuildContext context, String capacityLabel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF171C38), Color(0xFF101428)],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacity',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  capacityLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _JoinButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => JoinEventPage(event: widget.event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(EventStatus status) {
    final value = eventStatusToString(status);
    if (value.isEmpty) {
      return 'Draft';
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _JoinButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _JoinButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9B6CFF), Color(0xFF6EA8FF)],
              ),
            ),
            child: const Center(
              child: Text(
                'Join event',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}