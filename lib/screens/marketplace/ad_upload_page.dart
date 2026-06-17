import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/campaign_model.dart';
import '../../core/models/media_asset_model.dart';

import '../../core/services/campaign_service.dart';
import '../../data/firebase_storage_service.dart';

class AdvertisementPage extends StatefulWidget {
  const AdvertisementPage({super.key});

  @override
  State<AdvertisementPage> createState() =>
      _AdvertisementPageState();
}

class _AdvertisementPageState
    extends State<AdvertisementPage> {

  final _formKey =
  GlobalKey<FormState>();
  late final TextEditingController
  _priceController;

  final ImagePicker picker =
  ImagePicker();

  // =========================================================
  // FORM DATA
  // =========================================================

  String title = '';
  String description = '';
  String price = '';
  String contact = '';
  String transactionId = '';

  String selectedDuration =
      '3_days';



  bool isUploading = false;

  bool isVideoPricing = false;

  double uploadProgress = 0;

  String uploadStatus =
      "Preparing Advertisement...";



  List<XFile> selectedImages = [];

  List<XFile> selectedVideos = [];

  @override
  void initState() {

    super.initState();

    _priceController =
        TextEditingController();
  }

  // =========================================================
  // PICK IMAGES
  // =========================================================

  Future<void> _pickImages() async {

    try {

      final imgs =
      await picker.pickMultiImage(
        imageQuality: 75,
      );

      if (imgs.isNotEmpty && mounted) {

        setState(() {

          if (selectedImages.length +
              imgs.length >
              10) {

            selectedImages = [
              ...selectedImages,
              ...imgs,
            ].take(10).toList();

          } else {

            selectedImages.addAll(imgs);
          }
        });

        _recalculatePrice();
      }

    } catch (e) {

      _showError(
        "Unable to select images",
      );
    }
  }

  // =========================================================
  // PICK VIDEO
  // =========================================================

  Future<void> _pickVideo() async {

    try {

      final videos =
      await picker.pickMultipleMedia();

      final onlyVideos =
      videos.where((file) {

        final name =
        file.name.toLowerCase();

        return
          name.endsWith('.mp4') ||
              name.endsWith('.mov') ||
              name.endsWith('.avi') ||
              name.endsWith('.mkv');
      }).toList();

      if (
      onlyVideos.isNotEmpty &&
          mounted
      ) {

        setState(() {

          selectedVideos.addAll(
            onlyVideos,
          );

          isVideoPricing = true;
        });

        _recalculatePrice();
      }

    } catch (e) {

      _showError(
        "Unable to select videos",
      );
    }
  }

  void _recalculatePrice() {

    int finalPrice = 99;

    switch (selectedDuration) {

      case '7_days':
        finalPrice = 199;
        break;

      case '15_days':
        finalPrice = 349;
        break;

      case '30_days':
        finalPrice = 599;
        break;

      default:
        finalPrice = 99;
    }

    if (selectedVideos.isNotEmpty) {
      finalPrice += 100;
    }

    setState(() {

      price = finalPrice.toString();

      _priceController.text = price;
    });
  }
  DateTime _calculateEndDate() {

    switch (selectedDuration) {

      case '7_days':
        return DateTime.now().add(
          const Duration(days: 7),
        );

      case '15_days':
        return DateTime.now().add(
          const Duration(days: 15),
        );

      case '30_days':
        return DateTime.now().add(
          const Duration(days: 30),
        );

      default:
        return DateTime.now().add(
          const Duration(days: 3),
        );
    }
  }

  // =========================================================
  // PUBLISH
  // =========================================================

  Future<void> _publishListing() async {

    FocusScope.of(context)
        .unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }



    if (
    selectedImages.isEmpty &&
        selectedVideos.isEmpty
    ) {

      _showError(
        "Please upload image or video",
      );

      return;
    }

    _formKey.currentState!
        .save();

    if (mounted) {

      setState(() {

        isUploading = true;

        uploadProgress = 0;

        uploadStatus =
        "Preparing Advertisement...";
      });
    }

    try {

      // =====================================================
      // USER
      // =====================================================

      final user =
          FirebaseAuth
              .instance
              .currentUser;

      if (user == null) {

        throw Exception(
          "User not logged in",
        );
      }

      // =====================================================
      // CREATE CAMPAIGN
      // =====================================================

      final storage =
      FirebaseStorageService();

      final campaign = CampaignModel(

        id: '',

        ownerId: user.uid,

        title: title.trim(),

        description: description.trim(),

        transactionId: transactionId.trim(),

        paymentStatus: 'submitted',

        contactInfo: contact.trim(),

        price: double.tryParse(price) ?? 0,

        isActive: false,

        status: 'pending',

        priority: 1,

        rotationType: 'sequential',

        siteIds: [],

        mediaUrl: '',

        mediaType: 'image',

        durationSeconds: 10,

        startDate: DateTime.now(),

        endDate: _calculateEndDate(),

        durationDays:
        selectedDuration == '3_days'
            ? 3
            : selectedDuration == '7_days'
            ? 7
            : selectedDuration == '15_days'
            ? 15
            : 30,

        durationLabel:
        selectedDuration == '3_days'
            ? '3 Days'
            : selectedDuration == '7_days'
            ? '7 Days'
            : selectedDuration == '15_days'
            ? '15 Days'
            : '30 Days',

        totalPlays: 0,

        totalImpressions: 0,

        createdAt: DateTime.now(),

        updatedAt: DateTime.now(),
      );

      final campaignId =
      await CampaignService.createCampaign(
        campaign: campaign,
      );

      if (campaignId == null) {

        throw Exception(
          "Unable to create campaign",
        );
      }

      // =====================================================
      // UPLOAD IMAGES
      // =====================================================

      for (
      int i = 0;
      i < selectedImages.length;
      i++
      ) {

        if (mounted) {

          setState(() {

            uploadStatus =
            "Uploading Image ${i + 1}/${selectedImages.length}";

            uploadProgress =
                (i /
                    selectedImages.length) *
                    0.5;
          });
        }

        final image =
        selectedImages[i];

        final url =
        await storage
            .uploadImageWithProgress(

          image,

              (p) {},
        );
        await FirebaseFirestore.instance
            .collection('campaigns')
            .doc(campaignId)
            .update({
          'mediaUrl': url,
          'mediaType': 'image',
        });

        final checkDoc =
        await FirebaseFirestore.instance
            .collection('campaigns')
            .doc(campaignId)
            .get();

        debugPrint(
          "AFTER UPDATE => "
              "${checkDoc.data()?['mediaUrl']}",
        );

        // ===============================================
        // CREATE MEDIA ASSET
        // ===============================================

        final asset =
        MediaAssetModel(

          id: '',

          campaignId:
          campaignId,

          ownerId:
          user.uid,

          mediaUrl: url,

          mediaType: 'image',

          thumbnailUrl: url,

          fileName:
          image.name,

          durationSeconds: 10,

          sortOrder: i,

          priority: 1,

          isActive: true,

          fileSizeBytes: 0,

          aspectRatio: 1,

          resolution: '',

          totalPlays: 0,

          totalImpressions: 0,

          createdAt:
          DateTime.now(),

          updatedAt:
          DateTime.now(),
        );

        await CampaignService
            .addMediaAsset(

          campaignId:
          campaignId,

          asset: asset,
        );
      }

      // =====================================================
      // VIDEO
      // =====================================================

      for (
      int i = 0;
      i < selectedVideos.length;
      i++
      ) {

        if (mounted) {

          setState(() {

            uploadStatus =
            "Uploading Video ${i + 1}/${selectedVideos.length}";

            uploadProgress =
                0.5 +
                    (
                        (i /
                            selectedVideos.length) *
                            0.5
                    );
          });
        }

        final video =
        selectedVideos[i];

        final videoUrl =
        await storage
            .uploadVideoWithProgress(

          video,

              (p) {},
        );
        if (selectedImages.isEmpty && i == 0) {
          await FirebaseFirestore.instance
              .collection('campaigns')
              .doc(campaignId)
              .update({
            'mediaUrl': videoUrl,
            'mediaType': 'video',
          });
        }

        final asset =
        MediaAssetModel(

          id: '',

          campaignId:
          campaignId,

          ownerId:
          user.uid,

          mediaUrl: videoUrl,

          mediaType: 'video',

          thumbnailUrl: '',

          fileName:
          video.name,

          durationSeconds: 15,

          sortOrder:
          selectedImages.length + i,

          priority: 1,

          isActive: true,

          fileSizeBytes: 0,

          aspectRatio: 16 / 9,

          resolution: '',

          totalPlays: 0,

          totalImpressions: 0,

          createdAt:
          DateTime.now(),

          updatedAt:
          DateTime.now(),
        );
        debugPrint(
          "UPLOAD PROJECT => "
              "${FirebaseFirestore.instance.app.options.projectId}",
        );
        await CampaignService
            .addMediaAsset(

          campaignId:
          campaignId,

          asset: asset,
        );
      }

      // =====================================================
      // COMPLETE
      // =====================================================

      if (mounted) {

        setState(() {

          uploadProgress = 1;

          uploadStatus =
          "Advertisement Submitted";
        });
      }

      await Future.delayed(
        const Duration(
          milliseconds: 800,
        ),
      );

      if (mounted) {

        Navigator.pop(context);
      }

    } catch (e) {

      debugPrint(
        "UPLOAD ERROR: $e",
      );

      if (mounted) {

        setState(() {

          isUploading = false;
        });
      }

      _showError(
        "Upload Failed: $e",
      );
    }
  }

  // =========================================================
  // ERROR
  // =========================================================

  void _showError(
      String message,
      ) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
      ),
    );
  }
  @override
  void dispose() {

    _priceController.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Stack(

      children: [

        Scaffold(

          appBar: AppBar(

            iconTheme:
            const IconThemeData(
              color: Colors.white,
            ),

            title: const Text(
              "Create Advertisement",

              style: TextStyle(
                color: Colors.white,
              ),
            ),

            flexibleSpace: Container(

              decoration:
              const BoxDecoration(

                gradient:
                LinearGradient(
                  colors: [

                    Color(
                        0xFF0A2540),

                    Color(
                        0xFFFF6A00),
                  ],
                ),
              ),
            ),
          ),

          body: SingleChildScrollView(

            padding:
            const EdgeInsets.all(
              20,
            ),

            child: Form(

              key: _formKey,

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Row(

                    children: [

                      Expanded(

                        child: ElevatedButton.icon(

                          onPressed: _pickImages,

                          icon: const Icon(
                            Icons.image,
                          ),

                          label: const Text(
                            "Add Images",
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(

                        child: ElevatedButton.icon(

                          onPressed: _pickVideo,

                          icon: const Icon(
                            Icons.video_library,
                          ),

                          label: const Text(
                            "Add Videos",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Text(
                    "${selectedImages.length} Images • ${selectedVideos.length} Videos Selected",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(
                      height: 20),

                  DropdownButtonFormField<String>(

                    initialValue:
                    selectedDuration,

                    decoration:
                    InputDecoration(

                      labelText:
                      "Advertisement Duration",

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(

                        value: '3_days',

                        child: Text("3 Days"),
                      ),

                      DropdownMenuItem(

                        value: '7_days',

                        child: Text("7 Days"),
                      ),

                      DropdownMenuItem(

                        value: '15_days',

                        child: Text("15 Days"),
                      ),

                      DropdownMenuItem(

                        value: '30_days',

                        child: Text("30 Days"),
                      ),
                    ],

                    onChanged: (value) {

                      if (value == null) {
                        return;
                      }

                      setState(() {

                        selectedDuration =
                            value;
                      });

                      _recalculatePrice();
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  _field(
                    "Advertisement Title",
                        (v) =>
                    title = v!,
                  ),

                  TextFormField(

                    controller:
                    _priceController,

                    readOnly: true,

                    decoration:
                    InputDecoration(

                      labelText:
                      "Price (₹)",

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),

                      filled: true,

                      fillColor:
                      Colors.grey
                          .shade100,
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  _field(
                    "Contact Info",
                        (v) =>
                    contact = v!,
                    keyboard:
                    TextInputType
                        .phone,
                  ),

                  _field(
                    "Description",
                        (v) =>
                    description =
                    v!,
                    maxLines: 4,
                  ),

                  const SizedBox(
                      height: 20),

                  // =====================================================
                  // PAYMENT
                  // =====================================================

                  StreamBuilder<
                      DocumentSnapshot>(

                    stream:
                    FirebaseFirestore
                        .instance
                        .collection(
                        'app_settings')
                        .doc(
                        'payment')
                        .snapshots(),

                    builder:
                        (context,
                        snapshot) {

                      final data =
                      snapshot
                          .data
                          ?.data()
                      as Map<
                          String,
                          dynamic>?;

                      final upiId =
                          data?['upiId'] ??
                              'Not Configured';

                      final merchant =
                          data?[
                          'merchantName'] ??
                              'iServeU';

                      final bank =
                          data?[
                          'bankName'] ??
                              '';

                      final account =
                          data?[
                          'accountNumber'] ??
                              '';

                      final ifsc =
                          data?['ifsc'] ??
                              '';

                      final qrUrl =
                          data?[
                          'qrImage'] ??
                              '';

                      return Container(

                        margin: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(

                          color: Colors.orange.shade50,

                          borderRadius:
                          BorderRadius.circular(18),

                          boxShadow: [

                            BoxShadow(

                              color:
                              Colors.black.withValues(
                                alpha: 0.05,
                              ),

                              blurRadius: 10,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: LayoutBuilder(

                          builder: (context, constraints) {

                            final mobile =
                                constraints.maxWidth < 700;

                            Widget paymentInfo() {

                              return Column(

                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  const Text(

                                    "Payment Verification",

                                    style: TextStyle(

                                      fontWeight:
                                      FontWeight.bold,

                                      fontSize: 20,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Text(
                                    "Merchant: $merchant",
                                  ),

                                  const SizedBox(height: 10),

                                  SelectableText(

                                    "UPI ID: $upiId",

                                    style: TextStyle(

                                      color:
                                      Colors.blue.shade900,

                                      fontWeight:
                                      FontWeight.bold,

                                      fontSize: 16,
                                    ),
                                  ),

                                  if (bank.isNotEmpty)

                                    Padding(

                                      padding:
                                      const EdgeInsets.only(
                                        top: 16,
                                      ),

                                      child: Column(

                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Text(
                                            "Bank: $bank",
                                          ),

                                          Text(
                                            "A/C: $account",
                                          ),

                                          Text(
                                            "IFSC: $ifsc",
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            }

                            Widget qrWidget() {

                              if (qrUrl
                                  .toString()
                                  .isEmpty) {

                                return const SizedBox();
                              }

                              return Column(

                                children: [

                                  const Text(

                                    "Scan & Pay",

                                    style: TextStyle(

                                      fontWeight:
                                      FontWeight.bold,

                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  ClipRRect(

                                    borderRadius:
                                    BorderRadius.circular(
                                      16,
                                    ),

                                    child: Image.network(

                                      qrUrl,

                                      width: 180,

                                      height: 180,

                                      fit: BoxFit.contain,

                                      errorBuilder:
                                          (
                                          c,
                                          e,
                                          s,
                                          ) {

                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }

                            return mobile

                                ? Column(

                              children: [

                                paymentInfo(),

                                const SizedBox(height: 24),

                                qrWidget(),
                              ],
                            )

                                : Row(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Expanded(
                                  flex: 2,
                                  child:
                                  paymentInfo(),
                                ),

                                const SizedBox(width: 30),

                                Expanded(
                                  child:
                                  qrWidget(),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                      height: 15),

                  _field(
                    "Transaction ID (Optional)",
                        (v) =>
                    transactionId =
                    v!,
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(

                    width:
                    double.infinity,

                    height: 55,

                    child:
                    ElevatedButton(

                      style:
                      ElevatedButton
                          .styleFrom(

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

                      onPressed:
                      isUploading

                          ? null

                          : _publishListing,

                      child:
                      const Text(

                        "SUBMIT ADVERTISEMENT",

                        style:
                        TextStyle(
                          color: Colors
                              .white,

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
        ),

        // =====================================================
        // LOADER
        // =====================================================

        if (isUploading)

          Container(

            color: Colors.black54,

            child: Center(

              child: Card(

                child: Padding(

                  padding:
                  const EdgeInsets
                      .all(30),

                  child: Column(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      SizedBox(

                        width: 120,

                        child:
                        LinearProgressIndicator(
                          value:
                          uploadProgress,

                          minHeight: 8,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      Text(

                        uploadStatus,

                        textAlign:
                        TextAlign
                            .center,

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // FIELD
  // =========================================================

  Widget _field(
      String label,
      Function(String?) onSave, {

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

        decoration:
        InputDecoration(

          labelText: label,

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
        ),

        maxLines: maxLines,

        keyboardType: keyboard,

        validator: (v) {

          if (v == null ||
              v.trim().isEmpty) {

            return "Required";
          }

          return null;
        },

        onSaved: onSave,
      ),
    );
  }
}

// ===========================================================
// ACTION BUTTON
// ===========================================================

class ActionButton
    extends StatelessWidget {

  final IconData icon;

  final String label;

  final VoidCallback onTap;

  final bool active;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius:
      BorderRadius.circular(
        12,
      ),

      child: Container(

        padding:
        const EdgeInsets.all(
          15,
        ),

        decoration: BoxDecoration(

          color: active

              ? Colors.green
              .withValues(alpha:0.1)

              : Colors
              .grey.shade100,

          borderRadius:
          BorderRadius.circular(
            12,
          ),

          border: Border.all(

            color: active

                ? Colors.green

                : Colors.grey
                .shade300,
          ),
        ),

        child: Column(

          children: [

            Icon(

              icon,

              color: active

                  ? Colors.green

                  : Colors.grey,
            ),

            const SizedBox(
                height: 5),

            Text(

              label,

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}