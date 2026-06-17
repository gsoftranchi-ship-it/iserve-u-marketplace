import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../marketplace/ads_list_page.dart';
import '../food_dining/food_page.dart';
import '../admin/orders_page.dart';
import '../profile/profile_page.dart';
import '../../core/widgets/update_checker.dart';
import 'package:flutter/scheduler.dart';
import '../../features/restaurant/restaurant_dashboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/support/pages/support_page.dart';
import '../../features/notifications/services/notifications_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iserve_u/features/support/admin/admin_tickets_page.dart';
import '../admin/partner_approval_page.dart';
import '../../screens/admin/advertisement_management_page.dart';

class HomePage extends StatefulWidget {
  final String userRole;

  const HomePage({
    super.key,
    required this.userRole,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showSalesReportDialog() {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(

        title: const Text(
          'Platform Sales Report',
        ),

        content: StreamBuilder<QuerySnapshot>(

          stream: FirebaseFirestore.instance
              .collection('orders')
              .snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child:
                  CircularProgressIndicator(),
                ),
              );
            }

            int orders = 0;

            double revenue = 0;


            double restaurantEarnings = 0;
            double riderEarnings = 0;
            double platformCommission = 0;

            for (final doc
            in snapshot.data!.docs) {

              final data =
              doc.data()
              as Map<String, dynamic>;

              if ((data['status'] ?? '')
                  .toString()
                  .toUpperCase() ==
                  'DELIVERED') {

                orders++;

                revenue +=
                    (data['totalAmount'] ?? 0)
                        .toDouble();

                platformCommission +=
                    (data['platformCommission'] ?? 0)
                        .toDouble();

                restaurantEarnings +=
                    (data['restaurantEarning'] ?? 0)
                        .toDouble();

                riderEarnings +=
                    (data['deliveryCharge'] ?? 0)
                        .toDouble();
              }
            }
            double avgOrder =
            orders > 0
                ? revenue / orders
                : 0;

            return Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  const Text(
                    "ORDERS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text("Total Orders : $orders"),

                  Text(
                    "Total Revenue : ₹${revenue.toStringAsFixed(0)}",
                  ),

                  const Divider(),

                  const Text(
                    "SETTLEMENTS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Restaurant Payouts : ₹${restaurantEarnings.toStringAsFixed(0)}",
                  ),

                  Text(
                    "Rider Earnings : ₹${riderEarnings.toStringAsFixed(0)}",
                  ),

                  Text(
                    "Platform Commission : ₹${platformCommission.toStringAsFixed(0)}",
                  ),

                  const Divider(),

                  const Text(
                    "PERFORMANCE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Average Order Value : ₹${avgOrder.toStringAsFixed(0)}",
                  ),
                ]
            );
          },
        ),

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context),

            child: const Text(
              'Close',
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance
        .addPostFrameCallback((_) {

      UpdateChecker
          .checkForUpdates(context);
    });
  }

  int _currentIndex = 0;

  List<Widget> get _pages {

    switch (widget.userRole) {
      case 'admin':
      case 'super_admin':
        return [
          _buildDashboard(),
          AdsListPage(
            userRole: widget.userRole,
          ),
          const FoodPage(),
          OrdersPage(
            userRole: widget.userRole,
          ),
          const ProfilePage(),
        ];
      case 'restaurant_partner':
        return [
          _buildDashboard(),
          OrdersPage(userRole: widget.userRole),
          const RestaurantDashboardPage(),
          const ProfilePage(),
        ];

      case 'delivery_partner':
        return [
          _buildDashboard(),
          OrdersPage(userRole: widget.userRole),
          const ProfilePage(),
        ];

      default:
        return [
          _buildDashboard(),
          AdsListPage(
            userRole: widget.userRole,
          ),
          const FoodPage(),
          OrdersPage(
            userRole: widget.userRole,
          ),
          const ProfilePage(),
        ];
    }
  }
  bool get isAdmin =>
      widget.userRole == 'admin' ||
          widget.userRole == 'super_admin';
  void _changePage(int index) {
    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }

  Widget _getBody() {
    if (_currentIndex >= _pages.length) {
      return _pages[0];
    }

    return _pages[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {


   final bool isMobile =
        MediaQuery.of(context).size.width < 768;

    return Scaffold(

      appBar: _buildAppBar(),

      drawer: isMobile ? _buildDrawer() : null,
      drawerEnableOpenDragGesture: true,



      body: Row(
        children: [

          if (!isMobile)
            _buildSideNavigation(),

          Expanded(
            child: Container(
              color: const Color(0xFFF1F3F6),
              child: _getBody(),
            ),
          ),
        ],
      ),

      bottomNavigationBar:
      isMobile ? _buildBottomNav() : null,
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget _buildAppBar() {


    return AppBar(
      elevation: 0,
      leadingWidth: 70,
      leading: Center(
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
        ),
      ),

      title: const Text(
        'iserve-u',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.deepOrangeAccent,
        ),
      ),

      actions: [
        IconButton(

          tooltip: 'Support Tickets',

          icon: const Icon(
            Icons.headset_mic,
            color: Colors.blueAccent,
          ),

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const SupportPage(),
              ),
            );
          },
        ),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .limit(50)
              .snapshots(),

          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length ?? 0;

            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                  ),
                );
               },

                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.brown,
                      size: 28,
                    ),

                    if (count > 0)
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
            ),
           ],
                    ),
                ),

         );
       },
      ),

        PopupMenuButton<int>(

          tooltip: "Account",

          color: Colors.white,

          elevation: 8,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          icon: const Padding(
            padding: EdgeInsets.only(right: 12),

            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.orange,

              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          onSelected: (value) async {

            switch (value) {

              case 0:
                _changePage(_pages.length - 1);
                break;

              case 1:
                await _logout();
                break;
            }
          },

          itemBuilder: (context) => [

            const PopupMenuItem(
              value: 0,

              child: Row(
                children: [

                  Icon(
                    Icons.business_center_outlined,
                    size: 20,
                  ),

                  SizedBox(width: 10),

                  Text("Profile"),
                ],
              ),
            ),

            const PopupMenuDivider(),

            const PopupMenuItem(
              value: 1,

              child: Row(
                children: [

                  Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.red,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // DASHBOARD
  // =========================================================

  Widget _buildDashboard() {

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 768 ? 12 : 24,
        vertical: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          _buildHeroBanner(),

          const SizedBox(height: 12),
          const Text(
            "Explore iServe-U Services",

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0A2540),
            ),
          ),

          const SizedBox(height: 12),

          _buildServiceGrid(),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {

    final isDesktop =
        MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Container(

        height: 290,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),

          child: Stack(
            fit: StackFit.expand,

            children: [

              Image.asset(
                'assets/images/hero.png',
                fit: BoxFit.cover,
              ),

              Positioned(
                left: 60,
                top: 35,

                child: SizedBox(
                  width: 420,
                  child: _buildHeroText(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
        aspectRatio: 0.72,
        child: Container(
          width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),

        child: Stack(
          fit: StackFit.expand,

          children: [

            Image.asset(
              'assets/images/hero_mobile.png',
              fit: BoxFit.cover,
            ),

            Positioned(
              top: 22,
              left: 22,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  'ENTERPRISE READY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 210,
              left: 22,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(
                      'https://aarthik-udaan-clean.web.app/iserve-u.apk',
                    ),
                    webOnlyWindowName: '_blank',
                  );
                },

                icon: const Icon(
                  Icons.download,
                  size: 16,
                ),

                label: const Text(
                  'Download App',
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 90,
              left: 22,

              child: SizedBox(
                width: 220,

                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    children: [

                      TextSpan(
                        text: 'One Platform.\n',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      TextSpan(
                        text: 'Endless\n',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      TextSpan(
                        text: 'Possibilities.',
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ],
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

  Widget _buildHeroText() {

    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),

          child: const Text(
            'ENTERPRISE READY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'One Platform.\nEndless Possibilities.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
    'Food Delivery • Tiffin Service\nAdvertisements • Marketplace',
          style: TextStyle(
            color: Colors.yellowAccent,
            fontSize: 16,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: () async {
            await launchUrl(
              Uri.parse(
                'https://aarthik-udaan-clean.web.app/iserve-u.apk',
              ),
              webOnlyWindowName: '_blank',
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Download Android App'),
        ),
      ],
    );
  }
  // =========================================================
  // SERVICE GRID
  // =========================================================

  Widget _buildServiceGrid() {


    return LayoutBuilder(

      builder: (context, constraints) {

        return GridView.count(

          shrinkWrap: true,

          physics:
          const NeverScrollableScrollPhysics(),

          crossAxisCount:
          constraints.maxWidth > 1100
              ? 3
              : (constraints.maxWidth < 700 ? 1 : 2),

          mainAxisSpacing: 20,
          crossAxisSpacing: 20,

          childAspectRatio:
          MediaQuery.of(context).size.width < 768
              ? 1.1
              : 1.2,

          children: [

            if (widget.userRole != 'restaurant_partner' &&
                widget.userRole != 'delivery_partner')
              _serviceCard(
                "Offers & Promotions",
                Icons.local_offer,
                Colors.blue,
                "Local Deals & Services",
                    () => _changePage(1),
              ),
            if (isAdmin)
              _serviceCard(
                "Advertisements",
                Icons.campaign,
                Colors.deepPurple,
                "Approve Ads & Payments",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AdvertisementManagementPage(),
                    ),
                  );
                },
              ),

            if (widget.userRole != 'restaurant_partner' &&
                widget.userRole != 'delivery_partner')

              _serviceCard(
                "Food Service",
                Icons.restaurant,
                Colors.orange,
                "Dining & Pantry",
                    () => _changePage(2),
              ),

            _serviceCard(
              "Track Orders",
              Icons.receipt_long,
              Colors.green,
              "Live Status",
                  () {

                if (widget.userRole == 'restaurant_partner') {
                  _changePage(1);
                } else if (widget.userRole == 'delivery_partner') {
                  _changePage(1);
                } else {
                  _changePage(3);
                }
              },
            ),
            if (widget.userRole == 'restaurant_partner')

              _serviceCard(
                "Restaurant",
                Icons.restaurant_menu,
                Colors.deepOrange,
                "Manage Orders & Menu",
                    () => _changePage(2),
              ),

            if (isAdmin)
              _serviceCard(
                "Support Tickets",
                Icons.support_agent,
                Colors.teal,
                "Customer Support Desk",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AdminTicketsPage(),
                    ),
                  );
                },
              ),
            if (isAdmin)
              _serviceCard(
                "Sales Report",
                Icons.analytics,
                Colors.green,
                "Revenue & Commission",
                    () {
                  _showSalesReportDialog();
                },
              ),

        if (isAdmin)
          _serviceCard(
            "Partner Approvals",
              Icons.verified_user,
              Colors.green,
              "Approve Partners",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const PartnerApprovalPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }



  Widget _serviceCard(

      String title,
      IconData icon,
      Color color,
      String sub,
      VoidCallback onTap,
      ) {


      return Container(

      margin: const EdgeInsets.all(8),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Card(

        elevation: 0,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(20),

          side: BorderSide(
            color: Colors.grey.withValues(alpha:0.1),
          ),
        ),

        child: InkWell(

          onTap: onTap,

          borderRadius: BorderRadius.circular(20),

          child: Stack(
            children: [

              Positioned(
                right: -15,
                bottom: -15,

                child: Icon(
                  icon,
                  size: 100,
                  color: color.withValues(alpha:0.06),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF0A2540),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // NAVIGATION
  // =========================================================
  Widget _buildSideNavigation() {
    if (widget.userRole == 'restaurant_partner') {
      return NavigationRail(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changePage,
        labelType: NavigationRailLabelType.all,
        destinations: const [

          NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text("Home"),
          ),

          NavigationRailDestination(
            icon: Icon(Icons.receipt_long),
            label: Text("Orders"),
          ),

          NavigationRailDestination(
            icon: Icon(Icons.restaurant_menu),
            label: Text("Restaurant"),
          ),

          NavigationRailDestination(
            icon: Icon(Icons.person),
            label: Text("Profile"),
          ),
        ],
      );
    }

    if (widget.userRole == 'delivery_partner') {
      return NavigationRail(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changePage,
        labelType: NavigationRailLabelType.all,
        destinations: const [

          NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text("Home"),
          ),

          NavigationRailDestination(
            icon: Icon(Icons.receipt_long),
            label: Text("Orders"),
          ),

          NavigationRailDestination(
            icon: Icon(Icons.person),
            label: Text("Profile"),
          ),
        ],
      );
    }


    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: _changePage,
      labelType: NavigationRailLabelType.all,
      destinations: const [

        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text("Home"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.campaign),
          label: Text("Ads"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.restaurant),
          label: Text("Food"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.receipt_long),
          label: Text("Orders"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text("Profile"),
        ),
      ],
    );
  }


  Widget _buildBottomNav() {

    if (widget.userRole == 'restaurant_partner') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changePage,
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Restaurant",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      );
    }

    if (widget.userRole == 'delivery_partner') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changePage,
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      );
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _changePage,
      selectedItemColor: Colors.orange,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign),
          label: "Ads",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: "Food",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }

  Widget _buildDrawer() {

    return Drawer(

      child: ListView(
        children: [

          const DrawerHeader(

            decoration: BoxDecoration(
              color: Color(0xFF0A2540),
            ),

            child: Text(
              "iserve-u",

              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),

            onTap: () {
              _changePage(0);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text("Ads"),

            onTap: () {
              _changePage(1);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}