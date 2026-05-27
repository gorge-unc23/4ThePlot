import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/comment.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/registration.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/business_profile/business_profile_page.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_page.dart';
import 'package:fourtheplot/pages/join_event/join_event_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/trending_payment/trending_payment_page.dart';
import 'package:fourtheplot/widgets/comment_card.dart';
import 'package:fourtheplot/widgets/glassmorphism.dart';
import 'package:fourtheplot/widgets/gradient_text.dart';
import 'package:fourtheplot/widgets/info_card.dart';
import 'package:fourtheplot/widgets/report_dialog.dart';
import 'package:fourtheplot/widgets/tag_chip.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

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
  List<Comment> _comments = const [];
  late final User _currentUser;
  late final TextEditingController _commentController;
  late final FocusNode _commentFocusNode;
  Timer? _autoAdvanceTimer;
  Timer? _resumeAutoAdvanceTimer;
  bool _isAutoAdvancePaused = false;
  Registration? _registration;
  bool _isLoadingRegistration = true;
  bool _isUpdatingRegistration = false;
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;
  bool _isDeletingEvent = false;
  bool _isReportingEvent = false;
  int? _deletingCommentId;
  int? _reportingCommentId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // _bannerImages = _buildBannerImages(widget.event.coverImageUrl);
    _bannerImages = [widget.event.coverImageUrl];
    _currentUser = _buildCurrentUser();
    _commentController = TextEditingController();
    _commentFocusNode = FocusNode();
    _startAutoAdvance();
    _loadRegistration();
    _loadComments();
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

  Future<void> _loadRegistration() async {
    final eventId = int.tryParse(widget.event.id);
    if (eventId == null ||
        _isAdmin ||
        widget.event.hostId == MainWrapper.loggedInUser.id.toString()) {
      if (!mounted) {
        return;
      }
      setState(() {
        _registration = null;
        _isLoadingRegistration = false;
      });
      return;
    }

    setState(() {
      _isLoadingRegistration = true;
    });

    final result = await DatabaseHelper.instance.getRegistrationForUserEvent(
      MainWrapper.loggedInUser.id,
      eventId,
    );
    if (!mounted) {
      return;
    }

    Registration? registration;
    if (result.success && result.data is Registration) {
      registration = result.data;
    }

    setState(() {
      _registration = registration;
      _isLoadingRegistration = false;
    });
  }

  Future<void> _handleUnregister() async {
    if (_registration == null || _isUpdatingRegistration) {
      return;
    }

    final registrationId = _registration!.id;
    // if (registrationId == null) {
    //   _showSnackBar('Could not unregister: invalid registration id.');
    //   return;
    // }

    setState(() {
      _isUpdatingRegistration = true;
    });

    final result = await DatabaseHelper.instance.deleteRegistration(registrationId);
    if (!mounted) {
      return;
    }

    setState(() {
      _isUpdatingRegistration = false;
    });

    if (!result.success) {
      _showSnackBar('Could not unregister: ${result.message}');
      return;
    }

    setState(() {
      _registration = null;
    });
    _showSnackBar('You have unregistered from this event.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _loadComments() async {
    final eventId = int.tryParse(widget.event.id);
    if (eventId == null) {
      setState(() {
        _comments = const [];
        _isLoadingComments = false;
      });
      return;
    }

    setState(() {
      _isLoadingComments = true;
    });

    final result = await DatabaseHelper.instance.getCommentsByEvent(eventId);
    if (!mounted) {
      return;
    }

    if (!result.success || result.data is! List<Comment>) {
      setState(() {
        _comments = const [];
        _isLoadingComments = false;
      });
      _showSnackBar('Could not load comments: ${result.message}');
      return;
    }

    setState(() {
      _comments = result.data as List<Comment>;
      _isLoadingComments = false;
    });
  }

  bool _handleBannerScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      _pauseAutoAdvance();
    }
    if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      _pauseAutoAdvance();
    }
    if (notification is ScrollEndNotification) {
      _pauseAutoAdvance();
    }
    return false;
  }

  User _buildCurrentUser() {
    return MainWrapper.loggedInUser;
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    final eventId = int.tryParse(widget.event.id);
    if (text.isEmpty || _isSubmittingComment) {
      return;
    }
    if (eventId == null) {
      _showSnackBar('Could not post comment: invalid event id.');
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    final result = await DatabaseHelper.instance.createComment({
      'userId': MainWrapper.loggedInUser.id,
      'eventId': eventId,
      'text': text,
    });
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmittingComment = false;
    });

    if (!result.success) {
      _showSnackBar('Could not post comment: ${result.message}');
      return;
    }

    final createdComment = result.data is Map<String, dynamic>
        ? Comment.fromJson(result.data as Map<String, dynamic>)
        : Comment(
            id: 0,
            userId: MainWrapper.loggedInUser.id,
            eventId: eventId,
            text: text,
            createdAt: DateTime.now(),
            author: _currentUser,
          );

    setState(() {
      _comments = [createdComment, ..._comments];
      _commentController.clear();
    });
    _commentFocusNode.unfocus();
  }

  Future<void> _handleDeleteComment(Comment comment) async {
    if (_deletingCommentId != null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This comment will be removed from the event.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _deletingCommentId = comment.id;
    });
    final result = await DatabaseHelper.instance.deleteComment(comment.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _deletingCommentId = null;
    });

    if (!result.success) {
      _showSnackBar('Could not delete comment: ${result.message}');
      return;
    }

    setState(() {
      _comments = _comments.where((item) => item.id != comment.id).toList();
    });
    _showSnackBar('Comment deleted.');
  }

  Future<void> _handleDeleteEvent() async {
    if (_isDeletingEvent) {
      return;
    }

    final eventId = int.tryParse(widget.event.id);
    if (eventId == null) {
      _showSnackBar('Could not delete event: invalid event id.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('This will remove "${widget.event.title}" from the platform.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeletingEvent = true;
    });
    final result = await DatabaseHelper.instance.deleteEvent(eventId);
    if (!mounted) {
      return;
    }
    setState(() {
      _isDeletingEvent = false;
    });

    if (!result.success) {
      _showSnackBar('Could not delete event: ${result.message}');
      return;
    }

    MainWrapper.refresh();
    Navigator.of(context).pop();
  }

  Future<void> _handleReportEvent() async {
    final eventId = int.tryParse(widget.event.id);
    if (eventId == null || _isReportingEvent) {
      return;
    }
    final report = await showReportDialog(context, title: 'Report event');
    if (report == null) {
      return;
    }

    setState(() => _isReportingEvent = true);
    final result = await DatabaseHelper.instance.createSafetyReport(
      reportedEventId: eventId,
      reason: report.reason,
      severity: report.severity,
    );
    if (!mounted) return;
    setState(() => _isReportingEvent = false);
    if (!result.success) {
      _showSnackBar('Could not submit report: ${result.message}');
      return;
    }
    _showSnackBar('Report submitted for review.');
  }

  Future<void> _handleReportComment(Comment comment) async {
    if (_reportingCommentId != null) {
      return;
    }
    final report = await showReportDialog(context, title: 'Report comment');
    if (report == null) {
      return;
    }

    setState(() => _reportingCommentId = comment.id);
    final result = await DatabaseHelper.instance.createSafetyReport(
      reportedCommentId: comment.id,
      reason: report.reason,
      severity: report.severity,
    );
    if (!mounted) return;
    setState(() => _reportingCommentId = null);
    if (!result.success) {
      _showSnackBar('Could not submit report: ${result.message}');
      return;
    }
    _showSnackBar('Report submitted for review.');
  }

  Future<void> _handleShareEvent() async {
    final link = 'http://${DatabaseHelper.instance.serverIp}/events/${widget.event.id}';
    final text = 'Check out ${widget.event.title}: $link';
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          title: widget.event.title,
          subject: widget.event.title,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Could not share event.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final dateLabel = DateFormat('EEE, MMM d').format(event.startAt);
    final timeLabel =
        '${DateFormat('h:mm a').format(event.startAt)} - ${DateFormat('h:mm a').format(event.endAt)}';
    final capacityLabel = event.capacity.maxAttendees == null
        ? '${event.capacity.confirmedAttendees} joined'
        : '${event.capacity.confirmedAttendees}/${event.capacity.maxAttendees} joined';
    final statusLabel = _formatStatus(event.status);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
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
                          fontSize: 22,
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
      children: List.generate(_bannerImages.length, (index) {
        final isActive = index == _currentBannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 6),
          height: 6,
          width: isActive ? 18 : 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
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
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.8)),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GradientText(
                event.title,
                gradient: LinearGradient(colors: [accentBlue, accentPurple]),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleShareEvent,
              tooltip: 'Share event',
              icon: const Icon(Icons.ios_share, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusChip(statusLabel),
            const SizedBox(width: 10),
            Text(
              dateLabel,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                event.location.address,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
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
            Expanded(
              child: _buildHostLink(event),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostLink(Event event) {
    final hostId = int.tryParse(event.hostId);
    final hostName = event.hostName ?? 'Community';
    final style = TextStyle(
      color: hostId == null
          ? Colors.white.withValues(alpha: 0.7)
          : const Color(0xFF6EA8FF),
      decoration: hostId == null ? TextDecoration.none : TextDecoration.underline,
      decorationColor: const Color(0xFF6EA8FF).withValues(alpha: 0.7),
    );

    if (hostId == null) {
      return Text(
        'Hosted by $hostName',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BusinessProfilePage(
              hostId: hostId,
              currentEventId: event.id,
              initialHostName: hostName,
              onEventTap: (context, hostedEvent) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(event: hostedEvent),
                  ),
                );
              },
            ),
          ),
        );
      },
      child: Text(
        'Hosted by $hostName',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), height: 1.5),
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
              (category) => TagChip(label: category, color: accentPurple),
            ),
            ...event.tags.map((tag) => TagChip(label: '#$tag', color: accentBlue)),
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
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_isAdmin &&
            widget.event.hostId != MainWrapper.loggedInUser.id.toString()) ...[
          _buildCommentComposer(),
          Divider(color: Colors.white.withValues(alpha: 0.2)),
        ],
        if (_isLoadingComments)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_comments.isEmpty)
          _buildEmptyComments()
        else
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return CommentCard(
                  comment: comment,
                  onDelete: _isAdmin ? () => _handleDeleteComment(comment) : null,
                  onReport: _canReportComment(comment)
                      ? () => _handleReportComment(comment)
                      : null,
                  isDeleting: _deletingCommentId == comment.id,
                  isReporting: _reportingCommentId == comment.id,
                );
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
            child: const Text('Y', style: TextStyle(color: Colors.white)),
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
                hintText: _isSubmittingComment ? 'Posting...' : 'Share your thoughts...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSubmittingComment ? null : _submitComment,
            icon: _isSubmittingComment
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
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
        _isAdmin
            ? 'No comments have been posted for this event.'
            : 'No comments yet. Be the first to say something.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }

  Widget _buildJoinBar(BuildContext context, String capacityLabel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF171C38), Color(0xFF101428)]),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
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
          if (_isAdmin) ...[
            Expanded(
              child: _RegistrationButton(
                label: _isDeletingEvent ? 'Deleting...' : 'Delete event',
                isDestructive: true,
                isEnabled: !_isDeletingEvent,
                onPressed: _handleDeleteEvent,
              ),
            ),
          ] else if (widget.event.hostId != MainWrapper.loggedInUser.id.toString()) ...[
            Expanded(
              child: _RegistrationButton(
                label: _isReportingEvent ? 'Reporting...' : 'Report event',
                isDestructive: true,
                isEnabled: !_isReportingEvent,
                onPressed: _handleReportEvent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RegistrationButton(
                label: _registrationButtonLabel,
                isDestructive: _registration != null,
                isEnabled: !_isLoadingRegistration && !_isUpdatingRegistration,
                onPressed: _registration == null ? _handleJoinPressed : _handleUnregister,
              ),
            ),
          ] else ...[
            Expanded(
              child: _HostActionButton(
                label: 'Edit event',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditEventPage(event: widget.event),
                    ),
                  );
                },
              ),
            ),
            if (!widget.event.trending && MainWrapper.loggedInUser.role == UserRole.business) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _HostActionButton(
                  label: 'Promote event',
                  onPressed: _handlePromotePressed,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _handlePromotePressed() async {
    final promoted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => TrendingPaymentPage(event: widget.event)),
    );
    if (!mounted) {
      return;
    }
    if (promoted == true) {
      MainWrapper.refresh();
      Navigator.of(context).pop();
    }
  }

  String get _registrationButtonLabel {
    if (_isLoadingRegistration) {
      return 'Checking...';
    }
    if (_isUpdatingRegistration) {
      return _registration == null ? 'Joining...' : 'Unregistering...';
    }
    return _registration == null ? 'Join event' : 'Unregister';
  }

  bool get _isAdmin => MainWrapper.loggedInUser.role == UserRole.admin;

  bool _canReportComment(Comment comment) {
    return !_isAdmin && comment.userId != MainWrapper.loggedInUser.id;
  }

  Future<void> _handleJoinPressed() async {
    final joined = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => JoinEventPage(event: widget.event)),
    );
    if (!mounted) {
      return;
    }
    if (joined == true) {
      await _loadRegistration();
    }
  }

  String _formatStatus(EventStatus status) {
    final value = eventStatusToString(status);
    if (value.isEmpty) {
      return 'Draft';
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _RegistrationButton extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _RegistrationButton({
    required this.label,
    required this.isDestructive,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          child: Ink(
            height: 48,
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? LinearGradient(
                      colors: isDestructive
                          ? const [Color(0xFFFF6B6B), Color(0xFFFF4FB2)]
                          : const [Color(0xFF9B6CFF), Color(0xFF6EA8FF)],
                    )
                  : null,
              color: isEnabled ? null : Colors.white.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isEnabled ? 1 : 0.6),
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

class _HostActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HostActionButton({required this.label, required this.onPressed});

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
              gradient: LinearGradient(colors: [Color(0xFF9B6CFF), Color(0xFF6EA8FF)]),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
