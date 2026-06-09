import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

    } on FirebaseAuthException catch (e) {

      String message = "Login failed";

      switch (e.code) {

        case 'user-not-found':
          message = "No account found";
          break;

        case 'wrong-password':
          message = "Incorrect password";
          break;

        case 'invalid-email':
          message = "Invalid email address";
          break;

        case 'network-request-failed':
          message = "Network connection issue";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Try later.";
          break;
      }

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(message),

            backgroundColor: Colors.red,

            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(
              "Login Failed: ${e.toString()}",
            ),

            backgroundColor: Colors.red,

            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } finally {

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final bool isWide =
        MediaQuery.of(context).size.width > 900;

    return Scaffold(

      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [

          _buildAnimatedBackground(),

          SafeArea(
            child: Center(

              child: SingleChildScrollView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                child: isWide

                    ? Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  crossAxisAlignment:
                  CrossAxisAlignment.center,

                  children: [

                    _buildInfoSection(),

                    const SizedBox(width: 60),

                    _buildLoginCard(isWide),
                  ],
                )

                    : Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    _buildLoginCard(isWide),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BACKGROUND
  // =========================================================

  Widget _buildAnimatedBackground() {

    return Container(

      decoration: const BoxDecoration(

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFF0A2540),
            Color(0xFF1B3B5A),
            Color(0xFF0A2540),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFO SECTION
  // =========================================================

  Widget _buildInfoSection() {

    return SizedBox(

      width: 400,

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(
            "iserve-u",

            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Empowering Businesses with Digital Excellence.",

            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 30),

          _buildInfoRow(
            Icons.check_circle_outline,
            "Enterprise Marketplace Solutions",
          ),

          _buildInfoRow(
            Icons.check_circle_outline,
            "Corporate Food & Dining Management",
          ),

          _buildInfoRow(
            Icons.check_circle_outline,
            "Advanced Real-time Analytics",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String text,
      ) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        children: [

          Icon(
            icon,
            color: const Color(0xFFFF6A00),
            size: 24,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LOGIN CARD
  // =========================================================

  Widget _buildLoginCard(bool isWide) {

    return Container(

      width: isWide
          ? 400
          : MediaQuery.of(context).size.width * 0.95,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),

      child: Form(

        key: _formKey,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Image.asset(
              'assets/images/logo.png',

              height: 80,

              errorBuilder:
                  (context, error, stackTrace) {

                return const Icon(
                  Icons.business,
                  size: 60,
                  color: Colors.orange,
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome Back",

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A2540),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Login to your corporate dashboard",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 30),

            _buildTextField(
              "Email Address",
              Icons.email_outlined,
              _emailController,
              isEmail: true,
            ),

            const SizedBox(height: 15),

            _buildTextField(
              "Password",
              Icons.lock_outline,
              _passwordController,
              isPassword: true,
            ),

            const SizedBox(height: 25),

            SizedBox(

              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed:
                _isLoading ? null : _login,

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFFFF6A00),

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: _isLoading

                    ? const SizedBox(
                  height: 22,
                  width: 22,

                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )

                    : const Text(
                  "LOGIN TO DASHBOARD",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(

              onPressed: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) =>
                    const ForgotPasswordPage(),
                  ),
                );
              },

              child: const Text(
                "Forgot Password?",

                style: TextStyle(
                  color: Color(0xFF0A2540),
                ),
              ),
            ),

            const Divider(height: 30),

            FittedBox(

              fit: BoxFit.scaleDown,

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    "New partner? ",

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  TextButton(

                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const RegisterPage(),
                        ),
                      );
                    },

                    child: const Text(
                      "Create Account",

                      style: TextStyle(
                        color: Color(0xFFFF6A00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {

        bool isPassword = false,
        bool isEmail = false,
      }) {

    return TextFormField(

      controller: controller,

      obscureText:
      isPassword ? _isObscured : false,

      keyboardType:
      isEmail
          ? TextInputType.emailAddress
          : TextInputType.text,

      textInputAction:
      isPassword
          ? TextInputAction.done
          : TextInputAction.next,

      onFieldSubmitted: (_) {
        if (isPassword) {
          _login();
        }
      },

      style: const TextStyle(
        fontSize: 14,
      ),

      decoration: InputDecoration(

        labelText: label,

        prefixIcon: Icon(
          icon,
          color: const Color(0xFF0A2540),
          size: 20,
        ),

        suffixIcon: isPassword

            ? IconButton(

          icon: Icon(
            _isObscured
                ? Icons.visibility_off
                : Icons.visibility,

            size: 20,
          ),

          onPressed: () {

            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )

            : null,

        filled: true,

        fillColor: Colors.grey.shade100,

        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(12),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(12),

          borderSide: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),

      validator: (value) {

        if (value == null || value.isEmpty) {
          return 'Required';
        }

        if (isEmail &&
            !value.contains('@')) {
          return 'Enter valid email';
        }

        if (isPassword &&
            value.length < 6) {
          return 'Minimum 6 characters';
        }

        return null;
      },
    );
  }
}