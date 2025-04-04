import 'package:flutter/material.dart';
import 'package:todo_app_firebase/controllers/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final secondaryTextColor = textColor.withOpacity(0.7);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Animated header section
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .9,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create a new account and get started",
                              style: TextStyle(
                                fontSize: 16,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    // Animated form fields with icons
                    ..._buildAnimatedFormFields(
                      primaryColor: primaryColor,
                      backgroundColor: backgroundColor, 
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor
                    ),
                    const SizedBox(height: 20),
                    // Enhanced signup button with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.95 + (0.05 * value),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              AuthService()
                                  .createAccountWithEmail(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                              )
                                  .then((value) {
                                setState(() => _isLoading = false);
                                if (value == "Account created. Please verify your email.") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Account Created")));
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Text("Email Verification", style: TextStyle(color: textColor)),
                                      content: Text(
                                        "A verification email has been sent to ${_emailController.text}. Please verify your email and then log in.",
                                        style: TextStyle(color: secondaryTextColor),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Text("OK", style: TextStyle(color: primaryColor)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      value,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                  ));
                                }
                              });
                            }
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.person_add_outlined),
                                      SizedBox(width: 8),
                                      Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Enhanced login link with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedFormFields({
    required Color primaryColor,
    required Color backgroundColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final fields = [
      _buildTextField(
        controller: _nameController,
        label: "Name",
        icon: Icons.person_outlined,
        validator: (value) => value!.isEmpty ? "Name cannot be empty." : null,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      ),
      _buildTextField(
        controller: _emailController,
        label: "Email",
        icon: Icons.email_outlined,
        validator: (value) {
          if (value!.isEmpty) {
            return "Email cannot be empty.";
          }
          String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
          RegExp regex = RegExp(pattern);
          if (!regex.hasMatch(value)) {
            return "Enter a valid email address.";
          }
          return null;
        },
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      ),
      _buildTextField(
        controller: _passwordController,
        label: "Password",
        icon: Icons.lock_outlined,
        isPassword: true,
        obscureText: _obscurePassword,
        onToggleVisibility: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        validator: (value) =>
            value!.length < 8 ? "Password should have at least 8 characters." : null,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      ),
      _buildTextField(
        controller: _confirmPasswordController,
        label: "Confirm Password",
        icon: Icons.lock_outlined,
        isPassword: true,
        obscureText: _obscureConfirmPassword,
        onToggleVisibility: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
        validator: (value) =>
            value != _passwordController.text ? "Passwords do not match." : null,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      ),
    ];

    return List.generate(fields.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .9,
            child: fields[index],
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FormFieldValidator<String> validator,
    required Color primaryColor,
    required Color backgroundColor,
    required Color textColor,
    required Color secondaryTextColor,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: secondaryTextColor),
        hintText: "Enter your $label",
        hintStyle: TextStyle(color: secondaryTextColor),
        labelText: label,
        labelStyle: TextStyle(color: secondaryTextColor),
        filled: true,
        fillColor: backgroundColor.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    key: ValueKey<bool>(obscureText),
                    color: secondaryTextColor,
                  ),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}