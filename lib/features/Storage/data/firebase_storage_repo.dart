import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/features/Storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo{

  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    // TODO: implement uploadProfileImageMobile
    return _uploadFile(path, fileName, "profile_images");
  }


  /*

  Helper methods - to upload files to storage

   */

    Future<String?> _uploadFile(String path , String fileName , String folder) async{
      try{
        //get file
        final file = File(path);

        // find place to store
        final storageRef = storage.ref().child('$folder/$fileName');

        //upload
        final uploadTask = await storageRef.putFile(file);

        //get image download url
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        return downloadUrl;
      }
      catch(e){
        return null;
      }
    }
}