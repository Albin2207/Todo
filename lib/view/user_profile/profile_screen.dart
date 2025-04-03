import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_firebase/provider/user_provider.dart';
import 'package:todo_app_firebase/view/update_user_profile/update_profile_screen.dart';
import 'package:todo_app_firebase/view/user_profile/widgets/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User avatar
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.yellow[300],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: authProvider.profileImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              authProvider.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // User info
              Text(
                authProvider.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (authProvider.username != null && authProvider.username!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "@${authProvider.username}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  authProvider.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              
              // Bio section
              if (authProvider.bio != null && authProvider.bio!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bio",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Edit profile button
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateProfile(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Edit Profile"),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              
              // Profile options
              _buildOptionsCard(context),
              
              const SizedBox(height: 24),
              
              // Logout Button
              LogoutButton(authProvider: authProvider),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            context: context,
            title: 'Task Statistics',
            icon: Icons.bar_chart_outlined,
            onPress: () => Navigator.pushNamed(context, "/statistics"),
          ),
          _buildDivider(),
          _buildOptionTile(
            context: context,
            title: 'App Settings',
            icon: Icons.settings_outlined,
            onPress: () => Navigator.pushNamed(context, "/settings"),
          ),
          _buildDivider(),
          _buildOptionTile(
            context: context,
            title: 'Help & Support',
            icon: Icons.support_agent,
            onPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Contact us at support@todoapp.com",
                    style: TextStyle(fontSize: 14),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPress,
  }) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onPress,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 0.5,
      endIndent: 16,
      indent: 16,
      height: 1,
      color: Colors.grey,
    );
  }
}