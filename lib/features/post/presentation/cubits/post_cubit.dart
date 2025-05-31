import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/Storage/domain/storage_repo.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';
import 'package:social_media_app/features/post/domain/repos/post_repo.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_state.dart';

import '../../domain/entities/post.dart';

class PostCubit extends Cubit<PostState>{
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.storageRepo , required this.postRepo}) : super(PostsInitial());

  //create a post
  Future<void> createPost(Post post , {String? imagePath} ) async{
    String? imageUrl ;

    try{
      print("🔄 PostCubit: Starting createPost...");

      //handle image upload for mobile platforms (using file path)
      if(imagePath != null){
        print("📸 PostCubit: Uploading image from path: $imagePath");
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
        print("✅ PostCubit: Image uploaded successfully: $imageUrl");
      }

      //give image url to post
      final newPost = post.copyWith(imageUrl: imageUrl);
      print("📝 PostCubit: Creating post with data: ${newPost.toString()}");

      //create post in the backend - ADD AWAIT HERE!
      await postRepo.createPost(newPost);  // ⚠️ MISSING AWAIT!
      print("✅ PostCubit: Post created successfully in backend");

      //refetch all posts
      print("🔄 PostCubit: Refetching all posts after creation...");
      await fetchAllPosts();  // Add await for consistency

    }
    catch(e, stackTrace){
      print("💥 PostCubit: Error in createPost: $e");
      print("Stack trace: $stackTrace");
      emit(PostsError('Failed to create post: $e'));
    }
  }

  Future<void> fetchAllPosts() async{
    try{
      print("🔄 PostCubit: Starting fetchAllPosts...");
      emit(PostsLoading());

      final posts = await postRepo.fetchAllPosts();

      print("📊 PostCubit: Repository returned ${posts?.length ?? 'null'} posts");

      if (posts == null) {
        print("❌ PostCubit: Posts is null from repository!");
        emit(PostsError("No data received from repository"));
        return;
      }

      if (posts.isEmpty) {
        print("⚠️ PostCubit: Posts list is empty");
        print("🔍 Possible reasons:");
        print("   1. No posts exist in database");
        print("   2. Database query is incorrect");
        print("   3. Posts exist but not being retrieved properly");
        print("   4. Wrong collection/table name");
        print("   5. Authentication/permission issues");
      } else {
        print("✅ PostCubit: Found ${posts.length} posts:");
        for (int i = 0; i < posts.length && i < 3; i++) {  // Log first 3 posts
          print("   Post $i: ID=${posts[i].id}, ImageURL=${posts[i].imageUrl}");
        }
      }

      emit(PostsLoaded(posts));

    }
    catch(e, stackTrace){
      print("💥 PostCubit: Error in fetchAllPosts: $e");
      print("Stack trace: $stackTrace");
      emit(PostsError("Failed to load posts: $e"));
    }
  }

  //delete a post
  Future<void> deletePost(String postId) async{
    try{
      print("🔄 PostCubit: Starting deletePost for ID: $postId");

      await postRepo.deletePost(postId);
      print("✅ PostCubit: Post deleted successfully");

      // Refetch posts after deletion
      print("🔄 PostCubit: Refetching posts after deletion...");
      await fetchAllPosts();

    }
    catch(e, stackTrace){
      print("💥 PostCubit: Error in deletePost: $e");
      print("Stack trace: $stackTrace");
      emit(PostsError("Failed to delete post: $e"));
    }
  }


  Future<void> toggleLikePost(String postId, String userId) async{
    try{
      await postRepo.toggleLikePost(postId, userId);
    }
    catch(e){
      emit(PostsError("Unable to like $e"));
    }

  }

  //add a comment
  Future<void> addComment(String postId , Comment comment) async{
    try{
      await postRepo.addComment(postId, comment);
      fetchAllPosts();
    }
    catch(e){
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  //delete a comment
  Future<void> deleteComment(String postId, String commentId) async{
    try{
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPosts();
    }
    catch(e){
      emit(PostsError("Failed to delete comment: $e"));
    }
  }


}