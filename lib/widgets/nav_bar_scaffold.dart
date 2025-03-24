import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../views/home/home_screen.dart';
import '../views/booking/bookings_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/help/about_us_screen.dart';
import '../views/help/help_faq_page.dart';

class NavBarScaffold extends StatefulWidget {
  final String title;
  final Widget body;

  const NavBarScaffold({Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  _NavBarScaffoldState createState() => _NavBarScaffoldState();
}

class _NavBarScaffoldState extends State<NavBarScaffold> {
  Widget _buildDrawer(UserProvider userProvider) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[900]!, Colors.grey[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black,
                    backgroundImage: (userProvider.currentUser != null &&
                            userProvider.currentUser!.profileImage != null &&
                            userProvider.currentUser!.profileImage!.isNotEmpty)
                        ? FileImage(
                            File(userProvider.currentUser!.profileImage!))
                        : null,
                    child: (userProvider.currentUser == null ||
                            userProvider.currentUser!.profileImage == null ||
                            userProvider.currentUser!.profileImage!.isEmpty)
                        ? const Icon(Icons.person,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProvider.currentUser?.name ?? 'Guest',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    userProvider.currentUser?.email ?? 'Not Logged In',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Profile Expansion Tile
            ExpansionTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title:
                  const Text("Profile", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black45,
              collapsedBackgroundColor: Colors.transparent,
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.account_circle, color: Colors.white70),
                  title: const Text("My Profile",
                      style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => UserProfileScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.movie, color: Colors.white70),
                  title: const Text("My Bookings",
                      style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BookingListScreen()));
                  },
                ),
              ],
            ),
            // Help/FAQ and About Us
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title:
                  const Text("Help/FAQ", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HelpFaqPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title:
                  const Text("About Us", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()));
              },
            ),
            const Divider(color: Colors.white54, thickness: 1),
            // Login/Logout
            ListTile(
              leading: Icon(
                userProvider.isAuthenticated ? Icons.logout : Icons.login,
                color: userProvider.isAuthenticated ? Colors.red : Colors.green,
              ),
              title: Text(
                userProvider.isAuthenticated ? "Logout" : "Login",
                style: TextStyle(
                  color:
                      userProvider.isAuthenticated ? Colors.red : Colors.green,
                ),
              ),
              onTap: () {
                if (userProvider.isAuthenticated) {
                  userProvider.logout();
                  Navigator.pushReplacementNamed(context, "/login");
                } else {
                  Navigator.pushNamed(context, "/login");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: _buildDrawer(userProvider),
      body: widget.body,
    );
  }
}
