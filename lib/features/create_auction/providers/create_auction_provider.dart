import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/routers/router_constant.dart';
import '../../../cores/utils/navigation_service.dart';
import '../../auction_stage/views/auction_stage_view.dart';
import '../model/create_auction_request_model.dart';

final createAuctionProvider = NotifierProvider.autoDispose<
    CreateAuctionNotifier, CreateAuctionNotifierData>(
  CreateAuctionNotifier.new,
);

class CreateAuctionNotifier extends Notifier<CreateAuctionNotifierData> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController startingBidController = TextEditingController();
  final TextEditingController auctionTitleController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  CreateAuctionNotifierData build() {
    ref.onDispose(() {
      itemNameController.dispose();
      startingBidController.dispose();
      auctionTitleController.dispose();
      usernameController.dispose();
    });

    return CreateAuctionNotifierData(
      request: CreateAuctionRequestModel(),
      createState: PageState.initial,
    );
  }

  /// common update request
  void updateData(CreateAuctionRequestModel value) {
    state = state.copyWith(request: value);
  }

  /// Pick photo from gallery or camera
  Future<void> pickPhoto({bool fromCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 70,
      );

      if (image != null) {
        state = state.copyWith(
          request: state.request.copyWith(photoPath: image.path),
          createState: PageState.initial,
        );
        debugPrint('Photo selected: ${image.path}');
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
      state = state.copyWith(createState: PageState.error);
    }
  }

  /// Show photo source selection
  Future<void> showPhotoSourceSelection(BuildContext context) async =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF182234),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickPhoto(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickPhoto(fromCamera: false);
                },
              ),
            ],
          ),
        ),
      );

  /// Validate all fields and go live
  Future<void> goLiveAndStartAuction() async {
    // Clear previous error state
    state = state.copyWith(
      createState: PageState.initial,
      errorMessage: null,
    );

    // Validate all mandatory fields
    if (!state.request.isValid) {
      String errorMessage = 'Please fill in all required fields:';
      final errors = <String>[];

      if (state.request.photoError != null) {
        errors.add(state.request.photoError!);
      }
      if (state.request.itemNameError != null) {
        errors.add(state.request.itemNameError!);
      }
      if (state.request.startingBidError != null) {
        errors.add(state.request.startingBidError!);
      }
      if (state.request.usernameError != null) {
        errors.add(state.request.usernameError!);
      }
      if (errors.isNotEmpty) {
        errorMessage = errors.first;
      }

      debugPrint('Validation failed: $errorMessage');
      state = state.copyWith(
        createState: PageState.error,
        errorMessage: errorMessage,
      );
      return;
    }

    // Start loading
    state = state.copyWith(createState: PageState.loading);

    await Future.delayed(const Duration(milliseconds: 700));

    final uid = Random().nextInt(1 << 31);
    debugPrint('Generated random UID: $uid');
    final roomId = Random().nextInt(1 << 31).toString();

    final uploadUrl = await _uploadItemImage(state.request.photoPath, roomId);

    if (uploadUrl == null) {
      const errorMessage = 'Unable to upload item photo, please try again.';
      debugPrint('Photo upload failed for room $roomId');
      state = state.copyWith(
        createState: PageState.error,
        errorMessage: errorMessage,
      );
      return;
    }

    state = state.copyWith(
      createState: PageState.success,
      request: state.request.copyWith(photoUrl: uploadUrl),
    );

    final data = AuctionStageViewData(
      roomId: roomId,
      uid: uid,
      username: state.request.username ?? '',
      isHost: true,
      startingBid: state.request.startingBid,
      itemName: state.request.itemName,
      hostId: uid,
      auctionImageUrl: uploadUrl,
    );

    NavigationService.pushNamed(Routes.auctionStage, args: data);
  }

  Future<String?> _uploadItemImage(String? sourcePath, String roomId) async {
    if (sourcePath == null || sourcePath.isEmpty) {
      return null;
    }

    try {
      final compressedFile = await _compressImage(sourcePath);
      if (compressedFile == null) {
        return null;
      }

      final storagePath = 'auction_items/$roomId/${path.basename(compressedFile.path)}';
      final reference = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = reference.putFile(File(compressedFile.path));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('Firebase storage upload error: ${e.code} ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error uploading image: $e');
    }
    return null;
  }

  Future<XFile?> _compressImage(String sourcePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final baseName = path.basenameWithoutExtension(sourcePath);
      final extension = path.extension(sourcePath).isNotEmpty
          ? path.extension(sourcePath)
          : '.jpg';

      for (var quality = 85; quality >= 30; quality -= 10) {
        final targetPath = path.join(
          tempDir.path,
          '$baseName-$quality-${DateTime.now().millisecondsSinceEpoch}$extension',
        );
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          targetPath,
          minWidth: 720,
          minHeight: 720,
          quality: quality,
          keepExif: false,
        );

        if (compressedFile == null) {
          continue;
        }

        if ((await compressedFile.length()) <= 200 * 1024 || quality <= 30) {
          return compressedFile;
        }
      }
    } catch (e) {
      debugPrint('Image compression failed: $e');
    }
    return null;
  }

  /// Update entire request
  void updateRequest(CreateAuctionRequestModel value) {
    state = state.copyWith(request: value);
  }
}

class CreateAuctionNotifierData {
  CreateAuctionRequestModel request;
  PageState createState;
  String? errorMessage;

  CreateAuctionNotifierData({
    required this.request,
    required this.createState,
    this.errorMessage,
  });

  CreateAuctionNotifierData copyWith({
    CreateAuctionRequestModel? request,
    PageState? createState,
    String? errorMessage,
  }) =>
      CreateAuctionNotifierData(
        request: request ?? this.request,
        createState: createState ?? this.createState,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
