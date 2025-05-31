import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/post/domain/repos/post_repo.dart';

import '../domain/entities/comment.dart';
import '../domain/entities/post.dart';

class FirebasePostRepo implements PostRepo{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  //store posts in a collection called 'posts'
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  @override
  Future<List<Post>> fetchAllPosts() async {
    try{
      print("🗂️ FirebasePostRepo: Fetching from collection: 'posts'");
      print("🔍 FirebasePostRepo: Querying posts.orderBy('timestamp', descending: true)");

      //get all posts with most recent one on top
      final postsSnapshot = await postsCollection.orderBy('timeStamp' , descending: true).get();

      print("📊 FirebasePostRepo: Query returned ${postsSnapshot.docs.length} documents");

      if (postsSnapshot.docs.isEmpty) {
        print("⚠️ FirebasePostRepo: No documents found in 'posts' collection");
        print("🔍 Troubleshooting steps:");
        print("   1. Check Firebase Console: https://console.firebase.google.com/");
        print("   2. Navigate to: Firestore Database > Data > 'posts' collection");
        print("   3. Verify documents exist and have 'timestamp' field");
        print("   4. Check Firestore security rules");
        return [];
      }

      print("📄 FirebasePostRepo: Processing documents...");

      //convert each firestore doc from json to list of posts
      final List<Post> allPosts = [];

      for (int i = 0; i < postsSnapshot.docs.length; i++) {
        final doc = postsSnapshot.docs[i];
        try {
          print("📄 Processing doc ${i + 1}/${postsSnapshot.docs.length}: ID = ${doc.id}");
          final data = doc.data() as Map<String, dynamic>;
          print("📄 Document data: $data");

          final post = Post.fromJson(data);
          allPosts.add(post);
          print("✅ Successfully parsed post: ${post.id}");

        } catch (e) {
          print("❌ Error parsing document ${doc.id}: $e");
          print("📄 Document data was: ${doc.data()}");
          // Continue with other documents
        }
      }

      print("✅ FirebasePostRepo: Successfully parsed ${allPosts.length}/${postsSnapshot.docs.length} posts");
      return allPosts;

    }
    catch(e, stackTrace){
      print("💥 FirebasePostRepo: Error in fetchAllPosts: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Error fetch posts: $e");
    }
  }

  @override
  Future<void> createPost(Post post) async {
    try{
      print("📝 FirebasePostRepo: Creating post with ID: ${post.id}");
      print("📝 Post data: ${post.toJson()}");

      await postsCollection.doc(post.id).set(post.toJson());

      print("✅ FirebasePostRepo: Post created successfully in 'posts' collection");

    }
    catch(e, stackTrace){
      print("💥 FirebasePostRepo: Error creating post: $e");
      print("Stack trace: $stackTrace");
    }
  }

  @override
  Future<void> deletePost(String postId) async{
    try{
      print("🗑️ FirebasePostRepo: Deleting post: $postId");

      await postsCollection.doc(postId).delete();

      print("✅ FirebasePostRepo: Post deleted successfully");

    }
    catch(e, stackTrace){
      print("💥 FirebasePostRepo: Error deleting post: $e");
      print("Stack trace: $stackTrace");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      print("👤 FirebasePostRepo: Fetching posts for userId: $userId");

      //fetch posts snapshot with this uid
      final postSnapshot = await postsCollection.where('userId', isEqualTo: userId).get();

      print("📊 FirebasePostRepo: User query returned ${postSnapshot.docs.length} documents");

      //convert firestore docs from json to list of posts
      final List<Post> userPosts = postSnapshot.docs.map((doc)=> Post.fromJson(doc.data() as Map<String , dynamic>)).toList();

      print("✅ FirebasePostRepo: Successfully fetched ${userPosts.length} posts for user");

      return userPosts;
    }
    catch (e, stackTrace) {
      print("💥 FirebasePostRepo: Error fetching user posts: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Error fetching your posts: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    // TODO: implement toggleLikePost
    try{
      final postDoc = await postsCollection.doc(postId).get();

      if(!postDoc.exists) return;

      final post = Post.fromJson(postDoc.data() as Map<String , dynamic>);

      //check if user has already liked this post
      final hasLiked = post.likes.contains(userId);

      //update the liked posts
      if(hasLiked){
        post.likes.remove(userId);
      }
      else{
        post.likes.add(userId);
      }

      //update the new document with new liked list
      await postsCollection.doc(postId).update({
        'likes': post.likes,
      });
    }
    catch(e){
      throw Exception("Error toggling like $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    // TODO: implement addComment
    try{
      //get post document
      final postDoc = await postsCollection.doc(postId).get();

      if(postDoc.exists){
        //convert json -> post
        final post = Post.fromJson(postDoc.data() as Map<String , dynamic>);

        //add comment in the comments list of post
        post.comments.add(comment);

        //update firestore
        await postsCollection.doc(postId).update({
          'comments' : post.comments.map((comment) => comment.toJson()).toList(),
        });
      }

      else{
        throw Exception("Post not found!");
      }

    }
    catch(e){
      throw Exception("Error adding your comment $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    // TODO: implement deleteComment
    //get post document

    try{
      final postDoc = await postsCollection.doc(postId).get();

      if(postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.removeWhere((comment) => comment.id == commentId);

        //update firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      }

      else{
        throw Exception("Post not found!");
      }
    }

    catch(e){
      throw Exception("Error deleting post: $e");
    }

  }
}