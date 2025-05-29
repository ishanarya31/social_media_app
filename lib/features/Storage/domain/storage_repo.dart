abstract class StorageRepo{
  //upload profile images on mobile platforms
  Future<String?> uploadProfileImageMobile(String path , String fileName);

  //upload post images on mobiles
  Future<String?> uploadPostImageMobile(String path, String fileName);
}