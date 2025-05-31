import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_state.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/pages/profile_page.dart';

import '../../auth/domain/entities/app_user.dart';
import '../domain/entities/post.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<StatefulWidget> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //current user
  AppUser? currentUser;

  //post user
  ProfileUser? postUser;

  //comment text controller
  final commentTextController = TextEditingController();

  //on startup
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  //Like TOGGLE
  void toggleLikePost() {
    //current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //optimistically updating ui
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); // unlike
      } else {
        widget.post.likes.add(currentUser!.uid); //like
      }
    });

    //update like
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
        error,
        ) {
      //if there's an error revert back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); //like
        } else {
          widget.post.likes.remove(currentUser!.uid); //unlike
        }
      });
    });
  }

  //open a comment box
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Comment',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: MyTextField(
          controller: commentTextController,
          hintText: "Write your comment...",
          obscureText: false,
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),

          //save button
          TextButton(
            onPressed: () {
              addComment();
              Navigator.pop(context);
            },
            child: const Text(
              "Post",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void addComment() {
    if (commentTextController.text.trim().isEmpty) return;

    //create a new Comment with CURRENT USER info (not post user)
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid, // Fixed: Use current user's ID
      userName: currentUser!.name, // Fixed: Use current user's name
      postId: widget.post.id,
      text: commentTextController.text.trim(),
      timeStamp: DateTime.now(),
    );

    //add comment using cubit
    postCubit.addComment(widget.post.id, newComment);

    //clear the text field
    commentTextController.clear();
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //delete dialog box
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void showCommentOptions(Comment comment){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Comment',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              context.read<PostCubit>().deleteComment(comment.postId, comment.id);
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }



  // Helper method to build comment tile
  Widget _buildCommentTile(Comment comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: Text(
                  comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(comment.timeStamp),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                comment.text,
                style: const TextStyle(fontSize: 14, height: 1.3),
              ),

              const Spacer(),

              if(comment.userId == currentUser?.uid || isOwnPost)
                GestureDetector(
                  onTap:() { showCommentOptions(comment);},
                  child: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary,),
                )
            ],
          ),

        ],
      ),
    );
  }

  // Helper method to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if postUser is not loaded yet
    if (postUser == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 1,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and options
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.post.userId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (postUser!.profileImageUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(postUser!.profileImageUrl)
                        : null,
                    child: (postUser!.profileImageUrl.isEmpty)
                        ? Text(
                      widget.post.userName.isNotEmpty ? widget.post.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Username and handle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${widget.post.userName}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Options menu for own posts
                  if (isOwnPost)
                    IconButton(
                      onPressed: showOptions,
                      icon: const Icon(Icons.more_vert),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Post text content (if exists)
          if (widget.post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.post.text,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),

          if (widget.post.text.isNotEmpty) const SizedBox(height: 1),

          // Post image
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: CachedNetworkImage(
                imageUrl: widget.post.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),


          // Action buttons (like, comment, share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Like button
                IconButton(
                  onPressed: toggleLikePost,
                  icon: Icon(
                    widget.post.likes.contains(currentUser!.uid)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.likes.contains(currentUser!.uid)
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 40),
                  ),
                ),
                Text(
                  widget.post.likes.length.toString(),
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),

                const SizedBox(width: 16),

                // Comment button
                IconButton(
                  onPressed: openNewCommentBox,
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: Colors.grey[600],
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 40),
                  ),
                ),
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),

                const SizedBox(width: 16),

                // Share button
                IconButton(
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                  icon: const Icon(Icons.share_outlined),
                  color: Colors.grey[600],
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 40),
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                // Find the current post
                final currentPost = state.posts.firstWhere(
                      (post) => post.id == widget.post.id,
                  orElse: () => widget.post,
                );

                if (currentPost.comments.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 1),
                      // Comments header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '${currentPost.comments.length} ${currentPost.comments.length == 1 ? 'comment' : 'comments'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      // Scrollable Comments list
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 100, // Maximum height for comment section
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: currentPost.comments.length,
                          itemBuilder: (context, index) {
                            final comment = currentPost.comments[index];
                            return _buildCommentTile(comment);
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );
                }
              } else if (state is PostsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is PostsError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Error loading comments: ${state.message}',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}