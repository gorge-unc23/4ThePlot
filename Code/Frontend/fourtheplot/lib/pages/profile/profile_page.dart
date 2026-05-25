import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/event_details/event_details_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Event> _hostedEvents = const [];
  List<Event> _upcomingJoinedEvents = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileEvents();
  }

  Future<void> _loadProfileEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _refreshLoggedInUser();
    if (!mounted) return;

    if (MainWrapper.loggedInUser.role == UserRole.business ||
        MainWrapper.loggedInUser.role == UserRole.admin) {
      setState(() {
        _hostedEvents = const [];
        _upcomingJoinedEvents = const [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    final userId = MainWrapper.loggedInUser.id;
    final results = await Future.wait([
      DatabaseHelper.instance.getEventsByHostId(userId),
      DatabaseHelper.instance.getRegisteredEvents(userId),
    ]);
    if (!mounted) {
      return;
    }

    final hostedResult = results[0];
    final registeredResult = results[1];
    if (!hostedResult.success || !registeredResult.success) {
      setState(() {
        _isLoading = false;
        _errorMessage = !hostedResult.success
            ? hostedResult.message
            : registeredResult.message;
      });
      return;
    }

    final now = DateTime.now();
    final hostedEvents = _eventsFromResult(hostedResult)..sort(_sortByStartDate);
    final upcomingJoinedEvents = _eventsFromResult(
      registeredResult,
    ).where((event) => !event.startAt.isBefore(now)).toList()..sort(_sortByStartDate);

    setState(() {
      _hostedEvents = hostedEvents;
      _upcomingJoinedEvents = upcomingJoinedEvents;
      _isLoading = false;
    });
  }

  Future<void> _refreshLoggedInUser() async {
    final result = await DatabaseHelper.instance.getUser(MainWrapper.loggedInUser.id);
    if (!mounted || !result.success || result.data is! User) {
      return;
    }

    final user = result.data as User;
    MainWrapper.loggedInUser = user;
    await DatabaseHelper.instance.saveUser(user);
    if (!mounted) return;
    setState(() {});
  }

  List<Event> _eventsFromResult(ApiResult result) {
    return (result.data as List<dynamic>? ?? const []).whereType<Event>().toList();
  }

  int _sortByStartDate(Event a, Event b) {
    return a.startAt.compareTo(b.startAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _loadProfileEvents,
          child: ListView(
            children: [
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildSettingsButton(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                MainWrapper.loggedInUser.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (MainWrapper.loggedInUser.hostCredibility?.trusted ==
                                true) ...[
                              const SizedBox(width: 8),
                              _buildVerifiedRibbon(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MainWrapper.loggedInUser.email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (MainWrapper.loggedInUser.role != UserRole.business &&
                  MainWrapper.loggedInUser.role != UserRole.admin) ...[
                _buildStatsPill(),
                const SizedBox(height: 20),
              ],
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (MainWrapper.loggedInUser.role == UserRole.business) {
      return _buildBusinessProfileContent();
    }

    if (MainWrapper.loggedInUser.role == UserRole.admin) {
      return _buildAdminProfileContent();
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              'Could not load profile events: $_errorMessage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadProfileEvents, child: const Text('Try again')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGoerPreferencesContent(),
        const SizedBox(height: 20),
        _buildEventSection(
          icon: Icons.storefront,
          iconColor: const Color.fromARGB(255, 238, 187, 34),
          title: 'Hosted Events',
          emptyText: 'You are not hosting any events yet.',
          events: _hostedEvents,
        ),
        const SizedBox(height: 20),
        _buildEventSection(
          icon: Icons.event_available,
          iconColor: const Color(0xFFC084FC),
          title: 'Upcoming Events',
          emptyText: 'You have not joined any upcoming events.',
          events: _upcomingJoinedEvents,
        ),
      ],
    );
  }

  Widget _buildGoerPreferencesContent() {
    final categories = MainWrapper.loggedInUser.goerPreferences?.categories ?? const [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.interests_outlined, color: Color(0xFF22D3EE)),
              SizedBox(width: 8),
              Text(
                'Goer preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (categories.isEmpty)
            Text(
              'No preferred categories selected yet.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (category) => _buildPreferenceChip(
                      category,
                      const Color(0xFFC084FC),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferenceChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBusinessProfileContent() {
    final businessProfile = MainWrapper.loggedInUser.businessProfile;
    final name = businessProfile?.name.isNotEmpty == true
        ? businessProfile!.name
        : MainWrapper.loggedInUser.displayName;
    final description = businessProfile?.description?.trim();
    final websiteUrl = businessProfile?.websiteUrl?.trim();
    final isPublished = businessProfile?.isPublished ?? false;
    final hostCredibility = MainWrapper.loggedInUser.hostCredibility;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBusinessLogo(businessProfile?.logoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPublished
                          ? 'Published business profile'
                          : 'Draft business profile',
                      style: TextStyle(
                        color: (isPublished ? const Color(0xFF22D3EE) : Colors.white)
                            .withValues(alpha: isPublished ? 1 : 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), height: 1.45),
            ),
          ],
          if (websiteUrl != null && websiteUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    websiteUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _buildHostCredibilitySummary(
            rating: hostCredibility?.rating,
            reviewCount: hostCredibility?.reviewCount,
            trusted: hostCredibility?.trusted,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileContent() {
    final user = MainWrapper.loggedInUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF6EA8FF).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Administrator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Platform moderation access',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdminInfoRow('Name', user.displayName),
          _buildAdminInfoRow('Email', user.email),
          _buildAdminInfoRow('Role', userRoleToString(user.role)),
          _buildAdminInfoRow('Status', userStatusToString(user.status)),
        ],
      ),
    );
  }

  Widget _buildAdminInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostCredibilitySummary({
    required double? rating,
    required int? reviewCount,
    required bool? trusted,
  }) {
    final clampedRating = (rating ?? 0).clamp(0, 5).toDouble();
    final fullStars = clampedRating.floor();
    final hasHalfStar = clampedRating - fullStars >= 0.5 && fullStars < 5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: Color(0xFF22D3EE), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Host credibility',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (trusted == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22D3EE).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Trusted',
                    style: TextStyle(
                      color: Color(0xFF22D3EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                IconData icon;
                if (index < fullStars) {
                  icon = Icons.star;
                } else if (index == fullStars && hasHalfStar) {
                  icon = Icons.star_half;
                } else {
                  icon = Icons.star_border;
                }
                return Icon(icon, size: 20, color: const Color(0xFFFACC15));
              }),
              const SizedBox(width: 10),
              Text(
                clampedRating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Text(
                '(${reviewCount ?? 0} reviews)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessLogo(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.storefront, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        logoUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 56,
          height: 56,
          color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
          child: const Icon(Icons.storefront, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String emptyText,
    required List<Event> events,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          _buildEmptyCard(emptyText)
        else
          ...events.map(_buildProfileEventCard),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (context) => SettingsPage()));
        },
        icon: const Icon(Icons.settings, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = MainWrapper.loggedInUser.avatarUrl?.trim();
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return _buildAvatarFallback();
    }

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF48C6EF), Color(0xFF6F86FF)]),
      ),
      child: Center(
        child: Text(
          _initials(MainWrapper.loggedInUser.displayName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22D3EE).withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: Color(0xFF22D3EE)),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildStatsPill() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            _isLoading ? '-' : _hostedEvents.length.toString(),
            'Events hosted',
            const Color(0xFF22D3EE),
          ),
          _buildDivider(),
          _buildStatItem(
            _isLoading ? '-' : _upcomingJoinedEvents.length.toString(),
            'Events upcoming',
            const Color(0xFFC084FC),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.65))),
    );
  }

  Widget _buildProfileEventCard(Event event) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B1F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                event.coverImageUrl,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 62,
                  height: 62,
                  color: Colors.white.withValues(alpha: 0.08),
                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, h:mm a').format(event.startAt),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location.venueName?.isNotEmpty == true
                              ? event.location.venueName!
                              : event.location.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
