import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/add_event/add_event_flow_root.dart';
import 'package:fourtheplot/pages/admin/admin_dashboard_page.dart';
import 'package:fourtheplot/pages/admin/admin_events_page.dart';
import 'package:fourtheplot/pages/calendar/calendar_page.dart';
import 'package:fourtheplot/pages/discover/discover_page.dart';
import 'package:fourtheplot/pages/hosted_business_events/hosted_business_events_page.dart';
import 'package:fourtheplot/pages/map/map_page.dart';
import 'package:fourtheplot/pages/profile/profile_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainWrapper extends StatefulWidget {
  static late User loggedInUser;
  static _MainWrapperState? _activeState;

  const MainWrapper({super.key});

  static void refresh() {
    _activeState?.refresh();
  }

  static void refreshFrom(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainWrapperState>() ?? _activeState;
    state?.refresh();
  }

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    MainWrapper._activeState = this;
  }

  @override
  void dispose() {
    if (MainWrapper._activeState == this) {
      MainWrapper._activeState = null;
    }
    super.dispose();
  }

  void refresh() {
    if (!mounted) {
      return;
    }
    setState(() {
      _refreshVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBackground = isDark ? Colors.black : Colors.white;
    final navBehind = isDark ? const Color(0xFF0F1012) : const Color(0xFFF7F8FC);
    final shadowColor = isDark ? Colors.black : Colors.black.withValues(alpha: 0.12);
    final borderColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.1 : 0.08,
    );

    return KeyedSubtree(
      key: ValueKey(_refreshVersion),
      child: PersistentTabView(
        context,
        screens: _buildScreens(),
        items: _navBarsItems(),
        backgroundColor: navBackground,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          colorBehindNavBar: navBehind,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 14,
              offset: Offset(0, -4),
            ),
            BoxShadow(
              color: borderColor,
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    if (MainWrapper.loggedInUser.role == UserRole.admin) {
      return const [AdminDashboardPage(), AdminEventsPage(), MapPage(), ProfilePage()];
    }

    final homePage = MainWrapper.loggedInUser.role == UserRole.business
        ? const HostedBusinessEventsPage()
        : const DiscoverPage();
    return [homePage, CalendarPage(), AddEventFlowRoot(), MapPage(), ProfilePage()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    if (MainWrapper.loggedInUser.role == UserRole.admin) {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.square_grid_2x2),
          title: "Admin",
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.list_bullet),
          title: "Events",
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.map),
          title: ("Map"),
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.profile_circled),
          title: ("Profile"),
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: MainWrapper.loggedInUser.role == UserRole.business ? "Hosted" : "Home",
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.calendar),
        title: ("Calendar"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.add),
        title: ("Add"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.map),
        title: ("Map"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.profile_circled),
        title: ("Profile"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
}
