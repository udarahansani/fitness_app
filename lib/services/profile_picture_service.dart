import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:flutter/services.dart';

class ProfilePictureService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadProfilePicture({
    required ImageSource source,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      // Check if ImagePicker is available
      final ImagePicker picker = ImagePicker();
      
      XFile? image;
      try {
        // Pick image with error handling
        image = await picker.pickImage(
          source: source,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 70,
        );
      } on PlatformException catch (e) {
        log('Platform exception in image picker: ${e.message}');
        if (e.code == 'no_available_camera') {
          throw 'No camera available on this device.';
        } else if (e.code == 'permission_denied') {
          throw 'Camera/gallery permission denied. Please enable permissions in app settings.';
        } else {
          throw 'Failed to access camera/gallery. Error: ${e.message}';
        }
      } catch (error) {
        log('General image picker error: $error');
        throw 'Failed to access camera/gallery. Please check app permissions and try again.';
      }

      if (image == null) {
        return null; // User cancelled
      }

      // Create a reference to store the image
      final String fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('profile_pictures/$fileName');

      // Upload the file
      final UploadTask uploadTask = ref.putFile(File(image.path));
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      log('Profile picture uploaded successfully: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      log('Error uploading profile picture: $e');
      throw 'Failed to upload profile picture: $e';
    }
  }

  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      log('Profile picture deleted successfully');
    } catch (e) {
      log('Error deleting profile picture: $e');
      // Don't throw error as it's not critical if old image can't be deleted
    }
  }
}