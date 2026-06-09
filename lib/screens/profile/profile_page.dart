import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/partner/pages/partner_application_page.dart';
import '../../features/profile/guards/profile_guard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _bioController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _addressController =
  TextEditingController();

  final TextEditingController _landmarkController =
  TextEditingController();

  final TextEditingController _pincodeController =
  TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  XFile? _selectedImage;

  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> _loadProfile() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {

      final doc =
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (doc.exists) {

        final data = doc.data()!;

        _nameController.text =
            data['name'] ?? '';

        _bioController.text =
            data['bio'] ?? '';

        _phoneController.text =
            data['phone'] ?? '';

        _emailController.text =
            data['email'] ?? '';

        _addressController.text =
            data['address'] ?? '';

        _landmarkController.text =
            data['landmark'] ?? '';

        _pincodeController.text =
            data['pincode'] ?? '';

        _profileImageUrl =
        data['profileImage'];

        setState(() {});
      }

    } catch (e) {

      debugPrint(
        "Load Profile Error: $e",
      );
    }
  }

  // =========================================================
  // PICK IMAGE
  // =========================================================

  Future<void> _pickImage() async {

    final picked =
    await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {

      setState(() {

        _selectedImage = picked;
      });
    }
  }

  // =========================================================
  // SAVE PROFILE
  // =========================================================

  Future<void> _saveProfile() async {

    setState(() {
      _isLoading = true;
    });

    try {

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      String imageUrl =
          _profileImageUrl ?? '';

      // UPLOAD IMAGE
      if (_selectedImage != null) {

        final ref =
        FirebaseStorage.instance
            .ref()
            .child(
          'profile_images/${user.uid}.png',
        );

        final bytes =
        await _selectedImage!.readAsBytes();

        await ref.putData(bytes);

        imageUrl =
        await ref.getDownloadURL();
      }

      // SAVE TO FIRESTORE
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .set({

        "name":
        _nameController.text.trim(),

        "bio":
        _bioController.text.trim(),

        "phone":
        _phoneController.text.trim(),

        "email":
        _emailController.text.trim(),

        "address":
        _addressController.text.trim(),

        "landmark":
        _landmarkController.text.trim(),

        "pincode":
        _pincodeController.text.trim(),

        "profileImage":
        imageUrl,

        "updatedAt":
        FieldValue.serverTimestamp(),
      });
      // ALSO UPDATE USERS COLLECTION
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({

        'name':
        _nameController.text.trim(),

        'phone':
        _phoneController.text.trim(),

        'address':
        _addressController.text.trim(),

        'landmark':
        _landmarkController.text.trim(),

      }, SetOptions(
        merge: true,
      ));
      if (!mounted) return;
      setState(() {

        _profileImageUrl =
            imageUrl;

        _isEditing = false;

        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.green,

          content: Text(
            "Profile Updated Successfully!",
          ),
        ),
      );

    } catch (e) {

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.grey.shade50,

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        title: const Text(

          "Business Profile",

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(

            icon: Icon(

              _isEditing
                  ? Icons.close
                  : Icons.edit,
            ),

            onPressed: () {

              setState(() {

                _isEditing =
                !_isEditing;
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              // =========================================================
              // PROFILE IMAGE
              // =========================================================

              Center(

                child: Column(

                  children: [

                    Stack(

                      children: [

                        CircleAvatar(

                          radius: 60,

                          backgroundColor:
                          Colors.orange.shade100,

                          backgroundImage:

                          _selectedImage != null

                              ? NetworkImage(
                            _selectedImage!.path,
                          )

                              : (_profileImageUrl != null &&
                              _profileImageUrl!
                                  .isNotEmpty)

                              ? NetworkImage(
                            _profileImageUrl!,
                          )

                              : null
                          as ImageProvider?,

                          child:

                          _selectedImage == null &&
                              (_profileImageUrl ==
                                  null ||
                                  _profileImageUrl!
                                      .isEmpty)

                              ? const Icon(
                            Icons.business,
                            size: 50,
                            color: Colors.orange,
                          )

                              : null,
                        ),

                        if (_isEditing)

                          Positioned(

                            bottom: 0,
                            right: 0,

                            child: GestureDetector(

                              onTap: _pickImage,

                              child: Container(

                                padding:
                                const EdgeInsets.all(8),

                                decoration:
                                const BoxDecoration(

                                  color: Colors.orange,

                                  shape:
                                  BoxShape.circle,
                                ),

                                child: const Icon(

                                  Icons.camera_alt,

                                  color: Colors.white,

                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (_isEditing)

                      const Text(

                        "Tap camera icon to change photo",

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================================================
              // FIELDS
              // =========================================================

              _profileField(
                "Company Name/Name",
                _nameController,
                Icons.store,
              ),

              _profileField(
                "Short Bio/Tagline",
                _bioController,
                Icons.info_outline,
                maxLines: 3,
              ),

              _profileField(
                "Contact Number",
                _phoneController,
                Icons.phone,
                keyboard:
                TextInputType.phone,
              ),

              _profileField(
                "Business Email",
                _emailController,
                Icons.email,
                keyboard:
                TextInputType.emailAddress,
              ),

              _profileField(
                "Default Delivery Address",
                _addressController,
                Icons.location_on,
                maxLines: 3,
              ),

              _profileField(
                "Landmark",
                _landmarkController,
                Icons.place,
              ),

              _profileField(
                "Pincode",
                _pincodeController,
                Icons.pin_drop,
                keyboard: TextInputType.number,
              ),

              const SizedBox(height: 40),

              // =========================================================
              // SAVE BUTTON
              // =========================================================

              if (_isEditing)

                SizedBox(

                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                    _isLoading
                        ? null
                        : _saveProfile,

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(
                        0xFFFF6A00,
                      ),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),

                    child:

                    _isLoading

                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )

                        : const Text(

                      "UPDATE PROFILE",

                      style: TextStyle(

                        color: Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton.icon(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xFF0A2540),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  onPressed: () async {

                    final profileReady =
                    await ProfileGuard
                        .checkProfileCompletion(
                      context,
                    );

                    if (!profileReady) {
                      return;
                    }

                    if (!context.mounted) return;

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const PartnerApplicationPage(),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.handshake,
                    color: Colors.white,
                  ),

                  label: const Text(

                    "Join iServe-U Partner Network",


                    style: TextStyle(

                      color: Colors.white,

                      fontWeight:
                      FontWeight.bold,
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


  // =========================================================
  // FIELD WIDGET
  // =========================================================

  Widget _profileField(

      String label,

      TextEditingController controller,

      IconData icon, {

        int maxLines = 1,

        TextInputType keyboard =
            TextInputType.text,
      }) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextFormField(

        controller: controller,

        enabled: _isEditing,

        maxLines: maxLines,

        keyboardType: keyboard,

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Icon(
            icon,
            color: Colors.blueGrey,
          ),

          filled: true,

          fillColor:

          _isEditing
              ? Colors.white
              : Colors.transparent,

          border: OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),
    );
  }
}