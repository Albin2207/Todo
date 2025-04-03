import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_firebase/controllers/database_service.dart';
import 'package:todo_app_firebase/provider/user_provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = user.name;
    _emailController.text = user.email;
    _usernameController.text = user.username ?? '';
    _bioController.text = user.bio ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildTextFormField(
                  _nameController, 
                  "Name", 
                  "Enter your name",
                ),
                const SizedBox(height: 16),
                
                _buildTextFormField(
                  _emailController, 
                  "Email", 
                  "Email address",
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                
                _buildTextFormField(
                  _usernameController, 
                  "Username", 
                  "Choose a username",
                ),
                const SizedBox(height: 16),
                
                _buildTextFormField(
                  _bioController, 
                  "Bio", 
                  "Tell us about yourself",
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, 
      String labelText, 
      String hintText, {
      bool readOnly = false,
      int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) =>
          value!.isEmpty && labelText == "Name" ? "Name cannot be empty." : null,
    );
  }

  Future<void> _handleSubmit() async {
    if (formKey.currentState!.validate()) {
      var data = {
        "name": _nameController.text,
        "email": _emailController.text,
        "username": _usernameController.text,
        "bio": _bioController.text,
      };
      await DbService().updateUserData(extraData: data);
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profile Updated")));
    }
  }
}