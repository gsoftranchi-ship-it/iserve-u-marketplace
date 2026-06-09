import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // 🚀 RESET PASSWORD LOGIC
  Future<void> _resetPassword() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Success! Password reset link sent to your email.",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
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

    // ✅ Responsive Check
    final bool isWide =
        MediaQuery.of(context).size.width > 900;

    return Scaffold(

      body: Stack(
        children: [

          // 🌊 ENTERPRISE BACKGROUND
          Container(
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
          ),

          Center(
            child: SingleChildScrollView(

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                child: isWide

                // 🖥️ WEB VIEW
                    ? Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    // ✅ INFO SECTION
                    _buildInfoSection(),

                    const SizedBox(width: 60),

                    // ✅ RESET CARD
                    _buildResetCard(isWide),
                  ],
                )

                // 📱 MOBILE VIEW
                    : Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    _buildResetCard(isWide),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ADD THIS TO FIX THE ERROR
  Widget _buildInfoSection() {

    return SizedBox(
      width: 400,

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(
            "Account Recovery",

            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Don't worry, it happens to the best of us. Let's get you back to work.",

            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ RESET CARD
  Widget _buildResetCard(bool isWide) {

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
          )
        ],
      ),

      child: Form(

        key: _formKey,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            const Icon(
              Icons.lock_reset,
              size: 60,
              color: Color(0xFFFF6A00),
            ),

            const SizedBox(height: 20),

            const Text(
              "Reset Password",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A2540),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter your registered email below",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 35),

            // ✅ EMAIL FIELD
            TextFormField(

              controller: _emailController,

              keyboardType:
              TextInputType.emailAddress,

              style: const TextStyle(fontSize: 14),

              decoration: InputDecoration(

                labelText: "Email Address",

                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF0A2540),
                  size: 20,
                ),

                filled: true,

                fillColor: Colors.grey.shade100,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),

                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),

              validator: (v) {

                if (v == null || !v.contains("@")) {
                  return "Enter a valid corporate email";
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            // ✅ RESET BUTTON
            SizedBox(

              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed:
                _isLoading ? null : _resetPassword,

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFFFF6A00),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: _isLoading

                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )

                    : const Text(
                  "SEND RESET LINK",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Back to Login",

                style: TextStyle(
                  color: Color(0xFF0A2540),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}