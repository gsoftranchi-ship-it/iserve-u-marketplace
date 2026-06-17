  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    State<RegisterPage> createState() => _RegisterPageState();
  }

  class _RegisterPageState extends State<RegisterPage> {
    final _formKey = GlobalKey<FormState>();

    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    bool _isLoading = false;
    bool _isObscured = true;
    bool _isConfirmObscured = true;

    // 🚀 REGISTRATION LOGIC WITH FIRESTORE
    Future<void> _register() async {

      if (!_formKey.currentState!.validate()) return;

      setState(() => _isLoading = true);

      try {

        // ✅ Create User
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // ✅ Save User in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({

          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'client',
          'active': true,
          'deliveryRequest': false,
          'createdAt': FieldValue.serverTimestamp(),

        });

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }

      } catch (e) {

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Registration Failed: ${e.toString()}"),
              backgroundColor: Colors.red,
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

        body: Stack(
          children: [

            // 🌊 BACKGROUND
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // ✅ INFO SECTION
                      _buildInfoSection(),

                      const SizedBox(width: 60),

                      // ✅ REGISTER CARD
                      _buildRegisterCard(isWide),

                    ],
                  )

                  // 📱 MOBILE VIEW
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      _buildRegisterCard(isWide),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ ADD THIS SECTION TO FIX THE ERROR
    Widget _buildInfoSection() {
      return SizedBox(
        width: 400,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Join iserve-u",
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Partner with India's fastest-growing enterprise delivery network.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 40),

            _infoRow(
              Icons.verified_user_outlined,
              "Secure Partner Portal",
            ),

            _infoRow(
              Icons.speed,
              "Real-time Order Management",
            ),

            _infoRow(
              Icons.support_agent,
              "24/7 Corporate Support",
            ),
          ],
        ),
      );
    }

    // ✅ Helper for the Info Rows
    Widget _infoRow(IconData icon, String text) {

      return Padding(
        padding: const EdgeInsets.only(bottom: 15),

        child: Row(
          children: [

            Icon(
              icon,
              color: const Color(0xFFFF6A00),
              size: 24,
            ),

            const SizedBox(width: 15),

            Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // ✅ REGISTER CARD
    Widget _buildRegisterCard(bool isWide) {

      return Container(

        width: isWide
            ? 450
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

              const Text(
                "Partner Registration",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A2540),
                ),
              ),

              const SizedBox(height: 25),

              _buildTextField(
                "Full Name / Business Name",
                Icons.person_outline,
                _nameController,
              ),

              const SizedBox(height: 15),

              _buildTextField(
                "Email Address",
                Icons.email_outlined,
                _emailController,
                isEmail: true,
              ),

              const SizedBox(height: 15),

              _buildTextField(
                "Create Password",
                Icons.lock_outline,
                _passwordController,

                isPassword: true,

                obscure: _isObscured,

                onToggle: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),

              const SizedBox(height: 15),

              _buildTextField(
                "Confirm Password",
                Icons.lock_reset,
                _confirmPasswordController,

                isConfirm: true,

                obscure: _isConfirmObscured,

                onToggle: () {
                  setState(() {
                    _isConfirmObscured =
                    !_isConfirmObscured;
                  });
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  onPressed:
                  _isLoading ? null : _register,

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

                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )

                      : const Text(
                    "CREATE PARTNER ACCOUNT",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Already a partner? Login",

                  style: TextStyle(
                    color: Color(0xFF0A2540),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ TEXT FIELD
    Widget _buildTextField(
        String label,
        IconData icon,
        TextEditingController controller, {

          bool isPassword = false,
          bool isEmail = false,
          bool isConfirm = false,
          bool? obscure,
          VoidCallback? onToggle,
        }) {

      return TextFormField(

        controller: controller,

        obscureText: obscure ?? false,

        style: const TextStyle(fontSize: 14),

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Icon(
            icon,
            color: const Color(0xFF0A2540),
            size: 20,
          ),

          // ✅ PASSWORD VIEW ICON
          suffixIcon: (isPassword || isConfirm)

              ? IconButton(
            icon: Icon(
              obscure!
                  ? Icons.visibility_off
                  : Icons.visibility,

              size: 20,
            ),

            onPressed: onToggle,
          )

              : null,

          filled: true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),

            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),

        validator: (value) {

          if (value == null || value.isEmpty) {
            return 'Required';
          }

          if (isEmail && !value.contains("@")) {
            return 'Invalid Email';
          }

          if (isPassword && value.length < 6) {
            return 'Minimum 6 chars';
          }

          if (isConfirm &&
              value != _passwordController.text) {
            return 'Passwords do not match';
          }

          return null;
        },
      );
    }
  }