import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> base64ToFile(String base64String, String fileName) async {
  try {
    // Decode the base64 string into bytes
    final directory = await getApplicationDocumentsDirectory();

    // Convert base64 string to bytes
    final bytes = base64Decode(
      base64String.contains(',') ? base64String.split(',')[1] : base64String,
    );

    // Create a file path
    final filePath = '${directory.path}/$fileName';

    // Write the bytes to the file
    File file = File(filePath)..writeAsBytesSync(bytes);

    // Return the File object
    return file;
  } catch (e) {
    debugPrint('error convert base64 to File: $e');
    return null;
  }
}

Future<String> fileToBase64(String filePath) async {
  try {
    // Get the file extension to determine MIME type
    File file = File(filePath);
    String extension = file.uri.pathSegments.last.split('.').last;

    // Read the file as bytes
    List<int> fileBytes = await file.readAsBytes();

    // Convert the bytes to Base64
    String base64String = base64Encode(fileBytes);

    // Determine the MIME type based on the file extension
    String mimeType = '';
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'pdf') {
      mimeType = 'application/pdf';
    } else {
      mimeType = 'application/octet-stream'; // Fallback MIME type
    }

    // Concatenate MIME type and Base64 string
    String base64WithMime = 'data:$mimeType;base64,$base64String';

    return base64WithMime;
  } catch (e) {
    debugPrint('Error: $e');
    return '';
  }
}

Uint8List dataFromBase64(String base64String) => base64Decode(base64String);
