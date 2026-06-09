import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantProfilePage extends StatefulWidget {
  const RestaurantProfilePage({super.key});

  @override
  State<RestaurantProfilePage> createState() =>
      _RestaurantProfilePageState();
}

class _RestaurantProfilePageState
    extends State<RestaurantProfilePage> {

  final _formKey = GlobalKey<FormState>();

  final restaurantNameController =
  TextEditingController();

  final gstController =
  TextEditingController();

  final fssaiController =
  TextEditingController();

  final openingController =
  TextEditingController();

  final closingController =
  TextEditingController();

  final minimumOrderController =
  TextEditingController();

  final deliveryRadiusController =
  TextEditingController();

  final logoController =
  TextEditingController();

  final bannerController =
  TextEditingController();

  bool active = true;

  bool loading = true;

  String ownerName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();

    if (data == null) return;

    ownerName =
        data['name'] ?? '';

    email =
        data['email'] ?? '';

    restaurantNameController.text =
        data['restaurantName'] ?? '';

    gstController.text =
        data['gstNumber'] ?? '';

    fssaiController.text =
        data['fssaiNumber'] ?? '';

    openingController.text =
        data['openingTime'] ?? '';

    closingController.text =
        data['closingTime'] ?? '';

    minimumOrderController.text =
        data['minimumOrderAmount'] ?? '';

    deliveryRadiusController.text =
        data['deliveryRadius'] ?? '';

    logoController.text =
        data['logoUrl'] ?? '';

    bannerController.text =
        data['bannerUrl'] ?? '';

    active =
        data['active'] ?? true;

    setState(() {
      loading = false;
    });
  }

  Future<void> _saveProfile() async {

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({

      'restaurantName': restaurantNameController.text.trim(),

      'gstNumber': gstController.text.trim(),

      'fssaiNumber': fssaiController.text.trim(),

      'openingTime': openingController.text.trim(),

      'closingTime': closingController.text.trim(),

      'minimumOrderAmount': minimumOrderController.text.trim(),

      'deliveryRadius': deliveryRadiusController.text.trim(),

      'logoUrl': logoController.text.trim(),

      'bannerUrl': bannerController.text.trim(),

      'active': active,
    });
    final menuItems =
    await FirebaseFirestore.instance
        .collection('food_menu')
        .where(
      'restaurantId',
      isEqualTo: uid,
    )
        .get();

    for (final doc in menuItems.docs) {
      await doc.reference.update({
        'restaurantActive': active,
      });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content:
        Text('Profile Updated'),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 16),

      child: TextFormField(

        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          border:
          const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title:
        const Text('Restaurant Profile'),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                ownerName,
                style:
                const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              Text(email),

              const SizedBox(height: 20),

              _field(
                'Restaurant Name',
                restaurantNameController,
              ),

              _field(
                'GST Number',
                gstController,
              ),

              _field(
                'FSSAI Number',
                fssaiController,
              ),

              _field(
                'Opening Time',
                openingController,
              ),

              _field(
                'Closing Time',
                closingController,
              ),

              _field(
                'Minimum Order Amount',
                minimumOrderController,
              ),

              _field(
                'Delivery Radius',
                deliveryRadiusController,
              ),

              _field(
                'Logo URL',
                logoController,
              ),

              _field(
                'Banner URL',
                bannerController,
              ),

              SwitchListTile(

                title:
                const Text('Active'),

                value: active,

                onChanged: (value) {

                  setState(() {
                    active = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed:
                  _saveProfile,

                  child: const Text(
                    'SAVE PROFILE',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}