import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  CreateAuctionNotifierData build() {
    ref.onDispose(() {
      itemNameController.dispose();
      startingBidController.dispose();
      auctionTitleController.dispose();
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
        imageQuality: 85,
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
  Future<void> showPhotoSourceSelection(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF182234),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
  }

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
      if (state.request.auctionTitleError != null) {
        errors.add(state.request.auctionTitleError!);
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

    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(createState: PageState.success);

    final data = AuctionStageViewData(
      roomId: 'test-room1',
      userId: 'host',
      username: 'host',
      isHost: true,
      startingBid: state.request.startingBid,
      itemName: state.request.itemName, 
      hostId: int.parse('host'.hashCode.toString().substring(0, 8)),
    );

    NavigationService.pushNamed(Routes.auctionStage, args: data);
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
